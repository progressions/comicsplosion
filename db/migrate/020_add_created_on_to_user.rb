class AddCreatedOnToUser < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do
      add_column :users, :created_on, :datetime
      add_column :users, :updated_on, :datetime
    end
  end

  def self.down
    ActiveRecord::Base.connection.transaction do
      remove_column :users, :created_on
      remove_column :users, :updated_on
    end
  end
end
