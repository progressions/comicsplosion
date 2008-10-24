class AddComicToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :comic_id, :integer
  end

  def self.down
    remove_column :comments, :comic_id
  end
end
