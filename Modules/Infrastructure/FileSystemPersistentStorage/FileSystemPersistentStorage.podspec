Pod::Spec.new do |s|
  s.name             = "FileSystemPersistentStorage"
  s.version          = "1.0.0"
  s.summary          = "FileSystemPersistentStorage"
  s.description      = "FileSystemPersistentStorage"

  s.homepage         = "https://github.com/FileSystemPersistentStorage/FileSystemPersistentStorage"
  s.license          = 'MIT'
  s.author           = 'FileSystemPersistentStorage Contributors'
  s.source           = { :git => "https://github.com/FileSystemPersistentStorage/FileSystemPersistentStorage.git", :tag => s.version.to_s }

  s.source_files     = 'Shared/Source/**/*.{swift}'

  s.ios.deployment_target     = '15.0'
  s.osx.deployment_target     = '12.0'
end