require "RMagick"
require "knjrbfw"
require "tmpdir"

class RailsImager
  IMG_FROMpARAMS_ALLOWED_ARGS = [:image, :params]
  PARAMS_ARGS = [:width, :height, :smartsize, :maxwidth, :maxheight, :rounded_corners, :border, :border_color]
  INITIALIZE_ALLOWED_ARGS = [:cache_dir]
  
  #This is the default cache which is plased in the temp-directory, so it will be cleared on every restart. It should always exist.
  DEFAULT_CACHE_DIR = "#{Dir.tmpdir}/rails-imager-cache"
  Dir.mkdir(DEFAULT_CACHE_DIR) if !Dir.exists?(DEFAULT_CACHE_DIR)
  
  #Default arguments unless something else is given in constructor.
  DEFAULT_ARGS = {
    :cache_dir => DEFAULT_CACHE_DIR
  }
  
  #Initializes the RailsImager.
  def initialize(args = {})
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !INITIALIZE_ALLOWED_ARGS.include?(key)
    end
    
    @args = DEFAULT_ARGS.merge(args)
  end
  
  #Create a new image-object based on the given image-object and the parameters.
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
  
  CACHENAME_FROM_PARAMS_ALLOWED_ARGS = [:params, :image, :fpath]
  #Returns the path to a cached object based on the given filepath, image and request-parameters.
  def cachename_from_params(args)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !CACHENAME_FROM_PARAMS_ALLOWED_ARGS.include?(key)
    end
    
    params = args[:params]
    raise "No params was given." if !params
    
    if args[:image] and !args[:image].filename.to_s.strip.empty?
      name = Knj::Strings.sanitize_filename(args[:image].filename)
    elsif args[:fpath]
      name = Knj::Strings.sanitize_filename(args[:fpath])
    else
      raise "No image or fpath was given."
    end
    
    name << "__ARGS__"
    
    PARAMS_ARGS.each do |val|
      name += "_" if !name.empty?
      name += "#{val}-#{params[val]}"
    end
    
    return name
  end
  
  FORCE_CACHE_FROM_PARAMS_ALLOWED_ARGS = [:fpath, :image, :request]
  #Checks if a cache-file is created for the given filepath or image. If not then it will be created. If the cache-object is too old, then it will updated. Then returns the path to the cache-object in the end.
  def force_cache_from_request(args)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !FORCE_CACHE_FROM_PARAMS_ALLOWED_ARGS.include?(key)
    end
    
    img = nil
    
    if args[:fpath] and !args[:fpath].to_s.strip.empty?
      fpath = args[:fpath]
    elsif args[:image] and !args[:image].filename.to_s.strip.empty?
      fpath = args[:image].filename
      img = args[:image]
    else
      raise "No image or filename was given."
    end
    
    request = args[:request]
    raise "Invalid request: '#{request.class.name}'." if !request
    params = request.request_parameters
    raise "No parameters on that request: '#{params.class.name}'." if !params
    
    mod_time = File.mtime(fpath)
    cachename = self.cachename_from_params(:fpath => fpath, :params => params)
    cachepath = "#{@args[:cache_dir]}/#{cachename}"
    not_modified = false
    
    if !File.exists?(cachepath) or File.mtime(cachepath) < File.mtime(fpath)
      should_generate = true
    else
      should_generate = false
    end
    
    if should_generate
      img = Magick::Image.read(fpath).first if !img
      img = self.img_from_params(:image => img, :params => params)
      img.write(cachepath)
    else
      if_mod_since_time = request.if_modified_since
      not_modified = true if if_mod_since_time and if_mod_since_time.utc.to_s == mod_time.utc.to_s
    end
    
    return {
      :cachepath => cachepath,
      :generated => should_generate,
      :not_modified => not_modified,
      :mod_time => mod_time
    }
  end
  
  #Yields every cache-file to the block. If the block returns true, then the cache-file will be deleted. If no block is given all the cache will be deleted.
  def clear_cache(&blk)
    Dir.foreach(@args[:cache_dir]) do |file|
      next if file == "." or file == ".."
      fn = "#{@args[:cache_dir]}/#{file}"
      next if !File.file?(fn)
      
      if blk == nil
        res = true
      else
        res = yield(fn)
      end
      
      File.unlink(fn) if res == true
    end
  end
end