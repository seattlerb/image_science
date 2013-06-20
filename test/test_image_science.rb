require 'tmpdir'
dir = Dir.mktmpdir "image_science."
ENV['INLINEDIR'] = dir
Minitest.after_run do
  require 'fileutils'
  FileUtils.rm_rf dir
end

require 'rubygems'
require 'minitest/unit'
require 'minitest/autorun' if $0 == __FILE__
require 'image_science'

class TestImageScience < Minitest::Test
  def setup
    @_50x50         = 'test/pix.png'
    @_50x50_tmppath = 'test/pix-tmp.png'

    @_50x30         = 'test/pix-50x30.png'
    @_50x30_tmppath = 'test/pix-50x30-tmp.png'
  end

  def teardown
    [@_50x50_tmppath, @_50x30_tmppath].each do |file|
      File.unlink file if File.exist? file
    end
  end

  def test_class_with_image
    ImageScience.with_image @_50x50 do |img|
      assert_kind_of ImageScience, img
      assert_equal 50, img.height
      assert_equal 50, img.width
      assert img.save(@_50x50_tmppath)
    end

    assert File.exists?(@_50x50_tmppath)

    ImageScience.with_image @_50x50_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 50, img.height
      assert_equal 50, img.width
    end
  end

  def test_class_with_image_missing
    assert_raises TypeError do
      ImageScience.with_image @_50x50 + "nope" do |img|
        flunk
      end
    end
  end

  def test_class_with_image_missing_with_img_extension
    assert_raises RuntimeError do
      assert_nil ImageScience.with_image("nope#{@_50x50}") do |img|
        flunk
      end
    end
  end

  def test_class_with_image_from_memory
    data = File.new(@_50x50).binmode.read

    ImageScience.with_image_from_memory data do |img|
      assert_kind_of ImageScience, img
      assert_equal 50, img.height
      assert_equal 50, img.width
      assert img.save(@_50x50_tmppath)
    end

    assert File.exists?(@_50x50_tmppath)

    ImageScience.with_image @_50x50_tmppath do |img|
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
    ImageScience.with_image @_50x30 do |img|
      img.cropped_thumbnail(10) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    assert File.exists?(@_50x30_tmppath)

    ImageScience.with_image @_50x30_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 10, img.height
      assert_equal 10, img.width
    end
  end

  def test_cropped_thumbnail_floats
    ImageScience.with_image @_50x30 do |img|
      img.cropped_thumbnail(10.2) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    assert File.exists?(@_50x30_tmppath)

    ImageScience.with_image @_50x30_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 10, img.height
      assert_equal 10, img.width
    end
  end

  def test_cropped_thumbnail_zero
    assert_raises ArgumentError do
      ImageScience.with_image @_50x30 do |img|
        img.cropped_thumbnail(0) do |thumb|
          assert thumb.save(@_50x30_tmppath)
        end
      end
    end

    refute File.exists?(@_50x30_tmppath)
  end

  def test_cropped_thumbnail_negative
    assert_raises ArgumentError do
      ImageScience.with_image @_50x30 do |img|
        img.cropped_thumbnail(-10) do |thumb|
          assert thumb.save(@_50x30_tmppath)
        end
      end
    end

    refute File.exists?(@_50x30_tmppath)
  end

  def test_cropped_resize
    ImageScience.with_image @_50x30 do |img|
      img.cropped_resize(10, 5) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    assert File.exists?(@_50x30_tmppath)

    ImageScience.with_image @_50x30_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 5, img.height
      assert_equal 10, img.width
    end
  end

  def test_cropped_resize_floats
    ImageScience.with_image @_50x30 do |img|
      img.cropped_resize(10.2, 5) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    assert File.exists?(@_50x30_tmppath)

    ImageScience.with_image @_50x30_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 5, img.height
      assert_equal 10, img.width
    end

    ImageScience.with_image @_50x30 do |img|
      img.cropped_resize(10, 5.2) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    assert File.exists?(@_50x30_tmppath)

    ImageScience.with_image @_50x30_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 5, img.height
      assert_equal 10, img.width
    end
  end

  def test_cropped_resize_zero
    assert_raises ArgumentError do
      ImageScience.with_image @_50x30 do |img|
        img.cropped_resize(0, 25) do |thumb|
          assert thumb.save(@_50x30_tmppath)
        end
      end
    end

    refute File.exists?(@_50x30_tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @_50x30 do |img|
        img.cropped_resize(25, 0) do |thumb|
          assert thumb.save(@_50x30_tmppath)
        end
      end
    end

    refute File.exists?(@_50x30_tmppath)
  end

  def test_cropped_resize_negative
    assert_raises ArgumentError do
      ImageScience.with_image @_50x30 do |img|
        img.cropped_resize(1, -10) do |thumb|
          assert thumb.save(@_50x30_tmppath)
        end
      end
    end

    refute File.exists?(@_50x30_tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @_50x30 do |img|
        img.cropped_resize(-10, 1) do |thumb|
          assert thumb.save(@_50x30_tmppath)
        end
      end
    end

    refute File.exists?(@_50x30_tmppath)
  end

  def test_thumbnail
    ImageScience.with_image @_50x30 do |img|
      img.thumbnail(10) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    assert File.exists?(@_50x30_tmppath)

    ImageScience.with_image @_50x30_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 6, img.height
      assert_equal 10, img.width
    end
  end

  def test_thumbnail_use_short_edge
    ImageScience.with_image @_50x30 do |img|
      img.thumbnail(10, true) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    assert File.exists?(@_50x30_tmppath)

    ImageScience.with_image @_50x30_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 10, img.height
      assert_equal 16, img.width
    end
  end

  def test_thumbnail_floats
    ImageScience.with_image @_50x30 do |img|
      img.thumbnail(10.2) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    assert File.exists?(@_50x30_tmppath)

    ImageScience.with_image @_50x30_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 6, img.height
      assert_equal 10, img.width
    end
  end

  def test_thumbnail_zero
    assert_raises ArgumentError do
      ImageScience.with_image @_50x30 do |img|
        img.thumbnail(0) do |thumb|
          assert thumb.save(@_50x30_tmppath)
        end
      end
    end

    refute File.exists?(@_50x30_tmppath)
  end

  def test_thumbnail_negative
    assert_raises ArgumentError do
      ImageScience.with_image @_50x30 do |img|
        img.thumbnail(-10) do |thumb|
          assert thumb.save(@_50x30_tmppath)
        end
      end
    end

    refute File.exists?(@_50x30_tmppath)
  end

  def test_ratio
    ImageScience.with_image @_50x30 do |img|
      assert_equal 0.6, img.ratio
    end
    ImageScience.with_image @_50x50 do |img|
      assert_equal 1, img.ratio
    end
  end

  def test_resize
    ImageScience.with_image @_50x50 do |img|
      img.resize(25, 25) do |thumb|
        assert thumb.save(@_50x50_tmppath)
      end
    end

    assert File.exists?(@_50x50_tmppath)

    ImageScience.with_image @_50x50_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_and_cropped_resize
    ImageScience.with_image @_50x30 do |img|
      img.resize(10, 5) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    img1 = IO.read @_50x30_tmppath, nil, 0, :encoding => "binary"

    ImageScience.with_image @_50x30 do |img|
      img.resize(10, 5) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    img2 = IO.read @_50x30_tmppath, nil, 0, :encoding => "binary"

    ImageScience.with_image @_50x30 do |img|
      img.cropped_resize(10, 5) do |thumb|
        assert thumb.save(@_50x30_tmppath)
      end
    end

    img3 = IO.read @_50x30_tmppath, nil, 0, :encoding => "binary"

    assert_equal img1, img2
    refute_equal img2, img3
  end

  def test_resize_floats
    ImageScience.with_image @_50x50 do |img|
      img.resize(25.2, 25.7) do |thumb|
        assert thumb.save(@_50x50_tmppath)
      end
    end

    assert File.exists?(@_50x50_tmppath)

    ImageScience.with_image @_50x50_tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_zero
    assert_raises ArgumentError do
      ImageScience.with_image @_50x50 do |img|
        img.resize(0, 25) do |thumb|
          assert thumb.save(@_50x50_tmppath)
        end
      end
    end

    refute File.exists?(@_50x50_tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @_50x50 do |img|
        img.resize(25, 0) do |thumb|
          assert thumb.save(@_50x50_tmppath)
        end
      end
    end

    refute File.exists?(@_50x50_tmppath)
  end

  def test_resize_negative
    assert_raises ArgumentError do
      ImageScience.with_image @_50x50 do |img|
        img.resize(-25, 25) do |thumb|
          assert thumb.save(@_50x50_tmppath)
        end
      end
    end

    refute File.exists?(@_50x50_tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @_50x50 do |img|
        img.resize(25, -25) do |thumb|
          assert thumb.save(@_50x50_tmppath)
        end
      end
    end

    refute File.exists?(@_50x50_tmppath)
  end

  def test_thumbnail
    ImageScience.with_image @path do |img|
      img.thumbnail(29) do |thumb|
        assert thumb.save(@tmppath)
      end
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 29, img.height
      assert_equal 29, img.width
    end
  end

  def test_auto_rotate_from_file
    ImageScience.with_image "test/portrait.jpg" do |img|
      assert_equal 50, img.height
      assert_equal 38, img.width
    end
  end

  def test_auto_rotate_from_memory
    data = File.new("test/portrait.jpg").binmode.read
    ImageScience.with_image_from_memory data do |img|
      assert_equal 50, img.height
      assert_equal 38, img.width
    end
  end
end
