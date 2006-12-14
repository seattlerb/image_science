ImageScience
    http://rubyforge.org/projects/seattlerb
    http://seattlerb.rubyforge.org/
    by Ryan Davis

== DESCRIPTION:

ImageScience is a clean and happy Ruby library that generates
thumbnails -- and kicks the living crap out of RMagick. Oh, and it
doesn't leak memory like a sieve. :)

For more information including build steps, see http://seattlerb.rubyforge.org/

== FEATURES/PROBLEMS:

* 93 glorious lines of graphics manipulation magi... errr, SCIENCE!
* Supports both square and proportional thumbnails.
* Pretty much any graphics format you could want. No really.

== SYNOPSYS:

  ImageScience.with_image(file) do |img|
    img.cropped_thumbnail("#{file}_cropped.png", 100)
  end
  
  ImageScience.with_image(file) do |img|
    img.thumbnail("#{file}_thumb.png", 100)
  end

== REQUIREMENTS:

* FreeImage
* ImageScience

== INSTALL:

* Download and install FreeImage. See notes at url above.
* sudo gem install -y image_science

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
