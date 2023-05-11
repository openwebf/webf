#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'webf'
  s.version          = '0.14.0'
  s.summary          = 'Build flutter apps with HTML/CSS and JavaScript.'
  s.description      = <<-DESC
  WebF (Web on Flutter) is a W3C standards-compliant web rendering engine based on Flutter, allowing web applications to run natively on Flutter.
                       DESC
  s.homepage         = 'https://openwebf.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'OpenWebF' => 'dongtiangche@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.prepare_command = 'bash prepare.sh'
  s.vendored_frameworks = 'Frameworks/*.xcframework'
  s.resource = 'Frameworks/*.*'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
