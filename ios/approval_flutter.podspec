#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint approval_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'approval_flutter'
  s.version          = '0.0.1'
  s.summary          = 'CreditChek Approval Flutter Plugin'
  s.description      = <<-DESC
Flutter plugin bridging to the native CreditChek Approval iOS SDK.
                       DESC
  s.homepage         = 'https://creditchek.africa'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CreditChek' => 'support@creditchek.africa' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  # s.dependency 'approval_ios'
  s.vendored_frameworks = 'Frameworks/approval_ios.xcframework'
  s.platform         = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version    = '5.9'
end
