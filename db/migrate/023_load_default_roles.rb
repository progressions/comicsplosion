require 'active_record/fixtures'

class LoadDefaultRoles < ActiveRecord::Migration
  def self.up
    down
    
    directory = File.join(File.dirname(__FILE__), "data")
    Fixtures.create_fixtures(directory, "roles")
    Fixtures.create_fixtures(directory, "permissions")
  end

  def self.down
    Role.delete_all
    Permission.delete_all
  end
end
