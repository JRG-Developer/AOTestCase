Pod::Spec.new do |s|
  s.platform     = :ios
  s.ios.deployment_target = "6.0"
  s.name         = "AOTestCase"
  s.version      = "1.0.2"
  s.summary      = "AOTestCase subclasses XCTestCase and adds asynchronous unit test support, method swizzling, and a category for associating objects."
  s.homepage     = "https://github.com/JRG-Developer/AOTestCase.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Joshua Greene" => "jrg.developer@gmail.com" }
  s.source   	   = { :git => "https://github.com/JRG-Developer/AOTestCase.git", :tag => "#{s.version}"}
  s.framework    = "XCTest"
  s.requires_arc = true
  s.source_files = "AOTestCase/*.{h,m}"
end