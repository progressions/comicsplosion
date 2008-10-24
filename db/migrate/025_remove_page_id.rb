class RemovePageId < ActiveRecord::Migration
  def self.up
    remove_column :views, :page_id
  end

  def self.down
    add_column :views, :page_id, :integer
  end
end
