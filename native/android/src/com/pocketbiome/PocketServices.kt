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
import com.google.android.gms.ads.RequestConfiguration
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
        SignalInfo("ad_lifecycle", String::class.java),
        SignalInfo("ad_ready", java.lang.Boolean::class.java),
        SignalInfo("interstitial_ready", java.lang.Boolean::class.java),
        SignalInfo("ad_rewarded", String::class.java),
        SignalInfo("ad_failed", String::class.java, String::class.java),
        SignalInfo("purchase_completed", String::class.java, String::class.java),
        SignalInfo("purchase_failed", String::class.java),
        SignalInfo("products_updated", String::class.java),
        SignalInfo("service_error", String::class.java)
    )
    private val adContexts = mutableMapOf<String,String>()
    private val breakContexts = setOf("chapter","habitat","river","expedition","expedition_replay","mastery")
    private fun adSetting(name: String): String {
        val host = activity ?: return ""
        val id = host.resources.getIdentifier("pocket_ads_$name","string",host.packageName)
        return if (id == 0) "" else host.getString(id)
    }
    private fun testAds(): Boolean {
        val host = activity ?: return true
        return (host.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0 || adSetting("mode") != "production"
    }
    private fun adUnit(kind: String): String = if (testAds()) {
        if (kind == "rewarded") "ca-app-pub-3940256099942544/5224354917" else "ca-app-pub-3940256099942544/1033173712"
    } else adSetting(kind+"_unit_id")
    private fun configureAdAudience() {
        val children = adSetting("audience") == "children_families"
        MobileAds.setRequestConfiguration(RequestConfiguration.Builder()
            .setMaxAdContentRating(if (children) RequestConfiguration.MAX_AD_CONTENT_RATING_G else RequestConfiguration.MAX_AD_CONTENT_RATING_PG)
            .setTagForChildDirectedTreatment(if (children) RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_TRUE else RequestConfiguration.TAG_FOR_CHILD_DIRECTED_TREATMENT_UNSPECIFIED)
            .setTagForUnderAgeOfConsent(if (children) RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_TRUE else RequestConfiguration.TAG_FOR_UNDER_AGE_OF_CONSENT_UNSPECIFIED).build())
    }
    private var adSequence = 0L
    private var rewardedPlacement = ""
    private var interstitialPlacement = ""
    private fun nextPlacement(kind: String): String { adSequence += 1; return "$kind:$adSequence" }
    private fun adLifecycle(event: String, kind: String, placement: String, value: AdValue? = null) {
        while (adContexts.size > 128) adContexts.remove(adContexts.keys.first())
        val data = JSONObject().put("event",event).put("kind",kind).put("placement",placement).put("context",adContexts[placement] ?: "")
        if (value != null) data.put("value_micros",value.valueMicros).put("currency",value.currencyCode).put("precision",value.precisionType)
        emitSignal("ad_lifecycle",data.toString())
    }
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
                if (host.getSharedPreferences("pocket_diagnostics",0).getBoolean("enabled",false))
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
        if (!host.getSharedPreferences("pocket_diagnostics",0).getBoolean("enabled",false)) return ""
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
    private var adsInitialized = false
    private var rewardedLoading = false
    private var interstitialLoading = false
    private var rewardedAttemptAt = -60000L
    private var interstitialAttemptAt = -60000L
    @UsedByGodot fun retryAds() {
        val host = activity ?: return
        host.runOnUiThread {
            if (!adsInitialized) return@runOnUiThread
            val now = android.os.SystemClock.elapsedRealtime()
            if (rewarded == null && !rewardedLoading && now-rewardedAttemptAt >= 60000L) loadRewarded()
            if (interstitial == null && !interstitialLoading && now-interstitialAttemptAt >= 60000L) loadInterstitial()
        }
    }
    @UsedByGodot fun initializeServices() {
        val host = activity ?: return
        host.runOnUiThread {
            configureAdAudience()
            if (!initialized) { initialized = true; if (adSetting("billing_enabled") != "false") initializeBilling(host) }
            else if (adSetting("billing_enabled") != "false") restorePurchases()
            if ((host.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
                MobileAds.initialize(host) { adsInitialized = true; loadRewarded(); loadInterstitial() }
                return@runOnUiThread
            }
            val consent = UserMessagingPlatform.getConsentInformation(host)
            consent.requestConsentInfoUpdate(host, ConsentRequestParameters.Builder().setTagForUnderAgeOfConsent(adSetting("audience") == "children_families").build(), {
                UserMessagingPlatform.loadAndShowConsentFormIfRequired(host) { error ->
                    if (error != null) emitSignal("service_error", "Consent unavailable: ${error.message}")
                    if (consent.canRequestAds()) MobileAds.initialize(host) { adsInitialized = true; loadRewarded(); loadInterstitial() }
                }
            }, { error ->
                emitSignal("service_error", "Consent unavailable: ${error.message}. Offline gameplay remains available.")
                if (consent.canRequestAds()) MobileAds.initialize(host) { adsInitialized = true; loadRewarded(); loadInterstitial() }
            })
        }
    }
    @UsedByGodot fun privacyOptionsRequired(): Boolean {
        val host = activity ?: return false
        return UserMessagingPlatform.getConsentInformation(host).privacyOptionsRequirementStatus ==
            ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED
    }
    @UsedByGodot fun showPrivacyOptions() {
        val host = activity ?: return
        host.runOnUiThread {
            if (!privacyOptionsRequired()) {
                emitSignal("service_error", "Ad privacy choices are not currently required or available")
                return@runOnUiThread
            }
            rewarded = null; interstitial = null
            emitSignal("ad_ready", false); emitSignal("interstitial_ready", false)
            UserMessagingPlatform.showPrivacyOptionsForm(host) { error ->
                if (error != null) emitSignal("service_error", "Privacy choices unavailable: ${error.message}")
                if (UserMessagingPlatform.getConsentInformation(host).canRequestAds()) {
                    MobileAds.initialize(host) { adsInitialized = true; loadRewarded(); loadInterstitial() }
                }
            }
        }
    }
    @UsedByGodot fun setDiagnosticsEnabled(enabled: Boolean) {
        val host = activity ?: return
        val prefs = host.getSharedPreferences("pocket_diagnostics",0)
        val update = prefs.edit().putBoolean("enabled",enabled)
        // Do not import Android process-exit records from a period without consent.
        if (enabled && !prefs.getBoolean("enabled",false)) update.putLong("last_exit",System.currentTimeMillis())
        update.apply()
    }
    @UsedByGodot fun deleteDiagnostics() {
        activity?.let { host ->
            File(host.filesDir, "pocket_java_crash.json").delete()
            host.getSharedPreferences("pocket_diagnostics",0).edit()
                .putLong("last_exit",System.currentTimeMillis()).apply()
        }
    }
    private fun loadRewarded() {
        val host = activity ?: return
        host.runOnUiThread {
            if ((host.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) == 0 && !UserMessagingPlatform.getConsentInformation(host).canRequestAds()) return@runOnUiThread
            if (rewardedLoading || rewarded != null) return@runOnUiThread
            rewardedLoading = true; rewardedAttemptAt = android.os.SystemClock.elapsedRealtime()
            val placement = nextPlacement("rewarded")
            adLifecycle("request","rewarded",placement)
            RewardedAd.load(host, adUnit("rewarded"), AdRequest.Builder().build(), object: RewardedAdLoadCallback() {
                override fun onAdLoaded(ad: RewardedAd) {
                    rewardedLoading = false; rewarded = ad; rewardedPlacement = placement
                    ad.setOnPaidEventListener { value -> adLifecycle("paid","rewarded",placement,value) }
                    adLifecycle("loaded","rewarded",placement); emitSignal("ad_ready", true)
                }
                override fun onAdFailedToLoad(error: LoadAdError) { rewardedLoading = false; rewarded = null; adLifecycle(if (error.code == AdRequest.ERROR_CODE_NO_FILL) "no_fill" else "load_failed","rewarded",placement); emitSignal("ad_ready", false) }
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
            if ((host.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) == 0 &&
                !UserMessagingPlatform.getConsentInformation(host).canRequestAds()) {
                emitSignal("ad_failed", requestId, "Ad privacy permission is unavailable")
                return@runOnUiThread
            }
            val placement = rewardedPlacement
            adLifecycle("show_requested","rewarded",placement)
            var earned = false
            ad.fullScreenContentCallback = object: FullScreenContentCallback() {
                override fun onAdImpression() { adLifecycle("impression","rewarded",placement) }
                override fun onAdDismissedFullScreenContent() {
                    adLifecycle("dismissed","rewarded",placement)
                    if (!earned) emitSignal("ad_failed", requestId, "The optional ad was closed before its reward")
                    loadRewarded()
                }
                override fun onAdFailedToShowFullScreenContent(error: AdError) { adLifecycle("show_failed","rewarded",placement); emitSignal("ad_failed", requestId, error.message); loadRewarded() }
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
            if ((host.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) == 0 && !UserMessagingPlatform.getConsentInformation(host).canRequestAds()) return@runOnUiThread
            if (interstitialLoading || interstitial != null) return@runOnUiThread
            interstitialLoading = true; interstitialAttemptAt = android.os.SystemClock.elapsedRealtime()
            val placement = nextPlacement("interstitial")
            adLifecycle("request","interstitial",placement)
            InterstitialAd.load(host,adUnit("interstitial"),AdRequest.Builder().build(),object: InterstitialAdLoadCallback() {
                override fun onAdLoaded(ad: InterstitialAd) {
                    interstitialLoading = false; interstitial = ad; interstitialPlacement = placement
                    ad.setOnPaidEventListener { value -> adLifecycle("paid","interstitial",placement,value) }
                    adLifecycle("loaded","interstitial",placement); emitSignal("interstitial_ready",true)
                }
                override fun onAdFailedToLoad(error: LoadAdError) { interstitialLoading = false; interstitial = null; adLifecycle(if (error.code == AdRequest.ERROR_CODE_NO_FILL) "no_fill" else "load_failed","interstitial",placement); emitSignal("interstitial_ready",false) }
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
    @UsedByGodot fun showInterstitial() { showInterstitialAt("chapter") }
    @UsedByGodot fun showInterstitialAt(context: String) {
        val host = activity ?: return
        if (context !in breakContexts) return
        val requestedAt = android.os.SystemClock.elapsedRealtime()
        host.runOnUiThread {
            fun fail() {
                val token = nextPlacement("interstitial-unavailable")
                adContexts[token] = context
                adLifecycle("show_failed","interstitial",token)
            }
            // Never wait for an ad to load or present a delayed surprise.
            if (android.os.SystemClock.elapsedRealtime()-requestedAt > 1500L) { fail(); return@runOnUiThread }
            if (!testAds() && !UserMessagingPlatform.getConsentInformation(host).canRequestAds()) {
                interstitial = null; emitSignal("interstitial_ready",false); fail(); return@runOnUiThread
            }
            val ad = interstitial
            if (ad == null) { emitSignal("interstitial_ready",false); fail(); return@runOnUiThread }
            interstitial = null
            emitSignal("interstitial_ready",false)
            val placement = interstitialPlacement
            adContexts[placement] = context
            while (adContexts.size > 128) adContexts.remove(adContexts.keys.first())
            adLifecycle("show_requested","interstitial",placement)
            ad.fullScreenContentCallback = object: FullScreenContentCallback() {
                override fun onAdImpression() { adLifecycle("impression","interstitial",placement) }
                override fun onAdDismissedFullScreenContent() { adLifecycle("dismissed","interstitial",placement); loadInterstitial() }
                override fun onAdFailedToShowFullScreenContent(error: AdError) { adLifecycle("show_failed","interstitial",placement); loadInterstitial() }
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
        if (adSetting("billing_enabled") == "false") return
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
        if (adSetting("billing_enabled") == "false") return
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
                val extension = source.extension.lowercase()
                if (extension !in listOf("png","gif") || source.length() > 16L*1024*1024) throw SecurityException("Unsupported app image")
                val header = ByteArray(8)
                source.inputStream().use { if (it.read(header) != 8) throw SecurityException("Invalid image") }
                val gif = extension == "gif"
                if (gif && String(header.copyOfRange(0,6),Charsets.US_ASCII) !in listOf("GIF87a","GIF89a")) throw SecurityException("Invalid GIF")
                if (!gif && !header.contentEquals(byteArrayOf(137.toByte(),80,78,71,13,10,26,10))) throw SecurityException("Invalid PNG")
                val dir = File(host.cacheDir,"shares").apply { mkdirs() }
                val copy = source.copyTo(File(dir,"pocket-biome.$extension"),true)
                val uri = FileProvider.getUriForFile(host,host.packageName+".pocket.share",copy)
                val intent = Intent(Intent.ACTION_SEND).setType(if (gif) "image/gif" else "image/png").putExtra(Intent.EXTRA_STREAM,uri).addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                host.startActivity(Intent.createChooser(intent,"Share your Pocket Biome"))
            } catch (error: Exception) { emitSignal("service_error","Photo sharing unavailable: ${error.message}") }
        }
    }
}
