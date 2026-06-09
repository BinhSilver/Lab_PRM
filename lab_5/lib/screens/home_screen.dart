import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';

// ═══════════════════════════════════════════════════════════════════════════
// HomeScreen – StatefulWidget (vì có state: danh sách yêu thích + tìm kiếm)
// ═══════════════════════════════════════════════════════════════════════════
//
// THAY ĐỔI so với ban đầu:
//   • StatelessWidget → StatefulWidget  (để lưu favorites và query tìm kiếm)
//   • Thêm Set<String> _favoriteIds     (lưu id phim đã yêu thích)
//   • Thêm SearchBar trong AppBar       (lọc phim theo tên)
//   • Truyền callback onFavoriteToggle  xuống MovieCard
// ═══════════════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── 1. STATE: Danh sách id phim yêu thích ──────────────────────────────
  //
  // Dùng Set<String> thay vì List<String> vì:
  //   • Set không chứa phần tử trùng → không lo bị add 2 lần
  //   • contains() trên Set là O(1)   → nhanh hơn List.contains() O(n)
  final Set<String> _favoriteIds = {};

  // ── 2. STATE: Từ khóa tìm kiếm hiện tại ────────────────────────────────
  String _searchQuery = '';

  // Controller để điều khiển TextField tìm kiếm (clear text, v.v.)
  final TextEditingController _searchController = TextEditingController();

  // ── 3. Getter: Danh sách phim đã lọc ───────────────────────────────────
  //
  // Đây là "computed property" – tính lại mỗi lần build() chạy.
  // Không cần lưu vào state riêng vì nó phụ thuộc vào _searchQuery.
  List<Movie> get _filteredMovies {
    if (_searchQuery.isEmpty) {
      // Không có từ khóa → trả về tất cả phim
      return sampleMovies;
    }
    // Lọc phim có title chứa từ khóa (không phân biệt hoa thường)
    return sampleMovies.where((movie) {
      return movie.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // ── 4. Hàm toggle favorite ──────────────────────────────────────────────
  //
  // Được truyền xuống MovieCard và MovieDetailScreen dưới dạng callback.
  // Khi được gọi → setState() → build() chạy lại → UI cập nhật.
  void _toggleFavorite(String movieId) {
    setState(() {
      if (_favoriteIds.contains(movieId)) {
        _favoriteIds.remove(movieId); // Bỏ yêu thích
      } else {
        _favoriteIds.add(movieId);    // Thêm yêu thích
      }
    });
  }

  // ── 5. Giải phóng controller khi widget bị xóa khỏi cây ────────────────
  //
  // QUAN TRỌNG: Luôn dispose controller để tránh memory leak.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar ─────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Movies',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ── Body ───────────────────────────────────────────────────────────
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────────────
          _buildSearchBar(),

          // ── Danh sách phim hoặc thông báo "không tìm thấy" ─────────────
          Expanded(
            child: _filteredMovies.isEmpty
                ? _buildEmptyState()
                : _buildMovieList(),
          ),
        ],
      ),

      // ── FAB: Demo Deep Link ─────────────────────────────────────────────
      //
      // FloatingActionButton mở một BottomSheet hiển thị danh sách
      // các route deep link. Khi nhấn vào một route → Navigator.pushNamed()
      // → onGenerateRoute trong main.dart xử lý → mở thẳng màn hình chi tiết
      //
      // Đây chính là minh họa trực tiếp của Deep Link!
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDeepLinkDemo(context),
        backgroundColor: Colors.blueGrey,
        icon: const Icon(Icons.link, color: Colors.white),
        label: const Text(
          'Deep Link Demo',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // ── Widget: Demo Deep Link Bottom Sheet ─────────────────────────────────
  //
  // Hiển thị danh sách các "URL" deep link.
  // Mỗi URL tương ứng với một phim trong sampleMovies.
  // Khi nhấn → Navigator.pushNamed(context, '/movie/{id}')
  //          → main.dart xử lý qua onGenerateRoute
  //          → Mở thẳng MovieDetailScreen (không qua HomeScreen)
  void _showDeepLinkDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // BottomSheet chỉ cao bằng nội dung
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              const Text(
                '🔗 Deep Link Demo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Nhấn vào một route để mở thẳng màn hình chi tiết\n'
                'mà KHÔNG qua HomeScreen.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Divider(height: 24),

              // Danh sách route deep link cho từng phim
              ...sampleMovies.map((movie) {
                final route = '/movie/${movie.id}';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  // Icon link màu xanh
                  leading: const Icon(Icons.open_in_new, color: Colors.blueGrey),
                  // Hiển thị route như một URL
                  title: Text(
                    route,
                    style: const TextStyle(
                      fontFamily: 'monospace', // Font code để trông như URL
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  subtitle: Text(
                    movie.title,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    // ① Đóng BottomSheet trước
                    Navigator.pop(context);

                    // ② Gọi pushNamed với route '/movie/1', '/movie/2', ...
                    //    → Flutter gọi onGenerateRoute(settings) trong main.dart
                    //    → onGenerateRoute phân tích URI, tìm phim, tạo Route
                    //    → Mở MovieDetailScreen trực tiếp
                    Navigator.pushNamed(context, route);
                  },
                );
              }),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Widget: Search Bar ──────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        // Controller: cho phép đọc/xóa nội dung TextField từ code
        controller: _searchController,

        // Mỗi khi người dùng gõ, cập nhật _searchQuery → rebuild
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },

        decoration: InputDecoration(
          hintText: 'Search movies...',
          hintStyle: const TextStyle(color: Colors.grey),

          // Icon kính lúp bên trái
          prefixIcon: const Icon(Icons.search, color: Colors.grey),

          // Nút X để xóa nội dung (chỉ hiện khi có text)
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    // Xóa text trong TextField và reset query
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null, // Không hiện nút X khi trống

          // Viền bo tròn
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Không có viền mặc định
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F7), // Nền xám nhạt
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── Widget: Danh sách phim ──────────────────────────────────────────────
  Widget _buildMovieList() {
    return ListView.builder(
      itemCount: _filteredMovies.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final movie = _filteredMovies[index];

        return MovieCard(
          movie: movie,
          // Kiểm tra phim này có trong Set favorites không
          isFavorite: _favoriteIds.contains(movie.id),
          // Truyền callback toggle xuống MovieCard
          onFavoriteToggle: () => _toggleFavorite(movie.id),
          // Truyền toàn bộ Set favorites xuống để màn hình Detail dùng
          favoriteIds: _favoriteIds,
          // Callback để Detail screen cập nhật state lên Home
          onFavoriteChanged: _toggleFavorite,
        );
      },
    );
  }

  // ── Widget: Không tìm thấy kết quả ─────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No movies found for "$_searchQuery"',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
