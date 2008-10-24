class AddMoreAttachmentFu < ActiveRecord::Migration
  def self.up
    add_column :users, :parent_id,  :integer
    add_column :users, :content_type, :string
    add_column :users, :filename, :string    
    add_column :users, :thumbnail, :string 
    add_column :users, :size, :integer
    add_column :users, :width, :integer
    add_column :users, :height, :integer
    
    
    add_column :comics, :parent_id,  :integer
    add_column :comics, :content_type, :string
    add_column :comics, :filename, :string    
    add_column :comics, :thumbnail, :string 
    add_column :comics, :size, :integer
    add_column :comics, :width, :integer
    add_column :comics, :height, :integer
  end

  def self.down
    remove_column :users, :parent_id
    remove_column :users, :content_type
    remove_column :users, :filename 
    remove_column :users, :thumbnail
    remove_column :users, :size
    remove_column :users, :width
    remove_column :users, :height
    
    remove_column :comics, :parent_id
    remove_column :comics, :content_type
    remove_column :comics, :filename 
    remove_column :comics, :thumbnail
    remove_column :comics, :size
    remove_column :comics, :width
    remove_column :comics, :height
  end
end
