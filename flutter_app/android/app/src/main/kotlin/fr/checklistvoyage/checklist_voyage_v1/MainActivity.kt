package fr.checklistvoyage.app

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingBackup: ByteArray? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
