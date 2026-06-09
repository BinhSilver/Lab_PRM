import '../models/movie.dart';

/// Dữ liệu mẫu tĩnh – không cần gọi API.
///
/// Sử dụng hình ảnh từ Unsplash/TMDB-style public URLs
/// để đảm bảo chạy được trên DartPad và Android Studio.
final List<Movie> sampleMovies = [
  Movie(
    id: '1',
    title: 'Dune: Part Two',
    posterUrl:
        'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
    overview:
        'Paul Atreides unites with Chani and the Fremen while seeking '
        'revenge against the conspirators who destroyed his family. '
        'Facing a choice between the love of his life and the fate of '
        'the known universe, he endeavors to prevent a terrible future '
        'only he can foresee.',
    genres: ['Sci-Fi', 'Adventure', 'Drama'],
    rating: 8.6,
    trailers: [
      'Official Trailer #1',
      'IMAX Sneak Peek',
      'Behind the Scenes',
    ],
  ),
  Movie(
    id: '2',
    title: 'Deadpool & Wolverine',
    posterUrl:
        'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
    overview:
        'The multiverse gets messy when Wade Wilson teams up with '
        'Wolverine for a not-so-family-friendly mission. Together they '
        'face new threats that challenge everything they know about '
        'their world and themselves.',
    genres: ['Action', 'Comedy'],
    rating: 8.3,
    trailers: [
      'Red Band Trailer',
      'Behind the Scenes',
      'Official Trailer #2',
    ],
  ),
  Movie(
    id: '3',
    title: 'Inside Out 2',
    posterUrl:
        'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
    overview:
        'Riley enters adolescence and her Headquarters gets a surprise '
        'demolition to make room for something completely unexpected: '
        'new Emotions! Joy, Sadness, Anger, Fear and Disgust are not '
        'sure how to feel when Anxiety shows up.',
    genres: ['Animation', 'Family', 'Comedy'],
    rating: 7.9,
    trailers: [
      'Official Trailer',
      'Teaser Trailer',
      'Clip – New Emotions',
    ],
  ),
];
