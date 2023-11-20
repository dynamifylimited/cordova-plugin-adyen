package com.plugin.dynamify;

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
import com.judopay.judokit.android.model.JudoError;
import com.judopay.judokit.android.model.JudoResult;
import com.judopay.judokit.android.model.PaymentWidgetType;
import com.judopay.judokit.android.model.Reference;
import com.judopay.judokit.android.model.googlepay.GooglePayAddressFormat;
import com.judopay.judokit.android.model.googlepay.GooglePayBillingAddressParameters;
import com.judopay.judokit.android.model.googlepay.GooglePayEnvironment;
import com.judopay.judokit.android.model.googlepay.GooglePayShippingAddressParameters;

import java.util.Arrays;

/**
 * Google Pay implementation for Cordova
 */
public class JudopayGooglePay extends CordovaPlugin {
    private static final int LOAD_PAYMENT_DATA_REQUEST_CODE = 991;
    private static final int PAYMENT_CANCELLED = 3;
    private static final int PAYMENT_SUCCESS = 2;
    private static final int PAYMENT_ERROR = 4;
    private static final int JUDO_PAYMENT_WIDGET_REQUEST_CODE = 1;

    private static final String JUDO_RESULT =  "com.judopay.judokit.android.result";
    private static final String JUDO_ERROR =  "com.judopay.judokit.android.error";
    private static final String JUDO_OPTIONS = "com.judopay.judokit.android.options";


    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        if (action.equals("makePaymentRequest")) {
            this.makePaymentRequest(args, callbackContext);
            return true;
        }

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
        if(requestCode == JUDO_PAYMENT_WIDGET_REQUEST_CODE) {
            switch (resultCode) {
                case PAYMENT_CANCELLED:
                    callbackContext.error("User cancelled the payment");
                    break;

                case PAYMENT_SUCCESS:
                    callbackContext.success(data.getParcelableExtra(JUDO_RESULT, JudoResult.class).getReceiptId());
                    break;

                case PAYMENT_ERROR:
                    callbackContext.error(data.getParcelableExtra(JUDO_ERROR, JudoError.class).getMessage());
                    break;
            }

        }
    }


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
                    .setEnvironment(GooglePayEnvironment.PRODUCTION)
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
            intent.putExtra(JUDO_OPTIONS, judo);
            cordova.setActivityResultCallback(this);
            cordova.getActivity().startActivityForResult(intent, JUDO_PAYMENT_WIDGET_REQUEST_CODE);

        } catch (JSONException e) {
            callbackContext.error(e.getMessage());
        }
    }

    private String getParam(JSONObject args, String name) throws JSONException {
        String param = args.getString(name);

        if (param == null || param.length() == 0) {
            throw new JSONException(String.format("%s is required", name));
        }

        return param;
    }

}
