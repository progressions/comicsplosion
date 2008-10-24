class AddCopyright < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do
      add_column :comics, :copyright, :text
    end    
  end

  def self.down
    ActiveRecord::Base.connection.transaction do
      remove_column :comics, :copyright
    end
  end
end
