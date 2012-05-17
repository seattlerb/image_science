##
# Provides a clean and simple API to generate thumbnails using
# FreeImage as the underlying mechanism.
#
# For more information or if you have build issues with FreeImage, see
# http://seattlerb.rubyforge.org/ImageScience.html

class ImageScience

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
end
