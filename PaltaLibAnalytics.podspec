Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibAnalytics'
  spec.version               = '2.2.4'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Analytics'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "analytics-v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '11.0'
  spec.swift_versions        = '5.3'

  spec.source_files = 'Sources/Analytics/**/*.swift'

  spec.dependency 'PaltaLibCore', '2.3.1'
  spec.dependency 'Amplitude', '>= 8.5.0'
end

