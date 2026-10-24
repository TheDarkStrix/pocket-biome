package com.pocketbiome

import android.app.Activity
import android.app.ActivityManager
import android.app.ApplicationExitInfo
import android.os.Build
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.os.Bundle
import android.view.View
import androidx.core.content.FileProvider
import com.android.billingclient.api.*
import com.google.android.gms.ads.*
import com.google.android.gms.ads.rewarded.RewardedAd
import com.google.android.gms.ads.rewarded.RewardedAdLoadCallback
import com.google.android.gms.ads.interstitial.InterstitialAd
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback
import com.google.android.ump.*
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/** Development-only provider IDs. Production replacement requires explicit configuration. */
class PocketServices(godot: Godot) : GodotPlugin(godot), PurchasesUpdatedListener {
    override fun getPluginName() = "PocketServices"
    override fun getPluginSignals(): Set<SignalInfo> = setOf(
        SignalInfo("ad_ready", java.lang.Boolean::class.java),
        SignalInfo("interstitial_ready", java.lang.Boolean::class.java),
        SignalInfo("ad_rewarded", String::class.java),
        SignalInfo("ad_failed", String::class.java, String::class.java),
        SignalInfo("purchase_completed", String::class.java, String::class.java),
        SignalInfo("purchase_failed", String::class.java),
        SignalInfo("products_updated", String::class.java),
        SignalInfo("service_error", String::class.java)
    )
    private var rewarded: RewardedAd? = null
    private var interstitial: InterstitialAd? = null
    private var billing: BillingClient? = null
    private val catalog = mutableMapOf<String, ProductDetails>()
    private val awarded = mutableSetOf<String>()
    private var initialized = false
    private var pendingCrashTime = 0L
    private val productIds = listOf("pocket_biome_remove_ads_test", "pocket_biome_moon_theme_test", "pocket_biome_founders_test")

