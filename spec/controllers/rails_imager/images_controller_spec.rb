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
    response.headers["Expires"].should_not eq nil
    assert_equal response.headers["Last-Modified"], File.mtime(image_path).httpdate
  end
  
  it "invalid parameters" do
    expect {
      get :show, :use_route => :rails_imager, :id => "test.png", :image => {:invalid_param => "kasper"}
    }.to raise_error(ArgumentError)
  end
end
