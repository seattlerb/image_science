dir = File.expand_path "~/.ruby_inline"
if test ?d, dir then
  require 'fileutils'
  puts "nuking #{dir}"
  # force removal, Windoze is bitching at me, something to hunt later...
  FileUtils.rm_r dir, :force => true
end

require 'rubygems'
require 'minitest/unit'
require 'minitest/autorun' if $0 == __FILE__
require 'image_science'

class TestImageScience < MiniTest::Unit::TestCase
  def setup
    @fifty_x_fifty         = 'test/pix.png'
    @fifty_x_fifty_tmppath = 'test/pix-tmp.png'

    @fifty_x_thirty         = 'test/pix-50x30.png'
    @fifty_x_thirty_tmppath = 'test/pix-50x30-tmp.png'
  end

  def teardown
    [@fifty_x_fifty_tmppath, @fifty_x_thirty_tmppath].each do |file|
      File.unlink file if File.exist? file
    end
  end

  def test_class_with_image
    ImageScience.with_image @fifty_x_fifty do |img|
      assert_kind_of ImageScience, img
      assert_equal 50, img.height
      assert_equal 50, img.width
      assert img.save(@fifty_x_fifty_tmppath)
    end

    assert File.exists?(@fifty_x_fifty_tmppath)

    ImageScience.with_image @fifty_x_fifty_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 50, img.height
      assert_equal 50, img.width
    end
  end

  def test_class_with_image_missing
    assert_raises TypeError do
      ImageScience.with_image @fifty_x_fifty + "nope" do |img|
        flunk
      end
    end
  end

  def test_class_with_image_missing_with_img_extension
    assert_raises RuntimeError do
      assert_nil ImageScience.with_image("nope#{@fifty_x_fifty}") do |img|
        flunk
      end
    end
  end

  def test_class_with_image_from_memory
    data = File.new(@fifty_x_fifty).binmode.read

    ImageScience.with_image_from_memory data do |img|
      assert_kind_of ImageScience, img
      assert_equal 50, img.height
      assert_equal 50, img.width
      assert img.save(@fifty_x_fifty_tmppath)
    end

    assert File.exists?(@fifty_x_fifty_tmppath)

    ImageScience.with_image @fifty_x_fifty_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 50, img.height
      assert_equal 50, img.width
    end
  end

  def test_class_with_image_from_memory_empty_string
    assert_raises TypeError do
      ImageScience.with_image_from_memory "" do |img|
        flunk
      end
    end
  end

  def test_cropped_thumbnail
    ImageScience.with_image @fifty_x_thirty do |img|
      img.cropped_thumbnail(10) do |thumb|
        assert thumb.save(@fifty_x_thirty_tmppath)
      end
    end

    assert File.exists?(@fifty_x_thirty_tmppath)

    ImageScience.with_image @fifty_x_thirty_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 10, img.height
      assert_equal 10, img.width
    end
  end

  def test_cropped_thumbnail_floats
    ImageScience.with_image @fifty_x_thirty do |img|
      img.cropped_thumbnail(10.2) do |thumb|
        assert thumb.save(@fifty_x_thirty_tmppath)
      end
    end

    assert File.exists?(@fifty_x_thirty_tmppath)

    ImageScience.with_image @fifty_x_thirty_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 10, img.height
      assert_equal 10, img.width
    end
  end

  def test_cropped_thumbnail_zero
    assert_raises ArgumentError do
      ImageScience.with_image @fifty_x_thirty do |img|
        img.cropped_thumbnail(0) do |thumb|
          assert thumb.save(@fifty_x_thirty_tmppath)
        end
      end
    end

    refute File.exists?(@fifty_x_thirty_tmppath)
  end

  def test_cropped_thumbnail_negative
    assert_raises ArgumentError do
      ImageScience.with_image @fifty_x_thirty do |img|
        img.cropped_thumbnail(-10) do |thumb|
          assert thumb.save(@fifty_x_thirty_tmppath)
        end
      end
    end

    refute File.exists?(@fifty_x_thirty_tmppath)
  end

  def test_thumbnail
    ImageScience.with_image @fifty_x_thirty do |img|
      img.thumbnail(10) do |thumb|
        assert thumb.save(@fifty_x_thirty_tmppath)
      end
    end

    assert File.exists?(@fifty_x_thirty_tmppath)

    ImageScience.with_image @fifty_x_thirty_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 6, img.height
      assert_equal 10, img.width
    end
  end

  def test_thumbnail_floats
    ImageScience.with_image @fifty_x_thirty do |img|
      img.thumbnail(10.2) do |thumb|
        assert thumb.save(@fifty_x_thirty_tmppath)
      end
    end

    assert File.exists?(@fifty_x_thirty_tmppath)

    ImageScience.with_image @fifty_x_thirty_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 6, img.height
      assert_equal 10, img.width
    end
  end

  def test_thumbnail_zero
    assert_raises ArgumentError do
      ImageScience.with_image @fifty_x_thirty do |img|
        img.thumbnail(0) do |thumb|
          assert thumb.save(@fifty_x_thirty_tmppath)
        end
      end
    end

    refute File.exists?(@fifty_x_thirty_tmppath)
  end

  def test_thumbnail_negative
    assert_raises ArgumentError do
      ImageScience.with_image @fifty_x_thirty do |img|
        img.thumbnail(-10) do |thumb|
          assert thumb.save(@fifty_x_thirty_tmppath)
        end
      end
    end

    refute File.exists?(@fifty_x_thirty_tmppath)
  end

  def test_ratio
    ImageScience.with_image @fifty_x_thirty do |img|
      assert_equal 0.6, img.ratio
    end
    ImageScience.with_image @fifty_x_fifty do |img|
      assert_equal 1, img.ratio
    end
  end

  def test_resize
    ImageScience.with_image @fifty_x_fifty do |img|
      img.resize(25, 25) do |thumb|
        assert thumb.save(@fifty_x_fifty_tmppath)
      end
    end

    assert File.exists?(@fifty_x_fifty_tmppath)

    ImageScience.with_image @fifty_x_fifty_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_floats
    ImageScience.with_image @fifty_x_fifty do |img|
      img.resize(25.2, 25.7) do |thumb|
        assert thumb.save(@fifty_x_fifty_tmppath)
      end
    end

    assert File.exists?(@fifty_x_fifty_tmppath)

    ImageScience.with_image @fifty_x_fifty_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_zero
    assert_raises ArgumentError do
      ImageScience.with_image @fifty_x_fifty do |img|
        img.resize(0, 25) do |thumb|
          assert thumb.save(@fifty_x_fifty_tmppath)
        end
      end
    end

    refute File.exists?(@fifty_x_fifty_tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @fifty_x_fifty do |img|
        img.resize(25, 0) do |thumb|
          assert thumb.save(@fifty_x_fifty_tmppath)
        end
      end
    end

    refute File.exists?(@fifty_x_fifty_tmppath)
  end

  def test_resize_negative
    assert_raises ArgumentError do
      ImageScience.with_image @fifty_x_fifty do |img|
        img.resize(-25, 25) do |thumb|
          assert thumb.save(@fifty_x_fifty_tmppath)
        end
      end
    end

    refute File.exists?(@fifty_x_fifty_tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @fifty_x_fifty do |img|
        img.resize(25, -25) do |thumb|
          assert thumb.save(@fifty_x_fifty_tmppath)
        end
      end
    end

    refute File.exists?(@fifty_x_fifty_tmppath)
  end
end
