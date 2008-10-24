class AddAliases < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do
      add_column :users, :alias, :string, :limit => 100
      add_column :comics, :alias, :string, :limit => 100
    end
  end

  def self.down
    ActiveRecord::Base.connection.transaction do
      remove_column :users, :alias
      remove_column :comics, :alias
    end
  end
end
