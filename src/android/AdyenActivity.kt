package com.dynamify.plugin.adyen;

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.adyen.checkout.core.Environment
import com.adyen.checkout.core.exception.CheckoutException
import com.adyen.checkout.dropin.DropIn
import com.adyen.checkout.dropin.SessionDropInCallback
import com.adyen.checkout.dropin.SessionDropInResult
import com.adyen.checkout.dropin.internal.ui.model.SessionDropInResultContractParams
import com.adyen.checkout.sessions.core.CheckoutSession
import com.adyen.checkout.sessions.core.CheckoutSessionProvider
import com.adyen.checkout.sessions.core.CheckoutSessionResult
import com.adyen.checkout.sessions.core.SessionModel
import com.adyen.checkout.sessions.core.SessionPaymentResult
import com.adyen.checkout.core.CheckoutConfiguration
import com.adyen.checkout.googlepay.GooglePayConfiguration
import com.google.android.gms.wallet.WalletConstants
import kotlinx.coroutines.launch
import org.apache.cordova.LOG

class AdyenActivity: AppCompatActivity() {

    companion object {
        private const val LOG_TAG = "AdyenActivity"
    }

    private lateinit var dropInLauncher: ActivityResultLauncher<SessionDropInResultContractParams>
    private lateinit var sessionModel: SessionModel
    private lateinit var clientKey: String
    private lateinit var countryCode: String
    private var isTesting: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        LOG.d(LOG_TAG, "on create")
        super.onCreate(savedInstanceState)
        dropInLauncher = DropIn.registerForDropInResult(this,  AdyenSessionDropInCallback(this))
        sessionModel = intent.getParcelableExtra("sessionModel") ?: run {
            handleCheckoutSessionError(CheckoutException("SessionModel is missing"))
            return
        }
        clientKey = intent.getStringExtra("clientKey") ?: run {
            handleCheckoutSessionError(CheckoutException("ClientKey is missing"))
            return
        }

        countryCode = intent.getStringExtra("countryCode") ?: run {
            handleCheckoutSessionError(CheckoutException("countryCode is missing"))
            return
        }

        isTesting = intent.getBooleanExtra("isTesting", false)

        createPaymentSession(sessionModel, clientKey, countryCode, isTesting)
    }

    private fun createPaymentSession(sessionModel: SessionModel, clientKey: String, countryCode: String, isTesting: Boolean) {
        LOG.d(LOG_TAG, "creating payment sessions for client key: $clientKey")
        lifecycleScope.launch {
            LOG.d(LOG_TAG, "calling CheckoutSessionProvider.createSession")
            val result = CheckoutSessionProvider.createSession(sessionModel, getEnvironmentFromCountryCode(countryCode,isTesting), clientKey)
            when (result) {
                is CheckoutSessionResult.Success -> handleCheckoutSessionSuccess(result.checkoutSession)
                is CheckoutSessionResult.Error -> handleCheckoutSessionError(result.exception)
                else -> handleCheckoutSessionError(CheckoutException("Unexpected resul from CheckoutSessionProvider"))
            }
        }
    }

    private fun getEnvironmentFromCountryCode(countryCode: String, isTesting: Boolean): Environment {
        if (isTesting) {
            return Environment.TEST
        }

        return when (countryCode.uppercase()) {
            "AU" -> Environment.AUSTRALIA
            "US" -> Environment.UNITED_STATES

            // Europe (most EU merchant accounts)
            "NL", "DE", "FR", "BE", "ES", "IT", "PT", "IE",
            "AT", "FI", "SE", "NO", "DK", "PL", "CZ", "SK",
            "HU", "RO", "BG", "HR", "SI", "LT", "LV", "EE",
            "LU", "MT", "CY", "GR" -> Environment.EUROPE

            // United Kingdom
            "GB", "UK" -> Environment.EUROPE

            // Canada (Adyen routes via US live)
            "CA" -> Environment.UNITED_STATES

            // Default fallback (IMPORTANT: must be live, not TEST)
            else -> Environment.EUROPE
        }
    }

    private fun handleCheckoutSessionError(exception: CheckoutException) {
        LOG.e(LOG_TAG, "Error while creating checkout session: ${exception.message}", exception)
        setResultAndFinish(PaymentStatus.ERROR, Activity.RESULT_CANCELED)
    }

    private fun handleCheckoutSessionSuccess(checkoutSession: CheckoutSession) {
        try {
            // Read Google Pay values passed from the Cordova plugin
            val googlePayMerchantName = intent.getStringExtra("googlePayMerchantName")
            val googlePayMerchantId = intent.getStringExtra("googlePayMerchantId")
            val googlePayGatewayMerchantId = intent.getStringExtra("googlePayGatewayMerchantId")
            val hasGooglePayConfig =
                !googlePayMerchantName.isNullOrBlank() &&
                        !googlePayMerchantId.isNullOrBlank() &&
                        !googlePayGatewayMerchantId.isNullOrBlank()

            if (hasGooglePayConfig) {
                val adyenEnv = getEnvironmentFromCountryCode(countryCode, isTesting)
                val googlePayConfig = GooglePayConfiguration.Builder(this, clientKey, adyenEnv)
                    .setGooglePayEnvironment(
                        if (isTesting) WalletConstants.ENVIRONMENT_TEST
                        else WalletConstants.ENVIRONMENT_PRODUCTION
                    )
                    .setMerchantName(googlePayMerchantName!!)
                    .setMerchantId(googlePayMerchantId!!)
                    .setGatewayMerchantId(googlePayGatewayMerchantId!!)
                    .build()

                val checkoutConfig = CheckoutConfiguration.Builder(this, clientKey, adyenEnv)
                    .addGooglePayConfiguration(googlePayConfig)
                    .build()

                DropIn.startPayment(this, dropInLauncher, checkoutSession, checkoutConfig)
            } else {
                // Google Pay not configured → start Drop-in without it
                DropIn.startPayment(this, dropInLauncher, checkoutSession)
            }
        } catch (e: Exception) {
            LOG.e(LOG_TAG, "Error starting DropIn payment: ${e.message}", e)
            setResultAndFinish(PaymentStatus.ERROR, Activity.RESULT_CANCELED)
        }
    }

    private fun setResultAndFinish(resultCode: String, activityResultCodes: Int) {
        val data = Intent().apply {
            putExtra("resultCode", resultCode)
        }
        LOG.d(LOG_TAG, "Setting result with data and finishing activity")
        showAlert(resultCode, data, activityResultCodes)
    }

    private fun showAlert(resultCode: String, data: Intent, activityResultCodes: Int) {
        val message = if (resultCode == "Authorised") "Success" else resultCode
        AlertDialog.Builder(this)
            .setTitle("Payment Status")
            .setMessage(message)
            .setPositiveButton("OK") { _, _ ->
                LOG.d(LOG_TAG, "Setting result with data and finishing activity")
                this.setResult(activityResultCodes, data)
                this.finish()
            }
            .setCancelable(false)
            .show()
    }

}


