# Cordova Square Android plugin

> A plugin for Square pos implementation for android. 

## Installation

```
cordova plugin add https://github.com/dynamifylimited/cordova-plugin-judopay-googlepay
```
```


For testing and producing screenshots of your buyflow for submission to Google:
```
<preference name="GooglePayEnvironment" value="test" />
```

## Usage

`makePaymentRequest()` initiates pay session.

```
 let request = {
    amount: decimalTotal,
    countryCode: countryCode,
    currencyCode: currencyCode,
    judoId: judopayIdForGooglePay,
    token: judopayApiTokenForGooglePay,
    paymentSession: reference,
      consumerReference: consumerReference
  };
cordova.plugins.JudopayGooglePay.makePaymentRequest(request).then(function (receiptId) {
        // in success callback, raw response as encoded JSON is returned. Pass it to your payment processor as is.
     
   })
```

All parameters in request object are required.

