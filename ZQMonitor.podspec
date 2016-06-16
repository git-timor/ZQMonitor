#
# Be sure to run `pod lib lint ZQMonitor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZQMonitor'
  s.version          = '0.1.0'
  s.summary          = 'A Monitor demo from Yoosee of ZQMonitor.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: A Monitor demo from Yoosee of ZQMonitor.代码为MRC,需要包含框架'Foundation', 'CoreGraphics', 'UIKit','OpenGLES','OpenAL','MediaToolbox','MediaPlayer','AVFoundation','CoreVideo','CoreMedia','CoreAudio','QuartzCore','SystemConfiguration','libstdc++.6.0.9.tdb'.
                       DESC

  s.homepage         = 'https://github.com/git-timor/ZQMonitor'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZQ' => '1163018319@qq.com' }
  s.source           = { :git => 'https://github.com/git-timor/ZQMonitor.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZQMonitor/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZQMonitor' => ['ZQMonitor/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'UIKit','OpenGLES','OpenAL','MediaToolbox','MediaPlayer','AVFoundation','CoreVideo','CoreMedia','CoreAudio','QuartzCore','SystemConfiguration','libstdc++.6.0.9.tdb'
   s.dependency 'AFNetworking','FMDatabase','ComboBox','SDWebImageSample','KTPhotoBrowser','libPwdEncrypt','DXPopover','MPNotificationView','OBGradientView','JSBadgeView','MJRefresh','libqrencode','GCDAsyncUpdSocket','IDJPickerView','YLLabel','SVPullToRefresh','Toast','MBProgressHUD'
end
