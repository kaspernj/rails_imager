require "uri"

module RailsImager::ImagesHelper
  def rails_imager_p(path, args = {})
    if path.class.name == "Paperclip::Attachment"
      raise "Paperclip path does not start with public path." unless path.path.to_s.start_with?(Rails.public_path.to_s)
      path_without_public = path.path.to_s.gsub("#{Rails.public_path}/", "")
      raise "Path didn't change '#{path.path}' - '#{path_without_public}'." if path.path.to_s == path_without_public
      path = path_without_public
    end
    
    # Check for invalid parameters.
    args.each do |key, val|
      raise ArgumentError, "Invalid parameter: '#{key}'." unless RailsImager::ImageHandler::PARAMS_ARGS.include?(key)
    end
    
    newpath = "/rails_imager/images/"
    newpath << URI.encode(path)
    newpath << "/?"
    
    first = true
    args.each do |key, val|
      if first
        first = false
      else
        newpath << "&"
      end
      
      realkey = "image[#{key}]"
      
      newpath << URI.encode(realkey.to_s)
      newpath << "="
      newpath << URI.encode(val.to_s)
    end
    
    return newpath
  end
end
