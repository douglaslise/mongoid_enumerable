require "mongoid_enumerable/version"
require "mongoid"

module MongoidEnumerable
  def self.included(base)
    base.class.redefine_method :enumerable do |field_name, values, options = {}|
      field_name = String(field_name)
      values.collect!(&:to_s)

      prefix = options.fetch(:prefix, "")
      default = options.fetch(:default, values.first)

      field(field_name, type: String, default: default)

      values.each do |value|
        method_name = "#{prefix}#{value}"

        define_method("#{method_name}!") do
          update!(field_name => value)
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
