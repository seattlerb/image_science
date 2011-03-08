#include "ruby.h"
#include "FreeImage.h"

#define GET_BITMAP(name) Data_Get_Struct(self, FIBITMAP, (name)); if (!(name)) rb_raise(rb_eTypeError, "Bitmap has already been freed");

VALUE unload(VALUE self) {
  FIBITMAP *bitmap;
  GET_BITMAP(bitmap);

  FreeImage_Unload(bitmap);
  DATA_PTR(self) = NULL;
  return Qnil;
}


VALUE wrap_and_yield(FIBITMAP *image, VALUE self, FREE_IMAGE_FORMAT fif) {
  unsigned int self_is_class = rb_type(self) == T_CLASS;
  VALUE klass = self_is_class ? self         : CLASS_OF(self);
  VALUE type  = self_is_class ? INT2FIX(fif) : rb_iv_get(self, "@file_type");
  VALUE obj = Data_Wrap_Struct(klass, NULL, NULL, image);
  rb_iv_set(obj, "@file_type", type);
  return rb_ensure(rb_yield, obj, unload, obj);
}


void copy_icc_profile(VALUE self, FIBITMAP *from, FIBITMAP *to) {
  FREE_IMAGE_FORMAT fif = FIX2INT(rb_iv_get(self, "@file_type"));
  if (fif != FIF_PNG && FreeImage_FIFSupportsICCProfiles(fif)) {
    FIICCPROFILE *profile = FreeImage_GetICCProfile(from);
    if (profile && profile->data) {
      FreeImage_CreateICCProfile(to, profile->data, profile->size);
    }
  }
}


void FreeImageErrorHandler(FREE_IMAGE_FORMAT fif, const char *message) {
  rb_raise(rb_eRuntimeError,
           "FreeImage exception for type %s: %s",
            (fif == FIF_UNKNOWN) ? "???" : FreeImage_GetFormatFromFIF(fif),
            message);
}


static VALUE with_image(VALUE self, VALUE _input) {
  char * input = StringValuePtr(_input);

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
    return (result);
  }
  rb_raise(rb_eTypeError, "Unknown file format");
}


static VALUE with_image_from_memory(VALUE self, VALUE _image_data) {
  VALUE image_data = (_image_data);

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
  return (result);
}


static VALUE with_crop(VALUE self, VALUE _l, VALUE _t, VALUE _r, VALUE _b) {
  int l = FIX2INT(_l);
  int t = FIX2INT(_t);
  int r = FIX2INT(_r);
  int b = FIX2INT(_b);

  FIBITMAP *copy, *bitmap;
  VALUE result = Qnil;
  GET_BITMAP(bitmap);

  if (copy = FreeImage_Copy(bitmap, l, t, r, b)) {
    copy_icc_profile(self, bitmap, copy);
    result = wrap_and_yield(copy, self, 0);
  }
  return (result);
}


static VALUE height(VALUE self) {

  FIBITMAP *bitmap;
  GET_BITMAP(bitmap);

  return INT2FIX(FreeImage_GetHeight(bitmap));
}


static VALUE width(VALUE self) {

  FIBITMAP *bitmap;
  GET_BITMAP(bitmap);

  return INT2FIX(FreeImage_GetWidth(bitmap));
}


static VALUE resize(VALUE self, VALUE _w, VALUE _h) {
  long w = NUM2LONG(_w);
  long h = NUM2LONG(_h);

  FIBITMAP *bitmap, *image;
  if (w <= 0) rb_raise(rb_eArgError, "Width <= 0");
  if (h <= 0) rb_raise(rb_eArgError, "Height <= 0");
  GET_BITMAP(bitmap);
  image = FreeImage_Rescale(bitmap, w, h, FILTER_CATMULLROM);
  if (image) {
    copy_icc_profile(self, bitmap, image);
    return (wrap_and_yield(image, self, 0));
  }
  return (Qnil);
}


static VALUE save(VALUE self, VALUE _output) {
  char * output = StringValuePtr(_output);

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
      bitmap = FreeImage_ConvertTo24Bits(bitmap), unload = 1;

    result = FreeImage_Save(fif, bitmap, output, flags);

    if (unload) FreeImage_Unload(bitmap);

    return (result ? Qtrue : Qfalse);
  }
  rb_raise(rb_eTypeError, "Unknown file format");
}



#ifdef __cplusplus
extern "C" {
#endif
  void Init_extension() {
    VALUE c = rb_cObject;
    c = rb_const_get(c, rb_intern("ImageScience"));

    rb_define_method(c, "height", (VALUE(*)(ANYARGS))height, 0);
    rb_define_method(c, "resize", (VALUE(*)(ANYARGS))resize, 2);
    rb_define_method(c, "save", (VALUE(*)(ANYARGS))save, 1);
    rb_define_method(c, "width", (VALUE(*)(ANYARGS))width, 0);
    rb_define_method(c, "with_crop", (VALUE(*)(ANYARGS))with_crop, 4);
    rb_define_singleton_method(c, "with_image", (VALUE(*)(ANYARGS))with_image, 1);
    rb_define_singleton_method(c, "with_image_from_memory", (VALUE(*)(ANYARGS))with_image_from_memory, 1);
FreeImage_SetOutputMessage(FreeImageErrorHandler);

  }
#ifdef __cplusplus
}
#endif
