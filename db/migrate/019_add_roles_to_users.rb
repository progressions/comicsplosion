class AddRolesToUsers < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.transaction do      
      create_table :permissions do |t|
        t.column :user_id, :integer, :null => false
        t.column :role_id, :integer, :null => false
      end
      
      create_table :roles do |t|
        t.column :name, :string
      end      
    end
  end

  def self.down    
    ActiveRecord::Base.connection.transaction do
      drop_table :permissions
      drop_table :roles
    end
  end
end
