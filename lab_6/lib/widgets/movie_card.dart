import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'star_rating.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final BoxConstraints parentConstraints;

  const MovieCard({
    super.key,
    required this.movie,
    required this.parentConstraints,
  });

  @override
  Widget build(BuildContext context) {
    // BONUS: LayoutBuilder bên trong từng card để responsive poster
    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final isWide = parentConstraints.maxWidth >= 800;
        final posterWidth = isWide
            ? cardConstraints.maxWidth * 0.28
            : cardConstraints.maxWidth * 0.32;
        final posterHeight =
            isWide ? posterWidth * 1.3 : posterWidth * 1.4;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Poster ──────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.network(
                  movie.posterUrl,
                  width: posterWidth,
                  height: posterHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: posterWidth,
                    height: posterHeight,
                    color: const Color(0xFF2A2A3E),
                    child: const Icon(Icons.broken_image_rounded,
                        color: Colors.white24, size: 36),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: posterWidth,
                      height: posterHeight,
                      color: const Color(0xFF2A2A3E),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Info ─────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Year
                      Text(
                        '${movie.year}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // BONUS: Star Rating
                      StarRating(rating: movie.rating),
                      const SizedBox(height: 8),

                      // Genre tags
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: movie.genres
                            .map(
                              (g) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF)
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF6C63FF)
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  g,
                                  style: const TextStyle(
                                    color: Color(0xFF9B95FF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
