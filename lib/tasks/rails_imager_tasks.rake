namespace :rails_imager do
  desc "Explaining what the task does"
  task clear_cache: :environment do
    puts "Beginning to clear cache"

    count = 0
    RailsImager.cache_handler.clear do |full_path|
      puts "Deleted #{full_path}"
      count += 1
    end

    puts "Cleared #{count} files"
  end
end
