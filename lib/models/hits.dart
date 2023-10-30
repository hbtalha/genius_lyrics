import 'models.dart';

enum SortHitsParamns { byDate, byName }

class Hit {
  int? _annotationCount;
  String? _apiPath;
  String? _artistNames;
  String? _fullTitle;
  String? _headerImageThumbnailUrl;
  String? _headerImageUrl;
  int? _id;
  int? _lyricsOwnerId;
  LyricsState? _lyricsState;
  String? _path;
  int? _pyongsCount;
  ReleaseDateComponents? _releaseDateComponents;
  DateTime? _releaseDateForDisplay;
  String? _songArtImageThumbnailUrl;
  String? _songArtImageUrl;
  Stats? _stats;
  String? _title;
  String? _titleWithFeatured;
  String? _url;
  List<Artist> _featuredArtists = [];
  Artist? _primaryArtist;

  Hit(Map<String, dynamic> json) {
    _annotationCount = json['annotation_count'];
    _apiPath = json['api_path'];
    _artistNames = json['artist_names'];
    _fullTitle = json['full_title'];
    _headerImageThumbnailUrl = json['header_image_thumbnailUrl'];
    _headerImageUrl = json['header_imageUrl '];
    _id = json['id'];
    _lyricsOwnerId = json['lyrics_ownerId'];
    _lyricsState = _statusFromString(json['lyrics_state']);
    _path = json['path'];
    _pyongsCount = json['pyongs_count'];
    _releaseDateComponents =
        ReleaseDateComponents.fromJson(json['release_date_components']);
    _releaseDateForDisplay = DateTime(_releaseDateComponents!.year,
        _releaseDateComponents!.month, _releaseDateComponents!.day);
    json["release_date_with_abbreviated_month_for_display"];
    _stats = Stats(stats: json);
    _songArtImageThumbnailUrl = json["song_art_image_thumbnail_url"];
    _songArtImageUrl = json['songs_art_imageUrl'];
    _title = json['title'];
    _titleWithFeatured = json['title_with_featured'];
    _url = json['url'];
    for (var artist in json['featured_artists']) {
      _featuredArtists.add(Artist.fromJson(artist));
    }
    _primaryArtist = Artist.fromJson(json['primary_artist']);
  }

  int get annotationCount => _annotationCount!;

  ///
  /// the path used to find the song on the genius api
  ///
  String get apiPath => _apiPath!;

  ///
  /// all artists that participate on the song
  ///
  String get artistNames => _artistNames!;

  ///
  /// full music title
  /// this title include feat artists
  ///
  String get fullTitle => _fullTitle!;

  String? get headerImageThumbnailUrl => _headerImageThumbnailUrl;

  String? get headerImageUrl => _headerImageUrl;

  int get id => _id!;

  int? get lyricsOwnerId => _lyricsOwnerId;

  LyricsState get lyricsState => _lyricsState!;

  String get lyricsPath => _path!;

  ///
  /// pyong represent the number of people who create a link to the song
  /// more info about pyong https://genius.com/2544094
  ///
  int? get pyongsCount => _pyongsCount;

  DateTime get releaseDate => _releaseDateForDisplay!;

  String get songArtImageThumbnailUrl => _songArtImageThumbnailUrl!;

  String get songArtImageUrl => _songArtImageUrl!;
  Stats get stats => _stats!;

  String get title => _title!;

  String? get titleWithFeaturead => _titleWithFeatured;

  String get url => _url!;

  ///
  ///list of [Artists] that apear's on the song
  /// this propertie doesn't include all artist properties, some infos could be null
  /// to get all artist info use [artist] function provide on genius class
  ///
  List<Artist> get featuresArtists => _featuredArtists;

  ///
  /// returns the [Artist] object who is owner of the song
  ///
  /// this propertie doesn't include all artist properties, some infos could be null
  /// to get all artist info use [artist] function provide on genius class
  ///
  Artist get primaryArtist => _primaryArtist!;

  static List<Hit> sortHits({
    required List<Hit> hits,
    SortHitsParamns sortParamns = SortHitsParamns.byDate,
  }) {
    var sortedHits = hits;

    switch (sortParamns) {
      case SortHitsParamns.byName:
        sortedHits
            .sort((first, second) => first._title!.compareTo(second._title!));
        break;
      default:
        sortedHits.sort(
          (first, second) => first._releaseDateForDisplay!
              .compareTo(second._releaseDateForDisplay!),
        );
    }

    return sortedHits;
  }
}

enum LyricsState { complete, umknow }

LyricsState _statusFromString(String status) {
  switch (status) {
    case 'complete':
      return LyricsState.complete;
    default:
      return LyricsState.umknow;
  }
}

class ReleaseDateComponents {
  int year;
  int month;
  int day;
  ReleaseDateComponents({
    required this.year,
    required this.month,
    required this.day,
  });

  factory ReleaseDateComponents.fromJson(Map<String, dynamic> json) {
    return ReleaseDateComponents(
      year: json['year'],
      month: json['month'],
      day: json['day'],
    );
  }
}
