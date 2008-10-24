$:.unshift(File.dirname(__FILE__) + '/../lib')

require File.dirname(__FILE__) + '/../../../../config/environment'
require 'test/unit'
# require 'rubygems'
require 'breakpoint'
require 'calendar_date_selector'
require 'action_controller/test_process'

ActionController::Base.logger = nil
ActionController::Base.ignore_missing_templates = false
ActionController::Routing::Routes.reload rescue nil

silence_warnings do
  Post = Struct.new("Post", :title, :author_name, :body, :written_on, :published_on)
  Post.class_eval do
    alias_method :title_before_type_cast, :title unless respond_to?(:title_before_type_cast)
    alias_method :body_before_type_cast, :body unless respond_to?(:body_before_type_cast)
    alias_method :author_name_before_type_cast, :author_name unless respond_to?(:author_name_before_type_cast)
    alias_method :written_on_before_type_cast, :written_on unless respond_to?(:written_on_before_type_cast)
    alias_method :published_on_before_type_cast, :published_on unless respond_to?(:published_on_before_type_cast)    
  end
end

class CalendarDateSelectorTest < Test::Unit::TestCase
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::CaptureHelper
  
  def setup
    @post = Post.new
    def @post.errors() Class.new{ def on(field) field == "author_name" end }.new end

    def @post.id; 123; end
    def @post.id_before_type_cast; 123; end

    @post.title       = "Hello World"
    @post.author_name = ""
    @post.body        = "Back to the hill and over it again!"
    @post.written_on  = Date.new(2007, 4, 20)
    @post.published_on = Time.local(2007, 4, 20, 4, 20)

    @controller = Class.new do
      def url_for(options, *parameters_for_method_reference)
        "http://www.example.com"
      end
    end
    @controller = @controller.new
  end
  
  def test_a_date_object_sucka
    _erbout = ''

    form_for(:post, @post) do |f|
      _erbout.concat f.text_field(:title)
      _erbout.concat f.text_area(:body)
      _erbout.concat f.date_select(:written_on)
    end
    
    expected = <<-EOF
<form action=\"http://www.example.com\" method=\"post\"><input id=\"post_title\" name=\"post[title]\" size=\"30\" type=\"text\" value=\"Hello World\" /><textarea cols=\"40\" id=\"post_body\" name=\"post[body]\" rows=\"20\">Back to the hill and over it again!</textarea>      <div id=\"dateBockspost_written_on\" class=\"dateBocks\">\n        <ul>\n          <li><input id=\"post_written_on\" name=\"post[written_on]\" onChange=\"magicDate('post_written_on');\" onClick=\"this.select();\" onKeyPress=\"magicDateOnlyOnSubmit('post_written_on', event); return dateBocksKeyListener(event);\" size=\"30\" type=\"text\" value=\"2007-04-20\" /></li>\n          <li><img src='/images/icon-calendar.gif' alt='Calendar' id='post_written_onButton' style='cursor: pointer;' /></li>\n          <li><img src='/images/icon-help.gif' alt='Help' id='post_written_onHelp' /></li>\n        </ul>\n        <div id=\"dateBocksMessagepost_written_on\"><div id=\"post_written_onMsg\"></div></div>\n        <script type=\"text/javascript\">\n          $('post_written_onMsg').innerHTML = calendarFormatString;\n          Calendar.setup({\n          inputField     :    \"post_written_on\",        // id of the input field\n          ifFormat       :    calendarIfFormat,         // format of the input field\n          button         :    \"post_written_onButton\",  // trigger for the calendar (button ID)\n          help           :    \"post_written_onHelp\",    // trigger for the help menu\n          align          :    \"Br\",                     // alignment (defaults to \"Bl\")\n          singleClick    :    true\n         });\n        </script>\n      </div>\n</form>
    EOF
    assert_equal expected.gsub(/\s+/m, ' ').strip, _erbout.gsub(/\s+/m, ' ')
  end
  
  def test_a_time_object_sucka
    _erbout = ''

    form_for(:post, @post) do |f|
      _erbout.concat f.text_field(:title)
      _erbout.concat f.text_area(:body)
      _erbout.concat f.date_select(:published_on)
    end

    expected = <<-EOF
<form action=\"http://www.example.com\" method=\"post\"><input id=\"post_title\" name=\"post[title]\" size=\"30\" type=\"text\" value=\"Hello World\" /><textarea cols=\"40\" id=\"post_body\" name=\"post[body]\" rows=\"20\">Back to the hill and over it again!</textarea> <div id=\"dateBockspost_published_on\" class=\"dateBocks\"> <ul> <li><input id=\"post_published_on\" name=\"post[published_on]\" onChange=\"magicDate('post_published_on');\" onClick=\"this.select();\" onKeyPress=\"magicDateOnlyOnSubmit('post_published_on', event); return dateBocksKeyListener(event);\" size=\"30\" type=\"text\" value=\"2007-04-20\" /></li> <li><img src='/images/icon-calendar.gif' alt='Calendar' id='post_published_onButton' style='cursor: pointer;' /></li> <li><img src='/images/icon-help.gif' alt='Help' id='post_published_onHelp' /></li> </ul> <div id=\"dateBocksMessagepost_published_on\"><div id=\"post_published_onMsg\"></div></div> <script type=\"text/javascript\"> $('post_published_onMsg').innerHTML = calendarFormatString; Calendar.setup({ inputField : \"post_published_on\", // id of the input field ifFormat : calendarIfFormat, // format of the input field button : \"post_published_onButton\", // trigger for the calendar (button ID) help : \"post_published_onHelp\", // trigger for the help menu align : \"Br\", // alignment (defaults to \"Bl\") singleClick : true }); </script> </div> </form>
    EOF
    assert_equal expected.gsub(/\s+/m, ' ').strip, _erbout.gsub(/\s+/m, ' ')
  end
  
  def test_a_time_object_in_a_regular_form
    _erbout = ''

    form_tag do
      _erbout.concat date_select_tag(:published_on, @post.published_on)
    end
    expected = <<-EOF
<form action=\"http://www.example.com\" method=\"post\">      <div id=\"dateBockspublished_on\" class=\"dateBocks\">\n        <ul>\n          <li><input id=\"published_on\" name=\"published_on\" onChange=\"magicDate('published_on');\" onClick=\"this.select();\" onKeyPress=\"magicDateOnlyOnSubmit('published_on', event); return dateBocksKeyListener(event);\" type=\"text\" value=\"Fri Apr 20 04:20:00 CDT 2007\" /></li>\n          <li><img src='/images/icon-calendar.gif' alt='Calendar' id='published_onButton' style='cursor: pointer;' /></li>\n          <li><img src='/images/icon-help.gif' alt='Help' id='published_onHelp' /></li>\n        </ul>\n        <div id=\"dateBocksMessagepublished_on\"><div id=\"published_onMsg\"></div></div>\n        <script type=\"text/javascript\">\n          $('published_onMsg').innerHTML = calendarFormatString;\n          Calendar.setup({\n          inputField     :    \"published_on\",        // id of the input field\n          ifFormat       :    calendarIfFormat,         // format of the input field\n          button         :    \"published_onButton\",  // trigger for the calendar (button ID)\n          help           :    \"published_onHelp\",    // trigger for the help menu\n          align          :    \"Br\",                     // alignment (defaults to \"Bl\")\n          singleClick    :    true\n         });\n        </script>\n      </div>\n</form>    
    EOF
    
    assert_equal expected.gsub(/\s+/m, ' ').strip, _erbout.gsub(/\s+/m, ' ')
  end
end