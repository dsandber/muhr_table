require 'muhr_table/backends/array_backend'
require 'muhr_table/backends/active_record_backend'
require 'muhr_table/muhr_exception'
require 'muhr_table/muhr_init_data'

module MuhrTable
  module ActionControllerMethods
    def muhr_init( backing, opts )
     ensure_valid_options opts, [:backing_opts, :per_page, :sort_column, :sort_dir]

      backing_opts = opts.delete(:backing_opts) || {}

      if backing.is_a?(Backend)
        backing = backing
      elsif backing.is_a?(ActiveRecord::Relation)
        backing = ActiveRecordBackend.new( backing, backing_opts )
      elsif backing.ancestors.index(ActiveRecord::Base)
        backing = ActiveRecordBackend.new( backing, backing_opts )
      else
        raise MuhrException.new('Backing must be an ActiveRecord, Relation, or Backend' )
      end     
      MuhrInitData.new( backing, opts )
    end

    def muhr_array_backend( data, column_types )
      ArrayBackend.new( data, column_types )
    end
  end
end 
