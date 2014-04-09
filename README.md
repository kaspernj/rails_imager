# RailsImager

Generate images on the fly with caching by giving simple parameters to URL's.

## Install

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

## Usage

Now you can use RailsImager to convert any image located in the public-folder like so:

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

## License
This project uses MIT-LICENSE.
