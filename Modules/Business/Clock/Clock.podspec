Pod::Spec.new do |s|
  s.name             = "Clock"
  s.version          = "1.0.0"
  s.summary          = "Clock"
  s.description      = "Clock"

  s.homepage         = "https://github.com/Clock/Clock"
  s.license          = 'MIT'
  s.author           = 'Clock Contributors'
  s.source           = { :git => "https://github.com/Clock/Clock.git", :tag => s.version.to_s }

  s.source_files     = 'Clock/**/*.{swift}'

  s.ios.deployment_target     = '15.0'
  s.osx.deployment_target     = '12.0'
end