require_dependency "rails_imager/application_controller"

class RailsImager::ImagesController < ApplicationController
  def show
    rimger = RailsImager::ImageHandler.new
    
    image_params = params[:image] || {}
    
    image_path = "#{Rails.public_path}/#{params[:id]}"
    image_path = File.realpath(image_path)
    validate_path(image_path)
    
    image = Magick::Image.read(image_path).first
    image = rimger.img_from_params(:image => image, :params => image_params)
    
    send_data image.to_blob, :type => "image/png", :disposition => "inline"
  end
  
private
  
  def validate_path(image_path)
    raise "No such file: '#{image_path}'." unless File.exists?(image_path)
    raise "Image wasn't in the public folder: '#{image_path}'." unless image_path.start_with?(Rails.public_path.to_s)
  end
end
