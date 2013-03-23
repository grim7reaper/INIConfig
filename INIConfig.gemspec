Gem::Specification.new do |spec|
  spec.name        = 'INIConfig'
  spec.version     = '1.0.0'
  spec.date        = '2013-03-23'
  spec.summary     = 'A file parser for INI-like configuration files'
  spec.license     = 'BSD3'
  spec.description = <<-eos
                        This gem implements a file parser for INI-like
                        configuration files. It can be used to write Ruby scripts
                        which can be customized easily.
                     eos
  spec.authors     = ['Sylvain Laperche']
  spec.email       = 'sylvain.laperche@gmx.fr'
  spec.files       = ['lib/INIConfig.rb']
  spec.test_files  = ['test/ts_INIConfig.rb']
end
