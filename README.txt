ImageScience
    by Ryan Davis
    http://rubyforge.org/projects/seattlerb

== DESCRIPTION:

ImageScience is a clean and capable image thumbnailer capable of
manipulating whatever image format you're probably already using. It
uses FreeImage to manipulate various graphics formats.

== FEATURES/PROBLEMS:

* Glorious 93 lines of graphics manipulation magi... errr, SCIENCE!
* Square and proportional thumbnailing.
* Pretty much any graphics format you could want.

== SYNOPSYS:

  ImageScience.with_image(file) do |img|
    img.cropped_thumbnail("#{file}_cropped.png", 100)
  end
  
  ImageScience.with_image(file) do |img|
    img.thumbnail("#{file}_thumb.png", 100)
  end

== REQUIREMENTS:

* FreeImage - http://sf.net/projects/freeimage - I suggest CVS for now
* RubyInline - sudo gem install RubyInline

== INSTALL:

* download and unpack FreeImage from URL above.
* make -f Makefile.osx (or just make)
* sudo make -f Makefile.osx install (exercise for the reader)
* sudo gem install ImageScience

== LICENSE:

(The MIT License)

Copyright (c) 2006 Ryan Davis, Seattle.rb

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
