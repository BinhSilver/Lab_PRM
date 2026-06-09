import 'package:flutter/material.dart';
import '../models/movie.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MovieDetailScreen – Màn hình chi tiết phim
// ═══════════════════════════════════════════════════════════════════════════
//
// THAY ĐỔI so với ban đầu:
//   • Nhận thêm prop favoriteIds        (Set<String> từ HomeScreen)
//   • Nhận thêm prop onFavoriteChanged  (callback để báo ngược lên Home)
//   • _isFavorite giờ được khởi tạo từ favoriteIds (đồng bộ với Home)
//   • _toggleFavorite gọi cả callback  → Home cũng cập nhật state
// ═══════════════════════════════════════════════════════════════════════════

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  // Set favorites đến từ HomeScreen (để biết phim này đã liked chưa)
  final Set<String> favoriteIds;

  // Callback để thông báo ngược lên HomeScreen khi toggle favorite
  final void Function(String movieId) onFavoriteChanged;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.favoriteIds,
    required this.onFavoriteChanged,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  // ── State: trạng thái yêu thích cục bộ ─────────────────────────────────
  //
  // Được khởi tạo từ widget.favoriteIds để đồng bộ với HomeScreen.
  // Nếu HomeScreen đã đánh dấu yêu thích phim này → mở Detail ra
  // icon tim đã đỏ sẵn.
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    // late bool _isFavorite không thể khởi tạo trực tiếp bằng widget
    // vì widget chưa sẵn sàng ở khai báo field.
    // initState() là nơi đúng để làm điều này.
    _isFavorite = widget.favoriteIds.contains(widget.movie.id);
  }

  /// Toggle favorite:
  ///   1. Cập nhật state cục bộ (_isFavorite) → UI màn hình này rebuild
  ///   2. Gọi callback lên HomeScreen         → UI Home cũng rebuild
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // Thông báo ngược lên HomeScreen để Set _favoriteIds được cập nhật
    widget.onFavoriteChanged(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final headerHeight = MediaQuery.of(context).size.height / 3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(context, movie, headerHeight),
            const SizedBox(height: 16),
            _buildGenreChips(movie),
            const SizedBox(height: 12),
            _buildOverview(movie),
            const SizedBox(height: 8),
            _buildActionButtons(),
            const Divider(thickness: 0.5, height: 24),
            _buildTrailersSection(movie),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Hero Banner: poster + gradient + title + back button
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildHeroBanner(
    BuildContext context,
    Movie movie,
    double headerHeight,
  ) {
    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Hero(
            tag: 'poster_${movie.id}',
            child: SizedBox.expand(
              child: Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stack) => Container(
                  color: Colors.grey[400],
                  child: const Icon(Icons.movie, size: 64, color: Colors.white),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black54,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Genre Chips
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildGenreChips(Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: movie.genres
            .map(
              (genre) => Chip(
                label: Text(genre, style: const TextStyle(fontSize: 13)),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.grey),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            )
            .toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Overview
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildOverview(Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        movie.overview,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Action Buttons: Favorite / Rate / Share
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Favorite – đổi màu theo _isFavorite cục bộ
        _ActionButton(
          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
          iconColor: _isFavorite ? Colors.red : Colors.black54,
          label: 'Favorite',
          onTap: _toggleFavorite,
        ),
        _ActionButton(
          icon: Icons.star_border,
          iconColor: Colors.black54,
          label: 'Rate',
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          iconColor: Colors.black54,
          label: 'Share',
          onTap: () {},
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Trailers Section
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildTrailersSection(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Trailers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movie.trailers.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.play_circle_filled,
                    color: Colors.black54,
                    size: 32,
                  ),
                  title: Text(
                    movie.trailers[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {},
                ),
                if (index < movie.trailers.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Widget nội bộ: nút action (Icon + Label)
// ─────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}
