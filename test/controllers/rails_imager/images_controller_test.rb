require 'test_helper'
require 'RMagick'

module RailsImager
  class ImagesControllerTest < ActionController::TestCase
    test "smartsize" do
      get :show, :use_route => :rails_imager, :id => "test.png", :image => {:smartsize => 200}
      assert_response :success
      assert "image/png", response.content_type
      
      img = ::Magick::Image.from_blob(response.body).first
      assert_same img.columns, 200
      assert_same img.rows, 196
    end
  end
end
