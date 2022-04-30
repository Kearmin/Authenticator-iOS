Pod::Spec.new do |s|
  s.name             = "AddAccountBusiness"
  s.version          = "1.0.0"
  s.summary          = "AddAccountBusiness"
  s.description      = "AddAccountBusiness"

  s.homepage         = "https://github.com/AddAccountBusiness/AddAccountBusiness"
  s.license          = 'MIT'
  s.author           = 'AddAccountBusiness Contributors'
  s.source           = { :git => "https://github.com/AddAccountBusiness/AddAccountBusiness.git", :tag => s.version.to_s }

  s.source_files     = 'Shared/Source/**/*.{swift}'

  s.ios.deployment_target     = '15.0'
  s.osx.deployment_target     = '12.0'
end