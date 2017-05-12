platform :ios, '10.0'
workspace 'Pelotonia'
inhibit_all_warnings!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/socialize/SocializeCocoaPods.git'

target "Pelotonia" do
    pod 'Socialize', :podspec => 'https://raw.github.com/socialize/socialize-sdk-ios/master/Socialize.podspec'
    pod 'hpple', '~> 0.2'
    pod 'AFNetworking'
    pod 'Appirater'
    pod 'MBProgressHUD'
    pod 'SDWebImage'
    pod 'UIActivityIndicator-for-SDWebImage'
    pod 'ECSlidingViewController'
    pod 'AAPullToRefresh'
    pod 'MagicalRecord'
    pod 'TTTAttributedLabel'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
        end
    end
end
