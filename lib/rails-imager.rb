require "RMagick"
require "knjrbfw"
require "tmpdir"

class RailsImager
  IMG_FROMpARAMS_ALLOWED_ARGS = [:image, :params]
  CACHENAME_FROMpARAMS_ALLOWED_ARGS = [:params]
  PARAMS_ARGS = [:width, :height, :smartsize, :maxwidth, :maxheight, :rounded_corners, :border, :border_color]
  INITIALIZE_ALLOWED_ARGS = [:cache_dir]
  
  DEFAULT_CACHE_DIR = "#{Dir.tmpdir}/rails-imager-cache"
  Dir.mkdir(DEFAULT_CACHE_DIR) if !Dir.exists?(DEFAULT_CACHE_DIR)
  
  DEFAULT_ARGS = {
    :cache_dir => DEFAULT_CACHE_DIR
  }
  
  def initialize(args = {})
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !INITIALIZE_ALLOWED_ARGS.include?(key)
    end
    
    @args = DEFAULT_ARGS.merge(args)
  end
  
  def img_from_params(args)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !IMG_FROMpARAMS_ALLOWED_ARGS.include?(key)
    end
    
    #Set up vars.
    img = args[:image]
    raise "No image given." if !img
    raise "Wrong image-object given: '#{img.class.name}'." if !img.is_a?(Magick::Image)
    
    params = args[:params]
    raise "No params given." if !params
    
    img_width = img.columns
    img_height = img.rows
    
    width = img_width
    height = img_height
    
    width = params[:width] if params[:width]
    height = params[:height] if params[:height]
    
    #Check arguments and manipulate image.
    if params[:smartsize]
      if img_width > img_height
        width = params[:smartsize].to_i
        height = (img_height.to_f / (img_width.to_f / width.to_f)).to_i
      else
        height = params[:smartsize].to_i
        width = (img_width.to_f / (img_height.to_f / height.to_f)).to_i
      end
    end
    
    if params[:maxwidth]
      maxwidth = params[:maxwidth].to_i
      
      if width > maxwidth
        height = (img_height.to_f / (img_width.to_f / maxwidth.to_f)).to_i
        width = maxwidth
      end
    end
    
    if params[:maxheight]
      maxheight = params[:maxheight].to_i
      
      if height > maxheight
        width = (img_width.to_f / (img_height.to_f / maxheight.to_f)).to_i
        height = maxheight
      end
    end
    
    if params[:width] and params[:height]
      width = params[:width].to_i
      height = params[:height].to_i
    end
    
    if width != img_width or height != img_height
      img = img.resize(width, height)
    end
    
    if params[:rounded_corners]
      img = img.clone
      args = {:img => img, :radius => params[:rounded_corners].to_i}
      
      if params[:border] and params[:border_color]
        args[:border] = params[:border].to_i
        args[:border_color] = params[:border_color]
      end
      
      Knj::Image.rounded_corners(args)
    end
    
    return img
  end
  
  def cachename_fromparams(args)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !CACHENAME_FROMpARAMS_ALLOWED_ARGS.include?(key)
    end
    
    params = args[:params]
    raise "No params was given." if !params
    
    name = ""
    PARAMS_ARGS.each do |val|
      name += "__" if !name.empty?
      name += "#{val}_#{params[val]}"
    end
    
    return name
  end
end