Gem::Specification.new do |spec|
  spec.name        = 'INIConfig'
  spec.version     = '2.0.2'
  spec.date        = '2014-01-25'
  spec.author      = 'Sylvain Laperche'
  spec.email       = 'sylvain.laperche@gmail.com'
  spec.summary     = 'A file parser for INI-like configuration files'
  spec.license     = 'BSD3'
  spec.homepage    = 'http://projects.gw-computing.net/projects/iniconfig/'
  spec.description = <<-eos
                        This gem implements a file parser for INI-like
                        configuration files. It can be used to write Ruby
                        scripts which can be customized easily.
                     eos
  spec.require_paths = [ 'lib' ]
  spec.files         = `git ls-files`.split("\n") - [ '.gitignore', '.yardopts',
                                                      __FILE__ ]
  spec.test_files    = [ 'test/ts_INIConfig.rb' ]
  spec.has_rdoc      = 'yard'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
end