    override fun onMainCreate(activity: Activity?): View? {
        val host = activity ?: return null
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            try {
                File(host.filesDir, "pocket_java_crash.json").writeText(JSONObject()
                    .put("type", "java_uncaught_exception")
                    .put("timestamp",System.currentTimeMillis())
                    .put("exception", throwable.javaClass.name)
                    .put("stack", throwable.stackTraceToString().take(12000)).toString())
            } catch (_: Exception) { }
            previous?.uncaughtException(thread, throwable)
        }
        return null
    }
    @UsedByGodot fun pendingCrash(): String {
        val host = activity ?: return ""
        val file = File(host.filesDir, "pocket_java_crash.json")
        try {
            if (file.exists()) {
                val record = JSONObject(file.readText())
                pendingCrashTime = record.optLong("timestamp",System.currentTimeMillis())
                return record.toString()
            }
            if (Build.VERSION.SDK_INT >= 30) {
                val prefs = host.getSharedPreferences("pocket_diagnostics",0)
                val last = prefs.getLong("last_exit",0)
                val manager = host.getSystemService(Activity.ACTIVITY_SERVICE) as ActivityManager
                val exit = manager.getHistoricalProcessExitReasons(host.packageName,0,8).firstOrNull {
                    it.timestamp > last && it.reason in listOf(ApplicationExitInfo.REASON_CRASH,ApplicationExitInfo.REASON_CRASH_NATIVE,ApplicationExitInfo.REASON_ANR)
                }
                if (exit != null) {
                    pendingCrashTime = exit.timestamp
                    return JSONObject().put("type","android_process_exit").put("reason",exit.reason).put("status",exit.status).put("timestamp",exit.timestamp).put("description",exit.description?.take(500)).toString()
                }
            }
        } catch (_: Exception) { }
        return ""
    }
    @UsedByGodot fun clearCrash() {
        activity?.let {
            File(it.filesDir, "pocket_java_crash.json").delete()
            it.getSharedPreferences("pocket_diagnostics",0).edit().putLong("last_exit",pendingCrashTime).apply()
        }
    }
    @UsedByGodot fun initializeServices() {
        val host = activity ?: return
        host.runOnUiThread {
            if (initialized) { loadRewarded(); restorePurchases(); return@runOnUiThread }
            initialized = true
            initializeBilling(host)
            if ((host.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
                MobileAds.initialize(host) { loadRewarded(); loadInterstitial() }
                return@runOnUiThread
            }
            val consent = UserMessagingPlatform.getConsentInformation(host)
            consent.requestConsentInfoUpdate(host, ConsentRequestParameters.Builder().build(), {
                UserMessagingPlatform.loadAndShowConsentFormIfRequired(host) { error ->
                    if (error != null) emitSignal("service_error", "Consent unavailable: ${error.message}")
                    if (consent.canRequestAds()) MobileAds.initialize(host) { loadRewarded(); loadInterstitial() }
                }
            }, { error ->
                emitSignal("service_error", "Consent unavailable: ${error.message}. Offline gameplay remains available.")
                if (consent.canRequestAds()) MobileAds.initialize(host) { loadRewarded(); loadInterstitial() }
            })
        }
    }
    private fun loadRewarded() {
        val host = activity ?: return
        host.runOnUiThread {
            if ((host.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) == 0 && !UserMessagingPlatform.getConsentInformation(host).canRequestAds()) return@runOnUiThread
            RewardedAd.load(host, "ca-app-pub-3940256099942544/5224354917", AdRequest.Builder().build(), object: RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) { rewarded = ad; emitSignal("ad_ready", true) }
                override fun onAdFailedToLoad(error: LoadAdError) { rewarded = null; emitSignal("ad_ready", false) }
            })
        }
    }
    @UsedByGodot fun showRewarded(requestId: String) {
        val host = activity ?: return
        host.runOnUiThread {
            val ad = rewarded
            rewarded = null
            emitSignal("ad_ready", false)
            if (ad == null) { emitSignal("ad_failed", requestId, "No test ad is loaded"); return@runOnUiThread }
            var earned = false
            ad.fullScreenContentCallback = object: FullScreenContentCallback() {
                override fun onAdDismissedFullScreenContent() {
                    if (!earned) emitSignal("ad_failed", requestId, "The optional ad was closed before its reward")
                    loadRewarded()
                }
                override fun onAdFailedToShowFullScreenContent(error: AdError) { emitSignal("ad_failed", requestId, error.message); loadRewarded() }
            }
            ad.show(host) {
                earned = true
                if (awarded.add(requestId)) {
                    val prefs = host.getSharedPreferences("pocket_service_receipts",0)
                    val pending = (prefs.getStringSet("reward_ids",emptySet()) ?: emptySet()).toMutableSet()
                    pending.add(requestId)
                    prefs.edit().putStringSet("reward_ids",pending).commit()
                    emitSignal("ad_rewarded", requestId)
                }
            }
        }
    }
    private fun loadInterstitial() {
        val host = activity ?: return
        host.runOnUiThread {
            InterstitialAd.load(host,"ca-app-pub-3940256099942544/1033173712",AdRequest.Builder().build(),object: InterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: InterstitialAd) { interstitial = ad; emitSignal("interstitial_ready",true) }
                override fun onAdFailedToLoad(error: LoadAdError) { interstitial = null; emitSignal("interstitial_ready",false) }
            })
        }
    }
    @UsedByGodot fun pendingRewards(): String {
        val host = activity ?: return "[]"
        return JSONArray((host.getSharedPreferences("pocket_service_receipts",0).getStringSet("reward_ids",emptySet()) ?: emptySet()).toList()).toString()
    }
    @UsedByGodot fun acknowledgeReward(id: String) {
        val host = activity ?: return
        val prefs = host.getSharedPreferences("pocket_service_receipts",0)
        val pending = (prefs.getStringSet("reward_ids",emptySet()) ?: emptySet()).toMutableSet()
        pending.remove(id)
        prefs.edit().putStringSet("reward_ids",pending).commit()
    }
    @UsedByGodot fun showInterstitial() {
        val host = activity ?: return
        host.runOnUiThread {
            val ad = interstitial ?: return@runOnUiThread
            interstitial = null
            emitSignal("interstitial_ready",false)
            ad.fullScreenContentCallback = object: FullScreenContentCallback() {
                override fun onAdDismissedFullScreenContent() { loadInterstitial() }
                override fun onAdFailedToShowFullScreenContent(error: AdError) { loadInterstitial() }
            }
            ad.show(host)
        }
    }
    private fun initializeBilling(host: Activity) {
        billing = BillingClient.newBuilder(host).setListener(this)
            .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
            .enableAutoServiceReconnection().build()
        billing?.startConnection(object: BillingClientStateListener {
            override fun onBillingSetupFinished(result: BillingResult) {
                if (result.responseCode == BillingClient.BillingResponseCode.OK) { queryCatalog(); restorePurchases() }
                else emitSignal("service_error", "Play sandbox unavailable: ${result.debugMessage}")
            }
            override fun onBillingServiceDisconnected() { emitSignal("service_error", "Play store disconnected; gameplay is unaffected") }
        })
    }
    private fun queryCatalog() {
        val products = productIds.map { QueryProductDetailsParams.Product.newBuilder().setProductId(it).setProductType(BillingClient.ProductType.INAPP).build() }
        billing?.queryProductDetailsAsync(QueryProductDetailsParams.newBuilder().setProductList(products).build()) { result, response ->
            if (result.responseCode != BillingClient.BillingResponseCode.OK) { emitSignal("service_error",result.debugMessage); return@queryProductDetailsAsync }
            val array = JSONArray()
            response.productDetailsList.forEach { product ->
                catalog[product.productId] = product
                array.put(JSONObject().put("id",product.productId).put("name",product.name).put("price",product.oneTimePurchaseOfferDetails?.formattedPrice ?: "Unavailable"))
            }
            emitSignal("products_updated",array.toString())
        }
    }
    @UsedByGodot fun purchase(id: String) {
        val host = activity ?: return
        host.runOnUiThread {
            val product = catalog[id]
            if (product == null) { emitSignal("service_error","Test product not configured in the Play sandbox"); return@runOnUiThread }
            val builder = BillingFlowParams.ProductDetailsParams.newBuilder().setProductDetails(product)
            product.oneTimePurchaseOfferDetails?.offerToken?.let { if (it.isNotEmpty()) builder.setOfferToken(it) }
            val result = billing?.launchBillingFlow(host,BillingFlowParams.newBuilder().setProductDetailsParamsList(listOf(builder.build())).build())
            if (result?.responseCode != BillingClient.BillingResponseCode.OK) emitSignal("service_error",result?.debugMessage ?: "Billing unavailable")
        }
    }
    override fun onPurchasesUpdated(result: BillingResult, purchases: MutableList<Purchase>?) {
        if (result.responseCode == BillingClient.BillingResponseCode.OK) purchases?.forEach { processPurchase(it) }
        else {
            val message = if (result.responseCode == BillingClient.BillingResponseCode.USER_CANCELED) "Purchase canceled; nothing was granted" else result.debugMessage
            emitSignal("service_error",message)
            emitSignal("purchase_failed",message)
        }
    }
    private fun processPurchase(purchase: Purchase) {
        if (purchase.purchaseState != Purchase.PurchaseState.PURCHASED) return
        fun grant() { purchase.products.filter { productIds.contains(it) }.forEach { emitSignal("purchase_completed",it,purchase.purchaseToken) } }
        if (purchase.isAcknowledged) grant()
        else billing?.acknowledgePurchase(AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchase.purchaseToken).build()) { result ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) grant()
            else emitSignal("service_error","Purchase is pending acknowledgement; restore will retry")
        }
    }
    @UsedByGodot fun restorePurchases() {
        val client = billing ?: return
        client.queryPurchasesAsync(QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.INAPP).build()) { result, purchases ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) purchases.forEach { processPurchase(it) }
            else emitSignal("service_error","Restore unavailable: ${result.debugMessage}")
        }
    }
    @UsedByGodot fun shareImage(path: String) {
        val host = activity ?: return
        host.runOnUiThread {
            try {
                val source = File(path).canonicalFile
                if (!source.path.startsWith(host.filesDir.canonicalPath+File.separator)) throw SecurityException("Not an app photo")
                val dir = File(host.cacheDir,"shares").apply { mkdirs() }
                val copy = source.copyTo(File(dir,"pocket-biome.png"),true)
                val uri = FileProvider.getUriForFile(host,host.packageName+".pocket.share",copy)
                val intent = Intent(Intent.ACTION_SEND).setType("image/png").putExtra(Intent.EXTRA_STREAM,uri).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                host.startActivity(Intent.createChooser(intent,"Share your Pocket Biome"))
            } catch (error: Exception) { emitSignal("service_error","Photo sharing unavailable: ${error.message}") }
        }
    }
}
