Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLibCore'
  spec.version               = '2.2.0'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK - Core part'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "core-v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '10.0'
  spec.swift_versions        = '5.3'
  spec.source_files = 'Sources/Core/**/*.swift'
end

