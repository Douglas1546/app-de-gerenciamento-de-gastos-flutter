import 'package:flutter/material.dart';
import 'dart:math';

class ShoppingBackground extends StatelessWidget {
  final Widget child;

  const ShoppingBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        CustomPaint(painter: DoodlePainter(), size: Size.infinite),
        child,
      ],
    );
  }
}

class DoodlePainter extends CustomPainter {
  final List<IconData> icons = [
    Icons.shopping_cart_outlined,
    Icons.shopping_bag_outlined,
    Icons.local_offer_outlined,
    Icons.receipt_long_outlined,
    Icons.credit_card_outlined,
    Icons.store_outlined,
    Icons.star_border,
    Icons.favorite_border,
    Icons.eco_outlined,
    Icons.local_mall_outlined,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent pattern
    const gridSize = 80.0;

    for (double y = 0; y < size.height; y += gridSize) {
      for (double x = 0; x < size.width; x += gridSize) {
        final iconIndex = random.nextInt(icons.length);
        final icon = icons[iconIndex];

        // Add some randomness to position
        final offsetX = random.nextDouble() * 20 - 10;
        final offsetY = random.nextDouble() * 20 - 10;

        // Draw icon using TextPainter
        final textPainter = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: 24,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              color: const Color(0xFF3B82F6).withValues(alpha: 0.06),
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x + gridSize / 2 + offsetX - 12,
            y + gridSize / 2 + offsetY - 12,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
