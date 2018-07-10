require "mongoid_enumerable/version"
require "mongoid"

module MongoidEnumerable
  def self.included(base)
    base.class.redefine_method :enumerable do |field_name, values, options = {}|
      field_name = String(field_name)
      values.collect!(&:to_s)

      prefix = options.fetch(:prefix, "")
      default = options.fetch(:default, values.first)

      before_change = options.fetch(:before_change, nil)
      after_change = options.fetch(:after_change, nil)

      field(field_name, type: String, default: default)

      values.each do |value|
        method_name = "#{prefix}#{value}"

        define_method("#{method_name}!") do
          value_before = send(field_name)
          value_after = value

          if before_change
            before_change_method = method(before_change)

            if before_change_method.arity != 2 && before_change_method.arity >= 0
              raise "Method #{before_change_method.name} must receive two parameters: old_value and new_value"
            end

            if method(before_change).call(value_before, value_after)
              update!(field_name => value)
            end
          else
            update!(field_name => value)
          end

          if after_change
            after_change_method = method(after_change)
            if after_change_method.arity != 2 && after_change_method.arity >= 0
              raise "Method #{after_change_method.name} must receive two parameters: old_value and new_value"
            end
            after_change_method.call(value_before, value_after)
          end
        end

        define_method("#{method_name}?") do
          send(field_name) == value
        end

        scope value, -> { where(field_name => value) }
      end

      base.define_singleton_method("all_#{field_name}") do
        values
      end
    end
  end
end
