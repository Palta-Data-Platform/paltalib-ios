# PaltaLib

Simple wrapper around [Amplitude-iOS](https://github.com/amplitude/Amplitude-iOS)

<br/>

## Installing

### Swift Package Manager

```swift
.package(url: "https://github.com/Palta-Data-Platform/paltalib-ios.git", branch: "master")
```

### CocoaPods

Add the following to your `Podfile`:

```ruby

```

<br/>

## Usage

`PaltaLib` should be configured on app start with `configure(name:amplitudeAPIKey:paltaAPIKey:)` method.  
`amplitudeAPIKey` and `paltaAPIKey` parameters are optional and can be omitted in case you don't need one of them.  
In addition you can add custom target by specifying `name`, `apiKey` and `serverURL` (optional) with `addTarget(_:)` method.  

After configuration you can use `PaltaLib.instance` for all amplitude logic such us:

- `logEvent(_:withEventProperties:withGroups:outOfSession:)`
- `logRevenue(_:)`
- `setUserProperties(_:)`
- `setUserId(_:)`

<br/>

## Example

Using Amplitude directly:

```swift
// in application(_:willFinishLaunchingWithOptions:)
//
let appAmplitude = Amplitude.instance(withName: "<AppName>Amplitude")
appAmplitude.initializeApiKey("<YourAmplitudeAPIKey>")

let paltaAmplitude = Amplitude.instance(withName: "<AppName>Palta")
paltaAmplitude.initializeApiKey("<YourPaltabrainAPIKey>")
paltaAmplitude.setServerUrl(URL(string: "https://api.paltabrain.com/events/")!)

// ...
// somewhere later
//

let amplitudes = [
    Amplitude.instance(withName: "<AppName>Amplitude"),
    Amplitude.instance(withName: "<AppName>Palta")
]

instance.amplitureInstances.forEach {
    $0.logEvent(
        "Event Name",
        withEventProperties: [
            "key": "value"
        ]
     )
}

instance.amplitureInstances.forEach {
    let revenue = AMPRevenue()
    revenue.setProductIdentifier("com.appname.app.some.product.id")
    revenue.setPrice(29.99)

    $0.logRevenueV2(revenue)
}

instance.amplitureInstances.forEach {
    $0.setUserProperties(
        [
            "Property Name": "property_value",
            "Another Property Name": "another_property_value",
        ]
    )
}

```

Using PaltaLib:

```swift
// in application(_:willFinishLaunchingWithOptions:)
//
PaltaLib.configure(
    name: "<AppName>",
    amplitudeAPIKey: "<YourAmplitudeAPIKey>",
    paltaAPIKey: "<YourPaltabrainAPIKey>"
)

// ...
// somewhere later
//
PaltaLib.instance.logEvent(
    "Event Name",
    withEventProperties: [
        "key": "value"
    ]
)

PaltaLib.instance.logRevenue(
    from: "com.appname.app.some.product.id",
    price: 29.99
)

PaltaLib.instance.setUserProperties(
    [
        "Property Name": "property_value",
        "Another Property Name": "another_property_value"
    ]
)
```