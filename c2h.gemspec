Gem::Specification.new do |s|
  s.name        = 'c2h'
  s.version     = '0.0.1'
  s.date        = '2015-12-07'
  s.summary     = 'Contentful 2 Hugo'
  s.description = 'A tool to create content-files for hugo from content on contentful'
  s.authors     = ['Arno Nuyts']
  s.email       = 'arno.nuyts@gmail.com'
  s.files       = ["bin/c2h"]
  s.bindir = 'bin'
  s.executables << 'c2h'
  s.add_runtime_dependency "contentful", ["= 0.8.0"]
  s.add_runtime_dependency "choice", ["= 0.2.0"]
  s.homepage    =
    'https://github.com/ArnoNuyts/contentful2hugo'
  s.license       = 'Apache License 2.0'
end
