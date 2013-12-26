module MuhrTable
  class Backend
    attr_writer :sort_column, :sort_dir, :constraints, :page, :records_per_page

    def allow_filtering?( column )
      true
    end
  end
end
