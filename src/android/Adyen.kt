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

    override fun execute(
        action: String?,
        args: JSONArray?,
        callbackContext: CallbackContext?
    ): Boolean {
        LOG.d("here", "action", action)
        LOG.d("here", "args", args)
        if (action == "requestCharge") {
           LOG.d("here", "in request charge")

            val context: Context = cordova.activity.applicationContext
            openNewActivity(context)
           
        }
        return false
    }

      private fun openNewActivity(context: Context) {
          AdyenLogger.setLogLevel(
              AdyenLogLevel.DEBUG
          )
        val intent = Intent(context, NewActivity::class.java)
          val sessionModel: SessionModel = SessionModel.SERIALIZER.deserialize(getSessionJson())
          val clientKey:String = "test_5UZIW4YRQRB67IPVCWRT4VIHBMXGQ2NS"
          intent.putExtra("sessionModel", sessionModel)
          intent.putExtra("clientKey", clientKey)

        cordova.activity.startActivity(intent)


    }

    private fun getSessionJson():JSONObject {
        val sessionData:String = "Ab02b4c0!BQABAgABVjGTsY1+LhuySOC08AywTH6PF5jddJWui0yjiKZQ+oINB9DVwQl2Z+FCZ1m/7gK3DsvY1XnipEDwtMm0jA6SDQ228zr/UPD1XV48w6vHs+T3iQxpyVQAY/RtxnHNBafSKDFZhdY9E5quxAiL6gE/odUizLo+f0G3ptCKNlwv0IDuQhWefGCm6n6jRrCgLQDTvXFFXPPOjLKbu4tL2zE6YhqB+iEGEif7S85aFiy3YjSW7Iz9c4gvCsuHDWy4oYG+LDDU0/gZMLMFaEOL9MeSS2DOWDQcEuGob6soE2YYuGQv9XBnCYkDKLaxPVSUivtY5H+sGa7FCASYN9e5oOWKTqmcAO9GAbUjdzVvKEorUVfsUc+RcpnUGdgrZnaEXM7q6/DxzYOkn0JilqpOWaDhb6OslPFWIrWAgN0FAIR0DazhJbaPjRR2PxtK364CbrkuT3ZV7NxjLNwaT+kR6wz1Fpcm2+vxepb/2gOm1p1guMWaQvXgXQHxuBOecFtE4qR658AN+NsY9t9my9G/CXZiHgvNBcHxsr5rqvIBA/zAvx1lGxnT/53IAypjQvHs+rxje77AbjP9l+6GCgYIqmkFJvQaY4vcaU+MYYluA766xhf5rbIc2EOvPznEm/+h1UMHjHPD8V4QD04AOZo/eEmgL8EvdNXQrnZi4WbFkKqCcQzuS6faB5ysxaDUNyEASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9kybKvMVRg72Vcxzs/XGLtMqCyV5ndAEJF1xLGDmrvd+b7hOK1UpY2Va6Nwrh0vPE/1P6b+MJA2pFMqSPXFMlrm+Hyfb07UjjNZ8+fx0fJB4dA3oRMGAHa6gvEKUzAWw4UUZW3IdIea8U7jjW8TJzxuPIqrTfoZUHcDP7SkPIzH8LhdUCjpB1bAFTVrvDiHjOf8kBR4aRcD6ejpQe4XNYkJGLHyZG2EEd5UA+v9FcfFABf3TvX484Hu4xp2uLqY7ynV42YFJ8Rech5VEnem8hVTZ2ckiZ4mLnidztU+S5BaERFvyLGsCmWIXLEUUcJ7Qmp6b8qSkGiHLnefp0WZWkAfXjt4aodsp26oxZZ1P5JHWfC9wDfdVJRaxLhgMr9ut7NTnwiq7jUBOua4aNESEmqdQSRxR6K6lhu2wf8Od9tf+ZBAA+KwyIuVoIM6RlPzY56iFf1bsMkNVEMIEDoQH8QqztEAY63e2YINDxeuxPqWrHXme28OugXdYnmfLw+VYs1bZ+pVrmf3mNquS9dSNUxBJuRXwwVKmmOFwjDojW+yxLH1xsuHcgY0ky5IXCbCyOY+pvPt72YTYvexKBlcq2iU3CgdVRjX3P+juL26HWHSTAJG0axiQna1D8ZSYyrJGywMA2sPYz8VhWxA=="
        return JSONObject().put(
            "amount", JSONObject()
                .put("currency", "AUD")
                .put("value", 100))
            .put("countryCode", "AU")
            .put("expiresAt", "2024-06-18T18:59:05+02:00")
            .put("id", "CS375C07F6971E58F3")
            .put("merchantAccount", "DynamifyLimited696ECOM")
            .put("reference", "test-payment")
            .put("returnUrl", "https://your-company.com/checkout?shopperOrder=12xy..")
            .put("shopperLocale", "en-US")
            .put("mode", "embedded")
            .put("sessionData",sessionData)
    }
}