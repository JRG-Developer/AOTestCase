Pod::Spec.new do |s|
  s.platform     = :ios
  s.ios.deployment_target = "6.0"
  s.name         = "AOTestCase"
  s.version      = "1.0.0"
  s.summary      = "AOTestCase subclasses XCTestCase and adds easy-to-use method swizzling and asynchronous test support"
  s.homepage     = "https://github.com/JRG-Developer/AOTestCase.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Joshua Greene" => "jrg.developer@gmail.com" }
  s.source   	   = { :git => "https://github.com/JRG-Developer/AOTestCase.git", :tag => "#{s.version}"}
  s.framework    = "XCTestCase"
  s.requires_arc = true
  s.source_files = "AOTestCase/*.{h,m}"
end