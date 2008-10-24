# CalendarDateSelector
class ActionView::Helpers::InstanceTag
  def value_before_type_cast(object)
    if object.respond_to?(@method_name) and (object.send(@method_name).is_a?Time or object.send(@method_name).is_a?Date)
      object.send(@method_name).strftime('%Y-%m-%d %H:%M')
    else        
      self.class.value_before_type_cast(object, @method_name)
    end
  end
end

module ActionView::Helpers::FormTagHelper
  def date_select_tag(name, value, options = {})
    calendar_ref = "#{name}"
    <<-EOL
      <div id="dateBocks#{name}" class="dateBocks">
        <ul>
          <li>#{text_field_tag name, value, { :onChange => "magicDate('#{calendar_ref}');", :onKeyPress => "magicDateOnlyOnSubmit('#{calendar_ref}', event); return dateBocksKeyListener(event);", :onClick => "this.select();"} }</li>
          <li><img src='/images/icon-calendar.gif' alt='Calendar' id='#{calendar_ref}Button' style='cursor: pointer;' /></li>
          <li><img src='/images/icon-help.gif' alt='Help' id='#{calendar_ref}Help' /></li>
        </ul>
        <div id="dateBocksMessage#{name}"><div id="#{calendar_ref}Msg"></div></div>
        <script type="text/javascript">
          $('#{calendar_ref}Msg').innerHTML = calendarFormatString;
          Calendar.setup({
          inputField     :    "#{calendar_ref}",        // id of the input field
          ifFormat       :    calendarIfFormat,         // format of the input field
          button         :    "#{calendar_ref}Button",  // trigger for the calendar (button ID)
          help           :    "#{calendar_ref}Help",    // trigger for the help menu
          align          :    "Br",                     // alignment (defaults to "Bl")
          singleClick    :    true
         });
        </script>
      </div>
    EOL
  end

  def datetime_select_tag(name, value, options = {})
    calendar_ref = "#{name}"
    <<-EOL
      <div id="dateBocks#{name}" class="dateBocks">
        <ul>
          <li>#{text_field_tag name, value, { :onChange => "magicDate('#{calendar_ref}');", :onKeyPress => "magicDateOnlyOnSubmit('#{calendar_ref}', event); return dateBocksKeyListener(event);", :onClick => "this.select();"} }</li>
          <li><img src='/images/icon-calendar.gif' alt='Calendar' id='#{calendar_ref}Button' style='cursor: pointer;' /></li>
          <li><img src='/images/icon-help.gif' alt='Help' id='#{calendar_ref}Help' /></li>
        </ul>
        <div id="dateBocksMessage#{name}"><div id="#{calendar_ref}Msg"></div></div>
        <script type="text/javascript">
          $('#{calendar_ref}Msg').innerHTML = calendarFormatString;
          Calendar.setup({
          inputField     :    "#{calendar_ref}",        // id of the input field
          ifFormat       :    calendarIfFormatTime,     // format of the input field
          button         :    "#{calendar_ref}Button",  // trigger for the calendar (button ID)
          help           :    "#{calendar_ref}Help",    // trigger for the help menu
          align          :    "Br",                     // alignment (defaults to "Bl")
          singleClick    :    true,
          showsTime      :    true
         });
        </script>
      </div>
    EOL
  end
end

class ActionView::Helpers::FormBuilder  
  def date_select_with_datebocks(method, options = {})
    calendar_ref = "#{@object_name}_#{method}"
    <<-EOL
      <div id="dateBocks#{@object_name}_#{method}" class="dateBocks">
        <ul>
          <li>#{text_field method, { :onChange => "magicDate('#{calendar_ref}');", :onKeyPress => "magicDateOnlyOnSubmit('#{calendar_ref}', event); return dateBocksKeyListener(event);", :onClick => "this.select();"} }</li>
          <li><img src='/images/icon-calendar.gif' alt='Calendar' id='#{calendar_ref}Button' style='cursor: pointer;' /></li>
          <li><img src='/images/icon-help.gif' alt='Help' id='#{calendar_ref}Help' /></li>
        </ul>
        <div id="dateBocksMessage#{@object_name}_#{method}"><div id="#{calendar_ref}Msg"></div></div>
        <script type="text/javascript">
          $('#{calendar_ref}Msg').innerHTML = calendarFormatString;
          Calendar.setup({
          inputField     :    "#{calendar_ref}",        // id of the input field
          ifFormat       :    calendarIfFormat,         // format of the input field
          button         :    "#{calendar_ref}Button",  // trigger for the calendar (button ID)
          help           :    "#{calendar_ref}Help",    // trigger for the help menu
          align          :    "Br",                     // alignment (defaults to "Bl")
          singleClick    :    true
         });
        </script>
      </div>
    EOL
  end
  alias_method_chain :date_select, :datebocks

  def datetime_select_with_datebocks(method, options = {})
    calendar_ref = "#{@object_name}_#{method}"
    <<-EOL
      <div id="dateBocks#{@object_name}_#{method}" class="dateBocks">
        <ul>
          <li>#{text_field method, { :onChange => "magicDate('#{calendar_ref}');", :onKeyPress => "magicDateOnlyOnSubmit('#{calendar_ref}', event); return dateBocksKeyListener(event);", :onClick => "this.select();", :size => '17' } }</li>
          <li><img src='/images/icon-calendar.gif' alt='Calendar' id='#{calendar_ref}Button' style='cursor: pointer;' /></li>
          <li><img src='/images/icon-help.gif' alt='Help' id='#{calendar_ref}Help' /></li>
        </ul>
        <div id="dateBocksMessage#{@object_name}_#{method}"><div id="#{calendar_ref}Msg"></div></div>
        <script type="text/javascript">
          $('#{calendar_ref}Msg').innerHTML = calendarFormatString;
          Calendar.setup({
          inputField     :    "#{calendar_ref}",        // id of the input field
          ifFormat       :    calendarIfFormatTime,     // format of the input field
          button         :    "#{calendar_ref}Button",  // trigger for the calendar (button ID)
          help           :    "#{calendar_ref}Help",    // trigger for the help menu
          align          :    "Br",                     // alignment (defaults to "Bl")
          singleClick    :    true,
          showsTime      :    true
         });
        </script>
      </div>
    EOL
  end
  alias_method_chain :datetime_select, :datebocks
end
