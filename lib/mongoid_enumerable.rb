require "mongoid_enumerable/version"
require "mongoid"

module MongoidEnumerable
  def self.included(model)
    define_enumerable_methods(model)
  end

  private

  def self.define_enumerable_methods(model)
    model.define_singleton_method :enumerable do |field_name, values, options = {}|
      MongoidEnumerable.define_enumerable_method(model, field_name, values, options)
    end
  end

  def self.define_enumerable_method(model, field_name, values, options)
    field_name = String(field_name)
    values.collect!(&:to_s)

    prefix = options.fetch(:prefix, "")
    default = options.fetch(:default, values.first)

    before_change = options.fetch(:before_change, nil)
    after_change = options.fetch(:after_change, nil)

    model.field(field_name, type: String, default: default)

    values.each do |value|
      method_name = "#{prefix}#{value}"

      define_method("#{method_name}!") do
        value_before = send(field_name)
        value_after = value

        callback_result = run_callback(model, before_change, value_before, value_after)

        if callback_result
          update!(field_name => value)
          run_callback(model, after_change, value_before, value_after)
        end
      end

      define_method("#{method_name}?") do
        send(field_name) == value
      end

      model.scope value, -> { where(field_name => value) }
    end

    model.define_singleton_method("all_#{field_name}") do
      values
    end
  end

  def run_callback(model, callback_method_name, value_before, value_after)
    if callback_method_name
      callback_method = method(callback_method_name)
      validate_callback_method(callback_method)

      callback_method.call(value_before, value_after)
    else
      true
    end
  end

  def validate_callback_method(method)
    if method.arity != 2 && method.arity >= 0
      raise "Method #{method.name} must receive two parameters: old_value and new_value"
    end
  end
end
