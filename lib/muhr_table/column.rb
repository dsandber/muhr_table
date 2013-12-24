module MuhrTable
  class Column
    attr_reader :name, :block, :opts

    def initialize(name, opts, block)
      @name = name
      @opts = opts
      @block = block
    end

    def allow_sorting?
      @opts[:allow_sorting]!=false
    end

    def allow_filtering?
      @opts[:allow_filtering]!=false
    end

    def capitalize_name
      @name.to_s.split('_').map(&:capitalize).join(' ')
    end

    def display_name
      @title ||= @opts[:title] || capitalize_name
    end
  end
end
