Pod::Spec.new do |s|
  s.name             = "AuthenticatorListBusiness"
  s.version          = "1.0.0"
  s.summary          = "AuthenticatorListBusiness"
  s.description      = "AuthenticatorListBusiness"

  s.homepage         = "https://github.com/AuthenticatorListBusiness/AuthenticatorListBusiness"
  s.license          = 'MIT'
  s.author           = 'AuthenticatorListBusiness Contributors'
  s.source           = { :git => "https://github.com/AuthenticatorListBusiness/AuthenticatorListBusiness.git", :tag => s.version.to_s }

  s.source_files     = 'Shared/Source/**/*.{swift}'

  s.ios.deployment_target     = '15.0'
  s.osx.deployment_target     = '12.0'
end