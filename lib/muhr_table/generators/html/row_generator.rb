module MuhrTable
  class RowGenerator
    # these are both needed for content_tag to work
    include ActionView::Context
    include ActionView::Helpers::TagHelper

    def get_col_and_opts( block_value )
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

    def generate_column(row, col)
      td_options = col.opts.clone
      content = nil

      if col.block
        content, opts = get_col_and_opts( col.block.call(row) )
        td_options.merge!(opts)
      else
        content = row[col.name] 
      end
      content ||= (col.null_text || '').html_safe 
      content_tag :td, content, td_options 
    end

    def generate( muhr_init_data, muhr_table_settings, query_string_handler, row )
      tr_options = muhr_table_settings.row_options
      content_tag :tr, tr_options do
        buf="".html_safe
        muhr_table_settings.columns.each do |col| 
          buf << generate_column( row, col )
        end
        buf << "\n"
        buf
      end
    end
  end
end
