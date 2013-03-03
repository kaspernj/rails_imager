require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require "tmpdir"
require "fileutils"

describe "RailsImager" do
  TEST_FILE = File.realpath("#{File.dirname(__FILE__)}/test.png")
  IMG = Magick::Image.read(TEST_FILE).first
  CACHE_DIR = "#{Dir.tmpdir}/rails-imager-test-cache"
  FileUtils.rm_r(CACHE_DIR) if Dir.exists?(CACHE_DIR)
  Dir.mkdir(CACHE_DIR)
  RIMG = RailsImager.new(:cache_dir => CACHE_DIR)
  
  it "should do smartsizing" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:smartsize => 640})
    newimg.columns.should eql(640)
    newimg.rows.should eql(629)
  end
  
  it "should do exact sizes" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:width => 640, :height => 480})
    newimg.columns.should eql(640)
    newimg.rows.should eql(480)
  end
  
  it "should do rounded corners" do
    newimg = RIMG.img_from_params(:image => IMG, :params => {:smartsize => 640, :rounded_corners => 15})
    
    newimg.columns.should eql(640)
    newimg.rows.should eql(629)
    
    #Test that corner pixels are transparent.
    2.times do |time|
      pixel = newimg.pixel_color(time, time)
      pixel.opacity.should eql(65535)
      
      pixel_orig = IMG.pixel_color(time, time)
      pixel_orig.opacity.should eql(0)
    end
    
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
end
