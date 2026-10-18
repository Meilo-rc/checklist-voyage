package fr.checklistvoyage.app

import android.app.Activity
import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingBackup: ByteArray? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingJoinLink: String? = null
    private var shareInvitationChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingJoinLink = joinLinkFrom(intent)
        shareInvitationChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "fr.checklistvoyage.app/share_invitation",
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "takeInitialJoinLink" -> {
                        val link = pendingJoinLink
                        pendingJoinLink = null
                        result.success(link)
                    }
                    "shareText" -> {
                        val subject = call.argument<String>("subject")
                        val text = call.argument<String>("text")
                        if (subject.isNullOrBlank() || text.isNullOrBlank()) {
                            result.error("invalid_share", "Message de partage invalide.", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                                type = "text/plain"
                                putExtra(Intent.EXTRA_SUBJECT, subject)
                                putExtra(Intent.EXTRA_TEXT, text)
                            }
                            startActivity(Intent.createChooser(shareIntent, "Partager avec"))
                            result.success(null)
                        } catch (error: Exception) {
                            result.error(
                                "share_unavailable",
                                "Aucune application de partage n'est disponible.",
                                null,
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "fr.checklistvoyage.app/safety_backup",
        ).setMethodCallHandler { call, result ->
            if (call.method != "saveBackup") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (pendingResult != null) {
                result.error("backup_in_progress", "Un export est déjà en cours.", null)
                return@setMethodCallHandler
            }
            val bytes = call.argument<ByteArray>("bytes")
            val name = call.argument<String>("name")
            if (bytes == null || name.isNullOrBlank()) {
                result.error("invalid_backup", "Sauvegarde invalide.", null)
                return@setMethodCallHandler
            }
            pendingBackup = bytes
            pendingResult = result
            startActivityForResult(
                Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "application/json"
                    putExtra(Intent.EXTRA_TITLE, name)
                },
                backupRequestCode,
            )
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "fr.checklistvoyage.app/app_info",
        ).setMethodCallHandler { call, result ->
            if (call.method != "getVersion") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            @Suppress("DEPRECATION")
            val packageInfo = packageManager.getPackageInfo(packageName, 0)
            val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode
            } else {
                packageInfo.versionCode.toLong()
            }
            result.success(
                mapOf(
                    "versionName" to (packageInfo.versionName ?: ""),
                    "versionCode" to versionCode.toString(),
                ),
            )
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val link = joinLinkFrom(intent) ?: return
        val channel = shareInvitationChannel
        if (channel == null) {
            pendingJoinLink = link
        } else {
            channel.invokeMethod("onJoinLink", link)
        }
    }

    private fun joinLinkFrom(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_VIEW) return null
        return intent.dataString
    }

    @Deprecated("Deprecated in Android; retained for FlutterActivity compatibility")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != backupRequestCode) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingResult
        val bytes = pendingBackup
        pendingResult = null
        pendingBackup = null
        if (resultCode != Activity.RESULT_OK || data?.data == null || bytes == null) {
            result?.success(false)
            return
        }
        try {
            contentResolver.openOutputStream(data.data!!, "w").use { output ->
                requireNotNull(output) { "Destination inaccessible." }
                output.write(bytes)
            }
            result?.success(true)
        } catch (error: Exception) {
            result?.error("backup_write_failed", "Écriture de la sauvegarde impossible.", null)
        }
    }

    private companion object {
        const val backupRequestCode = 1501
    }
}
