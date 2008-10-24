class UsersController < ApplicationController

  before_filter :check_authentication, :except => [:index, :show, :new, :create, :favorites]

  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @users.to_xml }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find_by_alias(params[:id]) 
    @user = User.find(params[:id]) unless @user
    @comics = @user.live_comics

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user.to_xml }
    end
  end
  
  # GET /:id/favorites
  def favorites
    @user = User.find_by_alias(params[:id])
    @favorites = @user.favorites
    
    @favorites.map! { |fave| fave if fave.is_live? }
  end
  
  def add_favorite
    if @request.post?
      @user = User.find_by_alias(params[:user_id])
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1;edit
  def edit
    @page_title = "Manage your profile"
    @body_style = "user"
    @user = User.find(params[:id])
  end
  
  def change_password
    @page_title = "Change your password"
    @body_style = "user"
    @user = User.find(params[:id])
     
    if request.post?
      @user.change_password(params['user']['password'], params['user']['password_confirmation'])
      respond_to do |format|
        if @user.save
          flash[:notice] = 'User was successfully updated.'
          format.html { redirect_to user_url(@user) }
          format.xml  { head :ok }
        else
          format.html { render :action => "change_password" }
          format.xml  { render :xml => @user.errors.to_xml }
        end
      end
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.last_signin = Time.now

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { session[:user] = @user.id; redirect_to user_url(@user) }
        format.xml  { head :created, :location => user_url(@user) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.xml  { head :ok }
    end
  end
 
end

