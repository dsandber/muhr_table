require_relative 'backends/array_backend'
require_relative 'backends/active_record_backend'
require_relative 'muhr_exception'
require_relative 'muhr_facade'
require_relative 'muhr_init_data'
require_relative 'option_checker'

module MuhrTable
  module ActionControllerMethods
    include OptionChecker

    def muhr_init( backing, opts )
      ensure_valid_options opts, [:backing_opts, :sort_column, :sort_dir]
      
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
      muhr_init_data = MuhrInitData.new( backing, opts )
      MuhrFacade.new( muhr_init_data, self )
    end

    def muhr_array_backend( data, column_types )
      ArrayBackend.new( data, column_types )
    end
  end
end 
