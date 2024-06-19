package Adyen

import com.adyen.checkout.dropin.SessionDropInCallback
import com.adyen.checkout.dropin.SessionDropInResult
import com.adyen.checkout.dropin.SessionDropInService

class ExampleDropInService: SessionDropInCallback  {
    override fun onDropInResult(sessionDropInResult: SessionDropInResult?) {
        TODO("Not yet implemented")
    }
}