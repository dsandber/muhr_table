require 'set'

module MuhrTable
  module HTMLUtil
    def html_merge!(target, source )
      classes = target[:class].to_s + ' ' + source[:class].to_s
      classes_set = Set.new(classes.split)
      classes_text = classes_set.to_a.join(' ')
      target.merge!( source )
      target[:class]=classes_text
    end
  end
end
