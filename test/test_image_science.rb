require 'test/unit/testcase'
require 'test/unit' if $0 == __FILE__
require 'image_science'

class TestImageScience < Test::Unit::TestCase
  def deny x; assert ! x; end

  def setup
    @path = 'test/pix.png'
    @tmppath = 'test/pix-tmp.png'
    @h = @w = 50
  end

  def teardown
    File.unlink @tmppath if File.exist? @tmppath
  end

  def test_class_with_image
    ImageScience.with_image @path do |img|
      assert_kind_of ImageScience, img
      assert_equal @h, img.height
      assert_equal @w, img.width
      assert img.save(@tmppath)
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal @h, img.height
      assert_equal @w, img.width
    end
  end

  def test_class_with_image_missing
    assert_raises TypeError do
      ImageScience.with_image @path + "nope" do |img|
        flunk
      end
    end
  end

  def test_class_with_image_missing_with_img_extension
    assert_nil ImageScience.with_image("nope#{@path}") do |img|
      flunk
    end
  end

  def test_resize
    ImageScience.with_image @path do |img|
      img.resize(25, 25) do |thumb|
        assert thumb.save(@tmppath)
      end
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_floats
    ImageScience.with_image @path do |img|
      img.resize(25.2, 25.7) do |thumb|
        assert thumb.save(@tmppath)
      end
    end

    assert File.exists?(@tmppath)

    ImageScience.with_image @tmppath do |img|
      assert_kind_of ImageScience, img
      assert_equal 25, img.height
      assert_equal 25, img.width
    end
  end

  def test_resize_zero
    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(0, 25) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    deny File.exists?(@tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(25, 0) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    deny File.exists?(@tmppath)
  end

  def test_resize_negative
    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(-25, 25) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    deny File.exists?(@tmppath)

    assert_raises ArgumentError do
      ImageScience.with_image @path do |img|
        img.resize(25, -25) do |thumb|
          assert thumb.save(@tmppath)
        end
      end
    end

    deny File.exists?(@tmppath)
  end
end
