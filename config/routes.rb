RailsImager::Engine.routes.draw do
  resources :images, :constraints => { :id => /.*/ }, :only => :show
end
