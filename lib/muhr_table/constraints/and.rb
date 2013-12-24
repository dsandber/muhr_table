module MuhrTable
  class And(Constraint)
    def initialize( *parts )
      self.parts=parts
    end
  end
end
