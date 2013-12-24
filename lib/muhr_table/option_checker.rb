require "muhr_table/muhr_exception"

module MuhrTable
  module OptionChecker
    def ensure_valid_options( opts, valid_opts )
      passed_opts = opts.keys
      extra_opts = passed_opts - valid_opts
      raise MuhrException.new("unknown option: #{extra_opts[0]}") unless extra_opts.empty?
    end
  end
end
