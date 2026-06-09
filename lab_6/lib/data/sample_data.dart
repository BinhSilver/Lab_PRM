import '../models/movie.dart';

const List<Movie> kMovies = [
  Movie(
    title: 'Inception',
    year: 2010,
    genres: ['Action', 'Sci-Fi', 'Thriller'],
    posterUrl: 'https://picsum.photos/seed/inception/300/450',
    rating: 8.8,
  ),
  Movie(
    title: 'The Dark Knight',
    year: 2008,
    genres: ['Action', 'Drama', 'Crime'],
    posterUrl: 'https://picsum.photos/seed/darkknight/300/450',
    rating: 9.0,
  ),
  Movie(
    title: 'Interstellar',
    year: 2014,
    genres: ['Sci-Fi', 'Drama', 'Adventure'],
    posterUrl: 'https://picsum.photos/seed/interstellar/300/450',
    rating: 8.6,
  ),
  Movie(
    title: 'The Grand Budapest Hotel',
    year: 2014,
    genres: ['Comedy', 'Drama'],
    posterUrl: 'https://picsum.photos/seed/grandbudapest/300/450',
    rating: 8.1,
  ),
  Movie(
    title: 'Avengers: Endgame',
    year: 2019,
    genres: ['Action', 'Sci-Fi', 'Adventure'],
    posterUrl: 'https://picsum.photos/seed/endgame/300/450',
    rating: 8.4,
  ),
  Movie(
    title: 'Parasite',
    year: 2019,
    genres: ['Thriller', 'Drama', 'Comedy'],
    posterUrl: 'https://picsum.photos/seed/parasite/300/450',
    rating: 8.5,
  ),
];

const List<String> kAllGenres = [
  'Action',
  'Adventure',
  'Comedy',
  'Crime',
  'Drama',
  'Sci-Fi',
  'Thriller',
];

const List<String> kSortOptions = ['A–Z', 'Z–A', 'Year', 'Rating'];
