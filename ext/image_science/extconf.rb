require 'mkmf'

include_path = '/usr/local/include:/usr/include:/opt/local/include:/opt/include'
lib_path = '/usr/local/lib:/usr/lib:/opt/local/lib:/opt/lib'

dir_config("image_science", include_path, lib_path)

have_library('freeimage')

create_makefile("image_science/extension")
