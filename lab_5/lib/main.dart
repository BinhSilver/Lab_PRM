import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/movie_detail_screen.dart';
import 'data/sample_data.dart';

// ═══════════════════════════════════════════════════════════════════════════
// main.dart – Entry point với Deep Link support
// ═══════════════════════════════════════════════════════════════════════════
//
// THAY ĐỔI so với ban đầu:
//   • Thêm onGenerateRoute     → xử lý named routes động
//   • Thêm route '/movie/:id'  → deep link vào trang chi tiết
//
// DEEP LINK LÀ GÌ?
//   Deep link cho phép mở thẳng một màn hình cụ thể bằng URL/route,
//   thay vì luôn phải bắt đầu từ Home.
//
//   Ví dụ: Navigator.pushNamed(context, '/movie/1')
//   → Mở thẳng trang chi tiết phim có id = '1'
//   (Không cần qua HomeScreen, không cần nhấn vào thẻ phim)
// ═══════════════════════════════════════════════════════════════════════════

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Detail App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
      ),

      // ── Màn hình khởi đầu ───────────────────────────────────────────
      home: const HomeScreen(),

      // ── onGenerateRoute: Deep Link Handler ──────────────────────────
      //
      // Flutter gọi hàm này khi Navigator.pushNamed() được gọi.
      // settings.name = chuỗi route (ví dụ: '/movie/1')
      // settings.arguments = dữ liệu kèm theo (nếu có)
      //
      // Tại sao dùng onGenerateRoute thay vì routes: {} ?
      //   → routes: {} chỉ hỗ trợ route tĩnh (chính xác tên)
      //   → onGenerateRoute hỗ trợ route động với tham số (/movie/:id)
      onGenerateRoute: (RouteSettings settings) {
        // Phân tích tên route
        final uri = Uri.parse(settings.name ?? '');

        // Route: /movie/{id}  → Deep link vào trang chi tiết
        //
        // uri.pathSegments = ['movie', '1'] với route '/movie/1'
        // Kiểm tra:
        //   [0] == 'movie'  → đúng prefix
        //   length == 2     → có đúng 1 tham số (id)
        if (uri.pathSegments.length == 2 &&
            uri.pathSegments[0] == 'movie') {
          final movieId = uri.pathSegments[1]; // Lấy id từ URL

          // Tìm phim trong danh sách mẫu
          final movie = sampleMovies.firstWhere(
            (m) => m.id == movieId,
            orElse: () => sampleMovies.first, // Fallback nếu không tìm thấy
          );

          // Trả về Route dẫn thẳng đến MovieDetailScreen
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => MovieDetailScreen(
              movie: movie,
              // Deep link không có Home để đồng bộ favorites
              // → Dùng Set rỗng và callback rỗng (no-op)
              favoriteIds: const {},
              onFavoriteChanged: (_) {}, // no-op callback
            ),
          );
        }

        // Route không nhận ra → về Home (fallback)
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      },
    );
  }
}
