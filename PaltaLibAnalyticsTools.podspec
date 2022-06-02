Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibAnalyticsTools'
  spec.version               = '0.1.0'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Tools for analytics'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "tools-v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '10.0'
  spec.swift_versions        = '5.3'
  spec.source_files = 'Sources/AnalyticsTools/**/*.swift'
  spec.module_name = 'AnalyticsTools'
end
