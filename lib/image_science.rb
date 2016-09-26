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
  VERSION = '1.3.0'

  FREE_IMAGE_FORMAT = {
    FIF_UNKNOWN: -1,
    FIF_BMP: 0,
    FIF_ICO: 1,
    FIF_JPEG: 2,
    FIF_JNG: 3,
    FIF_KOALA: 4,
    FIF_LBM: 5,
    FIF_IFF: 5,
    FIF_MNG: 6,
    FIF_PBM: 7,
    FIF_PBMRAW: 8,
    FIF_PCD: 9,
    FIF_PCX: 10,
    FIF_PGM: 11,
    FIF_PGMRAW: 12,
    FIF_PNG: 13,
    FIF_PPM: 14,
    FIF_PPMRAW: 15,
    FIF_RAS: 16,
    FIF_TARGA: 17,
    FIF_TIFF: 18,
    FIF_WBMP: 19,
    FIF_PSD: 20,
    FIF_CUT: 21,
    FIF_XBM: 22,
    FIF_XPM: 23,
    FIF_DDS: 24,
    FIF_GIF: 25,
    FIF_HDR: 26,
    FIF_FAXG3: 27,
    FIF_SGI: 28,
    FIF_EXR: 29,
    FIF_J2K: 30,
    FIF_JP2: 31,
    FIF_PFM: 32,
    FIF_PICT: 33,
    FIF_RAW: 34,
    FIF_WEBP: 35,
    FIF_JXR: 36
  }

  CONTENT_TYPES = {
    FIF_UNKNOWN: 'image',
    FIF_BMP: 'image/bmp',
    FIF_ICO: 'image/x-icon',
    FIF_JPEG: 'image/jpeg',
    FIF_JNG: 'image',
    FIF_KOALA: 'image',
    FIF_LBM: 'image',
    FIF_IFF: 'image',
    FIF_MNG: 'image',
    FIF_PBM: 'image/x-portable-bitmap',
    FIF_PBMRAW: 'image/x-portable-bitmap',
    FIF_PCD: 'image',
    FIF_PCX: 'image/x-pcx',
    FIF_PGM: 'image/x-portable-greymap',
    FIF_PGMRAW: 'image/x-portable-greymap',
    FIF_PNG: 'image/png',
    FIF_PPM: 'image/x-portable-pixmap',
    FIF_PPMRAW: 'image/x-portable-pixmap',
    FIF_RAS: 'image/cmu-raster',
    FIF_TARGA: 'image/x-targa',
    FIF_TIFF: 'image/tiff',
    FIF_WBMP: 'image/vnd.wap.wbmp',
    FIF_PSD: 'application/octet-stream',
    FIF_CUT: 'image/x-cut',
    FIF_XBM: 'image/xbm',
    FIF_XPM: 'image/xpm',
    FIF_DDS: 'image/vnd-ms.dds',
    FIF_GIF: 'image/gif',
    FIF_HDR: 'image/vnd.radiance',
    FIF_FAXG3: 'image/fax-g3',
    FIF_SGI: 'image',
    FIF_EXR: 'image/x-exr',
    FIF_J2K: 'image/jp2',
    FIF_JP2: 'image/jp2',
    FIF_PFM: 'application/octet-stream',
    FIF_PICT: 'image/x-pict',
    FIF_RAW: 'image/raw',
    FIF_WEBP: 'image/webp',
    FIF_JXR: 'image/jxr'
  }
  ##
  # The top-level image loader opens +path+ and then yields the image.
  #
  # :singleton-method: with_image

  ##
  # The top-level image loader, opens an image from the string +data+
  # and then yields the image.
  #
  # :singleton-method: with_image_from_memory

  ##
  # Crops an image to +left+, +top+, +right+, and +bottom+ and then
  # yields the new image.
  #
  # :method: with_crop

  ##
  # Returns the width of the image, in pixels.
  #
  # :method: width

  ##
  # Returns the height of the image, in pixels.
  #
  # :method: height

  ##
  # Writes the image to memory and returns it as a binary String.
  #
  # :method: buffer

  ##
  # Resizes the image to +width+ and +height+ using a cubic-bspline
  # filter and yields the new image.
  #
  # :method: resize

  ##
  # Rotate the image to +angle+. Limited to 45 degree skewing only.
  #
  # :method: rotate

  ##
  # Gets the file type as an integer
  attr_reader :file_type

  ##
  # Returns the FreeImage file format as a symbol, e.g. :FIF_JPEG
  def file_format(type = @file_type)
    ImageScience::FREE_IMAGE_FORMAT.key(type)
  end

  ##
  # Returns an appropriate content type for the file type, e.g. 'image/jpeg'
  def content_type(type = @file_type)
    ImageScience::CONTENT_TYPES[file_format(type)]
  end

  ##
  # Returns an appropriate file extension for the file type, e.g. "jpg"
  def file_extension(type = @file_type)
    extension = file_format(type).to_s[4..-1].downcase
    extension = 'jpg' if extension == 'jpeg'
    extension
  end

  ##
  # Creates a proportional thumbnail of the image scaled so its longest
  # edge is resized to +size+ and yields the new image.

  def thumbnail(size) # :yields: image
    w, h = width, height
    scale = size.to_f / (w > h ? w : h)

    self.resize((w * scale).round, (h * scale).round) do |image|
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

  ##
  # Saves the image out to +path+. Changing the file extension will
  # convert the file type to the appropriate format.

  def save(path)
    File.open(path, "wb") do |file|
      file.write buffer(path)
    end
  end


  inline do |builder|
    %w[/opt/local /usr/local].each do |dir|
      if File.directory? "#{dir}/include" then
        builder.add_compile_flags "-I#{dir}/include"
        builder.add_link_flags "-L#{dir}/lib"
      end
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
      static ID err_key; /* used as thread-local key */
      static void clear_error(void);
      static void raise_error(void);
    END

    builder.prefix <<-"END"
      VALUE unload(VALUE self) {
        FIBITMAP *bitmap;
        GET_BITMAP(bitmap);

        FreeImage_Unload(bitmap);
        DATA_PTR(self) = NULL;
        clear_error();
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

    # we defer raising the error until it we find a safe point to do so
    # We cannot use rb_ensure in these cases because FreeImage may internally
    # make allocations via which our code will never see.
    builder.prefix <<-"END"
      void FreeImageErrorHandler(FREE_IMAGE_FORMAT fif, const char *message) {
        VALUE err = rb_sprintf(
                 "FreeImage exception for type %s: %s",
                  (fif == FIF_UNKNOWN) ? "???" : FreeImage_GetFormatFromFIF(fif),
                  message);
        rb_thread_local_aset(rb_thread_current(), err_key, err);
      }
    END

    # do not call this until necessary variables are wrapped up for GC
    # otherwise there will be leaks
    builder.prefix <<-"END"
      static void raise_error(void) {
        VALUE err = rb_thread_local_aref(rb_thread_current(), err_key);
        if (NIL_P(err)) {
          rb_raise(rb_eRuntimeError, "FreeImage exception");
        } else {
          rb_thread_local_aset(rb_thread_current(), err_key, Qnil);
          rb_raise(rb_eRuntimeError, "%s", StringValueCStr(err));
        }
      }
    END

    builder.prefix <<-"END"
      static void clear_error(void) {
        if (!NIL_P(rb_thread_local_aref(rb_thread_current(), err_key))) {
          rb_thread_local_aset(rb_thread_current(), err_key, Qnil);
        }
      }
    END

    builder.prefix <<-"END"
      FIBITMAP* ReOrient(FIBITMAP *bitmap) {
        FITAG *tagValue = NULL;
        FIBITMAP *oldBitmap = bitmap;
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
            bitmap = FreeImage_Clone(bitmap);
            break;
        }
        FreeImage_Unload(oldBitmap);
        return bitmap;
      }
    END

    builder.add_to_init "FreeImage_SetOutputMessage(FreeImageErrorHandler);"
    builder.add_to_init 'err_key = rb_intern("__FREE_IMAGE_ERROR");'

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

          if (!(bitmap = FreeImage_Load(fif, input, flags))) raise_error();
          if (!(bitmap = ReOrient(bitmap))) raise_error();

          result = wrap_and_yield(bitmap, self, fif);
          return result;
        }
        rb_raise(rb_eTypeError, "Unknown file format");
        return Qnil;
      }
    END

    builder.c_singleton <<-"END"
      VALUE with_image_from_memory(VALUE image_data) {
        FREE_IMAGE_FORMAT fif = FIF_UNKNOWN;
        BYTE *image_data_ptr;
        DWORD image_data_length;
        FIMEMORY *stream;
        FIBITMAP *bitmap = NULL;
        VALUE result = Qnil;
        int flags;

        Check_Type(image_data, T_STRING);
        image_data_ptr    = (BYTE*)RSTRING_PTR(image_data);
        image_data_length = (DWORD)RSTRING_LEN(image_data);
        stream = FreeImage_OpenMemory(image_data_ptr, image_data_length);

        if (NULL == stream) {
          rb_raise(rb_eTypeError, "Unable to open image_data");
        }

        fif = FreeImage_GetFileTypeFromMemory(stream, 0);
        if ((fif == FIF_UNKNOWN) || !FreeImage_FIFSupportsReading(fif)) {
          FreeImage_CloseMemory(stream);
          rb_raise(rb_eTypeError, "Unknown file format");
        }

        flags = fif == FIF_JPEG ? JPEG_ACCURATE : 0;
        bitmap = FreeImage_LoadFromMemory(fif, stream, flags);
        FreeImage_CloseMemory(stream);

        if (!bitmap) raise_error();
        if (!(bitmap = ReOrient(bitmap))) raise_error();

        result = wrap_and_yield(bitmap, self, fif);
        return result;
      }
    END

    builder.c <<-"END"
      VALUE with_crop(int l, int t, int r, int b) {
        FIBITMAP *copy, *bitmap;
        GET_BITMAP(bitmap);

        if (!(copy = FreeImage_Copy(bitmap, l, t, r, b))) raise_error();

        copy_icc_profile(self, bitmap, copy);
        return wrap_and_yield(copy, self, 0);
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
      VALUE resize(int w, int h) {
        FIBITMAP *bitmap, *image;
        if (w <= 0) rb_raise(rb_eArgError, "Width <= 0");
        if (h <= 0) rb_raise(rb_eArgError, "Height <= 0");
        GET_BITMAP(bitmap);

        image = FreeImage_Rescale(bitmap, w, h, FILTER_CATMULLROM);
        if (!image) raise_error();

        copy_icc_profile(self, bitmap, image);
        return wrap_and_yield(image, self, 0);
      }
    END

    builder.c <<-"END"
      VALUE rotate(int angle) {
        FIBITMAP *bitmap, *image;
        if ((angle % 45) != 0) rb_raise(rb_eArgError, "Angle must be 45 degree skew");
        GET_BITMAP(bitmap);
        image = FreeImage_RotateClassic(bitmap, angle);
        if (image) {
          copy_icc_profile(self, bitmap, image);
          return wrap_and_yield(image, self, 0);
        }
        return Qnil;
      }
    END

    builder.c_raw <<-"END"
      VALUE buffer(int argc, VALUE *argv, VALUE self) {
        VALUE output;
        int flags;
        FIBITMAP *bitmap;
        FIMEMORY *mem = NULL;
        long file_size;
        BYTE *mem_buffer = NULL;
        DWORD size_in_bytes = 0;
        FREE_IMAGE_FORMAT fif = FIF_UNKNOWN;
        VALUE ext;

        rb_scan_args(argc, argv, "01", &ext);
        if (RTEST(ext)) fif = FreeImage_GetFIFFromFilename(RSTRING_PTR(ext));
        if (fif == FIF_UNKNOWN) fif = FIX2INT(rb_iv_get(self, "@file_type"));

        if ((fif != FIF_UNKNOWN) && FreeImage_FIFSupportsWriting(fif)) {
          GET_BITMAP(bitmap);
          flags = fif == FIF_JPEG ? JPEG_QUALITYSUPERB : 0;
          BOOL result = 0, unload = 0;

          if (fif == FIF_PNG) FreeImage_DestroyICCProfile(bitmap);
          if (fif == FIF_JPEG && FreeImage_GetBPP(bitmap) != 24) {
            bitmap = FreeImage_ConvertTo24Bits(bitmap), unload = 1; // sue me
            if (!bitmap) raise_error();
          }

          mem = FreeImage_OpenMemory(0,0);
          result = FreeImage_SaveToMemory(fif, bitmap, mem, flags);

          // get the buffer from the memory stream
          FreeImage_AcquireMemory(mem, &mem_buffer, &size_in_bytes);

          // convert to ruby string
          output = rb_str_new(mem_buffer, size_in_bytes);

          // clean up
          if (unload) FreeImage_Unload(bitmap);
          FreeImage_CloseMemory(mem);

          if (!result) raise_error();
          return result ? output : Qnil;
        }
        rb_raise(rb_eTypeError, "Unknown file format");
        return Qnil;
      }
    END
  end
end
