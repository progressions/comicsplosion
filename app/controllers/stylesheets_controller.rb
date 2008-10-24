class StylesheetsController < ApplicationController
  layout nil
  session :off
  
  # serve dynamic stylesheet with name defined
  # by filename on incoming URL parameter :rcss
  def rcss
    # :rcssfile is defined in routes.rb
    if @stylefile = params[:rcssfile]
      #prep stylefile with relative path and correct extension
      @stylefile.gsub!(/.css$/, '')
      @stylefile = "/stylesheets/" + @stylefile + ".css.erb"
      render(:file => @stylefile, :use_full_path => true, :content_type => "text/css")
    else #no method/action specified
      render(:nothing => true, :status => 404)
    end #if @stylefile..
  end #rcss
end