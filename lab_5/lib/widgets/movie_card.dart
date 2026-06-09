import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../screens/movie_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MovieCard – Widget thẻ phim
// ═══════════════════════════════════════════════════════════════════════════
//
// THAY ĐỔI so với ban đầu:
//   • Thêm prop isFavorite        → hiển thị icon tim đỏ/rỗng trên card
//   • Thêm prop onFavoriteToggle  → callback khi nhấn icon tim
//   • Thêm prop favoriteIds       → truyền sang màn hình Detail
//   • Thêm prop onFavoriteChanged → callback từ Detail screen lên Home
//   • Thêm IconButton ❤ ở góc phải (thay cho chevron)
// ═══════════════════════════════════════════════════════════════════════════

class MovieCard extends StatelessWidget {
  final Movie movie;

  // Trạng thái yêu thích của phim này (đến từ HomeScreen._favoriteIds)
  final bool isFavorite;

  // Callback được gọi khi nhấn icon tim trên card
  final VoidCallback onFavoriteToggle;

  // Toàn bộ Set favorites để truyền sang màn hình Detail
  final Set<String> favoriteIds;

  // Callback để Detail screen báo ngược lên khi toggle favorite
  final void Function(String movieId) onFavoriteChanged;

  const MovieCard({
    super.key,
    required this.movie,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.favoriteIds,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final genreText = movie.genres.join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          // Điều hướng sang màn hình chi tiết
          // Truyền theo: movie, favoriteIds, và callback onFavoriteChanged
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(
                movie: movie,
                favoriteIds: favoriteIds,
                onFavoriteChanged: onFavoriteChanged,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // ── Poster thu nhỏ (Hero) ─────────────────────────────────
              Hero(
                tag: 'poster_${movie.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    movie.posterUrl,
                    width: 70,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 70,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) => Container(
                      width: 70,
                      height: 100,
                      color: Colors.grey[400],
                      child: const Icon(Icons.movie, color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── Thông tin phim ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '☆ ${movie.rating} • $genreText',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Icon Favorite (mới) ────────────────────────────────────
              //
              // Hiển thị icon tim đỏ nếu isFavorite == true.
              // Dùng IconButton để có vùng nhấn chuẩn (48x48).
              // stopPropagation: GestureDetector không có built-in,
              // nhưng InkWell cha sẽ không nhận onTap vì IconButton
              // đã consume sự kiện nhấn.
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.black45,
                ),
                onPressed: onFavoriteToggle,
                // Kích thước vùng nhấn tối thiểu (Material Design)
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
