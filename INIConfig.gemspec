Gem::Specification.new do |spec|
  spec.name        = 'INIConfig'
  spec.version     = '2.0.2'
  spec.date        = '2013-04-18'
  spec.summary     = 'A file parser for INI-like configuration files'
  spec.license     = 'BSD3'
  spec.homepage    = 'http://projects.gw-computing.net/projects/iniconfig/'
  spec.description = <<-eos
                        This gem implements a file parser for INI-like
                        configuration files. It can be used to write Ruby
                        scripts which can be customized easily.
                     eos
  spec.author        = 'Sylvain Laperche'
  spec.email         = 'sylvain.laperche@gmail.com'
  spec.require_paths = [ 'lib' ]
  spec.files         = `git ls-files`.split("\n") - [ '.gitignore', __FILE__ ]
  spec.test_files    = [ 'test/ts_INIConfig.rb' ]
  spec.extra_rdoc_files = ['README.rdoc', 'LICENSE']
  spec.rdoc_options     = [ 'lib', '-t', 'INIConfig', '-m', 'README.rdoc' ]
end
