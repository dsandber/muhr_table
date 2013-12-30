require_relative 'column'
require_relative 'html_util'

module MuhrTable
  class MuhrTableSettings
    # we include this so the blocks defined under 'column' in the DSL can access link_to, mail_to, etc
    #include ActionView::Helpers::UrlHelper
    include MuhrTable::HTMLUtil

    attr_reader :columns, :before_row_block, :during_row_block, :after_row_block
    attr_reader :decorator_before_table_block, :decorator_after_table_block
    attr_reader :filter_row_column_block, :row_options

    def initialize
      @columns=[]
      @name_to_column={}
      @row_options={}
    end

    def load_dsl( block )
      block.call( self )
    end

    def is_column( name )
      @name_to_column.include?(name)
    end

    def null_text( name )
      @name_to_column[name].null_text
    end

    def before_row( &block )
      @before_row_block = block
    end

    def after_row( &block )
      @after_row_block = block
    end

    def during_row( options={}, &block )
      check_is_hash( options )
      @row_options = options
      @during_row_block = block
    end

    def column( name, options={}, &block)
      check_is_hash( options )
      column = Column.new( name, options, block )
      @columns << column
      @name_to_column[name] = column
    end

    def filter_row_column( &block )
      @filter_row_column_block = block
    end

    def check_is_hash( options )
      throw MuhrException.new('options must be a hash') unless options.is_a?(Hash)
    end

    def decorator_before_table( &block )
      @decorator_before_table_block = block
    end

    def decorator_after_table( &block )
      @decorator_after_table_block = block
    end
  end
end
