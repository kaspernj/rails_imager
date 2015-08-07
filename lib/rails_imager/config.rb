class RailsImager::Config
  attr_reader :allowed_paths
  attr_accessor :path

  def initialize
    @allowed_paths = []
    @allowed_paths << Rails.public_path.to_s if Rails.public_path.to_s.present?

    @path = "/rails_imager"
  end
end
