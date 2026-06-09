import 'package:flutter/material.dart';

class GenreChips extends StatelessWidget {
  final List<String> allGenres;
  final Set<String> selectedGenres;
  final ValueChanged<String> onToggle;

  const GenreChips({
    super.key,
    required this.allGenres,
    required this.selectedGenres,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + BONUS badge đếm số genre đang active
          Row(
            children: [
              Text(
                'GENRES',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              if (selectedGenres.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${selectedGenres.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Chip list – dùng Wrap để tự xuống dòng
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allGenres.map((genre) {
              final isSelected = selectedGenres.contains(genre);
              return GestureDetector(
                onTap: () => onToggle(genre),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    genre,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
