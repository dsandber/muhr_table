require_relative 'backend'
require_relative 'hash_with_very_indifferent_access'

module MuhrTable
  class ArrayBackend < Backend    
    def initialize( data, column_types )
      @data=data
      @column_types = column_types
    end

    def total_pages
      total_pages = 1      
      total_pages = (data.length.to_f / @records_per_page).ceil if @records_per_page
    end

    def each_row_on_page(muhr_table_data)
      data = @data      
      data = handle_constraint( Set.new(data), @constraints ) if @constraints
      data = sort(data)
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

    def type( column )
      @column_types[column] || :string
    end

    private

    def handle_simple_constraint( data_set, name, operator_orig, operand_orig )    
      operator_method = operator_orig.to_sym
      operand = operand_orig
      
      if operator_orig.include?('like')
        operator_method = operator_orig.starts_with?('not') ? :'!~' : :'=~'
        case_insensitive = operator_orig.include?('ilike')
        operand = Regexp.new( operand_orig, case_insensitive )
      end
      filtered_data = data_set.select {|r| r[name].method(operator_method).call(operand) }
      Set.new( filtered_data )
    end

    def handle_and_constraint( data_set, constraint )
      subset = data_set
      constraint.parts.each do |part|
        partial_subset = handle_constraint( subset, part )
        subset = subset.intersection( partial_subset )
        break if subset.empty?
      end
      subset
    end

    
    def handle_constraint( data_set, constraint )
      subset = []

      if constraint.is_a?( And )
        subset = handle_and_constraint( data_set, constraint )
      elsif constraint.is_a?( Simple )
        name = constraint.name
        operand = constraint.operand
        operator = constraint.operator
        subset = handle_simple_constraint( data_set, name, operator, operand )
      elsif constraint.is_a?( IsNull )
        if constraint.is_null
          subset = handle_simple_constraint( data_set, name, '=', nil )
        else
          subset = handle_simple_constraint( data_set, name, '!=', nil )
        end
      elsif constraint.is_a?( Between )
        # not implemented yet
      elsif constraint.is_a?( Invalid )
        # not implemented yet
      else
        throw MuhrException.new( "Unknown constraint: " + constraint.class.name )
      end
      subset
    end

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
      sorted = data.sort{ |x,y| sort_func(x,y) } if @sort_column
      sorted
    end
  end
end
