# frozen_string_literal: true

require "mongoid_enumerable/version"
require "mongoid"

module MongoidEnumerable
  def self.included(model)
    define_enumerable_methods(model)
  end

  private

  def self.define_enumerable_methods(model)
    model.define_singleton_method :enumerable do |field_name, values, options = {}|
      MongoidEnumerable.define_enumerable_method(
        model: model,
        field_name: String(field_name),
        values: values.collect(&:to_s),
        default: options.fetch(:default, values.first),
        prefix: options.fetch(:prefix, nil),
        before_change: options[:before_change],
        after_change: options[:after_change]
      )
    end
  end

  def self.define_enumerable_method(model:, field_name:, values:, default:, prefix:, before_change:, after_change:)
    model.field(field_name, type: String, default: default)

    values.each do |value|
      define_value_methods(
        model: model,
        value: value,
        field_name: field_name,
        prefix: prefix,
        before_change: before_change,
        after_change: after_change
      )
    end

    model.define_singleton_method("all_#{field_name}") do
      values
    end
  end

  def self.define_value_methods(model:, value:, field_name:, prefix:, before_change:, after_change:)
    method_name = "#{prefix}#{value}"

    model.define_method("#{method_name}!") do
      value_before = send(field_name)
      value_after = value

      callback_result = run_callback(callback_method_name: before_change,
                                     value_before: value_before, value_after: value_after)

      if callback_result
        update!(field_name => value)
        run_callback(callback_method_name: after_change,
                     value_before: value_before, value_after: value_after)
      end
    end

    model.define_method("#{method_name}?") do
      send(field_name) == value
    end

    model.scope method_name, -> { where(field_name => value) }
  end

  def run_callback(callback_method_name:, value_before:, value_after:)
    if callback_method_name
      callback_method = method(callback_method_name)
      validate_callback_method(method: callback_method)

      callback_method.call(value_before, value_after)
    else
      true
    end
  end

  def validate_callback_method(method:)
    raise "Method #{method.name} must receive two parameters: old_value and new_value" if method.arity != 2 && method.arity >= 0
  end
end
