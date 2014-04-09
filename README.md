= RailsImager

Generate images on the fly with caching by giving simple parameters to URL's.

First add RailsImager to your gemfile and bundle it:

```ruby
gem 'rails_imager'
```

The mount RailsImager in your "routes.rb":

```
YourApp::Application.routes.draw do
  ...
  mount RailsImager::Engine => "/rails_imager"
  ...
end
```

Now you can use RailsImager to convert any image located in the public-folder like so:
```
http://localhost:3000/rails_imager/images/filename.png?rounded_corners=5&smartsize=150
```

This project rocks and uses MIT-LICENSE.
