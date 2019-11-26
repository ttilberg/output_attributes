# OutputAttributes

This gem helps you serialize your data object by providing an `output` class macro for defining your class. You can call `#output_attributes` to get a hash representing your object from the output helpers.

I find it jarring to keep `#to_hash` up to date on classes that have many data attributes, and a few helper methods. I often wish to just mark a method as "This method describes my data and should be part of `#to_hash`".

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'output_attributes'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install output_attributes

## Usage

Behold:

```ruby
require 'output_attributes'

class Item
  include OutputAttributes

  def name
    "The Name"
  end
  output :name

end

Item.new.output_attributes
# => {:name=>"The Name"}
```

The `output` declaration can come before, during, or after a method definition.

```ruby
class Item
  include OutputAttributes

  # Before:
  output :first_name

  def first_name
    "First Name"
  end

  # During -- this is my favorite. It leverages the fact that the `def meth` expression returns a symbol... Clever!
  output def middle_name
    "Middle Name"
  end

  # After
  def last_name
    "Last Name"
  end

  output :last_name
end

Item.new.output_attributes
# => {:first_name=>"First Name",
#  :middle_name=>"Middle Name",
#  :last_name=>"Last Name"}
```

Whatever style works best for you. Stack a bunch on top like typical `attr_readers`. Stash them on the bottom. Decorate them. It's all good.

Sometimes the method name is not what you want as your output key. `output` takes an optional `from: ` keyword argument. If `from` is a `Symbol`, it will call that method instead:

```ruby
class Item
  include OutputAttributes
  def name
    "An Item"
  end

  output :description, from: :name
end

Item.new.output_attributes
# => {:description=>'An Item'}
```

You can also pass a proc or lambda in. The first argument provided to the proc is the instance of the object. This can be helpful if you need just a little extra massaging.

```ruby
class Item
  include OutputAttributes
  def name
    "An Item"
  end

  def color
    "Red"
  end

  output :description, from: ->(item) { [item.name, item.color].join(', ') }
end

Item.new.output_attributes
# => {:description=>"An Item, Red"}

```

You can of course just ignore it as well.

```ruby
class Item
  include OutputAttributes

  output :extracted_at, from: ->(_) { Time.now }
end

Item.new.output_attributes
# => {:extracted_at=>2019-11-26 16:12:01 -0600}

```

I don't overwrite `#to_hash` or `#to_h` because I think those methods are kind of special. However, it's incredibly easy to do it yourself!

```ruby
class Item
  include OutputAttributes
  output def name
    "An Item"
  end

  alias to_h output_attributes

  # or

  def to_hash
    output_attributes.merge(
      with: :more,
      customization: :perhaps
    )
  end
end

item = Item.new
# => #<Item:0x000055e0ae92d0a8>
item.output_attributes
# => {:name=>"An Item"}
item.to_h
# => {:name=>"An Item"}
item.to_hash
# => {:name=>"An Item", :with=>:more, :customization=>:perhaps}
```

I find this style particularly useful when working with Page Objects for data extraction:

```ruby
class Page < SimpleDelegator
  include OutputAttributes

  output def name
    at_css('#title').text
  end

  output def price
    at_css('.price').text
  end

  output def color
    labels(:color)
  end

  output def size
    labels(:size)
  end

  output def description
    "#{name} #{size} #{color}"
  end

  def to_hash
    output_attributes.merge(
      extracted_at: Time.now,
      object: self.class
    )
  end

  private
  def labels(key)
    at_css("li:contains('#{key}')").text
  end

end

Page.new(nokogirilike).to_hash
```

Usually when I'm writing a method for a page object, I'm already thinking "Is this part of my data output, or is this just a helper method?". I've often forgotten to update `#to_hash` when it lives far away from the method itself.

I've also tried other styles that involved packaging my data methods into a module, and then doing something like `Attributes.public_instance_methods.reduce({})...` but I wanted to give this style a spin. For now, I like it well enough.


# Fun Fact

`def method; ...; end` returns a symbol. I saw a recent post on Reddit comparing Python's method decorators. This led to some example code using the Memoist gem that looked like this:

```ruby
memoize def my_method
  ...
end
```

I think this is pretty cool. It's exactly the type of syntax I usually wished I had when creating data objects.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/output_attributes.
