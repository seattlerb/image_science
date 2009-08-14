#!/usr/local/bin/ruby -w

require 'rubygems'
require 'inline'

##
# Provides a clean and simple API to generate thumbnails using
# FreeImage as the underlying mechanism.
#
# For more information or if you have build issues with FreeImage, see
# http://seattlerb.rubyforge.org/ImageScience.html

class ImageScience
  VERSION = '1.2.1'

  ##
  # The top-level image loader opens +path+ and then yields the image.

  def self.with_image(path) # :yields: image
  end

  ##
  # The top-level image loader, opens an image from the string +data+ and then yields the image.

  def self.with_image_from_memory(data) # :yields: image
  end

  ##
  # Crops an image to +left+, +top+, +right+, and +bottom+ and then
  # yields the new image.

  def with_crop(left, top, right, bottom) # :yields: image
  end

  ##
  # Returns the width of the image, in pixels.

  def width; end

  ##
  # Returns the height of the image, in pixels.

  def height; end

  ##
  # Saves the image out to +path+. Changing the file extension will
  # convert the file type to the appropriate format.

  def save(path); end

  ##
  # Resizes the image to +width+ and +height+ using a cubic-bspline
  # filter and yields the new image.

  def resize(width, height) # :yields: image
  end

  ##
  # Creates a proportional thumbnail of the image scaled so its longest
  # edge is resized to +size+ and yields the new image.

  def thumbnail(size) # :yields: image
    w, h = width, height
    scale = size.to_f / (w > h ? w : h)

    self.resize((w * scale).to_i, (h * scale).to_i) do |image|
      yield image
    end
  end

  ##
  # Creates a square thumbnail of the image cropping the longest edge
  # to match the shortest edge, resizes to +size+, and yields the new
  # image.

  def cropped_thumbnail(size) # :yields: image
    w, h = width, height
    l, t, r, b, half = 0, 0, w, h, (w - h).abs / 2

    l, r = half, half + h if w > h
    t, b = half, half + w if h > w

    with_crop(l, t, r, b) do |img|
      img.thumbnail(size) do |thumb|
        yield thumb
      end
    end
  end

  inline do |builder|
    if test ?d, "/opt/local" then
      builder.add_compile_flags "-I/opt/local/include"
      builder.add_link_flags "-L/opt/local/lib"
    end

    builder.add_link_flags "-lfreeimage"
    unless RUBY_PLATFORM =~ /mswin/
      builder.add_link_flags "-lfreeimage"
      # TODO: detect PPC
      builder.add_link_flags "-lstdc++" # only needed on PPC for some reason
    else
      builder.add_link_flags "freeimage.lib"
    end
    builder.include '"FreeImage.h"'

    builder.prefix <<-"END"
      #define GET_BITMAP(name) Data_Get_Struct(self, FIBITMAP, (name)); if (!(name)) rb_raise(rb_eTypeError, "Bitmap has already been freed");
    END

    builder.prefix <<-"END"
      VALUE unload(VALUE self) {
        FIBITMAP *bitmap;
        GET_BITMAP(bitmap);

        FreeImage_Unload(bitmap);
        DATA_PTR(self) = NULL;
        return Qnil;
      }
    END

    builder.prefix <<-"END"
      VALUE wrap_and_yield(FIBITMAP *image, VALUE self, FREE_IMAGE_FORMAT fif) {
        unsigned int self_is_class = rb_type(self) == T_CLASS;
        VALUE klass = self_is_class ? self         : CLASS_OF(self);
        VALUE type  = self_is_class ? INT2FIX(fif) : rb_iv_get(self, "@file_type");
        VALUE obj = Data_Wrap_Struct(klass, NULL, NULL, image);
        rb_iv_set(obj, "@file_type", type);
        return rb_ensure(rb_yield, obj, unload, obj);
      }
    END

    builder.prefix <<-"END"
      void copy_icc_profile(VALUE self, FIBITMAP *from, FIBITMAP *to) {
        FREE_IMAGE_FORMAT fif = FIX2INT(rb_iv_get(self, "@file_type"));
        if (fif != FIF_PNG && FreeImage_FIFSupportsICCProfiles(fif)) {
          FIICCPROFILE *profile = FreeImage_GetICCProfile(from);
          if (profile && profile->data) {
            FreeImage_CreateICCProfile(to, profile->data, profile->size);
          }
        }
      }
    END

    builder.prefix <<-"END"
      void FreeImageErrorHandler(FREE_IMAGE_FORMAT fif, const char *message) {
        rb_raise(rb_eRuntimeError,
                 "FreeImage exception for type %s: %s",
                  (fif == FIF_UNKNOWN) ? "???" : FreeImage_GetFormatFromFIF(fif),
                  message);
      }
    END

    builder.add_to_init "FreeImage_SetOutputMessage(FreeImageErrorHandler);"

    builder.c_singleton <<-"END"
      VALUE with_image(char * input) {
        FREE_IMAGE_FORMAT fif = FIF_UNKNOWN;
        int flags;

        fif = FreeImage_GetFileType(input, 0);
        if (fif == FIF_UNKNOWN) fif = FreeImage_GetFIFFromFilename(input);
        if ((fif != FIF_UNKNOWN) && FreeImage_FIFSupportsReading(fif)) {
          FIBITMAP *bitmap;
          VALUE result = Qnil;
          flags = fif == FIF_JPEG ? JPEG_ACCURATE : 0;
          if (bitmap = FreeImage_Load(fif, input, flags)) {
            FITAG *tagValue = NULL;
            FreeImage_GetMetadata(FIMD_EXIF_MAIN, bitmap, "Orientation", &tagValue); 
            switch (tagValue == NULL ? 0 : *((short *) FreeImage_GetTagValue(tagValue))) {
              case 6:
                bitmap = FreeImage_RotateClassic(bitmap, 270);
                break;
              case 3:
                bitmap = FreeImage_RotateClassic(bitmap, 180);
                break;
              case 8:
                bitmap = FreeImage_RotateClassic(bitmap, 90);
                break;
              default:
               break;
            }

            result = wrap_and_yield(bitmap, self, fif);
          }
          return result;
        }
        rb_raise(rb_eTypeError, "Unknown file format");
      }
    END

    builder.c_singleton <<-"END"
      VALUE with_image_from_memory(VALUE image_data) {
        FREE_IMAGE_FORMAT fif = FIF_UNKNOWN;

        Check_Type(image_data, T_STRING);
        BYTE *image_data_ptr    = (BYTE*)RSTRING_PTR(image_data);
        DWORD image_data_length = RSTRING_LEN(image_data);
        FIMEMORY *stream = FreeImage_OpenMemory(image_data_ptr, image_data_length);

        if (NULL == stream) {
          rb_raise(rb_eTypeError, "Unable to open image_data");
        }

        fif = FreeImage_GetFileTypeFromMemory(stream, 0);
        if ((fif == FIF_UNKNOWN) || !FreeImage_FIFSupportsReading(fif)) {
          rb_raise(rb_eTypeError, "Unknown file format");
        }

        FIBITMAP *bitmap = NULL;
        VALUE result = Qnil;
        int flags = fif == FIF_JPEG ? JPEG_ACCURATE : 0;
        bitmap = FreeImage_LoadFromMemory(fif, stream, flags);
        FreeImage_CloseMemory(stream);
        if (bitmap) {
          result = wrap_and_yield(bitmap, self, fif);
        }
        return result;
      }
    END

    builder.c <<-"END"
      VALUE with_crop(int l, int t, int r, int b) {
        FIBITMAP *copy, *bitmap;
        VALUE result = Qnil;
        GET_BITMAP(bitmap);

        if (copy = FreeImage_Copy(bitmap, l, t, r, b)) {
          copy_icc_profile(self, bitmap, copy);
          result = wrap_and_yield(copy, self, 0);
        }
        return result;
      }
    END

    builder.c <<-"END"
      int height() {
        FIBITMAP *bitmap;
        GET_BITMAP(bitmap);

        return FreeImage_GetHeight(bitmap);
      }
    END

    builder.c <<-"END"
      int width() {
        FIBITMAP *bitmap;
        GET_BITMAP(bitmap);

        return FreeImage_GetWidth(bitmap);
      }
    END

    builder.c <<-"END"
      VALUE resize(long w, long h) {
        FIBITMAP *bitmap, *image;
        if (w <= 0) rb_raise(rb_eArgError, "Width <= 0");
        if (h <= 0) rb_raise(rb_eArgError, "Height <= 0");
        GET_BITMAP(bitmap);
        image = FreeImage_Rescale(bitmap, w, h, FILTER_CATMULLROM);
        if (image) {
          copy_icc_profile(self, bitmap, image);
          return wrap_and_yield(image, self, 0);
        }
        return Qnil;
      }
    END

    builder.c <<-"END"
      VALUE save(char * output) {
        int flags;
        FIBITMAP *bitmap;
        FREE_IMAGE_FORMAT fif = FreeImage_GetFIFFromFilename(output);
        if (fif == FIF_UNKNOWN) fif = FIX2INT(rb_iv_get(self, "@file_type"));
        if ((fif != FIF_UNKNOWN) && FreeImage_FIFSupportsWriting(fif)) {
          GET_BITMAP(bitmap);
          flags = fif == FIF_JPEG ? JPEG_QUALITYSUPERB : 0;
          BOOL result = 0, unload = 0;

          if (fif == FIF_PNG) FreeImage_DestroyICCProfile(bitmap);
          if (fif == FIF_JPEG && FreeImage_GetBPP(bitmap) != 24)
            bitmap = FreeImage_ConvertTo24Bits(bitmap), unload = 1; // sue me

          result = FreeImage_Save(fif, bitmap, output, flags);

          if (unload) FreeImage_Unload(bitmap);

          return result ? Qtrue : Qfalse;
        }
        rb_raise(rb_eTypeError, "Unknown file format");
      }
    END
  end
end
