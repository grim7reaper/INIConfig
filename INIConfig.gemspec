Gem::Specification.new do |spec|
  spec.name        = 'INIConfig'
  spec.version     = '2.0.0'
  spec.date        = '2013-04-18'
  spec.summary     = 'A file parser for INI-like configuration files'
  spec.license     = 'BSD3'
  spec.homepage    = 'http://projects.gw-computing.net/projects/iniconfig/'
  spec.description = <<-eos
                        This gem implements a file parser for INI-like
                        configuration files. It can be used to write Ruby
                        scripts which can be customized easily.
                     eos
  spec.author      = 'Sylvain Laperche'
  spec.email       = 'sylvain.laperche@gmx.fr'
  spec.files       = ['lib/INIConfig.rb']
  spec.rdoc_options << '--title' << 'INIConfig'
end
