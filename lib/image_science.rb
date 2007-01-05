#!/usr/local/bin/ruby -w

require 'rubygems'
require 'inline'

##
# Provides a simple and clean API to generate thumbnails using
# FreeImage as the underlying mechanism.
#
# For more information or if you have build issues with FreeImage, see
# http://seattlerb.rubyforge.org/ImageScience.html

class ImageScience
  VERSION = '1.1.0'

  ##
  # The top-level image loader opens +path+ and then yields the image.

  def self.with_image(path); end # :yields: image

  ##
  # Crops an image to +left+, +top+, +right+, and +bottom+ and then
  # yields the new image.

  def with_crop(left, top, right, bottom); end # :yields: image

  ##
  # Returns the width of the image, in pixels.

  def width; end

  ##
  # Returns the height of the image, in pixels.

  def height; end

  ##
  # Resizes the image to +width+ and +height+ using a cubic-bspline
  # filter and yields the new image.

  def resize(width, height); end # :yields: image

  ##
  # Creates a proportional thumbnail of the image scaled so its widest
  # edge is resized to +size+ and yields the new image.

  def thumbnail(size); end # :yields: image

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
    builder.add_link_flags "-lstdc++" # only needed on PPC for some reason. lame
    builder.include '"FreeImage.h"'

    builder.prefix <<-"END"
      #define GET_BITMAP(name) FIBITMAP *(name); Data_Get_Struct(self, FIBITMAP, (name)); if (!(name)) rb_raise(rb_eTypeError, "Bitmap has already been freed")

      VALUE unload(VALUE self) {
        GET_BITMAP(bitmap);

        FreeImage_Unload(bitmap);
        DATA_PTR(self) = NULL;
        return Qnil;
      }
    END

    builder.c_singleton <<-"END"
      VALUE with_image(char * input) {
        FREE_IMAGE_FORMAT fif = FIF_UNKNOWN; 

        fif = FreeImage_GetFileType(input, 0); 
        if (fif == FIF_UNKNOWN) fif = FreeImage_GetFIFFromFilename(input); 
        if ((fif != FIF_UNKNOWN) && FreeImage_FIFSupportsReading(fif)) { 
          FIBITMAP *bitmap;
          VALUE result = Qnil;
          if (bitmap = FreeImage_Load(fif, input, 0)) {
            VALUE obj = Data_Wrap_Struct(self, NULL, NULL, bitmap);
            rb_iv_set(obj, "@file_type", INT2FIX(fif));
            result = rb_ensure(rb_yield, obj, unload, obj);
          }
          return result;
        }
        rb_raise(rb_eTypeError, "Unknown file format");
      }
    END

    builder.c <<-"END"
      VALUE with_crop(int l, int t, int r, int b) {
        FIBITMAP *copy;
        VALUE result = Qnil;
        GET_BITMAP(bitmap);

        if (copy = FreeImage_Copy(bitmap, l, t, r, b)) {
          VALUE obj = Data_Wrap_Struct(CLASS_OF(self), NULL, NULL, copy);
          result = rb_ensure(rb_yield, obj, unload, obj);
        }
        return result;
      }
    END

    builder.c <<-"END"
      int height() {
        GET_BITMAP(bitmap);

        return FreeImage_GetHeight(bitmap);
      }
    END

    builder.c <<-"END"
      int width() {
        GET_BITMAP(bitmap);

        return FreeImage_GetWidth(bitmap);
      }
    END

    builder.c <<-"END"
      VALUE thumbnail(int size) {
        GET_BITMAP(bitmap);
        FIBITMAP *image = FreeImage_MakeThumbnail(bitmap, size, TRUE);
        VALUE obj = Data_Wrap_Struct(CLASS_OF(self), NULL, NULL, image);
        return rb_ensure(rb_yield, obj, unload, obj);
      }
    END

    builder.c <<-"END"
      VALUE resize(int w, int h) {
        GET_BITMAP(bitmap);
        FIBITMAP *image = FreeImage_Rescale(bitmap, w, h, FILTER_BSPLINE);
        VALUE obj = Data_Wrap_Struct(CLASS_OF(self), NULL, NULL, image);
        return rb_ensure(rb_yield, obj, unload, obj);
      }
    END

    builder.c <<-"END"
      VALUE save(char * output) {
        FREE_IMAGE_FORMAT fif = FreeImage_GetFIFFromFilename(output);
        if (fif == FIF_UNKNOWN) fif = FIX2INT(rb_iv_get(self, "@file_type"));
        if ((fif != FIF_UNKNOWN) && FreeImage_FIFSupportsWriting(fif)) { 
          GET_BITMAP(bitmap);

          if (FreeImage_Save(fif, bitmap, output, 0)) {
            return Qtrue;
          }
          return Qfalse;
        }
        rb_raise(rb_eTypeError, "Unknown file format");
      }
    END
  end
end
