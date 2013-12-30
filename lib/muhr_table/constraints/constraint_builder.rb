require_relative 'and'
require_relative 'invalid'
require_relative 'simple'
require_relative 'is_null'

module MuhrTable
  # longer operators must come first because this array is searched in order for an operator match
  OPS = ['<=','>=','<','>','=','!=','!','~']

  class ConstraintBuilder
    def self.get_op_and_operand( val )
      op = nil
      operand = nil

      OPS.each do |op_to_try|
        if val.starts_with?( op_to_try )
          op = op_to_try
          operand = val[op_to_try.length..-1]
          break
        end
      end
      op = '==' if op=='='
      if not op
        op='~'
        operand=val
      end
      return [op, operand]
    end

    def self.numeric_get_op_and_operand( op_orig, operand_orig )
      op = op_orig

      # remove spaces around operand
      operand = operand_orig.gsub( ' ','' )
      op = '==' if op_orig == '~'
      op = '!=' if op_orig == '!'
      num = Float(operand) rescue nil
      [op, num]
    end

    def self.boolean_get_op_and_operand( op_orig, operand_orig )
      op=nil
      operand = nil
      operand_orig = operand_orig.downcase
      op_orig = '==' if op_orig=='~'
      op_orig = '!=' if op_orig=='!'

      if op_orig == '=' || op_orig == '!='
        op = op_orig
        if ['yes','true','on'].include?(operand_orig)
          operand = true
        elsif ['no','false','off'].include?(operand)
          operand = false
        end
      end

      [op, operand]
    end

    def self.parse_date( text, from )
      val = Time.zone.parse( text ) rescue nil
      val = from ? val.beginning_of_day : val.end_of_day if val
    end

    def self.create_constraints( backing, muhr_table_settings, filter_hash )
      simple_constraints=[]

      filter_hash.each do |key,value|
        constraint = Invalid.new(key)
        col_type = backing.type( key )
        null_text = muhr_table_settings.null_text(key)

        if col_type==:integer || col_type==:float
          op_orig, operand_orig = get_op_and_operand( value )
          op, operand = numeric_get_op_and_operand( op_orig, operand_orig )
          if op && operand
            constraint = Simple.new( key, op, operand ) 
          elsif null_text and ['=','!='].include?( op_orig ) and null_text =~ /#{operand_orig}/i
            is_null = op_orig == '='
            constraint = IsNull.new( key, is_null )
          end
        else
          throw MuhrException.new( ':null_text only supported on :integer and :float type columns' ) if null_text
          
          if col_type==:string
            op,operand = get_op_and_operand( value )
            if op == '~'
              op = 'ilike' 
            elsif op == '!'
              op = 'not ilike'
            end
            
            constraint = Simple.new( key, op, operand )  if op
          elsif col_type==:boolean
            op_orig, operand_orig = get_op_and_operand( value )
            op, operand = boolean_get_op_and_operand( op_orig, operand_orig )
            constraint = Simple.new( key, op, operand ) if op and operand
          elsif col_type==:datetime
            from_value=value['from']
            to_value=value['to']
            from = parse_date( from_value, true ) if from_value
            to = parse_date( to_value, false ) if to_value
            if (from_value && !from) || (to_value && !to)
              # one of the dates is invalid, so use default Invalid constraint
            else
              constraints=[]
              constraints << Simple.new( key, '>=', from) if from
              constraints << Simple.new( key, '<=', to) if to
              if constraints.length==0
                throw MuhrException.new( 'Datetime has no constraints' )
              elsif constraints.length==1                
                constraint = constraints[0]
              else
                constraint = And.new( constraints )
              end              
            end
          end
        end
        simple_constraints << constraint
      end
      if simple_constraints.empty?
        nil
      else
        And.new( simple_constraints )
      end
    end      
  end
end 
