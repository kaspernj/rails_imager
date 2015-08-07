require "uri"

module RailsImager::ImagesHelper
  def rails_imager_p(path, args = {})
    path = path_from_arg(path)

    if args.delete(:url)
      newpath = "#{request.protocol}#{request.host_with_port}"
    elsif args.delete(:mailer)
      newpath = mailer_pre_path
    else
      newpath = ""
    end

    check_arguments(args)

    newpath << "#{RailsImager.config.path}/images/"
    newpath << path

    if args && args.any?
      newpath << "?"
      newpath << url_encoded_arguments(args)
    end

    return newpath
  end

private

  def mailer_pre_path
    if ActionMailer::Base.default_url_options[:protocol]
      pre_path = ActionMailer::Base.default_url_options[:protocol]
    else
      pre_path = "http://"
    end

    pre_path << ActionMailer::Base.default_url_options[:host]

    if ActionMailer::Base.default_url_options[:port]
      pre_path << ":#{ActionMailer::Base.default_url_options[:port]}"
    end

    return pre_path
  end

  def url_encoded_arguments(args)
    path = ""

    first = true
    args.each do |key, val|
      if first
        first = false
      else
        path << "&"
      end

      realkey = "image[#{key}]"

      path << URI.encode(realkey)
      path << "="
      path << URI.encode(val.to_s)
    end

    return path
  end

  def check_arguments(args)
    # Check for invalid parameters.
    args.each do |key, val|
      raise ArgumentError, "Invalid parameter: '#{key}'." unless RailsImager::ImagesController::PARAMS_ARGS.include?(key)
    end
  end

  def path_from_arg(path)
    if path.class.name == "Paperclip::Attachment"
      # Ignore check when running tests - its normal to store Paperclip::Attachment's elsewhere for easy cleanup
      if Rails.env.test?
        return path.path.to_s
      else
        raise "Paperclip path does not start with public path: #{path.path}" unless path.path.to_s.start_with?(Rails.public_path.to_s)
        path_without_public = path.path.to_s.gsub("#{Rails.public_path}/", "")
        raise "Path didn't change '#{path.path}' - '#{path_without_public}'." if path.path.to_s == path_without_public
        return path_without_public
      end
    elsif path.is_a?(String)
      return path
    else
      raise "Unknown argument: #{path_from_arg}"
    end
  end
end
