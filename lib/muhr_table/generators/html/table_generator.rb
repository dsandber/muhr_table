require_relative 'row_generator'
require_relative '../../constraints/constraint_builder'
require_relative '../../html_util'

module MuhrTable
  class HTMLTableGenerator
    # these are both needed for content_tag to work
    include ActionView::Context
    include ActionView::Helpers::TagHelper
    include HTMLUtil

    def initialize
      @row_generator = RowGenerator.new
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

    def get_filter_row_column( muhr_table_settings, backing, query_string_handler, column )
      content_tag :th do
        name = column.name
        allow_filtering = column.allow_filtering? && backing.allow_filtering?(name)
        filter_row_column_block = muhr_table_settings.filter_row_column_block
        filter_row_column_block.call( name, backing.type( name ), allow_filtering, query_string_handler ) if filter_row_column_block
      end 
    end

    def get_title_row( muhr_init_data, muhr_table_settings, query_string_handler )
      title_row_options = muhr_table_settings.title_row_options
      content_tag :tr, title_row_options do
        buf="".html_safe
        muhr_table_settings.columns.each do |column|
          buf += get_header_column( muhr_init_data, query_string_handler, column )
        end            
        buf
      end
    end
    
    def get_filter_row( muhr_init_data, muhr_table_settings, query_string_handler )
      filter_row = "".html_safe

      if muhr_table_settings.filter_row_on?
        filter_row_options = muhr_table_settings.filter_row_options
        filter_row = content_tag :tr, filter_row_options do
          muhr_table_settings.columns.each do |column|
            filter_row += get_filter_row_column( muhr_table_settings, muhr_init_data.backing, query_string_handler, column ) + "\n"
          end            
          filter_row
        end
      end
      filter_row
    end

    def get_table_header( muhr_init_data, muhr_table_settings, query_string_handler )
      thead_options = muhr_table_settings.thead_options

      content_tag :thead, thead_options do
        title_row = get_title_row( muhr_init_data, muhr_table_settings, query_string_handler )
        filter_row = get_filter_row( muhr_init_data, muhr_table_settings, query_string_handler )
        title_row + filter_row
      end
    end

    def set_backing_attributes( muhr_init_data, muhr_table_settings, query_string_handler )
      backing = muhr_init_data.backing
      backing.sort_column=query_string_handler.sort_column || muhr_init_data.sort_column
      backing.sort_dir=query_string_handler.sort_dir || muhr_init_data.sort_dir
      filter_hash = query_string_handler.build_filter_hash( muhr_table_settings )
      backing.constraints=ConstraintBuilder.create_constraints( backing, muhr_table_settings, filter_hash )
    end

    def get_table_body( muhr_init_data, muhr_table_settings, query_string_handler )
      tbody_options = muhr_table_settings.tbody_options
      set_backing_attributes( muhr_init_data, muhr_table_settings, query_string_handler )
      number_of_columns = muhr_table_settings.columns.length

      content_tag :tbody, tbody_options do
        buf=''.html_safe
        muhr_init_data.backing.each_row_on_page(muhr_table_settings) do |row|
          buf += muhr_table_settings.before_row_block.call(row, number_of_columns) if muhr_table_settings.before_row_block

          row_text = nil
          row_text = muhr_table_settings.during_row_block.call(row, number_of_columns) if muhr_table_settings.during_row_block
          if row_text == nil
            buf += @row_generator.generate( muhr_init_data, muhr_table_settings, query_string_handler, row )
          else
            buf += content_tag :tr, row_text
          end
          buf += "\n"
          buf += muhr_table_settings.after_row_block.call(row, number_of_columns) if muhr_table_settings.after_row_block
        end
        buf
      end
    end

    def generate( muhr_init_data, muhr_table_settings, query_string_handler )      
      table_options = muhr_table_settings.table_options      
      all = content_tag :table, table_options do
        header = get_table_header(muhr_init_data, muhr_table_settings, query_string_handler)
        body = get_table_body( muhr_init_data, muhr_table_settings, query_string_handler )
        header+body
      end

      if muhr_table_settings.filter_row_on?
        form_options = muhr_table_settings.form_options
        url = query_string_handler.get_form_url
        form_options.merge!( method:'get', action:url )
        submit = content_tag :input, '', {class:'muhr_table_submit', type:'submit', tabindex:'-1', value:"!!! You didn't include muhr_table.css !!!"}
        all = content_tag :form, all+submit, form_options
      end
      all
    end
  end
end