class AdyenSessionDropInCallback(private val activity: Activity): SessionDropInCallback {

    companion object {
        private const val LOG_TAG = "AdyenSessionDropInCallback"
    }

    private fun handleDropInFinished(result: SessionPaymentResult) {
        when (result.resultCode) {
            PaymentStatus.AUTHORISED, PaymentStatus.PENDING, PaymentStatus.RECEIVED -> {
                setResultAndFinish(result.resultCode.toString(), Activity.RESULT_OK)
            } else -> {
            setResultAndFinish(result.resultCode.toString(), Activity.RESULT_CANCELED)
        }
        }
    }

    private fun handleDropInError(reason: String?) {
        setResultAndFinish(PaymentStatus.ERROR, Activity.RESULT_CANCELED)
    }

    private fun handleDropInCancelledByUser() {
        setResultAndFinish(PaymentStatus.CANCELLED, Activity.RESULT_OK)
    }

    private fun handleUnexpectedState() {
        setResultAndFinish(PaymentStatus.ERROR, Activity.RESULT_CANCELED)
    }

    private fun setResultAndFinish(resultCode: String, activityResultCodes: Int) {
        val data = Intent().apply {
            putExtra("resultCode", resultCode)
        }
        LOG.d(LOG_TAG, "Setting result with data and finishing activity")
        showAlert(resultCode, data, activityResultCodes)
    }

    private fun showAlert(resultCode: String, data: Intent, activityResultCodes: Int) {
        when (resultCode) {
            PaymentStatus.CANCELLED -> {
                activity.setResult(activityResultCodes, data)
                activity.finish()
            } else -> {
            val message = if (resultCode == "Authorised") "Success" else resultCode
            AlertDialog.Builder(activity)
                .setTitle("Payment Status")
                .setMessage(message)
                .setPositiveButton("OK") { _, _ ->
                    LOG.d(LOG_TAG, "Setting result with data and finishing activity")
                    activity.setResult(activityResultCodes, data)
                    activity.finish()
                }
                .setCancelable(false)
                .show()
            }
        }
    }

    override fun onDropInResult(sessionDropInResult: SessionDropInResult?) {
        LOG.d(LOG_TAG, sessionDropInResult.toString())
        when (sessionDropInResult) {
            // The payment finishes with a result.
            is SessionDropInResult.Finished -> handleDropInFinished(sessionDropInResult.result)
            // The shopper dismisses Drop-in.
            is SessionDropInResult.CancelledByUser -> handleDropInCancelledByUser()
            // Drop-in encounters an error.
            is SessionDropInResult.Error -> handleDropInError(sessionDropInResult.reason)
            // Drop-in encounters an unexpected state.
            null -> handleUnexpectedState()
        }
    }
}

object PaymentStatus {
    const val AUTHORISED = "Authorised"
    const val PENDING = "Pending"
    const val RECEIVED = "Received"
    const val CANCELLED = "Cancelled"
    const val ERROR = "Error"
}