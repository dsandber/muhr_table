require_relative 'constraint'

module MuhrTable
  class And < Constraint
    attr_reader :parts

    def initialize( parts )
      @parts=parts
    end
  end
end
