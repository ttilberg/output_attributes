require "test_helper"

class OutputAttributesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OutputAttributes::VERSION
  end

  # Set up classes to use for assertions:
  class Dog
    include OutputAttributes

    # test_output_declaration_can_come_before_method_definition
    output :name

    # test_the_helper_returns_the_method_symbol_so_you_can_keep_chaining
    # test_output_can_prepend_def_like_a_decorator

    class << self
      attr_reader :speaking_method
    end
    @speaking_method = output def speak
      "woof"
    end

    def name
      "Percy"
    end

    def describe
      "A good dog"
    end

    # test_output_declaration_can_come_after_method_definition
    output :describe

    # test_you_can_rename_a_key
    output :description, from: :describe

    # test_you_can_use_a_lambda
    output :sit, from: ->(dog) { "#{dog.name} is sitting." }
  end

  # Define a second class to ensure the class ivars are not getting melded together at the module
  # test_each_class_has_its_own_registered_attributes
  class Cat
    include OutputAttributes
    def speak
      "meow"
    end

    def is_a_dog
      false
    end

    output :speak
    output :is_a_dog
  end

  def setup
    @dog = Dog.new
    @attrs = @dog.output_attributes
  end

  def test_output_declaration_can_come_before_method_definition
    assert_equal "Percy", @attrs[:name]
  end

  def test_output_can_prepend_def_like_a_decorator
    assert_equal "woof", @attrs[:speak]
  end

  def test_output_declaration_can_come_after_method_definition
    assert_equal "A good dog", @attrs[:describe]
  end

  def test_you_can_rename_a_key
    assert_equal "A good dog", @attrs[:description]
  end

  def test_you_can_use_a_lambda
    assert_equal "Percy is sitting.", @attrs[:sit]
  end

  def test_each_class_has_its_own_registered_attributes
    cat = Cat.new
    attrs = cat.output_attributes
    assert_equal({speak: 'meow', is_a_dog: false}, attrs)
  end

  def test_the_helper_returns_the_method_symbol_so_you_can_keep_chaining
    assert_equal :speak, @dog.class.speaking_method
  end
end
