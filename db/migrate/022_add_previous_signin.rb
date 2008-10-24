class AddPreviousSignin < ActiveRecord::Migration
  def self.up
    add_column :users, :previous_signin, :datetime
  end

  def self.down
    remove_column :users, :previous_signin
  end
end
