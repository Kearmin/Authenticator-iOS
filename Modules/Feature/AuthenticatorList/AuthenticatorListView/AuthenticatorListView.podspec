Pod::Spec.new do |s|
  s.name             = "AuthenticatorListView"
  s.version          = "1.0.0"
  s.summary          = "AuthenticatorListView"
  s.description      = "AuthenticatorListView"

  s.homepage         = "https://github.com/AuthenticatorListView/AuthenticatorListView"
  s.license          = 'MIT'
  s.author           = 'AuthenticatorListView Contributors'
  s.source           = { :git => "https://github.com/AuthenticatorListView/AuthenticatorListView.git", :tag => s.version.to_s }

  s.source_files     = 'AuthenticatorListView/**/*.{swift}'

  s.ios.deployment_target     = '15.0'
end