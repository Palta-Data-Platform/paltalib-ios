Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibEvents'
  spec.version               = '1.0.1'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Template for event schema generation'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "events-v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '10.0'
  spec.swift_versions        = '5.3'
  spec.source_files = 'Sources/Events/**/*.{swift,m}'
  spec.module_name = 'PaltaEvents'
  
  spec.dependency 'PaltaLibAnalytics', '~> 3.0.1'
  spec.dependency 'PaltaLibEventsTransport', '~> 1.0.0'
end
