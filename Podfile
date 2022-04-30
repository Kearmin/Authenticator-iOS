project 'Authenticator-iOS/Authenticator-iOS.xcodeproj'

platform :ios, '15.0'

$basePath = './Modules'
$featurePath = $basePath + '/Feature/'
$businessPath = $basePath + '/Business/'
$infrastructurePath = $basePath + '/Infrastructure/'

use_frameworks!

def featureModules 
  pod "AddAccountBusiness", :path => $featurePath + 'AddAccount/AddAccountBusiness'
  pod "AddAccountView", :path => $featurePath + 'AddAccount/AddAccountView'
  pod "AuthenticatorListBusiness", :path => $featurePath + 'AuthenticatorList/AuthenticatorListBusiness'
  pod "AuthenticatorListView", :path => $featurePath + 'AuthenticatorList/AuthenticatorListView'
end

def businessModules 
  pod "AccountRepository", :path => $businessPath + 'AccountRepository'
  pod "Clock", :path => $businessPath + 'Clock'
end

def infrastructureModules 
  pod "UIKitNavigator", :path => $infrastructurePath + 'UIKitNavigator'
  pod "FileSystemPersistentStorage", :path => $infrastructurePath + 'FileSystemPersistentStorage'
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
