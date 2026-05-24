package id.awni.money

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Shader
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.concurrent.Executors

class RiwayatAppWidgetProvider : AppWidgetProvider() {

    private val executor = Executors.newSingleThreadExecutor()
    private val handler = Handler(Looper.getMainLooper())

    data class TempTx(val amount: Double, val isExpense: Boolean, val note: String)

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateRiwayatWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "id.awni.money.UPDATE_WIDGET") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, RiwayatAppWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    private fun updateRiwayatWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        executor.execute {
            val txList = mutableListOf<TempTx>()

            try {
                val sharedPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val activeProfileId = sharedPrefs.getLong("flutter.active_profile_id", -1)

                val dbFile = context.getDatabasePath("dompet_pintar.db")
                if (dbFile.exists()) {
                    val db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READONLY)

                    var profileId = activeProfileId
                    if (profileId == -1L) {
                        val profileCursor = db.rawQuery("SELECT id FROM profiles LIMIT 1", null)
                        if (profileCursor.moveToFirst()) {
                            profileId = profileCursor.getLong(0)
                        }
                        profileCursor.close()
                    }

                    val monthFormat = SimpleDateFormat("yyyy-MM", Locale.getDefault())
                    val rawMonthCode = monthFormat.format(Date())

                    if (profileId != -1L) {
                        // Query last 3 transactions of current month
                        val cursor = db.rawQuery(
                            "SELECT amount, isExpense, note FROM transactions WHERE month = ? AND profileId = ? ORDER BY timestamp DESC LIMIT 3",
                            arrayOf(rawMonthCode, profileId.toString())
                        )
                        while (cursor.moveToNext()) {
                            val amount = cursor.getDouble(0)
                            val isExpense = cursor.getInt(1) == 1
                            val note = cursor.getString(2)
                            txList.add(TempTx(amount, isExpense, note))
                        }
                        cursor.close()
                    }
                    db.close()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            // Determine dynamic time-of-day theme
            val calendar = Calendar.getInstance()
            val hour = calendar.get(Calendar.HOUR_OF_DAY)
            val isNightMode = hour >= 19 || hour < 5

            val width = 400
            val height = 400
            val bgBitmap = drawTimeBasedBackground(hour, width, height)

            val textColorHex = if (isNightMode) "#FFFFFF" else "#2D3142"
            val subtextColorHex = if (isNightMode) "#B0B3D6" else "#9C9EB9"

            handler.post {
                try {
                    val views = RemoteViews(context.packageName, R.layout.riwayat_widget_layout)

                    // Click Actions (Open History page in app)
                    val configIntent = Intent(context, MainActivity::class.java)
                    val configPendingIntent = PendingIntent.getActivity(
                        context,
                        2, // unique request code
                        configIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(R.id.widget_title, configPendingIntent)
                    views.setOnClickPendingIntent(R.id.widget_see_more, configPendingIntent)

                    // Adjust texts color based on theme
                    views.setTextColor(R.id.widget_title, Color.parseColor(textColorHex))
                    views.setTextColor(R.id.widget_see_more, Color.parseColor(subtextColorHex))
                    views.setTextColor(R.id.widget_empty_state, Color.parseColor(subtextColorHex))

                    // Bind items
                    if (txList.isEmpty()) {
                        views.setViewVisibility(R.id.widget_empty_state, View.VISIBLE)
                        views.setViewVisibility(R.id.widget_list_container, View.GONE)
                    } else {
                        views.setViewVisibility(R.id.widget_empty_state, View.GONE)
                        views.setViewVisibility(R.id.widget_list_container, View.VISIBLE)

                        // Set Row 1
                        if (txList.size >= 1) {
                            views.setViewVisibility(R.id.widget_item_1, View.VISIBLE)
                            val tx = txList[0]
                            views.setTextViewText(R.id.widget_item_title_1, tx.note)
                            views.setTextColor(R.id.widget_item_title_1, Color.parseColor(textColorHex))

                            if (tx.isExpense) {
                                views.setTextViewText(R.id.widget_item_value_1, "-" + formatRupiah(tx.amount))
                                views.setTextColor(R.id.widget_item_value_1, Color.parseColor("#E57373")) // pastel red
                                views.setImageViewResource(R.id.widget_item_icon_1, R.drawable.widget_indicator_red)
                            } else {
                                views.setTextViewText(R.id.widget_item_value_1, "+" + formatRupiah(tx.amount))
                                views.setTextColor(R.id.widget_item_value_1, Color.parseColor("#81C784")) // pastel green
                                views.setImageViewResource(R.id.widget_item_icon_1, R.drawable.widget_indicator_green)
                            }
                        } else {
                            views.setViewVisibility(R.id.widget_item_1, View.GONE)
                        }

                        // Set Row 2
                        if (txList.size >= 2) {
                            views.setViewVisibility(R.id.widget_item_2, View.VISIBLE)
                            val tx = txList[1]
                            views.setTextViewText(R.id.widget_item_title_2, tx.note)
                            views.setTextColor(R.id.widget_item_title_2, Color.parseColor(textColorHex))

                            if (tx.isExpense) {
                                views.setTextViewText(R.id.widget_item_value_2, "-" + formatRupiah(tx.amount))
                                views.setTextColor(R.id.widget_item_value_2, Color.parseColor("#E57373"))
                                views.setImageViewResource(R.id.widget_item_icon_2, R.drawable.widget_indicator_red)
                            } else {
                                views.setTextViewText(R.id.widget_item_value_2, "+" + formatRupiah(tx.amount))
                                views.setTextColor(R.id.widget_item_value_2, Color.parseColor("#81C784"))
                                views.setImageViewResource(R.id.widget_item_icon_2, R.drawable.widget_indicator_green)
                            }
                        } else {
                            views.setViewVisibility(R.id.widget_item_2, View.GONE)
                        }

                        // Set Row 3
                        if (txList.size >= 3) {
                            views.setViewVisibility(R.id.widget_item_3, View.VISIBLE)
                            val tx = txList[2]
                            views.setTextViewText(R.id.widget_item_title_3, tx.note)
                            views.setTextColor(R.id.widget_item_title_3, Color.parseColor(textColorHex))

                            if (tx.isExpense) {
                                views.setTextViewText(R.id.widget_item_value_3, "-" + formatRupiah(tx.amount))
                                views.setTextColor(R.id.widget_item_value_3, Color.parseColor("#E57373"))
                                views.setImageViewResource(R.id.widget_item_icon_3, R.drawable.widget_indicator_red)
                            } else {
                                views.setTextViewText(R.id.widget_item_value_3, "+" + formatRupiah(tx.amount))
                                views.setTextColor(R.id.widget_item_value_3, Color.parseColor("#81C784"))
                                views.setImageViewResource(R.id.widget_item_icon_3, R.drawable.widget_indicator_green)
                            }
                        } else {
                            views.setViewVisibility(R.id.widget_item_3, View.GONE)
                        }
                    }

                    if (bgBitmap != null) {
                        views.setImageViewBitmap(R.id.widget_background_image, bgBitmap)
                    }

                    appWidgetManager.updateAppWidget(appWidgetId, views)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun drawTimeBasedBackground(hour: Int, width: Int, height: Int): Bitmap? {
        try {
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)

            val path = Path()
            val rect = RectF(0f, 0f, width.toFloat(), height.toFloat())
            val cornerRadius = 48f
            path.addRoundRect(rect, cornerRadius, cornerRadius, Path.Direction.CW)
            canvas.clipPath(path)

            when {
                // Pagi (05:00 - 09:00): Sunrise yellow-to-pink
                hour in 5..9 -> {
                    val shader = LinearGradient(0f, 0f, width.toFloat(), height.toFloat(),
                        Color.parseColor("#FFF0F2"), Color.parseColor("#FFE7C4"), Shader.TileMode.CLAMP)
                    paint.shader = shader
                    canvas.drawRect(rect, paint)

                    paint.shader = null
                    paint.style = Paint.Style.FILL
                    paint.color = Color.parseColor("#FFF9C4")
                    canvas.drawCircle(330f, 70f, 50f, paint)

                    paint.color = Color.parseColor("#FFD54F")
                    canvas.drawCircle(330f, 70f, 32f, paint)
                }
                
                // Siang (10:00 - 14:00): Bright blue-to-mint
                hour in 10..14 -> {
                    val shader = LinearGradient(0f, 0f, width.toFloat(), height.toFloat(),
                        Color.parseColor("#E0F7FA"), Color.parseColor("#FFFDE7"), Shader.TileMode.CLAMP)
                    paint.shader = shader
                    canvas.drawRect(rect, paint)

                    paint.shader = null
                    paint.style = Paint.Style.FILL
                    paint.color = Color.parseColor("#FFE082")
                    canvas.drawCircle(330f, 70f, 45f, paint)

                    paint.color = Color.parseColor("#FFB300")
                    canvas.drawCircle(330f, 70f, 30f, paint)

                    paint.color = Color.parseColor("#E0FFFFFF")
                    canvas.drawCircle(300f, 90f, 25f, paint)
                    canvas.drawCircle(325f, 100f, 20f, paint)
                }

                // Sore (15:00 - 18:00): Sunset orange-to-rose
                hour in 15..18 -> {
                    val shader = LinearGradient(0f, 0f, width.toFloat(), height.toFloat(),
                        Color.parseColor("#FFF3E0"), Color.parseColor("#F48FB1"), Shader.TileMode.CLAMP)
                    paint.shader = shader
                    canvas.drawRect(rect, paint)

                    paint.shader = null
                    paint.style = Paint.Style.FILL
                    paint.color = Color.parseColor("#FFAB91")
                    canvas.drawCircle(330f, 80f, 48f, paint)

                    paint.color = Color.parseColor("#FF5722")
                    canvas.drawCircle(330f, 80f, 32f, paint)
                }

                // Malam (19:00 - 04:00): Deep starry night purple
                else -> {
                    val shader = LinearGradient(0f, 0f, width.toFloat(), height.toFloat(),
                        Color.parseColor("#12132C"), Color.parseColor("#261C3D"), Shader.TileMode.CLAMP)
                    paint.shader = shader
                    canvas.drawRect(rect, paint)

                    paint.shader = null
                    paint.style = Paint.Style.FILL

                    paint.color = Color.parseColor("#FFFDE7")
                    canvas.drawCircle(330f, 75f, 32f, paint)
                    paint.color = Color.parseColor("#1B1A34")
                    canvas.drawCircle(318f, 68f, 30f, paint)

                    paint.color = Color.parseColor("#60FFFFFF")
                    canvas.drawCircle(80f, 50f, 2f, paint)
                    canvas.drawCircle(220f, 40f, 2f, paint)
                    canvas.drawCircle(150f, 90f, 2f, paint)
                }
            }

            return bitmap
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun formatRupiah(value: Double): String {
        val absVal = Math.abs(value)
        val formatter = java.text.DecimalFormat("#,###")
        val symbols = formatter.decimalFormatSymbols
        symbols.groupingSeparator = '.'
        formatter.decimalFormatSymbols = symbols
        return "Rp${formatter.format(absVal)}"
    }
}
