require 'test_helper'

class RailsImager::ImagesHelperTest < ActionView::TestCase
  test "#rails_imager_path" do
    path = rails_imager_p("test.png", :smartsize => 200)
    assert_equal "/rails_imager/images/test.png/?image[smartsize]=200", path
  end
end
