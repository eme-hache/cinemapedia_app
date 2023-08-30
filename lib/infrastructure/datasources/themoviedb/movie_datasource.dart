import 'package:dio/dio.dart';

import 'package:cinemapedia/infrastructure/models/themoviedb/movies_response.dart';
import 'package:cinemapedia/infrastructure/models/themoviedb/movie_details.dart';
import 'package:cinemapedia/infrastructure/mappers/themoviedb/movie_mapper.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/config/constants/environment.dart';

class MovieDatasource extends MoviesDatasource {
  final dio = Dio(BaseOptions(
      baseUrl: Environment.theMovieDBUrl,
      queryParameters: {
        'api_key': Environment.theMovieDBKey,
        'language': 'es-MX'
      }));

  List<Movie> _jsonToMovies(Map<String, dynamic> json) {
    final theMovieDBResponse = MoviesResponse.fromJson(json);
    return theMovieDBResponse.results
        .where((theMovieDb) => theMovieDb.posterPath != 'no-poster')
        .map((theMovieDb) => MovieMapper.theMovieDBToEntity(theMovieDb))
        .toList();
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response =
        await dio.get('/movie/now_playing', queryParameters: {'page': page});

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    final response =
        await dio.get('/movie/popular', queryParameters: {'page': page});

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
    final response =
        await dio.get('/movie/top_rated', queryParameters: {'page': page});

    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final response =
        await dio.get('/movie/upcoming', queryParameters: {'page': page});

    return _jsonToMovies(response.data);
  }

  @override
  Future<Movie> getMovieById(String id) async {
    final response =
        await dio.get('/movie/$id');

    if (response.statusCode != 200) throw Exception('Movie with id: $id not found');

    final movieDetails = MovieDetails.fromJson(response.data);

    return MovieMapper.movieDetailsToEntity(movieDetails);
  }
  
  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    
     final response =
        await dio.get('/search/movie', queryParameters: {'query': query});

    return _jsonToMovies(response.data);
  }
}
