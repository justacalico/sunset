import 'package:flutter/material.dart';

class EditorMock extends StatelessWidget {
  const EditorMock({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 560,
      height: 340,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final w in [0.8, 0.6, 0.7, 0.5, 0.65, 0.75])
                  Container(
                    height: 14,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    width: 100 * w,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: 150,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 12,
                    width: 220,
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        height: 30,
                        width: 90,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 30,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(color: scheme.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary.withValues(alpha: 0.5),
                          const Color(0xFF8A4FFF).withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 110,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (var i = 0; i < 5; i++)
                  Container(
                    height: 18,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: i == 0
                          ? scheme.primary.withValues(alpha: 0.4)
                          : scheme.onSurfaceVariant.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SunsetScene extends StatelessWidget {
  const SunsetScene({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CustomPaint(painter: _SunsetPainter()),
    );
  }
}

class _SunsetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B1035),
            Color(0xFF53205E),
            Color(0xFFC64648),
            Color(0xFFF3813F),
          ],
          stops: [0.0, 0.4, 0.7, 0.85],
        ).createShader(rect),
    );
    final horizon = size.height * 0.72;
    canvas.drawCircle(
      Offset(size.width * 0.5, horizon),
      size.height * 0.22,
      Paint()..color = const Color(0xFFFFD682),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, size.width, size.height - horizon),
      Paint()..color = const Color(0xFF170C26),
    );
    final refl = Paint()..color = const Color(0xFFF5BE6E);
    for (var i = 0; i < 4; i++) {
      final y = horizon + size.height * (0.04 + i * 0.06);
      final w = size.width * (0.3 - i * 0.06);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width * 0.5, y),
            width: w,
            height: size.height * 0.014,
          ),
          Radius.circular(size.height * 0.007),
        ),
        refl..color = refl.color.withValues(alpha: 0.9 - i * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SunsetPainter old) => false;
}
