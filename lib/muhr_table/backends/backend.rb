module MuhrTable
  class Backend
    attr_writer :sort_column, :sort_dir, :constraints
    attr_accessor :page, :records_per_page
    attr_reader :total_pages

    def allow_filtering?( column )
      true
    end

    # run_query needs to set @offset, @total_pages, and @total_count and return the final query results
    def run_query
    end

    def run_query_if_havent
      if not @query_result
        @query_result = run_query
      end
    end

    def total_count
      run_query_if_havent      

      @total_count
    end

    def offset
      run_query_if_havent      

      @offset
    end

    def total_pages
      run_query_if_havent      

      @total_pages
    end

    def calc_total_page_from_total_count( total_count )
      total_pages = 1      
      total_pages = (total_count.to_f / @records_per_page).ceil if @records_per_page
      total_pages
    end

    def each_row_on_page
      run_query_if_havent

      @query_result.each do |row|
        yield row
      end
    end   
  end
end
