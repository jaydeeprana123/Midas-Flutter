package com.garima.midas

import android.Manifest
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.util.concurrent.Executors

class JobCardDownloadBridge(
    private val activity: FlutterActivity,
    messenger: BinaryMessenger,
) {
    private var pendingResult: MethodChannel.Result? = null
    private var pendingBaseUrl: String? = null
    private var pendingToken: String? = null
    private var pendingJobCardNumber: String? = null
    private val executor = Executors.newSingleThreadExecutor()

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "downloadJobCardReport" -> {
                    val jobCardNumber = call.argument<String>("jobCardNumber")
                    val baseUrl = call.argument<String>("baseUrl")
                    val token = call.argument<String>("token")
                    if (jobCardNumber.isNullOrBlank() ||
                        baseUrl.isNullOrBlank() ||
                        token.isNullOrBlank()
                    ) {
                        result.error("INVALID_ARGS", "Missing parameters", null)
                        return@setMethodCallHandler
                    }
                    startDownload(baseUrl, token, jobCardNumber, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startDownload(
        baseUrl: String,
        token: String,
        jobCardNumber: String,
        result: MethodChannel.Result,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            val granted = ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) {
                pendingResult = result
                pendingBaseUrl = baseUrl
                pendingToken = token
                pendingJobCardNumber = jobCardNumber
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                    STORAGE_REQUEST_CODE,
                )
                return
            }
        }
        downloadInBackground(baseUrl, token, jobCardNumber, result)
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode != STORAGE_REQUEST_CODE) return

        val result = pendingResult ?: return
        val baseUrl = pendingBaseUrl
        val token = pendingToken
        val jobCardNumber = pendingJobCardNumber
        pendingResult = null
        pendingBaseUrl = null
        pendingToken = null
        pendingJobCardNumber = null

        if (baseUrl == null || token == null || jobCardNumber == null) {
            result.error("PERMISSION_DENIED", "Storage permission denied", null)
            return
        }

        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (granted) {
            downloadInBackground(baseUrl, token, jobCardNumber, result)
        } else {
            result.error("PERMISSION_DENIED", "Storage permission denied", null)
        }
    }

    private fun downloadInBackground(
        baseUrl: String,
        token: String,
        jobCardNumber: String,
        result: MethodChannel.Result,
    ) {
        executor.execute {
            try {
                val normalizedBase = if (baseUrl.endsWith("/")) baseUrl else "$baseUrl/"
                val encodedJobCard = URLEncoder.encode(jobCardNumber, "UTF-8")
                val requestUrl =
                    "${normalizedBase}api/Report/JobCardTestingReportByJobCardNumber?jobCardNumber=$encodedJobCard"

                val connection = (URL(requestUrl).openConnection() as HttpURLConnection).apply {
                    requestMethod = "GET"
                    setRequestProperty("Accept", "application/json, text/plain, */*")
                    setRequestProperty("Authorization", "Bearer $token")
                    connectTimeout = 25_000
                    readTimeout = 25_000
                }

                if (connection.responseCode !in 200..299) {
                    activity.runOnUiThread {
                        result.error(
                            "DOWNLOAD_FAILED",
                            "Download failed: ${connection.responseCode}",
                            null,
                        )
                    }
                    connection.disconnect()
                    return@execute
                }

                val fileBytes = connection.inputStream.use { it.readBytes() }
                connection.disconnect()

                if (fileBytes.isEmpty()) {
                    activity.runOnUiThread {
                        result.error("DOWNLOAD_FAILED", "No data received", null)
                    }
                    return@execute
                }

                val fileName = "${jobCardNumber.replace("/", "_")}.pdf"
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val contentValues = ContentValues().apply {
                        put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                        put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
                        put(
                            MediaStore.Downloads.RELATIVE_PATH,
                            Environment.DIRECTORY_DOWNLOADS,
                        )
                    }

                    val uri = activity.contentResolver.insert(
                        MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                        contentValues,
                    )

                    if (uri == null) {
                        activity.runOnUiThread {
                            result.error("DOWNLOAD_FAILED", "Unable to save PDF", null)
                        }
                        return@execute
                    }

                    activity.contentResolver.openOutputStream(uri)?.use { output ->
                        output.write(fileBytes)
                    }

                    activity.runOnUiThread {
                        Toast.makeText(
                            activity,
                            "PDF downloaded successfully!",
                            Toast.LENGTH_LONG,
                        ).show()
                        openPdf(uri)
                        result.success(true)
                    }
                } else {
                    val downloadsDir =
                        activity.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
                    val targetFile = File(downloadsDir, fileName)
                    targetFile.parentFile?.mkdirs()
                    FileOutputStream(targetFile).use { it.write(fileBytes) }

                    val fileUri = FileProvider.getUriForFile(
                        activity,
                        "${activity.packageName}.fileprovider",
                        targetFile,
                    )

                    activity.runOnUiThread {
                        Toast.makeText(
                            activity,
                            "PDF downloaded successfully!",
                            Toast.LENGTH_LONG,
                        ).show()
                        openPdf(fileUri)
                        result.success(true)
                    }
                }
            } catch (e: Exception) {
                activity.runOnUiThread {
                    result.error(
                        "DOWNLOAD_FAILED",
                        e.message ?: "Download failed",
                        null,
                    )
                }
            }
        }
    }

    private fun openPdf(uri: Uri) {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/pdf")
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK
        }
        try {
            activity.startActivity(intent)
        } catch (_: Exception) {
            Toast.makeText(activity, "No PDF viewer installed", Toast.LENGTH_LONG).show()
        }
    }

    companion object {
        private const val CHANNEL = "com.garima.midas/job_card"
        private const val STORAGE_REQUEST_CODE = 1001
    }
}
