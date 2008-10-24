class Thumbnail < ActiveRecord::Base
  acts_as_attachment :content_type => :image, 
                 :storage => :file_system
                 
  validates_as_attachment                 
end
