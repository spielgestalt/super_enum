import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:super_enum/super_enum.dart';
import 'dart:io';

import 'movies.dart';

part 'main.g.dart';

@superEnum
enum _MoviesResponse {
  @Data(fields: [DataField<Movies>('movies')])
  Success,
  @object
  Unauthorized,
  @object
  NoNetwork,
  @Data(fields: [DataField<Exception>('exception')])
  UnexpectedException
}

class MoviesFetcher {
  http.Client client = http.Client();
  final _baseUrl = "http://api.themoviedb.org/3/movie";

  final String apiKey;

  MoviesFetcher({@required this.apiKey});

  Future<MoviesResponse> fetchMovies() async {
    try {
      final response = await client.get('$_baseUrl/popular?api_key=$apiKey');
      if (response.statusCode == 200) {
        final movies = Movies.fromJson(json.decode(response.body));
        return MoviesResponse.success(movies: movies);
      } else {
        return MoviesResponse.unauthorized();
      }
    } on SocketException {
      return MoviesResponse.noNetwork();
    } catch (e) {
      return MoviesResponse.unexpectedException(exception: e);
    }
  }
}

void main() async {
  final _moviesFetcher = MoviesFetcher(
    apiKey: '9c9576f8c2e86949a3220fcc32ae2fb6',
  );

  final _moviesResponse = await _moviesFetcher.fetchMovies();

  _moviesResponse.when(
    success: (data) => print('Total Movies: ${data.movies.totalPages}'),
    unauthorized: (_) => print('Invalid ApiKey'),
    noNetwork: (_) => print(
      'No Internet, Please check your internet connection',
    ),
    unexpectedException: (error) => print(error.exception),
  );
}
