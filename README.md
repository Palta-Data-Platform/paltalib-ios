# PaltaLib

PaltaLib is a set of internal Palta libraries and wrappers around popular third-party SDKs

## Products

| Product | Module name | Description |
| ------- | ----------- | ----------- |
| [Analytics](#analytics) | `PaltaLibAnalytics` | Used to send events to Palta Data Platform. |
| [Payments](#purchases) | `PaltaLibPurchases` | A single entry point to subscriptions management through IAPs, web subscriptions etc |

## Installing

### CocoaPods

Add necessary pods to your `Podfile`:

```ruby
pod 'PaltaLibAnalytics'
pod 'PaltaLibPurchases'
```

### Swift Package Manager

```swift
.package(url: "https://github.com/Palta-Data-Platform/paltalib-ios.git", branch: "main")
```

## Usage

### Analytics

`PaltaAnalytics` should be configured on app start 
```swift
PaltaAnalytics.instance.configure(
    name: "Your_application_name",
    amplitudeAPIKey: Constants.amplitudeApiKey,
    paltaAPIKey: Constants.paltaAPIKey
)
```

`amplitudeAPIKey` and `paltaAPIKey` parameters are optional and can be omitted in case you don't need one of them.  
After this call, `PaltaAnalytics` will fetch remote config and will act accordingly.

After configuration you can use `PaltaAnalytics.instance` for all event tracking logic such as:

- `logEvent(_:withEventProperties:withGroups:outOfSession:)`
- `logRevenueV2(_:)`
- `setUserProperties(_:)`
- `setUserId(_:)`

### Attribution

`PaltaAttribution` should be configured on app start 

```swift
private func setupAttribution() {
    PaltaAttribution.instance.delegate = self

    PaltaAttribution.instance.configureWith(
        appsFlyerDevKey: Constants.appsflyerKey,
        appleAppID: "\(Constants.appID)",
        userID: userID,
        useUninstallSandbox: !Environment.isRelease
    )

    if shouldRequestAppTracking {
        PaltaAttribution.instance.waitForATTUserAuthorization(with: 60)
    }
}
```

It is also **required** to call some methods of PaltaAttribution in response on UIApplicationDelegate events

There are all of them:

```swift
func applicationDidBecomeActive(_ application: UIApplication) {
    ...
    PaltaAttribution.instance.start()
}

func application(_: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    if ... {
        return true
    } else if PaltaAttribution.instance.open(url: url, options: options) {
        return true
    }

    return true
}

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    ...
    PaltaAttribution.instance.registerDeviceToken(deviceToken)
}

func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    ...
    return PaltaAttribution.instance.continueUserActivity(userActivity, restorationHandler: restorationHandler)
}
```

PaltaAttribution delegate methods are using for conversion, attribution and deep linking processing. 

### Purchases

`PaltaLibPurchases` module is using for native purchases performing and payment status handling. `PaltaPurchases` should be configured on app start 
```swift
private func setupPaltaPurchases() {
    PaltaPurchases.configureWith(revenueCatApiKey: Constants.revenueCatPublicAPIKey,
                                 userID: userIDProvider.userID,
                                 revenueCatDebugLogsEnabled: Environment.isDebug,
                                 webSubscriptionID: "zing-stage-zing")
}
```

You can use next extension for simple payment status handling (applicable only if you're using only single entitlement, i.e. only one premium access level)
```swift 
extension PaltaPurchases {
    static let premiumEntitlement = "your_project_entitlement_name"
}

extension PurchaserInfo {
    var isPurchased: Bool {
        return entitlements
            .first(where: { $0.name == PaltaPurchases.premiumEntitlement })?
            .isActive ?? false
    }
}
```
 
 Use `subscribeOnPurchaserInfoUpdated(_)` method to handle payment status changes, example
 
 ```swift
var observerToken: AnyObject?
...
...
...
{
    observerToken = purchases.subscribeOnPurchaserInfoUpdated { info in
        let isPurchased = info.isPurchased
        // handle purchase status change, update UI elements
    }
 }
 ```
 
 ### Web subscriptions support 
 
- Make sure you implement `PaltaAttributionDelegate` and pass **userID** to PaltaPurchases and other internal services once received

```swift
extension InternalService: PaltaAttributionDelegate {
    func didReceiveUserID(_ attribution: PaltaAttribution, userID: String) {
        PaltaPurchases.instance.configure(userID: userID) { result in
        switch result {
            // add logging or any internal completion calls
            }
        }
    }
```
- Make sure **Associated domains** capability enabled both on Developer portal for AppID, on on main Application target. Appsflyer provided domain name should be set up in project and in entitlements files **applinks:your_domain.onelink.me**
- Make sure **Application prefix** (or team name) set for Appsflyer OneLink template (Appsflyer console)
- Web subscription entitlement has separate type (web), see **PurchaseEntitlement.source**
- Use methods from **PaltaPurchases+WebSubscriptions.swift** for web subscription restore and cancellation

```swift
public func sendRestoreLink(to email: String, completion: @escaping (Result<Void, Error>) -> Void)

public func cancelSubscription(completion: @escaping (Result<Void, Error>) -> Void)
```


