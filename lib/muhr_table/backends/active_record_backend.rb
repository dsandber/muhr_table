require_relative 'backend'
require_relative 'hash_with_very_indifferent_access'

module MuhrTable
  class ActiveRecordBackend < Backend    
    def initialize( data )
      @data=data
    end

    def total_pages
      total_pages = 1      
      total_pages = (data.count.to_f / @records_per_page).ceil if @records_per_page
    end

    def each_row_on_page(muhr_table_data)
      data = @data
      if @page && @records_per_page
        offset = (@page-1) * records_per_page
        data = @data.limit(@records_per_page).offset(offset)
      end
      if @sort_column
        sort_dir = @sort_dir || 'asc'
        data = data.order( @sort_column + ' ' + sort_dir )
      end
      data.all.each do |row|
        print "row is: #{row}\n"
        yield row
      end
    end
    
    def type( column_name )
      column = @data.columns_hash[ column_name.to_s ]
      raise "Unknown column: #{column_name}" unless column
      column.type
    end
  end
end
