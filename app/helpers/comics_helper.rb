module ComicsHelper
  def info_link image, link_text, destination, options={}
    link_to(image_tag(image) + " " + link_text, destination, options)
  end
end
