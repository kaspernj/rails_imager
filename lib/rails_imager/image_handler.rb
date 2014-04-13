require "RMagick"
require "knjrbfw"
require "tmpdir"
require "datet"

class RailsImager::ImageHandler
  PARAMS_ARGS = [:width, :height, :smartsize, :maxwidth, :maxheight, :rounded_corners, :border, :border_color, :force]
  
  #This is the default cache which is plased in the temp-directory, so it will be cleared on every restart. It should always exist.
  DEFAULT_CACHE_DIR = "#{Dir.tmpdir}/rails-imager-cache"
  Dir.mkdir(DEFAULT_CACHE_DIR) unless Dir.exists?(DEFAULT_CACHE_DIR)
  
  #Default arguments unless something else is given in constructor.
  DEFAULT_ARGS = {
    :cache_dir => DEFAULT_CACHE_DIR
  }
  
  INITIALIZE_ALLOWED_ARGS = [:cache_dir]
  #Initializes the RailsImager.
  def initialize(args = {})
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." unless INITIALIZE_ALLOWED_ARGS.include?(key)
    end
    
    @args = DEFAULT_ARGS.merge(args)
  end
  
  IMG_FROM_PARAMS_ALLOWED_ARGS = [:image, :params]
  #Create a new image-object based on the given image-object and the parameters.
  def img_from_params(args)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." unless IMG_FROM_PARAMS_ALLOWED_ARGS.include?(key)
    end
    
    #Set up vars.
    img = args[:image]
    raise "No image given." unless img
    raise "Wrong image-object given: '#{img.class.name}'." unless img.is_a?(Magick::Image)
    
    params = args[:params]
    raise "No params given." unless params
    
    img_width = img.columns
    img_height = img.rows
    
    width = img_width
    height = img_height
    
    width = params[:width].to_i if params[:width].to_i > 0
    height = params[:height].to_i if params[:height].to_i > 0
    
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
    
    if params[:width] && !params[:height]
      height = (img_height.to_f / (img_width.to_f / width.to_f)).to_i
    elsif params[:height] && !params[:width]
      width = (img_width.to_f / (img_height.to_f / height.to_f)).to_i
    elsif params[:width] && params[:height]
      width = params[:width].to_i
      height = params[:height].to_i
    end
    
    if width != img_width || height != img_height
      img = img.resize(width, height)
    end
    
    if params[:rounded_corners]
      img = img.clone
      img.format = "png" # Needs PNG format for transparency.
      args = {:img => img, :radius => params[:rounded_corners].to_i}
      
      if params[:border] && params[:border_color]
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
      raise "Invalid argument: '#{key}'." unless CACHENAME_FROM_PARAMS_ALLOWED_ARGS.include?(key)
    end
    
    params = args[:params]
    raise "No params was given." unless params
    
    if args[:image] && !args[:image].filename.to_s.strip.empty?
      name = Knj::Strings.sanitize_filename(args[:image].filename)
    elsif args[:fpath]
      name = Knj::Strings.sanitize_filename(args[:fpath])
    else
      raise "No image or fpath was given."
    end
    
    name << "__ARGS__"
    
    PARAMS_ARGS.each do |val|
      name += "_" unless name.empty?
      name += "#{val}-#{params[val]}"
    end
    
    return name
  end
  
  FORCE_CACHE_FROM_PARAMS_ALLOWED_ARGS = [:fpath, :image, :request, :params]
  # Checks if a cache-file is created for the given filepath or image. If not then it will be created. If the cache-object is too old, then it will updated. Then returns the path to the cache-object in the end.
  def force_cache_from_request(args)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !FORCE_CACHE_FROM_PARAMS_ALLOWED_ARGS.include?(key)
    end
    
    img = nil
    
    if args[:fpath] && !args[:fpath].to_s.strip.empty?
      fpath = args[:fpath]
    elsif args[:image] && !args[:image].filename.to_s.strip.empty?
      fpath = args[:image].filename
      img = args[:image]
    else
      raise "No image or filename was given."
    end
    
    request = args[:request]
    raise "Invalid request: '#{request.class.name}'." if !request
    params = args[:params]
    raise "No parameters on that request: '#{params.class.name}'." if !params
    
    mod_time = File.mtime(fpath)
    cachename = self.cachename_from_params(:fpath => fpath, :params => params)
    cachepath = "#{@args[:cache_dir]}/#{cachename}"
    not_modified = false
    headers = request.headers
    
    if !File.exists?(cachepath) || File.mtime(cachepath) < File.mtime(fpath)
      should_generate = true
    else
      should_generate = false
    end
    
    if should_generate
      img = ::Magick::Image.read(fpath).first unless img
      img.format = "png"
      img = self.img_from_params(:image => img, :params => params)
      img.write(cachepath)
    else
      if_mod_since_time = nil
      if headers["HTTP_IF_MODIFIED_SINCE"]
        if_mod_since_time = Datet.in(headers["HTTP_IF_MODIFIED_SINCE"]).time
      else
        if_mod_since_time = request.if_modified_since
      end
      
      not_modified = true if if_mod_since_time && if_mod_since_time.utc.to_s == mod_time.utc.to_s
    end
    
    return {
      :cachepath => cachepath,
      :generated => should_generate,
      :not_modified => not_modified,
      :mod_time => mod_time,
    }
  end
  
  HANDLE_ALLOWED_ARGS = [:fpath, :image, :controller, :params]
  #Automatically handles the image with generation, cache control and more.
  def handle(args)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." unless HANDLE_ALLOWED_ARGS.include?(key)
    end
    
    controller = args[:controller]
    raise "No controller was given." unless controller
    request = controller.request
    params = args[:params]
    raise "No params was given." unless params
    
    if args[:image]
      fpath = args[:image].filename
    elsif args[:fpath]
      fpath = args[:fpath]
    end
    
    raise "No filepath was given." if !fpath
    res = self.force_cache_from_request(:fpath => fpath, :request => request, :params => params)
    
    if params[:force] && params[:force] != "0"
      force = true
    else
      force = false
    end
    
    controller.response.headers["Last-Modified"] = res[:mod_time].httpdate
    
    if force
      controller.response.headers["Expires"] = Time.now.httpdate
    else
      controller.response.headers["Expires"] = 2.hours.from_now.httpdate
    end
    
    if res[:not_modified] && !force
      controller.render :nothing => true, :status => "304 Not Modified"
    else
      controller.send_file res[:cachepath], :type => "image/png", :disposition => "inline", :filename => "picture.png"
    end
  end
  
  #Yields every cache-file to the block. If the block returns true, then the cache-file will be deleted. If no block is given all the cache will be deleted.
  def clear_cache(&blk)
    Dir.foreach(@args[:cache_dir]) do |file|
      next if file == "." || file == ".."
      fn = "#{@args[:cache_dir]}/#{file}"
      next unless File.file?(fn)
      
      if blk == nil
        res = true
      else
        res = yield(fn)
      end
      
      File.unlink(fn) if res == true
    end
  end
end
