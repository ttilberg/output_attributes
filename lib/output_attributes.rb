require "output_attributes/version"

# This module creates a class helper method `output` that can be used to create an output configuration
# The goal is to help assemble a class's hash representation.
# 
# Each time you call `output` in the class definition, you register a key => proc pair.
# You can then call `#output_attributes` to get the hash of key => values
#
# Example:
#
#    class Item
#      include OutputAttributes
#
#      # You can register outputs similar to attr_accessors
#      output :name
#
#      def name
#        "A Thing"
#      end
#
#      # Since the `def meth` expression returns a symbol, you can also register it like a decorator.
#      # It returns the symbol so you could keep chaining with other similar tools like memoize
#      output def price
#        "free"
#      end
#
#      # You can rename a method/key:
#      output :cost, from: :price
#
#      # You can also define a custom proc if the key doesn't match a method name.
#      # The argument to your proc is the instance itself so you have easy access to it's methods
#      output :description, from: ->(item){ [item.name, item.price].join(': ') }
#
#      # You can also call whatever you want:
#      output :extracted_at, from: ->(_){ Time.now }
#
#      def a_helper_method
#        "Ignore this"
#      end
#
#      # It does not override `#to_h/ash`, but this is easy enough if you wish!
#      def to_h
#        output_attributes
#      end
#      alias to_hash output_attributes
#    end
#
#    item = Item.new
#    item.output_attributes || item.to_h || item.to_hash
#    # => 
#      {
#        name: "A Thing",
#        price: "Free",
#        description: "A Thing: Free",
#        extracted_at: 2019-11-26 14:33:00.000
#      }

module OutputAttributes
  # Register this class's catalog of outputs
  def self.included(base)
    base.class_eval do
      @registered_output_attributes = {}

      def self.output(key, from: nil)
        @registered_output_attributes[key] = from || key
        key
      end

      def self.registered_output_attributes
        @registered_output_attributes
      end
    end
  end

  # Return a hash representing your outputs
  def output_attributes
    self.class.registered_output_attributes.map do |key, meth|
      value = case meth
      when Symbol, String
        self.send(meth.to_sym)
      when Proc
        meth.call(self)
      else
        raise ArgumentError, "Could not determine how to output #{meth} for #{key}."
      end
      [key, value]
    end.to_h
  end
end
