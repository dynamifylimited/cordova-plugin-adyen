# Cordova Adyen mobile plugin

> A plugin for Adyen pos implementation for android and iOS.

## Installation

```
cordova plugin add https://github.com/abhinax4991/cordova-plugin-adyen
```
```

## Usage

`requestCharge()` initiates pay session.

```
const credentialsRequestBody = {
currencyCode,
countryCode,
storeId: $scope.store.id,
amount: saleAmount
}

AdyenService.getAdyenCredentials(credentialsRequestBody).then(function(credentialsData) {
cordova.plugins.adyen.requestCharge(credentialsData.data, function (requestChargeData) {
// in success callback, raw response as encoded JSON is returned. Pass it to your payment processor as is.

    });
});
```

All parameters in request object are required.

