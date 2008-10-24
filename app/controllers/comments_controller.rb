class CommentsController < ApplicationController

  before_filter :find_comic
  before_filter :check_authentication, :except => [:index, :show, :view]

  # GET /comics/comic_alias/comments
  # GET /comics/comic_alias/comments.xml
  def index
    number_of_days = params[:days] ? params[:days].to_i : 2
    date = Time.now - number_of_days.days
    @comments = @comic.comments.find(:all, :order => "created_on DESC", :conditions => ["created_on >= ?", date])
    @comments_by_page = @comments.group_by {|comment| comment.page }

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @comments.to_xml }
      format.rss  { render :action => "comments_for_comic.rxml", :layout => false }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comic = Comic.find_by_alias_or_id(params[:comic_id])
    @comments = @comic.comments.find(:all, :group => "page_id", :order => "created_on DESC")
    @comments_by_page = @comments.group_by {|comment| comment.page }

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @comments.to_xml }
      format.rss  { render :action => "comments_for_comic.rxml", :layout => false }
    end
  end
  
  def view
    @comment = Comment.find(params[:id])
    @page = @comment.page
    @comic = @comment.comic
    
    respond_to do |format|
      format.html { redirect_to page_url(@page) }
      format.xml { render :xml => @comment.to_xml }
    end
  end
  
  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1;edit
  def edit
    @comment = Comment.find(params[:id])
    @page = @comment.page
  end

  # POST /comments
  # POST /comments.xml
  def create
    page = Page.find(params[:page])
    @comment = page.comments.new(params[:comment])
    page.comic.comments << @comment

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to comic_path(:id => @comic.alias, :page => page.locate) }
        format.xml  { head :created, :location => comment_url(@comment) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors.to_xml }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])
    @page = @comment.page

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to comic_path(:id => @comic.alias, :page => @page.locate) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors.to_xml }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @user = User.current_user
    @comment = Comment.find(params[:id])
    
    if @comic.created_by == @user || @comment.created_by == @user
      @comment.destroy
  
      respond_to do |format|
        format.html { 
          flash[:notice] = 'Comment was successfully deleted.'
          redirect_to comic_path(:id => @comic.alias, :page => @comment.page.locate) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "You can't do that."
      respond_to do |format|
        format.html { redirect_to comic_path(:id => @comic.alias, :page => @comment.page.locate) }
        format.xml  { head :ok }
      end
    end
  end
  
  private
  
  def find_comic
    @comic_id = params[:comic_id]
    redirect_to comics_path unless @comic_id
    @comic = Comic.find_by_alias_or_id(@comic_id)
  end
end
