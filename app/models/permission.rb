class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  
  def validate
    @user = self.user
    @role = Role.find(self.role_id)
    unless @user.permissions.find_by_role_id(self.role_id).blank?
      errors.add_to_base("#{@user.fullname} already has the permission #{@role.name}")
    end
  end
end
