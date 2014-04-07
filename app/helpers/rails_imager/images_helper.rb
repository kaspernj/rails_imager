require "uri"

module RailsImager::ImagesHelper
  def rails_imager_p(path, args = {})
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
