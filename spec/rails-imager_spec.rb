require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require "tmpdir"
require "fileutils"
require "datet"

describe "RailsImager" do
  TEST_FILE = File.realpath("#{File.dirname(__FILE__)}/test.png")
  IMG = Magick::Image.read(TEST_FILE).first
  CACHE_DIR = "#{Dir.tmpdir}/rails-imager-test-cache"
  CACHE_PATH_SMARTSIZE_350 = "#{CACHE_DIR}/#{Knj::Strings.sanitize_filename(IMG.filename)}__ARGS___width-_height-_smartsize-350_maxwidth-_maxheight-_rounded_corners-_border-_border_color-"
  FileUtils.rm_r(CACHE_DIR) if Dir.exists?(CACHE_DIR)
  Dir.mkdir(CACHE_DIR)
  RIMG = RailsImager.new(:cache_dir => CACHE_DIR)
  
  MOD_TIME = File.mtime(TEST_FILE)
  REQUEST_350 = Knj::Hash_methods.new({
    :request_parameters => {:smartsize => 350},
    :if_modified_since => MOD_TIME
  })
  
  it "should do smartsizing" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:smartsize => "640"})
    newimg.columns.should eql(640)
    newimg.rows.should eql(629)
  end
  
  it "should do exact sizes" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:width => "640", :height => "480"})
    newimg.columns.should eql(640)
    newimg.rows.should eql(480)
  end
  
  it "should do rounded corners" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:smartsize => "640", :rounded_corners => "15", :border => "1", :border_color => "black"})
    
    newimg.columns.should eql(640)
    newimg.rows.should eql(629)
    
    #Test that corner pixels are transparent.
    4.times do |time|
      pixel = newimg.pixel_color(time, time)
      pixel.opacity.should eql(65535)
      
      pixel_orig = IMG.pixel_color(time, time)
      pixel_orig.opacity.should eql(0)
    end
    
    #Test that it got a black border.
    pixel = newimg.pixel_color(2, 5)
    pixel.red.should eql(0)
    pixel.green.should eql(0)
    pixel.blue.should eql(0)
    pixel.opacity.should eql(0)
    
    #Test that middle pixels are not transparent.
    100.upto(200) do |time|
      pixel = newimg.pixel_color(time, time)
      pixel.opacity.should eql(0)
      
      pixel_orig = IMG.pixel_color(time, time)
      pixel_orig.opacity.should eql(0)
    end
  end
  
  it "should do max width and height" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:maxwidth => 200})
    newimg.columns.should eql(200)
    newimg.rows.should eql(196)
    
    newimg = RIMG.img_from_params(:image => IMG, :params => {:maxheight => 200})
    newimg.rows.should eql(200)
    newimg.columns.should eql(203)
  end
  
  it "should be able to generate valid cache names" do
    cachename = RIMG.cachename_from_params(:fpath => '1\\2 3', :params => {:smartsize => 400})
    cachename.should eql("1_2_3__ARGS___width-_height-_smartsize-400_maxwidth-_maxheight-_rounded_corners-_border-_border_color-")
  end
  
  it "should be able to generate cache" do
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => REQUEST_350)
    RIMG.clear_cache
    res_from_fpath = RIMG.force_cache_from_request(:fpath => TEST_FILE, :request => REQUEST_350)
    
    res_from_img[:cachepath].should eql(CACHE_PATH_SMARTSIZE_350)
    res_from_fpath[:cachepath].should eql(CACHE_PATH_SMARTSIZE_350)
    
    res_from_img[:generated].should eql(true)
    res_from_fpath[:generated].should eql(true)
    
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => REQUEST_350)
    res_from_fpath = RIMG.force_cache_from_request(:fpath => TEST_FILE, :request => REQUEST_350)
    
    res_from_img[:generated].should eql(false)
    res_from_fpath[:generated].should eql(false)
    
    RIMG.clear_cache
  end
  
  it "should send not modified" do
    #Generate fresh cache.
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => REQUEST_350)
    res_from_img[:cachepath].should eql(CACHE_PATH_SMARTSIZE_350)
    res_from_img[:generated].should eql(true)
    
    #Generate again - expect not-modified.
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => REQUEST_350)
    res_from_img[:generated].should eql(false)
    res_from_img[:not_modified].should eql(true)
    
    #Generate again - expected modified.
    day_ago = Datet.new.add_days(-1).time
    request_day_ago = Knj::Hash_methods.new(REQUEST_350.merge({:if_modified_since => day_ago}))
    res_from_img = RIMG.force_cache_from_request(:image => IMG, :request => request_day_ago)
    res_from_img[:not_modified].should eql(false)
    res_from_img[:generated].should eql(false)
    
    #Clear cache to reset.
    RIMG.clear_cache
  end
  
  it "should be able to clear the cache" do
    RIMG.clear_cache do |fpath|
      true
    end
    
    cache_size = 0
    Dir.foreach(CACHE_DIR) do |file|
      next if file == "." or file == ".."
      cache_size += 1
    end
    
    cache_size.should eql(0)
  end
end
