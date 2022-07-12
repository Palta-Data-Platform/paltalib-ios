Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibEventsTransport'
  spec.version               = '0.0.1'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Template for event schema generation'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "events-v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '10.0'
  spec.swift_versions        = '5.3'
  spec.source_files = 'Sources/EventsTransport/**/*.swift'
  spec.module_name = 'PaltaAnlyticsTransport'
end
