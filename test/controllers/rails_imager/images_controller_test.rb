require 'test_helper'
require 'RMagick'

module RailsImager
  class ImagesControllerTest < ActionController::TestCase
    test "smartsize" do
      get :show, :use_route => :rails_imager, :id => "test.png", :image => {:smartsize => 200}
      assert_response :success
      assert "image/png", response.content_type
      img = ::Magick::Image.from_blob(response.body).first
      assert_equal img.columns, 200
      assert_equal img.rows, 196
    end
    
    test "cache via expires" do
      get :show, :use_route => :rails_imager, :id => "test.png", :image => {:smartsize => 200, :rounded_corners => 8}
      image_path = "#{Rails.public_path}/test.png"
      
      puts "Headers: #{response.headers.to_a}"
      
      assert_not_nil response.headers["Expires"], "Didn't find expires header in response."
      assert_equal response.headers["Last-Modified"], File.mtime(image_path).httpdate
    end
    
    test "invalid parameters" do
      assert_raise ArgumentError do
        get :show, :use_route => :rails_imager, :id => "test.png", :image => {:invalid_param => "kasper"}
      end
    end
  end
end
