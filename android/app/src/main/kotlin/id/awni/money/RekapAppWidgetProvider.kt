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
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
import android.widget.RemoteViews
import java.io.File
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.concurrent.Executors

class RekapAppWidgetProvider : AppWidgetProvider() {

    private val executor = Executors.newSingleThreadExecutor()
    private val handler = Handler(Looper.getMainLooper())

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            triggerWidgetAnimation(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == "id.awni.money.UPDATE_WIDGET") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, RekapAppWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    /**
     * Runs a silky smooth frame-by-frame loading animation for the donut chart.
     */
    private fun triggerWidgetAnimation(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        // Query database first on background worker thread
        executor.execute {
            var totalMasuk = 0.0
            var totalKeluar = 0.0
            var targetLimit = 0.0
            var activeName = ""
            var currentMonthLabel = ""
            var rawMonthCode = ""

            try {
                val sharedPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val activeProfileId = sharedPrefs.getLong("flutter.active_profile_id", -1)

                val dbFile = context.getDatabasePath("dompet_pintar.db")
                if (dbFile.exists()) {
                    val db = SQLiteDatabase.openDatabase(dbFile.absolutePath, null, SQLiteDatabase.OPEN_READONLY)

                    var profileId = activeProfileId
                    if (profileId == -1L) {
                        val profileCursor = db.rawQuery("SELECT id, name FROM profiles LIMIT 1", null)
                        if (profileCursor.moveToFirst()) {
                            profileId = profileCursor.getLong(0)
                            activeName = profileCursor.getString(1)
                        }
                        profileCursor.close()
                    } else {
                        val profileCursor = db.rawQuery("SELECT name FROM profiles WHERE id = ?", arrayOf(profileId.toString()))
                        if (profileCursor.moveToFirst()) {
                            activeName = profileCursor.getString(0)
                        }
                        profileCursor.close()
                    }

                    // Get current month codes
                    val monthFormat = SimpleDateFormat("yyyy-MM", Locale.getDefault())
                    rawMonthCode = monthFormat.format(Date())

                    val idLocale = Locale("id", "ID")
                    val fullMonthFormat = SimpleDateFormat("MMMM yyyy", idLocale)
                    currentMonthLabel = fullMonthFormat.format(Date())

                    if (profileId != -1L) {
                        // Query transactions
                        val cursor = db.rawQuery(
                            "SELECT amount, isExpense FROM transactions WHERE month = ? AND profileId = ?",
                            arrayOf(rawMonthCode, profileId.toString())
                        )
                        while (cursor.moveToNext()) {
                            val amount = cursor.getDouble(0)
                            val isExpense = cursor.getInt(1) == 1
                            if (isExpense) {
                                totalKeluar += amount
                            } else {
                                totalMasuk += amount
                            }
                        }
                        cursor.close()

                        // Query monthly budget limit
                        val budgetCursor = db.rawQuery(
                            "SELECT targetAmount FROM monthly_budgets WHERE month = ? AND profileId = ?",
                            arrayOf(rawMonthCode, profileId.toString())
                        )
                        if (budgetCursor.moveToFirst()) {
                            targetLimit = budgetCursor.getDouble(0)
                        }
                        budgetCursor.close()
                    }
                    db.close()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            // Standardize month representations
            if (currentMonthLabel.isEmpty()) {
                currentMonthLabel = "Bulan Ini"
            }
            if (rawMonthCode.isEmpty()) {
                rawMonthCode = "2026-05"
            }

            // Determine dynamic time-of-day theme details
            val calendar = Calendar.getInstance()
            val hour = calendar.get(Calendar.HOUR_OF_DAY)
            val isNightMode = hour >= 19 || hour < 5

            // Generate Static dynamic background first
            val width = 600
            val height = 400
            val bgBitmap = drawTimeBasedBackground(hour, width, height)

            // Calculate budget progress values
            val remainingBudget = targetLimit - totalKeluar
            val progressPercent = if (targetLimit > 0.0) {
                val p = ((remainingBudget / targetLimit) * 100).toInt()
                p.coerceIn(0, 100)
            } else {
                100
            }

            val statusText = if (targetLimit > 0.0 && progressPercent <= 10) {
                "Status: BOROS"
            } else {
                "Status: AMAN"
            }

            val statusColor = if (targetLimit > 0.0 && progressPercent <= 10) {
                Color.parseColor("#C62828") // Red
            } else {
                if (isNightMode) Color.parseColor("#A5D6A7") else Color.parseColor("#2E7D32")
            }

            val textColorHex = if (isNightMode) "#FFFFFF" else "#2D3142"
            val subtextColorHex = if (isNightMode) "#B0B3D6" else "#9C9EB9"

            // Run Donut sweeping animation in 12 steps (over 300ms)
            val animationSteps = 12
            for (step in 1..animationSteps) {
                val animProgress = step.toFloat() / animationSteps.toFloat()
                
                // Draw Donut with current frame progress
                val donutChartBitmap = drawDonutChart(totalMasuk, totalKeluar, animProgress, isNightMode)

                handler.post {
                    try {
                        val views = RemoteViews(context.packageName, R.layout.rekap_widget_layout)

                        // Set tap action to open MainActivity
                        val configIntent = Intent(context, MainActivity::class.java)
                        val configPendingIntent = PendingIntent.getActivity(
                            context,
                            0,
                            configIntent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        )
                        views.setOnClickPendingIntent(R.id.widget_title, configPendingIntent)
                        views.setOnClickPendingIntent(R.id.widget_donut_chart, configPendingIntent)

                        // Update text values and colors dynamically
                        views.setTextViewText(R.id.widget_title, "Rekap Keuanganmu")
                        views.setTextColor(R.id.widget_title, Color.parseColor(textColorHex))
                        
                        views.setTextViewText(R.id.widget_subtitle, getWidgetSubtitle(hour))
                        views.setTextColor(R.id.widget_subtitle, Color.parseColor(subtextColorHex))
                        
                        views.setTextViewText(R.id.widget_period_pill, rawMonthCode)

                        views.setTextViewText(R.id.widget_pemasukan, formatRupiah(totalMasuk))
                        views.setTextViewText(R.id.widget_pengeluaran, formatRupiah(totalKeluar))

                        views.setTextViewText(R.id.widget_sisa_label, "Sisa Anggaran: $progressPercent%")
                        views.setTextColor(R.id.widget_sisa_label, Color.parseColor(textColorHex))
                        
                        views.setTextViewText(R.id.widget_status, statusText)
                        views.setTextColor(R.id.widget_status, statusColor)

                        // Update linear progress bar
                        views.setProgressBar(R.id.widget_progress_bar, 100, progressPercent, false)

                        views.setTextViewText(R.id.widget_limit, "Batas: " + formatRupiah(targetLimit))
                        views.setTextColor(R.id.widget_limit, Color.parseColor(subtextColorHex))
                        
                        views.setTextViewText(R.id.widget_spent, "Terpakai: " + formatRupiah(totalKeluar))
                        views.setTextColor(R.id.widget_spent, Color.parseColor(subtextColorHex))

                        // Bind static background and dynamic donut chart bitmaps
                        if (bgBitmap != null) {
                            views.setImageViewBitmap(R.id.widget_background_image, bgBitmap)
                        }
                        if (donutChartBitmap != null) {
                            views.setImageViewBitmap(R.id.widget_donut_chart, donutChartBitmap)
                        }

                        appWidgetManager.updateAppWidget(appWidgetId, views)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }

                // 25ms delay between frames for smooth animation
                try {
                    Thread.sleep(25)
                } catch (ignored: InterruptedException) {
                }
            }
        }
    }

    /**
     * Draws a highly customized, gorgeous, time-of-day specific background with cute illustrations.
     */
    private fun drawTimeBasedBackground(hour: Int, width: Int, height: Int): Bitmap? {
        try {
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)

            val paint = Paint(Paint.ANTI_ALIAS_FLAG)
            
            // 1. Draw rounded outer background card path
            val path = Path()
            val rect = RectF(0f, 0f, width.toFloat(), height.toFloat())
            val cornerRadius = 48f // beautiful Material You curved corners
            path.addRoundRect(rect, cornerRadius, cornerRadius, Path.Direction.CW)
            canvas.clipPath(path)

            // 2. Select pastel gradient and ornaments based on time
            when {
                // Pagi (05:00 - 09:00): Sunrise yellow-to-pink
                hour in 5..9 -> {
                    val shader = LinearGradient(0f, 0f, width.toFloat(), height.toFloat(),
                        Color.parseColor("#FFF0F2"), Color.parseColor("#FFE7C4"), Shader.TileMode.CLAMP)
                    paint.shader = shader
                    canvas.drawRect(rect, paint)

                    // Draw soft rising sun at top-right
                    paint.shader = null
                    paint.style = Paint.Style.FILL
                    paint.color = Color.parseColor("#FFF9C4") // outer glowing circle
                    canvas.drawCircle(530f, 70f, 65f, paint)

                    paint.color = Color.parseColor("#FFD54F") // warm morning sun
                    canvas.drawCircle(530f, 70f, 45f, paint)
                }
                
                // Siang (10:00 - 14:00): Bright blue-to-mint
                hour in 10..14 -> {
                    val shader = LinearGradient(0f, 0f, width.toFloat(), height.toFloat(),
                        Color.parseColor("#E0F7FA"), Color.parseColor("#FFFDE7"), Shader.TileMode.CLAMP)
                    paint.shader = shader
                    canvas.drawRect(rect, paint)

                    // Draw bright sun
                    paint.shader = null
                    paint.style = Paint.Style.FILL
                    paint.color = Color.parseColor("#FFE082") // glowing ring
                    canvas.drawCircle(530f, 70f, 55f, paint)

                    paint.color = Color.parseColor("#FFB300") // sun center
                    canvas.drawCircle(530f, 70f, 40f, paint)

                    // Overlap fluffy white clouds
                    paint.color = Color.parseColor("#E0FFFFFF") // cloud part 1
                    canvas.drawCircle(490f, 90f, 32f, paint)
                    canvas.drawCircle(520f, 100f, 25f, paint)
                    canvas.drawCircle(465f, 105f, 20f, paint)
                }

                // Sore (15:00 - 18:00): Sunset orange-to-rose
                hour in 15..18 -> {
                    val shader = LinearGradient(0f, 0f, width.toFloat(), height.toFloat(),
                        Color.parseColor("#FFF3E0"), Color.parseColor("#F48FB1"), Shader.TileMode.CLAMP)
                    paint.shader = shader
                    canvas.drawRect(rect, paint)

                    // Draw sunset red sun peeking
                    paint.shader = null
                    paint.style = Paint.Style.FILL
                    paint.color = Color.parseColor("#FFAB91") // sunset glow
                    canvas.drawCircle(530f, 85f, 60f, paint)

                    paint.color = Color.parseColor("#FF5722") // setting sun
                    canvas.drawCircle(530f, 85f, 42f, paint)

                    // Draw dynamic cute oren clouds
                    paint.color = Color.parseColor("#B0FFE0B2")
                    canvas.drawRoundRect(RectF(400f, 115f, 550f, 127f), 6f, 6f, paint)
                    canvas.drawRoundRect(RectF(460f, 133f, 570f, 143f), 5f, 5f, paint)
                }

                // Malam (19:00 - 04:00): Deep starry night purple
                else -> {
                    val shader = LinearGradient(0f, 0f, width.toFloat(), height.toFloat(),
                        Color.parseColor("#12132C"), Color.parseColor("#261C3D"), Shader.TileMode.CLAMP)
                    paint.shader = shader
                    canvas.drawRect(rect, paint)

                    paint.shader = null
                    paint.style = Paint.Style.FILL

                    // Draw glowing crescent moon
                    paint.color = Color.parseColor("#FFFDE7")
                    canvas.drawCircle(525f, 75f, 40f, paint)
                    // Clip moon with background colored offset circle
                    paint.color = Color.parseColor("#1B1A34")
                    canvas.drawCircle(510f, 68f, 38f, paint)

                    // Draw multiple cute little scattered stars
                    paint.color = Color.parseColor("#80FFFFFF")
                    drawStar(canvas, paint, 120f, 60f, 5f)
                    drawStar(canvas, paint, 280f, 40f, 4f)
                    drawStar(canvas, paint, 380f, 90f, 6f)
                    drawStar(canvas, paint, 460f, 35f, 4f)
                }
            }

            return bitmap
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun getWidgetSubtitle(hour: Int): String {
        val random = java.util.Random(hour.toLong() * 1000L + System.currentTimeMillis() / 3600000L)
        return when {
            hour in 5..10 -> {
                val opts = listOf("Pagi yang produktif! ☀️", "Mulai hari dengan hemat! 🌸", "Yuk catat sejak pagi! ☕")
                opts[random.nextInt(opts.size)]
            }
            hour in 11..14 -> {
                val opts = listOf("Siang ini keuanganmu aman? 🌤️", "Sudah dicatat belum? 📝", "Jaga anggaran siangmu! 💪")
                opts[random.nextInt(opts.size)]
            }
            hour in 15..18 -> {
                val opts = listOf("Rekap sore hari 🌇", "Gimana hari ini, Kak? 🌸", "Sore produktif, dompet aman! 🍃")
                opts[random.nextInt(opts.size)]
            }
            hour in 19..22 -> {
                val opts = listOf("Yuk rekap malam ini 🌙", "Catat sebelum istirahat! 💤", "Closing hari yang baik ✨")
                opts[random.nextInt(opts.size)]
            }
            else -> {
                val opts = listOf("Masih up? Cek dompet dulu 🦉", "Keuangan aman, tidur nyenyak 😌")
                opts[random.nextInt(opts.size)]
            }
        }
    }

    private fun drawStar(canvas: Canvas, paint: Paint, cx: Float, cy: Float, size: Float) {
        canvas.drawCircle(cx, cy, size / 2, paint)
        canvas.drawLine(cx - size, cy, cx + size, cy, paint)
        canvas.drawLine(cx, cy - size, cx, cy + size, paint)
    }

    /**
     * Draws the dynamic Donut Chart with centering text on a bitmap.
     */
    private fun drawDonutChart(pemasukan: Double, pengeluaran: Double, animProgress: Float, isNightMode: Boolean): Bitmap? {
        try {
            val size = 200
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)

            val paint = Paint(Paint.ANTI_ALIAS_FLAG)
            paint.style = Paint.Style.STROKE
            paint.strokeWidth = 20f
            paint.strokeCap = Paint.Cap.ROUND

            val rect = RectF(18f, 18f, size - 18f, size - 18f)

            val total = pemasukan + pengeluaran
            if (total <= 0.0) {
                // Neutral grey circle when empty
                paint.color = Color.parseColor(if (isNightMode) "#40FFFFFF" else "#EAEAEA")
                canvas.drawArc(rect, 0f, 360f, false, paint)
            } else {
                val expenseAngle = ((pengeluaran / total) * 360f * animProgress).toFloat()
                val incomeAngle = ((pemasukan / total) * 360f * animProgress).toFloat()

                // Draw income arc (Mint Green)
                paint.color = Color.parseColor("#81C784")
                canvas.drawArc(rect, -90f, incomeAngle, false, paint)

                // Draw expense arc (Rose Red)
                paint.color = Color.parseColor("#EF9A9A")
                canvas.drawArc(rect, -90f + incomeAngle, expenseAngle, false, paint)
            }

            // Draw center text inside the Donut Chart
            paint.style = Paint.Style.FILL
            paint.textAlign = Paint.Align.CENTER
            
            // "Selisih" label
            paint.color = Color.parseColor(if (isNightMode) "#B0B3D6" else "#9C9EB9")
            paint.textSize = sp10ToPx(8.5f)
            paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            canvas.drawText("Selisih", size / 2f, size / 2f - 4f, paint)

            // Net Difference Value
            val netDiff = pemasukan - pengeluaran
            val prefix = if (netDiff >= 0) "+" else ""
            val diffText = prefix + formatShortRupiah(netDiff)

            paint.color = when {
                netDiff > 0 -> Color.parseColor("#81C784") // pastel green
                netDiff < 0 -> Color.parseColor("#EF9A9A") // pastel red
                else -> Color.parseColor(if (isNightMode) "#FFFFFF" else "#2D3142")
            }
            paint.textSize = sp12ToPx(10.5f)
            paint.typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            canvas.drawText(diffText, size / 2f, size / 2f + 16f, paint)

            return bitmap
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun spToPx(sp: Float): Float {
        return sp * 2.7f // standard scale fallback for density scaling on bitmaps
    }

    private fun sp10ToPx(sp: Float): Float {
        return sp * 2.3f
    }

    private fun sp12ToPx(sp: Float): Float {
        return sp * 2.5f
    }

    private fun formatRupiah(value: Double): String {
        if (value <= 0.0) return "Rp0"
        val formatter = java.text.DecimalFormat("#,###")
        val symbols = formatter.decimalFormatSymbols
        symbols.groupingSeparator = '.'
        formatter.decimalFormatSymbols = symbols
        return "Rp${formatter.format(value)}"
    }

    private fun formatShortRupiah(value: Double): String {
        val absVal = Math.abs(value)
        return when {
            absVal >= 1_000_000_000 -> {
                val formatted = String.format("%.1f", value / 1_000_000_000.0)
                "Rp${formatted}M"
            }
            absVal >= 1_000_000 -> {
                val formatted = String.format("%.1f", value / 1_000_000.0)
                "Rp${formatted}jt"
            }
            absVal >= 1_000 -> {
                val formatted = String.format("%.1f", value / 1_000.0)
                "Rp${formatted}rb"
            }
            else -> "Rp${value.toInt()}"
        }
    }
}
