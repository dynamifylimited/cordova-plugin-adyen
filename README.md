# Cordova Freedompay Google Pay integration

> This is a fork of https://www.npmjs.com/package/cordova-plugin-apple-pay-google-pay with the addition of an Android environment preference to allow for testing and producing screenshots of your buyflow for [submission to Google](https://developers.google.com/pay/api/android/guides/brand-guidelines#put-it-all-together).

This plugin is built as unified method for obtaining payment tokens to forward it to your [supported payment processor](https://developers.google.com/pay/api#participating-processors) .


## Installation

```
cordova plugin add https://github.com/dynamifylimited/cordova-plugin-freedompay-googlepay
```
```


For testing and producing screenshots of your buyflow for submission to Google:
```
<preference name="GooglePayEnvironment" value="test" />
```

## Usage

`canMakePayments()` checks whether device is capable to make payments via Google Pay.

```
// use as plain Promise
async function checkForApplePayOrGooglePay(){
    let isAvailable = await cordova.plugins.FreedompayGooglePay.canMakePayments()
}

// OR
let available;

cordova.plugins.FreedompayGooglePay.canMakePayments((r) => {
  available = r
})
```

`makePaymentRequest()` initiates pay session.

```
let request = {
    merchantId: 'merchant.com.example', // obtain it from https://developer.apple.com/account/resources/identifiers/list/merchant
    purpose: `Payment for your order #1`,
    amount: 100,
    countryCode: "US",
    currencyCode: "USD"
}

cordova.plugins.FreedompayGooglePay.makePaymentRequest(request, r => {
        // in success callback, raw response as encoded JSON is returned. Pass it to your payment processor as is.
      let responseString = r

      },
      r => {
        // in error callback, error message is returned.
        // it will be "Payment cancelled" if used pressed Cancel button.
      }
   )
```

All parameters in request object are required.

## For Android

You will have to provide few extra parameters:

```
request.gateway = 'freedompay'; // or any another processor you are using: https://developers.google.com/pay/api#participating-processors
request.merchantId = 'XXXXXXX'; // merchant id provided by your processor
request.gpMerchantName = 'Your Company Name'; // will be displayed in transaction info
request.gpMerchantId = 'XXXXXXXXXXXX'; // obtain it at https://pay.google.com/business/console
```

Also, on Android checking payment availability calling `canMakePayments()` always returns false even if user has a valid card attached to GooglePay.
