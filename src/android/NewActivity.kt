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
import kotlinx.coroutines.launch
import org.apache.cordova.LOG

class NewActivity: AppCompatActivity() {

    companion object {
        private const val LOG_TAG = "NewActivity"
        private var instance: NewActivity? = null

        fun getInstance(): NewActivity? {
            return instance
        }
    }

    private lateinit var dropInLauncher: ActivityResultLauncher<SessionDropInResultContractParams>
    private lateinit var sessionModel: SessionModel
    private lateinit var clientKey: String

    override fun onCreate(savedInstanceState: Bundle?) {
        LOG.d(LOG_TAG, "on create")
        super.onCreate(savedInstanceState)
        dropInLauncher = DropIn.registerForDropInResult(this,  AdyenSessionDropInCallback(this))
        sessionModel = intent.getParcelableExtra<SessionModel>("sessionModel")!!
        clientKey = intent.getStringExtra("clientKey").toString()
        instance = this
        sessionModel?.let { model ->
            clientKey?.let { key ->
                // Call createPaymentSession with non-null data
                createPaymentSession(model, key)
            }
        }
    }

    private fun createPaymentSession(sessionModel: SessionModel, clientKey: String) {
        LOG.d(LOG_TAG, "creating payment sessions for client key: $clientKey")
        lifecycleScope.launch {
            LOG.d(LOG_TAG, "calling CheckoutSessionProvider.createSession")
            val result = CheckoutSessionProvider.createSession(sessionModel, Environment.TEST, clientKey)
            when (result) {
                is CheckoutSessionResult.Success -> handleCheckoutSessionSuccess(result.checkoutSession)
                is CheckoutSessionResult.Error -> handleCheckoutSessionError(result.exception)
                else -> {}
            }
        }
    }

    private fun handleCheckoutSessionError(exception: CheckoutException) {
        LOG.d(LOG_TAG, "Error while creating checkout sessions")
        setResultAndFinish("Error", Activity.RESULT_CANCELED)
    }

    private fun handleCheckoutSessionSuccess(checkoutSession: CheckoutSession) {
        try {
            DropIn.startPayment(this, dropInLauncher, checkoutSession)
        } catch (e: Exception) {
            LOG.e(LOG_TAG, "Error starting DropIn payment: ${e.message}", e)
            setResultAndFinish("Error", Activity.RESULT_CANCELED)
        }
    }

    private fun setResultAndFinish(resultCode: String, activityResultCodes: Int) {
        val data = Intent().apply {
            putExtra("resultCode", resultCode)
        }
        LOG.d(LOG_TAG, "Setting result with data and finishing activity")
        showAlert(resultCode, data, activityResultCodes)
//        this.setResult(activityResultCodes, data)
//        this.finish()
    }

    private fun showAlert(resultCode: String, data: Intent, activityResultCodes: Int) {
        AlertDialog.Builder(this)
            .setTitle("Payment Status")
            .setMessage(resultCode)
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
            "Authorised", "Pending", "Received", -> {
                setResultAndFinish(result.resultCode.toString(), Activity.RESULT_OK)
            } else -> {
            setResultAndFinish(result.resultCode.toString(), Activity.RESULT_CANCELED)
        }
        }
    }

    private fun handleDropInError(reason: String?) {
        setResultAndFinish("Error", Activity.RESULT_CANCELED)
    }

    private fun handleDropInCancelledByUser() {
        setResultAndFinish("Cancelled", Activity.RESULT_OK)
    }

    private fun handleUnexpectedState() {
        setResultAndFinish("Error", Activity.RESULT_CANCELED)
    }

    private fun setResultAndFinish(resultCode: String, activityResultCodes: Int) {
        val data = Intent().apply {
            putExtra("resultCode", resultCode)
        }
        LOG.d(LOG_TAG, "Setting result with data and finishing activity")
        showAlert(resultCode, data, activityResultCodes)
//        activity.setResult(activityResultCodes, data)
//        activity.finish()
    }

    private fun showAlert(resultCode: String, data: Intent, activityResultCodes: Int) {
        when (resultCode) {
            "Cancelled" -> {
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