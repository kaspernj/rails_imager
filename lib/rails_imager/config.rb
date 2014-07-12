class RailsImager::Config
  attr_reader :allowed_paths

  def initialize
    @allowed_paths = []
    @allowed_paths << Rails.public_path.to_s if Rails.public_path.to_s.present?
  end
end
