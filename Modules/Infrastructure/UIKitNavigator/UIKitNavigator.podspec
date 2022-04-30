Pod::Spec.new do |s|
  s.name             = "UIKitNavigator"
  s.version          = "1.0.0"
  s.summary          = "UIKitNavigator"
  s.description      = "UIKitNavigator"

  s.homepage         = "https://github.com/UIKitNavigator/UIKitNavigator"
  s.license          = 'MIT'
  s.author           = 'UIKitNavigator Contributors'
  s.source           = { :git => "https://github.com/UIKitNavigator/UIKitNavigator.git", :tag => s.version.to_s }

  s.source_files     = 'UIKitNavigator/**/*.{swift}'

  s.ios.deployment_target     = '15.0'
end