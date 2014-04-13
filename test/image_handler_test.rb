require "test_helper"
require "tmpdir"
require "fileutils"
require "datet"
require "RMagick"

class RailsImager::ImageHandlerTest < ActiveSupport::TestCase
  TEST_FILE = File.realpath("#{File.dirname(__FILE__)}/test.png")
  IMG = Magick::Image.read(TEST_FILE).first
  CACHE_DIR = "#{Dir.tmpdir}/rails-imager-test-cache"
  CACHE_PATH_SMARTSIZE_350 = "#{CACHE_DIR}/#{Knj::Strings.sanitize_filename(IMG.filename)}__ARGS___width-_height-_smartsize-350_maxwidth-_maxheight-_rounded_corners-_border-_border_color-_force-"
  FileUtils.rm_r(CACHE_DIR) if Dir.exists?(CACHE_DIR)
  Dir.mkdir(CACHE_DIR)
  RIMG = RailsImager::ImageHandler.new(:cache_dir => CACHE_DIR)
  
  MOD_TIME = File.mtime(TEST_FILE)
  PARAMS_350 = {:smartsize => 350}
  REQUEST_350 = Knj::Hash_methods.new({
    :headers => {
      "HTTP_IF_MODIFIED_SINCE" => MOD_TIME
    }
  })
  
  test "should do smartsizing" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:smartsize => "640"})
    assert_same newimg.columns, 640
    assert_same newimg.rows, 629
  end
  
  test "should do exact sizes" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:width => "640", :height => "480"})
    assert_same newimg.columns, 640
    assert_same newimg.rows, 480
  end
  
  test "should do rounded corners" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:smartsize => "640", :rounded_corners => "15", :border => "1", :border_color => "black"})
    
    assert_same newimg.columns, 640
    assert_same newimg.rows, 629
    
    #Test that corner pixels are transparent.
    4.times do |time|
      pixel = newimg.pixel_color(time, time)
      assert_same pixel.opacity, 65535
      
      pixel_orig = IMG.pixel_color(time, time)
      assert_same pixel_orig.opacity, 0
    end
    
    #Test that it got a black border.
    pixel = newimg.pixel_color(2, 5)
    assert_same pixel.red, 0
    assert_same pixel.green, 0
    assert_same pixel.blue, 0
    assert_same pixel.opacity, 0
    
    #Test that middle pixels are not transparent.
    100.upto(200) do |time|
      pixel = newimg.pixel_color(time, time)
      assert_same pixel.opacity, 0
      
      pixel_orig = IMG.pixel_color(time, time)
      assert_same pixel_orig.opacity, 0
    end
  end
  
  test "should do max width and height" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:maxwidth => 200})
    assert_same newimg.columns, 200
    assert_same newimg.rows, 196
    
    newimg = RIMG.img_from_params(:image => IMG, :params => {:maxheight => 200})
    assert_same newimg.rows, 200
    assert_same newimg.columns, 203
  end
  
  test "should be able to generate valid cache names" do
    cachename = RIMG.cachename_from_params(:fpath => '1\\2 3', :params => {:smartsize => 400})
    assert_equal cachename, "1_2_3__ARGS___width-_height-_smartsize-400_maxwidth-_maxheight-_rounded_corners-_border-_border_color-_force-"
  end
  
  test "should be able to generate cache" do
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => REQUEST_350, :params => PARAMS_350)
    RIMG.clear_cache
    res_from_fpath = RIMG.force_cache_from_request(:fpath => TEST_FILE, :request => REQUEST_350, :params => PARAMS_350)
    
    assert_equal res_from_img[:cachepath], CACHE_PATH_SMARTSIZE_350
    assert_equal res_from_fpath[:cachepath], CACHE_PATH_SMARTSIZE_350
    
    assert res_from_img[:generated]
    assert res_from_fpath[:generated]
    
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => REQUEST_350, :params => PARAMS_350)
    res_from_fpath = RIMG.force_cache_from_request(:fpath => TEST_FILE, :request => REQUEST_350, :params => PARAMS_350)
    
    assert_not res_from_img[:generated]
    assert_not res_from_fpath[:generated]
    
    RIMG.clear_cache
  end
  
  test "should send not modified" do
    #Generate fresh cache.
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => REQUEST_350, :params => PARAMS_350)
    assert_equal res_from_img[:cachepath], CACHE_PATH_SMARTSIZE_350
    assert res_from_img[:generated]
    
    #Generate again - expect not-modified.
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => REQUEST_350, :params => PARAMS_350)
    assert_not res_from_img[:generated]
    assert res_from_img[:not_modified]
    
    #Generate again - expected modified.
    day_ago = Datet.new.add_days(-1).time
    request_day_ago = Knj::Hash_methods.new(REQUEST_350.merge({:headers => {"HTTP_IF_MODIFIED_SINCE" => day_ago}}))
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => request_day_ago, :params => PARAMS_350)
    assert_not res_from_img[:not_modified]
    assert_not res_from_img[:generated]
    
    #Clear cache to reset.
    RIMG.clear_cache
  end
  
  test "should be able to clear the cache" do
    RIMG.clear_cache do |fpath|
      true
    end
    
    cache_size = 0
    Dir.foreach(CACHE_DIR) do |file|
      next if file == "." or file == ".."
      cache_size += 1
    end
    
    assert_same cache_size, 0
  end
end
