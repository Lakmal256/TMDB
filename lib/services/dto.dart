class UserResponseDto {
  String? localId;
  String? email;
  String? idToken;
  String? refreshToken;
  String? posterPath;
  String? releaseDate;

  UserResponseDto.fromJson(Map<String, dynamic> value)
      : localId = value['localId'],
        email = value['email'],
        idToken = value['idToken'],
        refreshToken = value['refreshToken'];
}

class MovieDto {
  int movieId;
  bool? adult;
  String? backdropPath;
  String? originalTitle;
  String? overview;
  String? originalLanguage;
  String? posterPath;
  String? releaseDate;
  double? voteAverage;
  int? voteCount;

  // Unnamed constructor
  MovieDto({
    required this.movieId,
    this.adult,
    this.backdropPath,
    this.originalTitle,
    this.overview,
    this.originalLanguage,
    this.posterPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
  });

  // Named constructor for JSON deserialization
  MovieDto.fromJson(Map<String, dynamic> value)
      : movieId = value['id'],
        adult = value['adult'],
        backdropPath = value['backdrop_path'],
        originalTitle = value['original_title'],
        overview = value['overview'],
        originalLanguage = value['original_language'],
        posterPath = value['poster_path'],
        releaseDate = value['release_date'],
        voteAverage = value['vote_average'],
        voteCount = value['vote_count'];
}

class MovieDetailsDto {
  int? movieId;
  int? runtime;
  List<MovieGenresDto>? genres;
  List<MovieProductionCompanyDto>? productionCompanies;

  MovieDetailsDto({
    this.movieId,
    this.runtime,
    this.genres,
    this.productionCompanies,
});

  MovieDetailsDto.fromJson(Map<String, dynamic> value)
      : movieId = value['id'],
        runtime = value['runtime'],
        genres = (value["genres"] as List<dynamic>?)?.map((genres) => MovieGenresDto.fromJson(genres)).toList(),
        productionCompanies = (value["production_companies"] as List<dynamic>?)
            ?.map((productionCompanies) => MovieProductionCompanyDto.fromJson(productionCompanies))
            .toList();

  MovieDetailsDto.empty()
      : movieId = null,
        genres = null,
        productionCompanies = null;
}

class MovieGenresDto {
  String? name;

  MovieGenresDto({
    this.name,
});

  MovieGenresDto.fromJson(Map<String, dynamic> value) : name = value['name'];
}

class MovieProductionCompanyDto {
  String? logoPath;
  String? name;

  MovieProductionCompanyDto({
    this.logoPath,
    this.name,
});

  Map<String,dynamic> toMap(){
    return {
      'name': name,
      'logo_path': logoPath
    };
  }

  MovieProductionCompanyDto.fromJson(Map<String, dynamic> value)
      : logoPath = value['logo_path'],
        name = value['name'];
}

class MovieCastDto {
  int id;
  List<CastMemberDto> cast;

  MovieCastDto.fromJson(Map<String, dynamic> value)
      : id = value['id'],
        cast = (value['cast'] as List).map((castMember) => CastMemberDto.fromJson(castMember)).toList();
}

class CastMemberDto {
  bool? adult;
  int? gender;
  int? id;
  String? knownForDepartment;
  String? name;
  String? originalName;
  double? popularity;
  String? profilePath;
  int? castId;
  String? character;
  String? creditId;
  int? order;

  CastMemberDto.fromJson(Map<String, dynamic> value)
      : adult = value['adult'],
        gender = value['gender'],
        id = value['id'],
        knownForDepartment = value['known_for_department'],
        name = value['name'],
        originalName = value['original_name'],
        popularity = value['popularity'],
        profilePath = value['profile_path'],
        castId = value['cast_id'],
        character = value['character'],
        creditId = value['credit_id'],
        order = value['order'];
}
