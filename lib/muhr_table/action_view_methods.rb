require 'muhr_table/generators/html/table_generator'
require 'muhr_table/decorators/bootstrap_decorator'
require "muhr_table/muhr_exception"
require "muhr_table/muhr_table_settings"
require "muhr_table/option_checker"
require "muhr_table/query_string_handler"
require "muhr_table/version"

module MuhrTable
  module ActionViewMethods
    include MuhrTable::OptionChecker

    def muhr_table( muhr_init_data, opts={}, &block )
      raise MuhrException.new('muhr_table must be instantiated with a block') unless block
      ensure_valid_options opts, [:decorator_name, :filter_row_on]
      
      query_string_handler = QueryStringHandler.new(self)
      muhr_table_settings = muhr_get_muhr_table_settings( opts, block )
      table_generator = HTMLTableGenerator.new    
      table_generator.generate( muhr_init_data, muhr_table_settings, query_string_handler )
    end

    def muhr_get_decorator_block( name )
      decorator = nil
      if name
        if name == :twitter
          decorator = BootstrapDecorator.new.get_block
        else
          raise MuhrException.new( "Unknown decorator: #{name}" )
        end 
      end
    end
    
    def muhr_get_muhr_table_settings( opts, block )
      decorator_name = opts[:decorator_name] || :twitter
      decorator_block = muhr_get_decorator_block( decorator_name )
      muhr_table_settings = MuhrTableSettings.new
      if decorator_block
        muhr_table_settings.load_dsl( decorator_block )
      end
      muhr_table_settings.load_dsl( block )
      muhr_table_settings.filter_row_on = opts[:filter_row_on] != false
      muhr_table_settings
    end
  end
end
