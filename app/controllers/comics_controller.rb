class ComicsController < ApplicationController
 
  before_filter :check_authentication, :only => [:new, :create, :manage, :recent, :edit, :update, :destroy]
    
  in_place_edit_for :comic, :description
  
  in_place_edit_for :page, :name
  
  def test
  end
  
  # GET /comics
  # GET /comics.xml
  def index
    @body_style = "comics"
    @comics = Comic.find(:all, :order => "last_updated DESC",  :conditions => ["live = 1 AND published_on <= ?", Time.now])

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @comics.to_xml }
    end
  end

  # GET /comics/1
  # GET /comics/1.xml
  def show
    begin
      @comic = Comic.find_by_alias_or_id(params[:id])
      @live_pages = @comic.live_pages
      @created_by = @comic.created_by
      
      raise ActiveRecord::RecordNotFound unless @comic.is_live?
      
      params[:page] ||= 1
      @page_number = params[:page].to_i
      
      if params[:page] && (@page_number > @live_pages.length || @page_number <= 0)
        flash[:notice] = "The page you are looking for could not be found."
        redirect_to comic_path(@comic.alias)
      else            
        @body_style = "pages"
        @total_pages = @live_pages.length
        
        @page = @live_pages[params[:page].to_i - 1]
        
        if params[:position]
          if params[:position] == "first"
            params[:page] = "1"
          elsif params[:position] == "latest"
            params[:page] = @live_pages.length
          end
        end
        
        @page_first = @page_number == 1
        @page_last = @page_number == @live_pages.length
        @page_previous = @page_number - 1
        @page_next = @page_number + 1
        
        increment_view @page
        
        @comments = @page.comments.find(:all, :include => [:created_by])
        
        @other_comics = @created_by.live_comics.find(:all, :limit => 3, :conditions => ["id != ?", @comic])
    
        respond_to do |format|
          format.html # show.rhtml
          format.xml  { render :xml => @comic.to_xml }
          format.rss do
           @pages = @comic.live_pages.find(:all, :order => "position DESC", :limit => 15 )
           render :action => "show.rxml", :layout => false
          end
        end
      
      end
        
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "The comic you are looking for could not be found."
      redirect_to home_path
    end  
  end
  
  def set_comic_name
    @comic = Comic.find(params[:id])
    previous_name = @comic.name
    @comic.name = params[:value]
    @comic.name = previous_name unless @comic.save
    render :text => @comic.name
  end
  
  def set_comic_alias
    @comic = Comic.find(params[:id])
    previous_alias = @comic.alias
    @comic.alias = params[:value]
    @comic.alias = previous_alias unless @comic.save
    render :text => @comic.alias
  end
  
  def first
    redirect_to :controller => :comics, :action => :show, :id => params[:id], :position => "first"
  end
  
  def latest
    redirect_to :controller => :comics, :action => :show, :id => params[:id], :position => "latest"  
  end
  
  def recent
    @comic = Comic.find_by_alias_or_id(params[:id])
    raise "Not signed in" unless User.current_user
    @user = User.current_user
    @user.reload
    @latest = @comic.new_pages(:since => @user.previous_signin)
    # raise comic_path(@comic.alias) if @latest.empty?
    if @latest.empty?
      flash[:notice] = "There are no new pages since your last visit."
      redirect_to comic_path(@comic.alias)
    else
      # raise @latest.first.id.inspect
      flash[:notice] = "Starting where you left off on your last visit."
      redirect_to page_path(@latest.first)
    end
  end

  # GET /comics/new
  def new
    @comic = Comic.new
  end
  
  def new_describe
    @comic = Comic.find(session[:comic_id])
    if request.get?
      raise "OMG" unless @comic
    elsif request.post?
      raise "couldnt save info" unless @comic.update_attributes(params[:comic])
      @comic.tag_with(params[:tags]) unless params[:tags].blank?
      raise "couldnt save tags" unless @comic.save
      redirect_to new_logo_path
    end
  end
  
  def new_logo
    session[:new_comic] = true
    @comic = Comic.find(session[:comic_id])
    if request.get?
      raise "OMG" unless @comic
    elsif request.post?
      unless params[:comic][:image].blank?
        raise "couldnt save logo" unless @comic.update_attributes(params[:comic])
        redirect_to new_logo_path
      else
        redirect_to new_pages_path(:comic => @comic.alias)
      end
    end      
  end
  
  def new_add_pages
    @start_index = 1
    @end_index = @start_index + 4
    if request.get?
      session[:comic_id] ||= params[:id]
      @comic = Comic.find(session[:comic_id])
    elsif request.post?
      @comic = Comic.find(session[:comic_id])
      
      # how many pages does @comic have now?
      session[:before_length] = @comic.pages.length
      session[:before_length] = 0 if session[:before_length] < 0
      
      for i in @start_index..@end_index
        page_data = params[eval(":page_#{i}")]
        unless page_data[:image].blank?
          @page = Page.new(page_data)
          @page.live = true
          @page.comic = @comic
          @comic.last_updated = Time.now
          raise "couldnt save #{page_data.inspect}" unless @page.save
        end
        @comic.save
        @comic.reload
        session[:after_length] = @comic.pages.length - 1
      end
      raise "No pages here either" if @comic.pages.empty?
      redirect_to new_edit_pages_path
    end
  end
    
  def new_edit_pages
    @comic = Comic.find(session[:comic_id])
    raise "OMG" unless @comic
    # @pages = @comic.pages[session[:before_length]..session[:after_length]]
    @pages = @comic.pages
    raise "No pages" if @pages.empty?
    if request.post?
      raise "Couldnt save page" unless Page.update(params[:page].keys, params[:page].values)
      flash[:notice] = "Your changes have been saved successfully."
    end
  end
  
  def new_publish
    @comic = Comic.find(session[:comic_id])
    if request.get?
      raise "OMG" unless @comic
    elsif request.post?
      params[:comic][:live] = true
      session[:new_comic] = nil
      raise "couldnt save info" unless @comic.update_attributes(params[:comic])
      redirect_to new_congrats_path
    end
  end
  
  def new_congratulations
    @comic = Comic.find(session[:comic_id])
  end
  
  def image_preview 
    @page = Page.find(params[:id])
    render :layout => false
  end
  

  # GET /comics/1;edit
  def edit
    @comic = Comic.find_by_alias(params[:id]) 
    @comic = Comic.find(params[:id]) unless @comic
  end

  # POST /comics
  # POST /comics.xml
  def create
    @comic = Comic.new(params[:comic])
    @comic.view_count = 0
        
    respond_to do |format|
      if @comic.save
        session[:comic_id] = @comic.id
        flash[:notice] = 'Comic was successfully created.'
        format.html { redirect_to new_page_path(:comic_id => @comic.alias) }
        format.xml  { head :created, :location => comic_url(@comic) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comic.errors.to_xml }
      end
    end
  end
  
  def manage
    @user = User.current_user
    @user = User.find(params[:id]) unless @user
    @comics = @user.comics
  end

  # PUT /comics/1
  # PUT /comics/1.xml
  def update
    @comic = Comic.find(params[:id])

    respond_to do |format|
      if @comic.update_attributes(params[:comic])
        flash[:notice] = 'Comic was successfully updated.'
        format.html { redirect_to home_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comic.errors.to_xml }
      end
    end
  end

  # DELETE /comics/1
  # DELETE /comics/1.xml
  def destroy
    @comic = Comic.find(params[:id])
    @comic.destroy

    respond_to do |format|
      format.html { redirect_to comics_url }
      format.xml  { head :ok }
    end
  end
  
  def add_tag
    @comic = Comic.find(params[:id])
    if request.get?
      render :update do |page|
        page.replace_html 'add_tag', :partial => 'add_tags'
      end
    else
      @comic.tag_with(params[:tags])
      render :update do |page|
        page.replace_html 'add_tag', :partial => 'add_tags'
        page.replace_html 'list_tags', :partial => 'list_tags'
      end
    end
  end

  def remove_tag
    @comic = Comic.find(params[:id])
    @comic.remove_tag(params[:tag])
    render :update do |page|
      page.replace_html 'list_tags', :partial => 'list_tags'
    end
  end
  
  private
  
  def increment_view page 
    unless session["page_#{@page.id}"]
      page.comic.view_count += 1
      session["page_#{@page.id}"] = true
      page.comic.save!
    end
    
    @user = User.current_user
    unless @user.nil?
      @view = @user.add_view(page)
    end
  end
end
