[![Code Climate](https://codeclimate.com/github/kaspernj/rails_imager.png)](https://codeclimate.com/github/kaspernj/rails_imager)
[![Test Coverage](https://codeclimate.com/github/kaspernj/rails_imager/coverage.png)](https://codeclimate.com/github/kaspernj/rails_imager)
[![Build Status](https://travis-ci.org/kaspernj/rails_imager.svg?branch=master)](https://travis-ci.org/kaspernj/rails_imager)

# RailsImager

Generate images on the fly with caching by giving simple parameters to URL's.

## Install

First add RailsImager to your gemfile and bundle it:

```ruby
gem 'rails_imager'
```

The mount RailsImager in your "routes.rb":

```ruby
YourApp::Application.routes.draw do
  ...
  mount RailsImager::Engine => "/rails_imager"
  ...
end
```

Add this to the `ApplicationHelper` in order to gain access to the `rails_imager_p`-helper method for generating URL's easy.
```ruby
module ApplicationHelper
  include RailsImager::ImagesHelper
end
```

## Capistrano

If you use Capistrano to deploy, you probably symlink the "public/system" directory, in order to share uploaded images between releases. This screws with RailsImager's security only to serve images from the "public"-folder.

You can solve this by adding the following initializer in "config/initializers/rails_imager.rb":
```ruby
# Add public/system to path, because it is symlinked through Capistrano on deployed servers.
RailsImager.config.allowed_paths << File.realpath("#{Rails.public_path.to_s}/system")
```

## Usage

Now you can use RailsImager to convert any image located in the public-folder like so:

### rails_imager_p helper method

Usage with a static image in the public folder:
```erb
<%= image_tag rails_imager_p("/picture.jpg", :smartsize => 200, :rounded_corners => 10, :border => 1, :border_color => "black") %>
```

Usage with a Paperclip attachment on a model:
```erb
<%= image_tag rails_imager_p(user.picture, :smartsize => 200) %>
```

### Rounded corners

Makes the corners of an image round.
```
http://localhost:3000/rails_imager/images/filename.png?rounded_corners=5
```

### Smart image sizing

Resize the longest side of an image to have a given size:
```
http://localhost:3000/rails_imager/images/filename.png?smartsize=200
```

### Normal sizing

Resize the given size but keep the aspect of the image:
```
http://localhost:3000/rails_imager/images/filename.png?width=200
```
```
http://localhost:3000/rails_imager/images/filename.png?height=200
```

### Max sizing

Sets the maximum size of an image but keeps the aspect:
```
http://localhost:3000/rails_imager/images/filename.png?maxwidth=200
```
```
http://localhost:3000/rails_imager/images/filename.png?maxheight=200
```

### Border

Give the image a border of a certain size and/or with a certain color.
```
http://localhost:3000/rails_imager/images/filename.png?border=2&border_color=black
```


## Caching

RailsImager performs various forms of caching, to avoid having to do too much work in regards to the actual resizing.

It caches the results as temp-files, so it never has to render the same image with the same parameters again.

It sends out the appropriate headers to the client, so the client doesn't read the same image again and again.


## License
This project uses MIT-LICENSE.
