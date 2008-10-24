class Comment < ActiveRecord::Base
  belongs_to :page
  belongs_to :comic
  
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by"
  
  validates_presence_of :content
end
