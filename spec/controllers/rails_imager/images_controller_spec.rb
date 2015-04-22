# encoding: utf-8

require 'spec_helper'
RailsImager.require_rmagick

describe RailsImager::ImagesController do
  before do
    @routes = RailsImager::Engine.routes

    RailsImager.config do |config|
      config.allowed_paths << File.realpath("#{File.dirname(__FILE__)}/../../dummy/public")
    end
  end

  it "smartsize" do
    get :show, id: "test.png", image: {smartsize: 200}
    assert_response :success
    assert "image/png", response.content_type
    img = ::Magick::Image.from_blob(response.body).first
    img.columns.should eq 200
    img.rows.should eq 196
  end

  it "cache via expires" do
    get :show, id: "test.png", image: {smartsize: 200, rounded_corners: 8}
    image_path = "#{Rails.public_path}/test.png"
    response.headers["Expires"].should_not eq nil
    assert_equal response.headers["Last-Modified"], File.mtime(image_path).httpdate
  end

  it "should not accept invalid parameters" do
    expect {
      get :show, id: "test.png", image: {invalid_param: "kasper"}
    }.to raise_error(ArgumentError)
  end

  it "should do exact sizes" do
    get :show, id: "test.png", image: {width: "640", height: "480"}
    img = ::Magick::Image.from_blob(response.body).first
    img.columns.should eq 640
    img.rows.should eq 480
  end

  it "should work correctly with special characters" do
    get :show, id: "test_æ_%C3%B8_å.png", image: {width: 640, height: 480}
    response.should be_success
    img = ::Magick::Image.from_blob(response.body).first
    img.columns.should eq 640
    img.rows.should eq 480
  end

  it "should do rounded corners" do
    get :show, id: "test.png", image: {smartsize: "640", rounded_corners: "15", border: "1", border_color: "black"}

    old_file_path = File.realpath("#{File.dirname(__FILE__)}/../../test.png")
    old_img = Magick::Image.read(old_file_path).first

    img = ::Magick::Image.from_blob(response.body).first
    img.columns.should eq 640
    img.rows.should eq 629

    #Test that corner pixels are transparent.
    unless RUBY_ENGINE == "jruby"
      4.times do |time|
        pixel = img.pixel_color(time, time)
        pixel.opacity.should eq 65535

        pixel_orig = old_img.pixel_color(time, time)
        pixel_orig.opacity.should eq 0
      end

      #Test that it got a black border.
      pixel = img.pixel_color(2, 5)
      pixel.red.should eq 0
      pixel.green.should eq 0
      pixel.blue.should eq 0
      pixel.opacity.should eq 0

      #Test that middle pixels are not transparent.
      100.upto(200) do |time|
        pixel = img.pixel_color(time, time)
        pixel.opacity.should eq 0

        pixel_orig = old_img.pixel_color(time, time)
        pixel_orig.opacity.should eq 0
      end
    end
  end

  it "should do max width" do
    get :show, id: "test.png", image: {maxwidth: 200}
    img = ::Magick::Image.from_blob(response.body).first
    img.columns.should eq 200
    img.rows.should eq 196
  end

  it "should do max height" do
    get :show, id: "test.png", image: {maxheight: 200}
    img = ::Magick::Image.from_blob(response.body).first
    img.rows.should eq 200
    img.columns.should eq 203
  end

  it "should be able to generate valid cache names" do
    get :show, id: "test.png", image: {smartsize: 400}
    assigns(:cache_name).should include "test.png__ARGS__width-_height-_smartsize-400_maxwidth-_maxheight-_rounded_corners-_border-_border_color-"
  end

  it "should be able to generate cache" do
    unless RUBY_ENGINE == "jruby"
      get :show, id: "test.png", image: {smartsize: 400, force: true}
      assigns(:image).should_not eq nil
      controller.instance_variable_set(:@image, nil)
      get :show, id: "test.png", image: {smartsize: 400}
      response.code.should eq "200"
      assigns(:image).should eq nil
    end
  end

  it "should send not modified" do
    old_file_path = File.realpath("#{File.dirname(__FILE__)}/../../test.png")

    get :show, id: "test.png", image: {smartsize: 350}
    request.headers["If-Modified-Since"] = File.mtime(old_file_path)
    get :show, id: "test.png", image: {smartsize: 350}

    response.code.should eq "304"
  end

  it "should not allow paths that havent specifically been allowed" do
    expect {
      get :show, id: "/../config.ru", image: {smartsize: 200}
    }.to raise_error(ArgumentError)
  end
end
