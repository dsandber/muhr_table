require_relative 'column'
require_relative 'html_util'

module MuhrTable
  class MuhrTableSettings
    # we include this so the blocks defined under 'column' in the DSL can access link_to, mail_to, etc
    #include ActionView::Helpers::UrlHelper
    include MuhrTable::HTMLUtil

    attr_reader :columns, :before_row_block, :during_row_block, :after_row_block
    attr_reader :thead_options, :title_row_options, :tbody_options, :table_options, :row_options
    attr_reader :decorator_before_table_block, :decorator_after_table_block, :filter_row_options
    attr_reader :filter_row_input_options, :filter_row_input_options_block
    attr_reader :form_options

    # we use filter_row_on? to get the value so this is for writing only
    attr_writer :filter_row_on

    def initialize
      @columns=[]
      @name_to_column={}
      @row_options={}
      @thead_options={}
      @title_row_options={}
      @tbody_options={}
      @table_options={}
      @filter_row_input_options={}
      @filter_row_options={}      
      @form_options={}
    end

    def load_dsl( block )
      block.call( self )
    end

    def is_column( name )
      @name_to_column.include?(name)
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

    def filter_row_on?
      @filter_row_on
    end

    def column( name, options={}, &block)
      check_is_hash( options )
      column = Column.new( name, options, block )
      @columns << column
      @name_to_column[name] = column
    end

    def table( options )
      check_is_hash( options )
      html_merge!( @table_options, options )
    end

    def filter_row( options )
      check_is_hash( options )
      html_merge!( @filter_row_options, options )      
    end

    def filter_row_input( options={}, &block )
      @filter_row_input_options_block = block
      html_merge!( @filter_row_input_options, options )      
    end

    def title_row( options )
      check_is_hash( options )
      html_merge!( @title_row_options, options )
    end

    def thead( options )
      check_is_hash( options )
      html_merge!( @thead_options, options )
    end

    def form( options )
      check_is_hash( options )
      html_merge!( @form_options, options )
    end

    def tbody( options )
      check_is_hash( options )
      html_merge!( @tbody_options, options )
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
