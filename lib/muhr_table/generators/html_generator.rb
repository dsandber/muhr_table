require_relative '../constraints/constraint_builder'
require_relative '../html_util'
require_relative "../option_checker"

module MuhrTable
  class HTMLGenerator
    # these are both needed for content_tag to work
    include MuhrTable::OptionChecker
    include ActionView::Context
    include ActionView::Helpers::TagHelper
    include HTMLUtil

    def initialize( muhr_init_data, muhr_table_settings, query_string_handler, options )
      ensure_valid_options options, [:filter_row_on, :pagination_status_on]

      @muhr_init_data = muhr_init_data
      @muhr_table_settings = muhr_table_settings
      @query_string_handler = query_string_handler
      @filter_row_on = options[:filter_row_on] != false
      @pagination_status_on = options[:pagination_status_on] != false
    end

    def title_row
      buf="".html_safe
      @muhr_table_settings.columns.each do |column|
        buf += get_header_column( @muhr_init_data, @query_string_handler, column )
      end            
      buf
    end
    
    def filter_row
      filter_row = "".html_safe
      @muhr_table_settings.columns.each do |column|
        filter_row += get_filter_row_column( @muhr_table_settings, @muhr_init_data.backing, @query_string_handler, column ) + "\n"
      end            
      filter_row
    end

    def form_url
      @query_string_handler.get_form_url
    end

    def filter_row?
      @filter_row_on
    end

    def pagination_status?
      @pagination_status_on
    end

    def rows
      number_of_columns = @muhr_table_settings.columns.length

      buf=''.html_safe
      @muhr_init_data.backing.each_row_on_page do |row|
        buf += @muhr_table_settings.before_row_block.call(row, number_of_columns) if @muhr_table_settings.before_row_block
        
        row_text = nil
        row_text = @muhr_table_settings.during_row_block.call(row, number_of_columns) if @muhr_table_settings.during_row_block
        if row_text == nil
          buf += generate_row( row )
        else
          buf += content_tag :tr, row_text
        end
        buf += "\n"
        buf += @muhr_table_settings.after_row_block.call(row, number_of_columns) if @muhr_table_settings.after_row_block
      end
      buf
    end

    def num_columns
      @muhr_table_settings.columns.length
    end

    private

    def get_row_col_and_opts( block_value )
      col="".html_safe
      opts={}

      if block_value
        if block_value.is_a?(Array)
          raise MuhrException.new('column block array must be of length 2') unless block_value.length==2
          col = block_value[0]
          opts = block_value[1]
        else
          col = block_value.to_s          
        end
      end
      [col,opts]
    end

    def generate_row_column(row, col)
      td_options = col.opts.clone
      content = nil

      if col.block
        content, opts = get_row_col_and_opts( col.block.call(row) )
        td_options.merge!(opts)
      else
        content = row[col.name] 
      end
      content ||= (col.null_text || '').html_safe 
      content_tag :td, content, td_options 
    end

    def generate_row( row )
      tr_options = @muhr_table_settings.row_options
      content_tag :tr, tr_options do
        buf="".html_safe
        @muhr_table_settings.columns.each do |col| 
          buf << generate_row_column( row, col )
        end
        buf << "\n"
        buf
      end
    end

    def current_sort_column_and_sort_dir( muhr_init_data, query_string_handler )
      sort_column = query_string_handler.sort_column
      sort_dir = query_string_handler.sort_dir

      if not sort_column
        sort_column = muhr_init_data.sort_column
        sort_dir = muhr_init_data.sort_dir || 'asc'
      end
      [sort_column, sort_dir]
    end

    def get_header_column( muhr_init_data, query_string_handler, column )
      content_tag :th do
        if column.allow_sorting?
          current_sort_column, current_sort_dir = current_sort_column_and_sort_dir( muhr_init_data, query_string_handler )
          href = query_string_handler.get_sort_href( column.name, current_sort_column, current_sort_dir )
          sort = nil
          sort = current_sort_dir if column.name.to_s==current_sort_column.to_s
          options = {href:href}
          options[:class]=sort if sort
          content_tag :a, options do
            column.display_name
          end
        else
          column.display_name
        end
      end
    end

    def get_filter_row_column_internal( column_name, column_type, query_string_handler )
      if column_type==:datetime
        name_from  = query_string_handler.get_input_field_name_of_range( column_name, true )
        value_from = query_string_handler.get_input_field_value_of_range( column_name, true )
        name_to    = query_string_handler.get_input_field_name_of_range( column_name, false )
        value_to   = query_string_handler.get_input_field_value_of_range( column_name, false )
        
        input_options={type:'text', class:'muhr_input_date'}
        
        input1 = content_tag :input, '', input_options.merge( name: name_from, value: value_from )
        input2 = content_tag :input, '', input_options.merge( name: name_to, value: value_to )
        [input1 + " to " + input2, {class:'muhr_filter_column'}]
      else
        input_options = { class:'muhr_input_string', type:'text' }
        filter_string = query_string_handler.get_input_field_value_of( column_name ) || ''
        input_options.merge!( value:filter_string, name:query_string_handler.get_input_field_name_of( column_name ) )
        content_tag :input, '', input_options
      end        
    end

    def get_filter_row_column( muhr_table_settings, backing, query_string_handler, column )
      text=''
      options={}

      name = column.name
      allow_filtering = column.allow_filtering? && backing.allow_filtering?(name)
      if allow_filtering
        filter_row_column_block = muhr_table_settings.filter_row_column_block
        if filter_row_column_block
          text, options = filter_row_column_block.call( name, backing.type( name ), query_string_handler ) 
        else
          text, options = get_filter_row_column_internal( name, backing.type( name ), query_string_handler ) 
        end
        options = {} unless options
      end

      content_tag :th, text, options
    end
  end
end
