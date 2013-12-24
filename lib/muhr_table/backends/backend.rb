module MuhrTable
  class Backend
    attr_writer :sort_column, :sort_dir, :filter_hash, :page, :records_per_page

    def allow_filtering?( column )
      true
    end
  end
end
