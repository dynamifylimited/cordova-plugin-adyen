package com.plugin.googlepay;

import android.app.Activity;
import android.content.Intent;
import androidx.annotation.NonNull;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.wallet.*;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.judopay.judokit.android.Judo;
import com.judopay.judokit.android.JudoActivity;
import com.judopay.judokit.android.api.model.PaymentSessionAuthorization;
import com.judopay.judokit.android.model.Amount;
import com.judopay.judokit.android.model.Currency;
import com.judopay.judokit.android.model.GooglePayConfiguration;
import com.judopay.judokit.android.model.PaymentWidgetType;
import com.judopay.judokit.android.model.Reference;
import com.judopay.judokit.android.model.googlepay.GooglePayAddressFormat;
import com.judopay.judokit.android.model.googlepay.GooglePayBillingAddressParameters;
import com.judopay.judokit.android.model.googlepay.GooglePayEnvironment;
import com.judopay.judokit.android.model.googlepay.GooglePayShippingAddressParameters;

import java.util.Arrays;

//import java.util.concurrent.Executor;

/**
 * Google Pay implementation for Cordova
 */
public class GooglePay extends CordovaPlugin {
    private static final int LOAD_PAYMENT_DATA_REQUEST_CODE = 991;
    // private PaymentsClient paymentsClient;

    private CallbackContext callbackContext;

    // private JSONArray allowedCardAuthMethods = new JSONArray(
    //         Arrays.asList(
    //                 "CRYPTOGRAM_3DS",
    //                 "PAN_ONLY"
    //         )
    // );

    // private JSONArray allowedCardNetworks = new JSONArray(
    //         Arrays.asList(
    //                 "MASTERCARD",
    //                 "VISA",
    //                 "AMEX",
    //                 "DISCOVER",
    //                 "JCB"
    //         )
    // );

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        // String environment = preferences.getString("GooglePayEnvironment", "production");

        // Wallet.WalletOptions walletOptions = new Wallet.WalletOptions.Builder().setEnvironment(
        //         environment.equals("production") ? WalletConstants.ENVIRONMENT_PRODUCTION : WalletConstants.ENVIRONMENT_TEST
        // ).build();

        // Activity activity = cordova.getActivity();

        // paymentsClient = Wallet.getPaymentsClient(activity, walletOptions);

        // if (action.equals("canMakePayments")) {
        //     this.canMakePayments(args, callbackContext);
        //     return true;
        // }
        if (action.equals("makePaymentRequest")) {
            this.makePaymentRequest(args, callbackContext);
            return true;
        }
        // if (action.equals("test")) {
        //     this.test(args, callbackContext);
        //     return true;
        // }

