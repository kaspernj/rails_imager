# encoding: utf-8
class RailsImager::ImagesController < ApplicationController
  PARAMS_ARGS = [:width, :height, :smartsize, :maxwidth, :maxheight, :rounded_corners, :border, :border_color, :force]
  URI_REPLACES = {
    "%C3%A6" => "æ",
    "%C3%B8" => "ø",
    "%C3%A5" => "å"
  }

  def show
    set_and_validate_parameters
    set_path
    @mod_time = File.mtime(@full_path)
    generate_cache_name
    generate_cache if should_generate_cache?
    set_headers

    if not_modified? && !force?
      render nothing: true, status: :not_modified
    else
      send_file @cache_path, type: "image/png", disposition: "inline", filename: "picture.png"
    end
  end

private

  def set_path
    id = params[:id]
    URI_REPLACES.each do |key, val|
      id = id.gsub(key, val)
    end

    @path = "#{Rails.public_path}/#{id}"
    @full_path = File.realpath(@path)
    validate_path
  end

  def set_and_validate_parameters
    @image_params = params[:image] || {}
    @image_params.each do |key, val|
      raise ArgumentError, "Invalid parameter: '#{key}'." unless PARAMS_ARGS.map{ |param| param.to_s }.include?(key)
    end
  end

  def force?
    if @image_params[:force] && @image_params[:force].to_s == "true"
      return true
    else
      return false
    end
  end

  def not_modified?
    if request.headers["HTTP_IF_MODIFIED_SINCE"]
      if_mod_since_time = Datet.in(request.headers["HTTP_IF_MODIFIED_SINCE"]).time
    else
      if_mod_since_time = request.if_modified_since
    end

    if if_mod_since_time && if_mod_since_time.utc.to_s == @mod_time.utc.to_s
      return true
    end

    return false
  end

  def set_headers
    response.last_modified = @mod_time

    if force?
      response.headers["Expires"] = Time.now.httpdate
    else
      response.headers["Expires"] = 2.hours.from_now.httpdate
    end
  end

  def validate_path
    allowed_paths = RailsImager.config.allowed_paths

    allowed = false
    allowed_paths.each do |allowed_path|
      if @full_path.start_with?(allowed_path)
        allowed = true
        break
      end
    end

    raise ArgumentError, "Image wasn't in an allowed path: '#{@full_path}', allowed paths: #{allowed_paths}." unless allowed
  end

  def generate_cache_name
    @cache_name = ::Knj::Strings.sanitize_filename(@path)
    @cache_name << "__ARGS_"

    PARAMS_ARGS.each do |val|
      next if val.to_s == "force"
      @cache_name << "_#{val}-#{@image_params[val]}"
    end

    @cache_path = "#{cache_directory}/#{Digest::MD5.hexdigest(@cache_name)}.png"
  end

  def cache_directory
    RailsImager.cache_handler.path
  end

  def should_generate_cache?
    return true if force?

    if File.exists?(@cache_path) && File.size(@cache_path) > 0
      if File.mtime(@cache_path) < File.mtime(@full_path)
        return true
      else
        return false
      end
    else
      return true
    end
  end

  def generate_cache
    @image = ::Magick::Image.read(@full_path).first
    @image.format = "png"
    apply_image_changes
    @image.write(@cache_path)
  end

  #Create a new image-object based on the given image-object and the parameters.
  def apply_image_changes
    @image_width = @image.columns
    @image_height = @image.rows

    if @image_params[:width].to_i > 0
      @width = @image_params[:width].to_i
    else
      @width = @image_width
    end

    if @image_params[:height].to_i > 0
      @height = @image_params[:height].to_i
    else
      @height = @image_height
    end

    calcuate_sizes
    @image = @image.resize(@width, @height) if @width != @image_width || @height != @image_height
    apply_rounded_corners if @image_params[:rounded_corners]
  end

  def calcuate_sizes
    validate_and_set_smartsize if @image_params[:smartsize]
    validate_and_set_max_width
    validate_and_set_max_height
    calculate_missing_width if @image_params[:height] && !@image_params[:width]
    calculate_missing_height if @image_params[:width] && !@image_params[:height]
  end

  def calculate_missing_height
    @height = (@image_height.to_f / (@image_width.to_f / @width.to_f)).to_i
  end

  def calculate_missing_width
    @width = (@image_width.to_f / (@image_height.to_f / @height.to_f)).to_i
  end

  def validate_and_set_smartsize
    if @image_width > @image_height
      @width = @image_params[:smartsize].to_i
      calculate_missing_height
    else
      @height = @image_params[:smartsize].to_i
      calculate_missing_width
    end
  end

  def validate_and_set_max_width
    if @image_params[:maxwidth]
      maxwidth = @image_params[:maxwidth].to_i

      if @width > maxwidth
        @width = maxwidth
        calculate_missing_height
      end
    end
  end

  def validate_and_set_max_height
    if @image_params[:maxheight]
      maxheight = @image_params[:maxheight].to_i

      if @height > maxheight
        @height = maxheight
        calculate_missing_width
      end
    end
  end

  def apply_rounded_corners
    @image = @image.clone
    @image.format = "png" # Needs PNG format for transparency.
    args = {img: @image, radius: @image_params[:rounded_corners].to_i}

    if @image_params[:border] && @image_params[:border_color]
      args[:border] = @image_params[:border].to_i
      args[:border_color] = @image_params[:border_color]
    end

    ::Knj::Image.rounded_corners(args)
  end
end
