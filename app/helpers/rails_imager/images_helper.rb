require "uri"

module RailsImager::ImagesHelper
  def rails_imager_p(path, args = {})
    if path.class.name == "Paperclip::Attachment"
      raise "Paperclip path does not start with public path: #{path.path}" unless path.path.to_s.start_with?(Rails.public_path.to_s)
      path_without_public = path.path.to_s.gsub("#{Rails.public_path}/", "")
      raise "Path didn't change '#{path.path}' - '#{path_without_public}'." if path.path.to_s == path_without_public
      path = path_without_public
    end
    
    newpath = ""
    
    if args[:url]
      args.delete(:url)
      newpath << "#{request.protocol}#{request.host_with_port}"
    elsif args[:mailer]
      args.delete(:mailer)
      
      if ActionMailer::Base.default_url_options[:protocol]
        newpath << ActionMailer::Base.default_url_options[:protocol]
      else
        newpath << "http://"
      end
      
      newpath << ActionMailer::Base.default_url_options[:host]
      
      if ActionMailer::Base.default_url_options[:port]
        newpath << ":#{ActionMailer::Base.default_url_options[:port]}"
      end
    end
    
    # Check for invalid parameters.
    args.each do |key, val|
      raise ArgumentError, "Invalid parameter: '#{key}'." unless RailsImager::ImageHandler::PARAMS_ARGS.include?(key)
    end
    
    
    
    newpath << "/rails_imager/images/"
    newpath << path
    
    if args && args.any?
      newpath << "?"
      
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
    end
    
    return newpath
  end
end
