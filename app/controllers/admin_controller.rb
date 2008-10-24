class AdminController < ApplicationController
  layout 'signin', :only => [:signin]
  
  before_filter :check_authentication, :except => [:signin, :show, :reset_passwords]

  # GET /signin
  # POST /signin
  # 
  # If the method is post, signs in the given username and password.
  # 
  def signin
    if request.post?
      u = User.authenticate(params[:user][:username], params[:user][:password])
      session[:user] = u.id if u
      user = User.find(session[:user]) if session[:user]
      if user
        user.previous_signin = user.last_signin.blank? ? Time.now : user.last_signin
        user.last_signin = Time.now        
        user.save
        if session[:intended_action]
          redirect_to session[:intended_action]  
        else 
          redirect_to home_path
        end
      else
        flash[:notice] = "Your username or password was invalid. Please try again."
      end
    end
  end
  
  def signout
    session[:user] = nil
    session[:intended_action] = nil
    redirect_to home_path
  end
  
  # BACKDOORS
  # TODO: REMOVE ALL THESE IN PRODUCTIONS
  
  
  # backdoor to reset all users' passwords to their username 
    def reset_passwords 
    @users = User.find(:all) 
    for user in @users do
      user.new_password = false
      user.password = "secret"
      user.email = "#{user.username}@email.com"
      user.save
    end 
    flash[:notice] = "WARNING: User passwords have been reset to 
  'secret'. This is for development ONLY." 
    redirect_to home_path 
  end
  
  # backdoor to reset all users to "Reader" and "Creator" permissions
  def reset_permissions
    @users = User.find(:all)
    @reader = Role.find_by_name("Reader")
    @creator = Role.find_by_name("Creator")
    @users.each do |user|
      Permission.new(:user => @user, :role => @reader)
      Permission.new(:user => @user, :role => @creator)
    end
    flash[:notice] = "WARNING: User permissions have been set to Reader and Creator. This is for development ONLY." 
    redirect_to home_path 
  end
  
  # backdoor to assign all comments' comic attribute
  def reset_comments
    @comments = Comment.find(:all)
    @comments.each do |comment|
      comment.comic = comment.page.comic
      if comment.created_by.nil? or comment.updated_by.nil? 
        comment.created_by = comment.page.created_by
        comment.updated_by = comment.page.updated_by
      end
      comment.save
    end
    flash[:notice] = "All comments' comic values have been set."
    redirect_to home_path
  end
end
