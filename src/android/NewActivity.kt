package com.dynamify.plugin.adyen;

import android.app.Activity
import android.os.Bundle
import android.os.PersistableBundle
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
    private lateinit var binding: ActivityMainBinding
    override fun onCreate(savedInstanceState: Bundle?) {
        LOG.d("CREATE", "on create")
        super.onCreate(savedInstanceState)
        val packageName: String = application.packageName
        setContentView(application.resources.getIdentifier("activity_new", "layout", packageName))
        dropInLauncher = DropIn.registerForDropInResult(this,  AdyenSessionDropInCallback())
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
                else -> {

                }

        }
        }
    }

    private fun handleError(exception: CheckoutException) {

    }

    private fun handleCheckoutSession(checkoutSession: CheckoutSession) {
        DropIn.startPayment(this, dropInLauncher, checkoutSession)
    }


}



class AdyenSessionDropInCallback: SessionDropInCallback {
    override fun onDropInResult(sessionDropInResult: SessionDropInResult?) {
       LOG.d("SESSION_DROPIN_CALLBACK", sessionDropInResult.toString())
    }

}