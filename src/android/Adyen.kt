package com.dynamify.plugin.adyen;

import android.content.Context
import android.content.Intent
import com.adyen.checkout.core.AdyenLogLevel
import com.adyen.checkout.core.AdyenLogger
import com.adyen.checkout.sessions.core.SessionModel
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaPlugin
import org.apache.cordova.LOG
import org.json.JSONArray
import org.json.JSONObject

class Adyen : CordovaPlugin() {

    companion object {
        private const val LOG_TAG = "AdyenPlugin"
    }

    override fun execute(
        action: String?,
        args: JSONArray?,
        callbackContext: CallbackContext?
    ): Boolean {
        LOG.d(LOG_TAG, "Executing action: $action")
        if (action == "requestCharge") {
            if (args != null && args.length() > 0) {
                try {
                    val options = args.getJSONObject(0) // Assuming options is the first element in args
                    val paymentRequest = parsePaymentRequest(options)
                    LOG.d(LOG_TAG, "Parsed payment request: $paymentRequest")
                    val context: Context = cordova.activity.applicationContext
                    openNewActivity(context, paymentRequest)
                    return true
                } catch (e: Exception) {
                    LOG.e(LOG_TAG, "Error parsing payment request", e)
                    callbackContext?.error("Error parsing payment request: ${e.message}")
                    return false
                }
            } else {
                LOG.e(LOG_TAG, "No options provided")
                callbackContext?.error("No options provided")
                return false
            }
        }
        return false
    }

    private fun openNewActivity(context: Context, paymentRequest: PaymentRequest) {
        AdyenLogger.setLogLevel(
              AdyenLogLevel.DEBUG
        )
        val intent = Intent(context, NewActivity::class.java)
        val sessionModel: SessionModel = SessionModel.SERIALIZER.deserialize(paymentRequestToJson(paymentRequest))
        intent.putExtra("sessionModel", sessionModel)
        intent.putExtra("clientKey", paymentRequest.clientKey)
        cordova.activity.startActivity(intent)
        cordova.activity.runOnUiThread {  }
    }

    private fun parsePaymentRequest(options: JSONObject): PaymentRequest {
        val amountJson = options.getJSONObject(PaymentRequest.FIELD_AMOUNT)
        val amount = Amount(
            currency = amountJson.optString(PaymentRequest.FIELD_CURRENCY, PaymentRequest.DEFAULT_CURRENCY),
            value = amountJson.optInt(PaymentRequest.FIELD_VALUE, 0)
        )

        return PaymentRequest(
            amount = amount,
            countryCode = options.optString(PaymentRequest.FIELD_COUNTRY_CODE, PaymentRequest.DEFAULT_COUNTRY_CODE),
            expiresAt = options.getString(PaymentRequest.FIELD_EXPIRES_AT),
            id = options.getString(PaymentRequest.FIELD_ID),
            merchantAccount = options.getString(PaymentRequest.FIELD_MERCHANT_ACCOUNT),
            reference = options.getString(PaymentRequest.FIELD_REFERENCE),
            returnUrl = options.getString(PaymentRequest.FIELD_RETURN_URL),
            shopperLocale = options.optString(PaymentRequest.FIELD_SHOPPER_LOCALE, PaymentRequest.DEFAULT_LOCALE),
            mode = options.optString(PaymentRequest.FIELD_MODE, PaymentRequest.DEFAULT_MODE),
            sessionData = options.getString(PaymentRequest.FIELD_SESSION_DATA),
            clientKey = options.getString(PaymentRequest.FIELD_CLIENT_KEY)
        )
    }

    private fun paymentRequestToJson(paymentRequest: PaymentRequest): JSONObject {
        return JSONObject().apply {
            put(PaymentRequest.FIELD_AMOUNT, JSONObject().apply {
                put(PaymentRequest.FIELD_CURRENCY, paymentRequest.amount.currency)
                put(PaymentRequest.FIELD_CURRENCY, paymentRequest.amount.value)
            })
            put(PaymentRequest.FIELD_COUNTRY_CODE, paymentRequest.countryCode)
            put(PaymentRequest.FIELD_EXPIRES_AT, paymentRequest.expiresAt)
            put(PaymentRequest.FIELD_ID, paymentRequest.id)
            put(PaymentRequest.FIELD_MERCHANT_ACCOUNT, paymentRequest.merchantAccount)
            put(PaymentRequest.FIELD_REFERENCE, paymentRequest.reference)
            put(PaymentRequest.FIELD_RETURN_URL, paymentRequest.returnUrl)
            put(PaymentRequest.FIELD_SHOPPER_LOCALE, paymentRequest.shopperLocale)
            put(PaymentRequest.FIELD_MODE, paymentRequest.mode)
            put(PaymentRequest.FIELD_SESSION_DATA, paymentRequest.sessionData)
        }
    }
}

data class Amount(
    val currency: String,
    val value: Int
)

data class PaymentRequest(
    val amount: Amount,
    val countryCode: String,
    val expiresAt: String,
    val id: String,
    val merchantAccount: String,
    val reference: String,
    val returnUrl: String,
    val shopperLocale: String,
    val mode: String,
    val sessionData: String,
    val clientKey: String
) {
    companion object {
        const val FIELD_AMOUNT = "amount"
        const val FIELD_CURRENCY = "currency"
        const val FIELD_VALUE = "value"
        const val FIELD_COUNTRY_CODE = "countryCode"
        const val FIELD_EXPIRES_AT = "expiresAt"
        const val FIELD_ID = "id"
        const val FIELD_MERCHANT_ACCOUNT = "merchantAccount"
        const val FIELD_REFERENCE = "reference"
        const val FIELD_RETURN_URL = "returnUrl"
        const val FIELD_SHOPPER_LOCALE = "shopperLocale"
        const val FIELD_MODE = "mode"
        const val FIELD_SESSION_DATA = "sessionData"
        const val DEFAULT_CURRENCY = "EUR"
        const val DEFAULT_COUNTRY_CODE = "NL"
        const val DEFAULT_LOCALE = "en-US"
        const val DEFAULT_MODE = "embedded"
        const val FIELD_CLIENT_KEY = "clientKey"
    }
}