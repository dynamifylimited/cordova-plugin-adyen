package com.dynamify.plugin.adyen;

import Adyen.ExampleDropInService
import android.Manifest
import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.PersistableBundle
import android.widget.Toast
import androidx.activity.result.ActivityResultLauncher
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
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
import com.dynamify.elior.R
import kotlinx.coroutines.launch
import org.apache.cordova.LOG

class NewActivity: AppCompatActivity() {

    companion object {
        private var instance: NewActivity? = null

        fun getInstance(): NewActivity? {
            return instance
        }
    }

    private lateinit var dropInLauncher: ActivityResultLauncher<SessionDropInResultContractParams>
    private lateinit var sessionModel: SessionModel
    private lateinit var clientKey: String
    override fun onCreate(savedInstanceState: Bundle?) {
        LOG.d("CREATE", "on create")
        super.onCreate(savedInstanceState)
        val packageName: String = application.packageName
        setContentView(application.resources.getIdentifier("activity_new", "layout", packageName))
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
        lifecycleScope.launch {
            val result = CheckoutSessionProvider.createSession(sessionModel, Environment.TEST, clientKey)
            when (result) {
                is CheckoutSessionResult.Success -> handleCheckoutSession(result.checkoutSession)
                is CheckoutSessionResult.Error -> handleError(result.exception)
                else -> {}

        }
        }
    }

    private fun handleError(exception: CheckoutException) {
        val data = Intent().apply {
            putExtra("error", exception.message)
        }
        this.setResult(Activity.RESULT_OK, data)
        this.finish()
    }

    private fun handleCheckoutSession(checkoutSession: CheckoutSession) {
        DropIn.startPayment(this, dropInLauncher, checkoutSession)
    }


}


class AdyenSessionDropInCallback(private val activity: Activity): SessionDropInCallback {
    private fun handleResult(result: SessionPaymentResult) {
        val data = Intent().apply {
            putExtra("paymentResult", result.toString())
        }
        activity.setResult(Activity.RESULT_OK, data)
        activity.finish()
    }

    private fun handleError(reason: String?) {
        val data = Intent().apply {
            putExtra("error", reason)
        }
        activity.setResult(Activity.RESULT_OK, data)
        activity.finish()
    }


    override fun onDropInResult(sessionDropInResult: SessionDropInResult?) {
       LOG.d("SESSION_DROPIN_CALLBACK", sessionDropInResult.toString())
        when (sessionDropInResult) {
            // The payment finishes with a result.
            is SessionDropInResult.Finished -> handleResult(sessionDropInResult.result)
            // The shopper dismisses Drop-in.
            is SessionDropInResult.CancelledByUser -> {
                activity.setResult(Activity.RESULT_CANCELED)
                activity.finish()
            }
            // Drop-in encounters an error.
            is SessionDropInResult.Error -> handleError(sessionDropInResult.reason)
            // Drop-in encounters an unexpected state.
            null -> { }
        }
    }

}