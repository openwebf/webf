#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint webf.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'webf'
  s.version          = '0.22.0'
  s.summary          = 'A W3C standard compliant Web rendering engine based on Flutter.'
  s.description      = <<-DESC
A W3C standard compliant Web rendering engine based on Flutter..
                       DESC
  s.homepage         = 'https://openwebf.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'WebF' => 'andycall@openwebf.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'FlutterMacOS'
  s.vendored_libraries = 'libwebf.dylib', 'libquickjs.dylib'
  s.prepare_command = 'bash prepare.sh'

  s.platform = :osx, '12'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
