Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLib'
  spec.version               = '1.0.0'
  spec.license               = 'MIT'
  spec.summary               = 'Simple wrapper around Amplitude-iOS'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "v#{spec.version}" }
  spec.source_files          = 'Sources/PaltaLib/**/*.swift'
  spec.requires_arc          = true
  spec.ios.deployment_target = '10.0'
  spec.swift_versions        = '5.3'

  spec.dependency 'Amplitude', '~> 8.3.0'
end