        return false;
    }

    /**
     * Handle a resolved activity from the Google Pay payment sheet.
     *
     * @param requestCode Request code originally supplied to AutoResolveHelper in requestPayment().
     * @param resultCode  Result code returned by the Google Pay API.
     * @param data        Intent from the Google Pay API containing payment or error data.
     * @see <a href="https://developer.android.com/training/basics/intents/result">Getting a result
     * from an Activity</a>
     */
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        // value passed in AutoResolveHelper
        if (requestCode != LOAD_PAYMENT_DATA_REQUEST_CODE) {
            return;
        }

        switch (resultCode) {

            case Activity.RESULT_OK:
                PaymentData paymentData = PaymentData.getFromIntent(data);
                String paymentInfo = paymentData.toJson();
                callbackContext.success(paymentInfo);
                break;

            case Activity.RESULT_CANCELED:
                callbackContext.error("Payment cancelled");
                break;

            case AutoResolveHelper.RESULT_ERROR:
                Status status = AutoResolveHelper.getStatusFromIntent(data);
                callbackContext.error(status.getStatusMessage());
                break;
        }
    }

    // private void canMakePayments(JSONArray args, CallbackContext callbackContext) throws JSONException {

    //     // The call to isReadyToPay is asynchronous and returns a Task. We need to provide an
    //     // OnCompleteListener to be triggered when the result of the call is known.
    //     IsReadyToPayRequest request = IsReadyToPayRequest.newBuilder()
    //             .addAllowedPaymentMethod(WalletConstants.PAYMENT_METHOD_TOKENIZED_CARD)
    //             .build();

    //     Task<Boolean> task = paymentsClient.isReadyToPay(request);

    //     task.addOnCompleteListener(cordova.getActivity(),
    //             new OnCompleteListener<Boolean>() {
    //                 @Override
    //                 public void onComplete(@NonNull Task<Boolean> task) {
    //                     boolean result = task.isSuccessful();

    //                     callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, result));
    //                 }
    //             });

    // }

    private void makePaymentRequest(JSONArray args, CallbackContext callbackContext) throws JSONException {
        JSONObject argss = args.getJSONObject(0);
        Activity activity = cordova.getActivity();
        cordova.setActivityResultCallback(this);

        this.callbackContext = callbackContext;

        try {
            String price = getParam(argss, "amount");
            String currencyCode = getParam(argss, "currencyCode");
            String judoId = getParam(argss, "judoId");
            String token = getParam(argss, "token");
            String countryCode = getParam(argss, "countryCode");
            String paymentSession = getParam(argss, "paymentSession");
            String consumerReference = getParam(argss, "consumerReference");

            Amount amount = new Amount.Builder()
            .setAmount(price)
            .setCurrency(Currency.GBP)
            .build();

            Reference reference = new Reference.Builder()
                    .setConsumerReference(consumerReference)
                    .build();


            PaymentSessionAuthorization paymentSessionAuthorization = new PaymentSessionAuthorization.Builder()
                    .setApiToken(token)
                    .setPaymentSession(paymentSession)
                    .build();

            GooglePayBillingAddressParameters billingAddressParams = new GooglePayBillingAddressParameters(
                    GooglePayAddressFormat.MIN,
                    true
            );

            GooglePayShippingAddressParameters shippingAddressParams = new GooglePayShippingAddressParameters(
                    null, true
            );

            GooglePayConfiguration googlePayConfiguration = new GooglePayConfiguration.Builder()
                    .setTransactionCountryCode(countryCode)
                    .setEnvironment(GooglePayEnvironment.TEST)
                    .setIsEmailRequired(true)
                    .setIsBillingAddressRequired(true)
                    .setBillingAddressParameters(billingAddressParams)
                    .setIsShippingAddressRequired(true)
                    .setShippingAddressParameters(shippingAddressParams)
                    .build();


            Judo judo = new Judo.Builder(PaymentWidgetType.GOOGLE_PAY)
                        .setAmount(amount)
                        .setJudoId(judoId)
                        .setGooglePayConfiguration(googlePayConfiguration)
                        .setAuthorization(paymentSessionAuthorization)
                        .setReference(reference)
                        .build();

            Intent intent = new Intent(this.cordova.getActivity().getApplicationContext(), JudoActivity.class);
            intent.putExtra("com.judopay.judokit.android.options", judo);
            cordova.getActivity().startActivityForResult(intent, 1);

        } catch (JSONException e) {
            callbackContext.error(e.getMessage());
        }
    }


    /**
     * Gateway Integration: Identify your gateway and your app's gateway merchant identifier.
     *
     * <p>The Google Pay API response will return an encrypted payment method capable of being charged
     * by a supported gateway after payer authorization.
     *
     * <p>TODO: Check with your gateway on the parameters to pass and modify them in Constants.java.
     *
     * @return Payment data tokenization for the CARD payment method.
     * @throws JSONException
     * @see <a href=
     * "https://developers.google.com/pay/api/android/reference/object#PaymentMethodTokenizationSpecification">PaymentMethodTokenizationSpecification</a>
     */
    // private static JSONObject getGatewayTokenizationSpecification(String gateway, String gatewayMerchantId) throws JSONException {
    //     return new JSONObject() {{
    //         put("type", "PAYMENT_GATEWAY");
    //         put("parameters", new JSONObject() {{
    //             put("gateway", gateway);
    //             put("gatewayMerchantId", gatewayMerchantId);
    //         }});
    //     }};
    // }


    /**
     * Describe your app's support for the CARD payment method.
     *
     * <p>The provided properties are applicable to both an IsReadyToPayRequest and a
     * PaymentDataRequest.
     *
     * @return A CARD PaymentMethod object describing accepted cards.
     * @throws JSONException
     * @see <a
     * href="https://developers.google.com/pay/api/android/reference/object#PaymentMethod">PaymentMethod</a>
     */
    // private JSONObject getBaseCardPaymentMethod() throws JSONException {
    //     JSONObject cardPaymentMethod = new JSONObject();
    //     cardPaymentMethod.put("type", "CARD");

    //     JSONObject parameters = new JSONObject();
    //     parameters.put("allowedAuthMethods", allowedCardAuthMethods);
    //     parameters.put("allowedCardNetworks", allowedCardNetworks);
    //     cardPaymentMethod.put("parameters", parameters);

    //     return cardPaymentMethod;
    // }

    /**
     * Describe the expected returned payment data for the CARD payment method
     *
     * @return A CARD PaymentMethod describing accepted cards and optional fields.
     * @throws JSONException
     * @see <a
     * href="https://developers.google.com/pay/api/android/reference/object#PaymentMethod">PaymentMethod</a>
     */
    // private JSONObject getCardPaymentMethod(String gateway, String gatewayMerchantId) throws JSONException {
    //     JSONObject cardPaymentMethod = getBaseCardPaymentMethod();
    //     cardPaymentMethod.put("tokenizationSpecification", getGatewayTokenizationSpecification(gateway, gatewayMerchantId));

    //     return cardPaymentMethod;
    // }

    // private static JSONObject getBaseRequest() throws JSONException {
    //     return new JSONObject().put("apiVersion", 2).put("apiVersionMinor", 0);
    // }

    /**
     * Provide Google Pay API with a payment amount, currency, and amount status.
     *
     * @return information about the requested payment.
     * @throws JSONException
     * @see <a
     * href="https://developers.google.com/pay/api/android/reference/object#TransactionInfo">TransactionInfo</a>
     */
    // private JSONObject getTransactionInfo(String price, String currencyCode, String countryCode) throws JSONException {
    //     JSONObject transactionInfo = new JSONObject();
    //     transactionInfo.put("totalPrice", price);
    //     transactionInfo.put("totalPriceStatus", "FINAL");
    //     transactionInfo.put("countryCode", countryCode);
    //     transactionInfo.put("currencyCode", currencyCode);
    //     transactionInfo.put("checkoutOption", "COMPLETE_IMMEDIATE_PURCHASE");

    //     return transactionInfo;
    // }


    private String getParam(JSONObject args, String name) throws JSONException {
        String param = args.getString(name);

        if (param == null || param.length() == 0) {
            throw new JSONException(String.format("%s is required", name));
        }

        return param;
    }

}
