require_relative 'constraint'

module MuhrTable
  class And < Constraint
    attr_reader :parts

    def initialize( parts )
      @parts=parts
    end

    def to_s
      '( ' + @parts.join( ' and ' ) + ' )'
    end
  end
end
