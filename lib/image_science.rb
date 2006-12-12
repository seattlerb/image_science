#!/usr/local/bin/ruby -w

require 'rubygems'
require 'inline'

class ImageScience
  VERSION = '1.0.0'

  def cropped_thumbnail(path, size)
    w, h = width, height
    l, t, r, b, half = 0, 0, w, h, (w > h ? (w - h) : (h - w)) / 2

    l, r = half, half + h if w > h
    t, b = half, half + w if h > w

    with_crop(l, t, r, b) do |img|
      img.thumbnail(path, size)
    end
  end

  inline do |builder|
    builder.add_link_flags "-lfreeimage"
    builder.include '"FreeImage.h"'

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
            result = rb_yield(obj);
            FreeImage_Unload(bitmap);
          }
          return result;
        }
        rb_raise(rb_eTypeError, "Unknown file format");
      }
    END

    builder.c <<-"END"
      VALUE with_crop(int l, int t, int r, int b) {
        FIBITMAP *bitmap, *copy;
        VALUE result = Qnil;
        Data_Get_Struct(self, FIBITMAP, bitmap);

        if (copy = FreeImage_Copy(bitmap, l, t, r, b)) {
          VALUE obj = Data_Wrap_Struct(CLASS_OF(self), NULL, NULL, copy);
          result = rb_yield(obj);
          FreeImage_Unload(copy);
        }
        return result;
      }
    END

    builder.c <<-"END"
      int height() {
        FIBITMAP *bitmap;
        Data_Get_Struct(self, FIBITMAP, bitmap);
        return FreeImage_GetHeight(bitmap);
      }
    END

    builder.c <<-"END"
      int width() {
        FIBITMAP *bitmap;
        Data_Get_Struct(self, FIBITMAP, bitmap);
        return FreeImage_GetWidth(bitmap);
      }
    END

    builder.c <<-"END"
      VALUE thumbnail(char * output, int size) {
        FIBITMAP *bitmap;
        FREE_IMAGE_FORMAT fif = FreeImage_GetFIFFromFilename(output);
        if (fif == FIF_UNKNOWN) fif = FIX2INT(rb_iv_get(self, "@file_type"));
        if ((fif != FIF_UNKNOWN) && FreeImage_FIFSupportsWriting(fif)) { 
          Data_Get_Struct(self, FIBITMAP, bitmap);
          FIBITMAP *thumbnail = FreeImage_MakeThumbnail(bitmap, size, TRUE);
          if (FreeImage_Save(fif, thumbnail, output, 0)) {
            FreeImage_Unload(thumbnail);
            return Qtrue;
          }
          return Qfalse;
        }
        rb_raise(rb_eTypeError, "Unknown file format");
      }
    END
  end
end
