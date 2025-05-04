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
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.libraries = 'c++'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'GCC_ENABLE_CPP_EXCEPTIONS' => 'NO',
    'GCC_ENABLE_CPP_RTTI' => 'YES',
    'OTHER_CPLUSPLUSFLAGS' => '$(inherited)', # Add specific C++ flags
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) APP_REV=\\"a804e0950\\" APP_VERSION=\\"0.21.0-beta.5+3\\" CONFIG_VERSION=\\"2021-03-27\\"',
    'HEADER_SEARCH_PATHS' => '$(inherited) ' +
      ' "${PODS_TARGET_SRCROOT}/../src/third_party/quickjs/include" '  +
      ' "${PODS_TARGET_SRCROOT}/../src/third_party/gumbo-parser/src" ' +
      ' "${PODS_TARGET_SRCROOT}/../src/third_party/modp_b64/include" ' +
      ' "${PODS_TARGET_SRCROOT}/../src/third_party/dart/include"'
  }
  s.swift_version = '5.0'
end
