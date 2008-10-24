class Favorite < ActiveRecord::Base
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
  belongs_to :page
  belongs_to :comic
  
  validates_uniqueness_of :page_id, :scope => "created_by"
  validates_uniqueness_of :created_by, :scope => "page_id"
  
  # A Favorite object is only live if:
  # - its comic is live, and
  # - its page is live.
  # 
  def is_live?
    self.comic.is_live? and self.page.is_live?
  end
end
