class AddComicId < ActiveRecord::Migration
  def self.up
    add_column :pages, :comic_id, :integer
  end

  def self.down
    remove_column :pages, :comic_id
  end
end
