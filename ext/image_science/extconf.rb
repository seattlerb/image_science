require 'mkmf'

include_path = '/usr/local/include:/usr/include'
lib_path = '/usr/local/lib:/usr/lib'

dir_config("hello", include_path, lib_path)

have_library('freeimage')

create_makefile("image_science")
