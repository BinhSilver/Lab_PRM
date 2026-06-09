import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/movie.dart';
import '../widgets/genre_chips.dart';
import '../widgets/movie_card.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/sort_dropdown.dart';

class MovieBrowseScreen extends StatefulWidget {
  const MovieBrowseScreen({super.key});

  @override
  State<MovieBrowseScreen> createState() => _MovieBrowseScreenState();
}

class _MovieBrowseScreenState extends State<MovieBrowseScreen> {
  // ── State ──────────────────────────────────
  String _searchQuery = '';
  final Set<String> _selectedGenres = {};
  String _selectedSort = 'A–Z';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filter & Sort pipeline ─────────────────
  List<Movie> get _visibleMovies {
    List<Movie> result = List<Movie>.from(kMovies);

    // 1. Lọc theo từ khoá (không phân biệt hoa/thường)
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((m) =>
              m.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 2. Lọc theo thể loại – giữ phim có ít nhất 1 genre đang chọn
    if (_selectedGenres.isNotEmpty) {
      result = result
          .where((m) => m.genres.any((g) => _selectedGenres.contains(g)))
          .toList();
    }

    // 3. Sắp xếp
    switch (_selectedSort) {
      case 'A–Z':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Z–A':
        result.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'Year':
        result.sort((a, b) => b.year.compareTo(a.year));
        break;
      case 'Rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return result;
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedGenres.isNotEmpty;

  // ── Handlers ───────────────────────────────
  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _onSearchClear() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _onToggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  void _onSortChanged(String? val) {
    if (val != null) setState(() => _selectedSort = val);
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedGenres.clear();
      _searchController.clear();
    });
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final visibleMovies = _visibleMovies;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SearchBarField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _onSearchClear,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GenreChips(
                    allGenres: kAllGenres,
                    selectedGenres: _selectedGenres,
                    onToggle: _onToggleGenre,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 2),
                  child: SortDropdown(
                    selectedSort: _selectedSort,
                    options: kSortOptions,
                    onChanged: _onSortChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildResultBar(visibleMovies.length),
            const SizedBox(height: 8),
            // Dùng Expanded để chiếm toàn bộ không gian còn lại
            Expanded(
              child: _buildMovieList(visibleMovies),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
            ).createShader(bounds),
            child: const Icon(
              Icons.movie_filter_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Find a Movie',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
                ).createShader(const Rect.fromLTWH(0, 0, 220, 40)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Result bar + BONUS Clear button ───────
  Widget _buildResultBar(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '$count ${count == 1 ? 'movie' : 'movies'} found',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          if (_hasActiveFilters)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(
                Icons.filter_alt_off_rounded,
                size: 16,
                color: Color(0xFFFF6B9D),
              ),
              label: const Text(
                'Clear filters',
                style: TextStyle(color: Color(0xFFFF6B9D), fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  // ── Responsive Movie List ─────────────────
  Widget _buildMovieList(List<Movie> movies) {
    if (movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_outlined,
                size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              'No movies found',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 16),
            ),
          ],
        ),
      );
    }

    // LayoutBuilder đọc maxWidth để chọn layout phù hợp
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          // ── Tablet / Web: 2 cột GridView ────
          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.6,
            children: movies
                .map((m) => MovieCard(
                      movie: m,
                      parentConstraints: constraints,
                    ))
                .toList(),
          );
        } else {
          // ── Mobile: 1 cột ListView ───────────
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            itemBuilder: (context, index) => MovieCard(
              movie: movies[index],
              parentConstraints: constraints,
            ),
          );
        }
      },
    );
  }
}
