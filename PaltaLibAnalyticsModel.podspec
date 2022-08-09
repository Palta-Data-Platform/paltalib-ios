Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibAnalyticsModel'
  spec.version               = '1.0.0-beta'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Analytics model'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "analyticsmodel-v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '10.0'
  spec.swift_versions        = '5.3'

  spec.source_files = 'Sources/AnalyticsModel/**/*.swift'
end

