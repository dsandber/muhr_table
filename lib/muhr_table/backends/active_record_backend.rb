require_relative 'backend'
require_relative 'hash_with_very_indifferent_access'
require_relative '../option_checker'

module MuhrTable
  class ActiveRecordBackend < Backend    
    include MuhrTable::OptionChecker

    def initialize( data, opts )
      @data=data
      ensure_valid_options opts, [:column_to_model_map]
      @column_to_model_map = opts[:column_to_model_map] || {}
    end

    def total_pages
      total_pages = 1      
      total_pages = (data.count.to_f / @records_per_page).ceil if @records_per_page
    end

    def qualify_name( name )
      qualified_name = name
      model = @column_to_model_map[name]
      if model
        qualified_name = model.table_name+'.'+name.to_s
      end
      qualified_name
    end

    def handle_and_constraint( constraint, name_to_value_map )
      sql = nil

      parts=[]
      valid = true
      constraint.parts.each do |part|
        this_constraint = handle_constraint( part, name_to_value_map )
        if this_constraint
          parts << this_constraint
        else
          valid = false
        end
      end

      if valid
        sql="(" + parts.join(" and ") + ")"
      end
      sql
    end

    def handle_constraint( constraint, name_to_value_map )
      if constraint.is_a?( And )
        handle_and_constraint( constraint, name_to_value_map )
      elsif constraint.is_a?( Simple )
        name = constraint.name
        operand = constraint.operand
        operator = constraint.operator
        operand = "%" + operand + "%" if operator.include?('like')
        operator='=' if operator=='=='
        name_to_value_map[name]=operand
        qualified_name = qualify_name( name )
        "#{qualified_name} #{operator} :#{name}"
      elsif constraint.is_a?( IsNull )
        qualified_name = qualify_name( constraint.name )
        if constraint.is_null
          "#{qualified_name} is null"
        else
          "#{qualified_name} is not null"
        end
      elsif constraint.is_a?( Between )
        nil
      elsif constraint.is_a?( Invalid )
        nil
      else
        throw MuhrException.new( "Unknown constraint: " + constraint.class.name )
      end
    end

    def each_row_on_page(muhr_table_data)
      name_to_value_map={}
      data = @data
      if @constraints
        data = nil
        where_clause = handle_constraint( @constraints, name_to_value_map )

        # where_clause is nil if one of the constraints is invalid
        if where_clause
          logger.debug "Where is: #{where_clause}, values: #{name_to_value_map}"
          data = @data.where( where_clause, name_to_value_map )
        end
      end

      if data
        if @page && @records_per_page
          offset = (@page-1) * records_per_page
          data = data.limit(@records_per_page).offset(offset)
        end
        if @sort_column
          sort_dir = @sort_dir || 'asc'
          data = data.order( @sort_column + ' ' + sort_dir )
        end
        data.all.each do |row|
          yield row
        end
      end
    end
    
    def type( column_name )
      model = @column_to_model_map[column_name]
      if model
        column = model.columns_hash[ column_name.to_s ]
      else
        column = @data.columns_hash[ column_name.to_s ]
      end
      raise "Unknown column: #{column_name}" unless column
      column.type
    end
  end
end
