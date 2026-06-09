import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating; // thang điểm 10

  const StarRating({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    // Scale từ 10 → 5 sao
    final scaledFull = (rating / 2).floor();
    final scaledHalf = ((rating / 2) - scaledFull) >= 0.5;
    const maxStars = 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxStars, (i) {
          if (i < scaledFull) {
            return const Icon(Icons.star_rounded,
                color: Color(0xFFFFD700), size: 15);
          } else if (i == scaledFull && scaledHalf) {
            return const Icon(Icons.star_half_rounded,
                color: Color(0xFFFFD700), size: 15);
          } else {
            return Icon(Icons.star_outline_rounded,
                color: Colors.white.withValues(alpha: 0.25), size: 15);
          }
        }),
        const SizedBox(width: 5),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
