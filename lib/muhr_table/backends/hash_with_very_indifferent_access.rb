module MuhrTable
  class HashWithVeryIndifferentAccess
    def initialize( hash, muhr_table_data )
      @hash = hash
      @muhr_table_data = muhr_table_data
    end

    def method_missing(method, *args, &block)
      is_column = @muhr_table_data.is_column(method)
      if is_column
        return @hash[method]
      else
        super
      end
    end

    def [](name)
      return @hash[name.to_sym]
    end
  end
end
