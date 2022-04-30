Pod::Spec.new do |s|
  s.name             = "AddAccountView"
  s.version          = "1.0.0"
  s.summary          = "AddAccountView"
  s.description      = "AddAccountView"

  s.homepage         = "https://github.com/AddAccountView/AddAccountView"
  s.license          = 'MIT'
  s.author           = 'AddAccountView Contributors'
  s.source           = { :git => "https://github.com/AddAccountView/AddAccountView.git", :tag => s.version.to_s }

  s.source_files     = 'AddAccountView/**/*.{swift}'

  s.ios.deployment_target     = '15.0'
end