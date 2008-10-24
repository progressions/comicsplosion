class AddViewCount < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do
      add_column :pages, :views, :integer, :default => 0
      add_column :comics, :views, :integer, :default => 0
    end
  end

  def self.down
    ActiveRecord::Base.connection.transaction do
      remove_column :pages, :views
      remove_column :comics, :views
    end
  end
end
