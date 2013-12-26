require "muhr_table/option_checker"

module MuhrTable
  class MuhrInitData
    include MuhrTable::OptionChecker

    attr_reader :backing, :per_page, :sort_column, :sort_dir

    def initialize( backing, opts )
      @backing = backing
      @per_page = opts[:per_page]
      @sort_column = opts[:sort_column]
      @sort_dir = opts[:sort_dir]      
    end
  end
end
