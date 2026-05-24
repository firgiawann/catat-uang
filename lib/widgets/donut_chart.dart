import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme_colors.dart';

class DonutChart extends StatefulWidget {
  final double pemasukan;
  final double pengeluaran;
  final ThemeColorFlavor colors;

  const DonutChart({
    Key? key,
    required this.pemasukan,
    required this.pengeluaran,
    required this.colors,
  }) : super(key: key);

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pemasukan != widget.pemasukan ||
        oldWidget.pengeluaran != widget.pengeluaran) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatRupiah(double value) {
    if (value == 0.0) return "Rp0";
    final isNegative = value < 0;
    final formatter = NumberFormat("#,###", "id_ID");
    final formatted = "Rp${formatter.format(value.abs()).replaceAll(',', '.')}";
    return isNegative ? "-$formatted" : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.pemasukan + widget.pengeluaran;
    final selisih = widget.pemasukan - widget.pengeluaran;
    final isSurplus = selisih >= 0;

    return Container(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(120, 120),
                painter: _DonutPainter(
                  pemasukan: widget.pemasukan,
                  pengeluaran: widget.pengeluaran,
                  animationValue: _animation.value,
                  colors: widget.colors,
                ),
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Selisih",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: widget.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  total == 0
                      ? "Rp0"
                      : "${isSurplus ? "+" : ""}${_formatRupiah(selisih.abs())}",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: total == 0
                        ? widget.colors.textPrimary
                        : (isSurplus ? amountGreen : amountRed),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double pemasukan;
  final double pengeluaran;
  final double animationValue;
  final ThemeColorFlavor colors;

  _DonutPainter({
    required this.pemasukan,
    required this.pengeluaran,
    required this.animationValue,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;
    final double radius = min(size.width, size.height) / 2 - strokeWidth / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Draw empty/progress track
    final trackPaint = Paint()
      ..color = colors.progressTrack.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    final total = pemasukan + pengeluaran;
    if (total <= 0.0) return;

    final pPct = pemasukan / total;
    final qPct = pengeluaran / total;

    // Start from top center (-pi/2)
    var startAngle = -pi / 2;

    // 2. Draw Pemasukan (Green Arc)
    if (pemasukan > 0) {
      final pSweep = pPct * 2 * pi * animationValue;
      final pPaint = Paint()
        ..color = amountGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, pSweep, false, pPaint);
      startAngle += pPct * 2 * pi; // Shift exactly by full percentage for transition placement
    }

    // 3. Draw Pengeluaran (Red Arc)
    if (pengeluaran > 0) {
      final qSweep = qPct * 2 * pi * animationValue;
      final qPaint = Paint()
        ..color = amountRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // The starting point shifts after green
      final currentStart = -pi / 2 + (pPct * 2 * pi * animationValue);
      canvas.drawArc(rect, currentStart, qSweep, false, qPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.pemasukan != pemasukan ||
        oldDelegate.pengeluaran != pengeluaran ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.colors != colors;
  }
}
