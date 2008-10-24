class BlogsController < ApplicationController
  # GET /blogs
  # GET /blogs.xml
  def index
    @blogs = Blog.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @blogs.to_xml }
    end
  end

  # GET /blogs/1
  # GET /blogs/1.xml
  def show
    @blog = Blog.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @blog.to_xml }
    end
  end

  # GET /blogs/new
  def new
    @comic = Comic.find_by_alias(params[:id]) 
    @comic = Comic.find(params[:id]) unless @comic
    @blog = Blog.new
  end

  # GET /blogs/1;edit
  def edit
    @blog = Blog.find(params[:id])
  end

  # POST /blogs
  # POST /blogs.xml
  def create
    @comic = Comic.find_by_alias(params[:id]) 
    @comic = Comic.find(params[:id]) unless @comic
    @blog = Blog.new(params[:blog])

    respond_to do |format|
      if @blog.save
        flash[:notice] = 'Blog was successfully created.'
        format.html { redirect_to blog_url(@blog) }
        format.xml  { head :created, :location => blog_url(@blog) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blog.errors.to_xml }
      end
    end
  end

  # PUT /blogs/1
  # PUT /blogs/1.xml
  def update
    @blog = Blog.find(params[:id])

    respond_to do |format|
      if @blog.update_attributes(params[:blog])
        flash[:notice] = 'Blog was successfully updated.'
        format.html { redirect_to blog_url(@blog) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog.errors.to_xml }
      end
    end
  end

  # DELETE /blogs/1
  # DELETE /blogs/1.xml
  def destroy
    @blog = Blog.find(params[:id])
    @blog.destroy

    respond_to do |format|
      format.html { redirect_to blogs_url }
      format.xml  { head :ok }
    end
  end
end
