
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mongoid_enumerable/version"

Gem::Specification.new do |spec|
  spec.name          = "mongoid_enumerable"
  spec.version       = MongoidEnumerable::VERSION
  spec.authors       = ["Douglas Lise"]
  spec.email         = ["douglaslise@gmail.com"]

  spec.summary       = %q{Mongoid Enumerable}
  spec.description   = %q{Mongoid Enumerable}
  spec.homepage      = "https://github.com/douglaslise/mongoid_enumerable"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "mongoid"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_dependency "mongoid", ">= 4.0"
  spec.add_development_dependency "simplecov"
end
