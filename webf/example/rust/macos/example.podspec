Pod::Spec.new do |spec|
  spec.name         = 'example_app'
  spec.version      = '1.0.0'
  spec.summary      = 'App built with Rust.'
  spec.description  = <<-DESC
                       A longer description of YourLibrary.
                       DESC
  spec.homepage     = 'https://example.com/YourLibrary'
  spec.license      = 'MIT'
  spec.author       = { 'Your Name' => 'your.email@example.com' }
  spec.platform     = :osx, '10.11'
  spec.source       = { :path => '.' }
  spec.vendored_libraries = 'libexample_app.dylib'
end
