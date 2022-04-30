project 'Authenticator-iOS/Authenticator-iOS.xcodeproj'


$iphoneDeploymentTarget = "15.0"
$basePath = './Modules'
$featurePath = $basePath + '/Feature/'
$businessPath = $basePath + '/Business/'
$infrastructurePath = $basePath + '/Infrastructure/'

platform :ios, $iphoneDeploymentTarget
use_frameworks!

def featureModules 
  pod "AddAccountBusiness", :testspecs => ["Tests"], :path => $featurePath + 'AddAccount/AddAccountBusiness'
  pod "AddAccountView", :path => $featurePath + 'AddAccount/AddAccountView'
  pod "AuthenticatorListBusiness", :testspecs => ["Tests"], :path => $featurePath + 'AuthenticatorList/AuthenticatorListBusiness'
  pod "AuthenticatorListView", :path => $featurePath + 'AuthenticatorList/AuthenticatorListView'
end

def businessModules 
  pod "AccountRepository", :testspecs => ["Tests"], :path => $businessPath + 'AccountRepository'
  pod "Clock", :path => $businessPath + 'Clock'
end

def infrastructureModules 
  pod "UIKitNavigator", :path => $infrastructurePath + 'UIKitNavigator'
  pod "FileSystemPersistentStorage", :testspecs => ["Tests"], :path => $infrastructurePath + 'FileSystemPersistentStorage'
end

target 'Authenticator-iOS' do

  pod "SwiftOTP", '~> 3.0.0'
  pod "Resolver", '~> 1.5.0'
  featureModules
  businessModules
  infrastructureModules

  target 'Authenticator-iOSTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = $iphoneDeploymentTarget
    end
  end
end
