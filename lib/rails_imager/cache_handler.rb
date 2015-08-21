class RailsImager::CacheHandler
  def initialize(args = {})
    @args = args
  end

  def path
    unless @path
      require "tmpdir"
      @path = "#{Dir.tmpdir}/rails-imager-cache"
      Dir.mkdir(@path) unless Dir.exist?(@path)
    end

    return @path
  end

  def clear(args = {})
    Dir.foreach(path) do |file|
      next if file == "." || file == ".."
      next unless file.end_with?(".png")

      full_path = "#{path}/#{file}"
      File.unlink(full_path)
      yield full_path if block_given?
    end
  end
end
