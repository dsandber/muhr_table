require_relative "muhr_exception"
require_relative "muhr_table_settings"
require_relative "query_string_handler"
require_relative "generators/html_generator"

module MuhrTable
  class MuhrFacade
    def initialize( muhr_init_data, controller )
      @muhr_init_data = muhr_init_data
      @query_string_handler = QueryStringHandler.new(controller)      
    end

    def configure( &block )
      raise MuhrException.new('muhr_table must be instantiated with a block') unless block

      @muhr_table_settings = MuhrTableSettings.new
      @muhr_table_settings.load_dsl( block )

      @backing = @muhr_init_data.backing
      @backing.sort_column=@query_string_handler.sort_column || @muhr_init_data.sort_column
      @backing.sort_dir=@query_string_handler.sort_dir || @muhr_init_data.sort_dir
      filter_hash = @query_string_handler.build_filter_hash( @muhr_table_settings )
      @backing.constraints=ConstraintBuilder.create_constraints( @backing, @muhr_table_settings, filter_hash )
    end
    
    def generate(format, options)
      gen = generator(format, options)
      gen.generate
    end
    
    def generator(format, options={})
      throw MuhrException.new( 'Unsupported format: ' + format ) unless format==:html
      throw MuhrException.new( 'configure must be called before generation' ) unless @muhr_table_settings

      # we have to set the records per page before we calculate page numbers
      @backing.records_per_page = options[:per_page] || 10
      @backing.page = @query_string_handler.page
      return HTMLGenerator.new( @muhr_init_data, @muhr_table_settings, @query_string_handler, options )
    end

    # for kaminari
    def current_page
      @backing.page
    end
    
    # for kaminari
    def total_pages
      @backing.total_pages
    end

    # for kaminari
    def limit_value
      @backing.records_per_page
    end

    # for kaminari
    def total_count
      @backing.total_count
    end

    # for kaminari
    def empty?
      total_pages == 0
    end

    # for kaminari
    def offset_value
      @backing.offset
    end

    # for kaminari
    def last_page?
      current_page == total_pages
    end

    # for kaminari
    def model_name
      klass = Class.new do
        def human
          ""
        end
      end
      klass.new
    end
  end
end
