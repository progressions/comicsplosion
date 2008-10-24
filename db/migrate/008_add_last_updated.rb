class AddLastUpdated < ActiveRecord::Migration
  def self.up
    add_column :comics, :last_updated, :datetime
  end

  def self.down
    remove_column :comics, :last_updated
  end
end
