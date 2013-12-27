class BootstrapDecorator
  include ActionView::Helpers::TagHelper

  def get_block
    Proc.new do |m|
      m.decorator_before_table do
        "<div class='wice-grid-container' id='grid'><div id='grid_title'></div>"
      end

      m.decorator_after_table do
        '</div>'
      end

      m.table class:'table-striped table-bordered table wice-grid' 
      m.title_row class:'wice-grid-title-row' 
      m.filter_row class:'wg-filter-row', id:'grid_filter_row'

      m.filter_row_column do |column_name, column_type, allow_filtering, query_string_handler|
        if allow_filtering
          if column_type==:datetime
            name_from = query_string_handler.get_input_field_name_of_range( column_name, true )
            name_to = query_string_handler.get_input_field_name_of_range( column_name, false )
            input_options={value:"", size:'10', type:'text', class:'muhr_date'}
            anchor_options={title:'Click to delete'}
            
            input1 = content_tag :input, '', input_options.merge( name: name_from )
            anchor1 = content_tag :a, '', anchor_options
            input2 = content_tag :input, '', input_options.merge( name: name_to )
            anchor2 = content_tag :a, '', anchor_options
            input1 + anchor1 + "<br/>".html_safe + input2 + anchor2
          else
            input_options = { class:'form-control input-sm', size:'8', type:'text' }
            filter_string = query_string_handler.get_input_field_value_of( column_name )
            input_options.merge!( value:filter_string ) if filter_string
            input_options.merge!( name:query_string_handler.get_input_field_name_of( column_name ) )
            content_tag :input, '', input_options
          end        
        else
          ""
        end 
      end
    end
  end
end
