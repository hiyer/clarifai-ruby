Gem::Specification.new do |spec|
  spec.name        = 'clarifai'
  spec.version     = '0.1.0'
  spec.date        = '2016-02-18'
  spec.summary     = "Interface for Clarifai"
  spec.description = "Gem for image tagging (and feedback) using Clarifai (http://www.clarifai.com/)"
  spec.authors     = ["Hariharan Iyer"]
  spec.email       = 'hariharan022@gmail.com'
  spec.files       = ["lib/clarifai.rb", "lib/clarifai/configuration.rb", "lib/clarifai/result.rb"]
  spec.homepage    = 'http://rubygems.org/gems/clarifai'
  spec.license     = 'MIT'
  spec.add_runtime_dependency 'rest-client', '~> 1.8', '>= 1.8.0'
  spec.add_development_dependency 'rspec', '~> 3.3', '>= 3.3.0'
end