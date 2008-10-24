class AddByline < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do 
      add_column :comics, :byline, :string
      add_column :comics, :schedule, :string
    end
  end

  def self.down
    ActiveRecord::Base.connection.transaction do
      remove_column :comics, :byline
      remove_column :comics, :schedule
    end
  end
end
