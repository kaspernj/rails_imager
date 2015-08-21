require 'spec_helper'

describe RailsImager::CacheHandler do
  it 'works' do
    File.open("#{RailsImager.cache_handler.path}/test.png", "w").close

    files = []
    RailsImager.cache_handler.clear do |file|
      files << file
    end

    expect(files).to eq ["#{RailsImager.cache_handler.path}/test.png"]
  end
end
