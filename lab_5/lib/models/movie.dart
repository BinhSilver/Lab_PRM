/// Data model đại diện cho một bộ phim.
///
/// Chứa toàn bộ thông tin cần thiết để hiển thị
/// trên Home Screen (card) và Movie Detail Screen.
class Movie {
  /// ID duy nhất của phim
  final String id;

  /// Tiêu đề phim
  final String title;

  /// URL hình poster (dùng Image.network)
  final String posterUrl;

  /// Mô tả nội dung phim
  final String overview;

  /// Danh sách thể loại (ví dụ: ['Sci-Fi', 'Adventure'])
  final List<String> genres;

  /// Điểm đánh giá (0.0 – 10.0)
  final double rating;

  /// Danh sách tên các trailer
  final List<String> trailers;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.overview,
    required this.genres,
    required this.rating,
    required this.trailers,
  });
}
