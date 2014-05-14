require 'spec_helper'
require 'RMagick'

describe RailsImager::ImagesController do
  it "smartsize" do
    get :show, :use_route => :rails_imager, :id => "test.png", :image => {:smartsize => 200}
    assert_response :success
    assert "image/png", response.content_type
    img = ::Magick::Image.from_blob(response.body).first
    img.columns.should eq 200
    img.rows.should eq 196
  end
  
  it "cache via expires" do
    get :show, :use_route => :rails_imager, :id => "test.png", :image => {:smartsize => 200, :rounded_corners => 8}
    image_path = "#{Rails.public_path}/test.png"
    assert_not_nil response.headers["Expires"], "Didn't find expires header in response."
    assert_equal response.headers["Last-Modified"], File.mtime(image_path).httpdate
  end
  
  it "invalid parameters" do
    assert_raise ArgumentError do
      get :show, :use_route => :rails_imager, :id => "test.png", :image => {:invalid_param => "kasper"}
    end
  end
end
