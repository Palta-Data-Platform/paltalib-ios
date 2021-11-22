Pod::Spec.new do |spec|
  spec.name                  = 'PaltaLib'
  spec.version               = '2.0.0'
  spec.license               = 'MIT'
  spec.summary               = 'PaltaLib iOS SDK'
  spec.homepage              = 'https://github.com/Palta-Data-Platform/paltalib-ios'
  spec.author                = { "Palta" => "dev@palta.com" }
  spec.source                = { :git => 'https://github.com/Palta-Data-Platform/paltalib-ios.git', :tag => "v#{spec.version}" }
  spec.requires_arc          = true
  spec.static_framework      = true
  spec.ios.deployment_target = '10.0'
  spec.swift_versions        = '5.3'
  spec.default_subspecs      = 'Core', 'Analytics', 'Purchases', 'Attribution'

  spec.subspec "Core" do |spec|
    spec.source_files = 'Sources/Core/**/*.swift'
  end

  spec.subspec "Analytics" do |spec|
    spec.source_files = 'Sources/Analytics/**/*.swift'
    spec.dependency 'PaltaLib/Core'
    spec.dependency 'Amplitude', '~> 8.4.0'
  end

  spec.subspec "Purchases" do |spec|
    spec.source_files = 'Sources/Purchases/**/*.swift'
    spec.dependency 'PaltaLib/Core'
    spec.dependency 'PaltaLib/Analytics'
    spec.dependency 'PaltaLib/Attribution'
    spec.dependency 'Purchases', '~> 3.12.6'
  end

  spec.subspec "Attribution" do |spec|
    spec.source_files = 'Sources/Attribution/**/*.swift'
    spec.dependency 'PaltaLib/Core'
    spec.dependency 'AppsFlyerFramework', '~> 6.4.0'
  end
end