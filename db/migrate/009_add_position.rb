class AddPosition < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do
      add_column :comics, :live, :boolean
      add_column :comics, :published_on, :datetime
      add_column :pages, :position, :integer
    end
  end

  def self.down
    ActiveRecord::Base.connection.transaction do
      remove_column :comics, :live
      remove_column :comics, :published_on
      remove_column :pages, :position
    end
  end
end
