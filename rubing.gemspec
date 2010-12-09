Gem::Specification.new do |spec|
  spec.name = 'RuBing'
  spec.author = 'Wesley Moxam'
  spec.email = 'wesley.moxam@savvica.com'
  spec.files = ['init.rb']
  spec.add_dependency('json', '>= 1.1.0')
  spec.description = 'A Ruby wrapper for Bing search API'
  spec.summary = 'A Ruby wrapper for Bing search API'
  spec.files = Dir['lib/*.rb'] + Dir['test/*.rb']
  spec.homepage = 'http://github.com/wmoxam/RuBing'
  spec.required_ruby_version = '>= 1.8.6'
  spec.version = '0.1.1'
end
