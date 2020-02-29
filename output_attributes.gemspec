lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "output_attributes/version"

Gem::Specification.new do |spec|
  spec.name          = "output_attributes"
  spec.version       = OutputAttributes::VERSION
  spec.authors       = ["Tim Tilberg"]
  spec.email         = ["ttilberg@gmail.com"]

  spec.summary       = %q{Easily declare a hash to represent your object using `output` attributes}
  spec.description   = <<~DESC
    Sometimes defining #to_hash is a drag because the source location of your methods
    is far away from `def to_hash`. This gem gives you a declarative way to build up
    a hash representation of your object as you define your methods.
  DESC
  spec.homepage      = "https://www.github.com/ttilberg/output_attributes"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://www.github.com/ttilberg/output_attributes"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry"
end
