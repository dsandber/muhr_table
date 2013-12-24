module MuhrTable
  INPUT_PREFIX="muhr_f_"

  class QueryStringHandler
    attr_reader :sort_column, :sort_dir, :filter_hash

    def initialize(view)
      @view=view
      parse_query_string
    end

    def parse_query_string
      @query_hash = Rack::Utils.parse_nested_query @view.request.query_string
      @sort_dir=nil
      @sort_column=nil
      @filter_hash = build_filter_hash
      sort = @query_hash['sort']
      if sort        
        if sort[0]=='-'
          @sort_dir='desc'
          @sort_column=sort[1..-1]
        else
          @sort_dir='asc'
          @sort_column=sort
        end
      end
    end

    def get_filter_string_of( column )
      @query_hash[get_input_field_name_of( column ) ]
    end

    def get_input_field_name_of( column )
      "#{INPUT_PREFIX}#{column.name.to_s}"
    end

    def build_filter_hash
      parts={}
      @query_hash.each do |key,value| 
        if key.starts_with?( INPUT_PREFIX )
          name = key[INPUT_PREFIX.length..-1]         
          parts[name]=value if value!=""
        end        
      end
      parts
    end

    def get_form_url
      '?' + @view.request.query_string
    end

    # there may be a default sort in place that wasn't specified by the query string, so we need to pass in the current sort info
    def get_sort_href( column_name, current_sort_column, current_sort_dir )
      new_sort=column_name.to_s

      if new_sort==current_sort_column.to_s && current_sort_dir=='asc'
        new_sort = '-' + new_sort
      end      
      '?' + @query_hash.merge('sort'=>new_sort).to_query
    end
  end
end
