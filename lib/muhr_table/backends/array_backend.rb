require_relative 'backend'
require_relative 'hash_with_very_indifferent_access'

module MuhrTable
  class ArrayBackend < Backend    
    def initialize( data, column_types )
      @data=data
      @column_types = column_types
      @page=nil
      @records_per_page=nil
    end

    def total_pages
      total_pages = 1      
      total_pages = (data.length.to_f / @records_per_page).ceil if @records_per_page
    end

    def each_row_on_page(muhr_table_data)
      data = sort(@data)
      # show all the records if page or records per page hasn't been set
      range = 0...data.length
      if @page && @records_per_page
        offset = (@page-1) * records_per_page
        range = offset...(offset+records_per_page)
      end
      data[range].each do |row|
        yield HashWithVeryIndifferentAccess.new(row, muhr_table_data )
      end
    end

    def allow_filtering?( column )
      true
    end

    def type( column )
      @column_types[column] || :string
    end

    private

    def sort_func(row1,row2)
      col1=row1[@sort_column.to_sym]
      col2=row2[@sort_column.to_sym]
      sort_num = if !col1 and !col2
                   0
                 elsif col1.blank?
                   1
                 elsif col2.blank?
                   -1
                 else
                   col1 <=> col2
                 end

      sort_num=-sort_num if @sort_dir=='desc'
      sort_num
    end

    def sort(data)
      sorted = data
      sorted = @data.sort{ |x,y| sort_func(x,y) } if @sort_column
      sorted
    end
  end
end
