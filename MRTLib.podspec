Pod::Spec.new do |s|
  s.name         = "MRTLib"
  s.version      = "0.5.0"
  s.summary      = "A library to help calculating routes for Taipei MRT."
  s.description  = "A library to help calculating routes for Taipei MRT."

  s.homepage     = "https://github.com/zonble/MRTSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  
  s.author             = { "zonble" => "zonble@gmail.com" }
  s.social_media_url   = "http://twitter.com/zonble"

  s.ios.deployment_target = "9.0"
  # s.osx.deployment_target = "10.10"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/zonble/MRTSwift.git", :tag => "#{s.version}" }

  s.source_files  = "Sources/MRTLib/*.swift"
  s.requires_arc = true
  s.resources = "Sources/MRTLib/address.txt", "Sources/MRTLib/data.sqlite", "Sources/MRTLib/data.txt"
  s.library = 'sqlite3'
  s.module_map = 'sqlite3.modulemap'

end
