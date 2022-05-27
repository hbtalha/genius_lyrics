import 'package:genius_lyrics/models/artist.dart';
import 'package:genius_lyrics/models/stats.dart';
import 'package:genius_lyrics/utils.dart';

class Song {
  String? _artist;
  final List<String> _featuredArtists = [];
  String? _lyrics;
  Artist? _primaryArtist;
  Stats? _stats;

  int? _annotationCount;
  String? _apiPath;
  String? _fullTitle;
  String? _headerImageThumbnailUrl;
  String? _headerImageUrl;
  int? _lyricsOwnerId;
  String? _lyricsState;
  String? _path;
  int? _pyongsCount;
  int? _id;
  String? _songArtImageThumbnailUrl;
  String? _songArtImageUrl;
  String? _title;
  String? _titleWithFeatured;
  String? _url;
  String? _releaseDate;
  String? _releaseDateForDisplay;
  Map<String, dynamic>? _songInfo;

  Song({required Map<String, dynamic> songInfo, required String lyrics}) {
    _songInfo = songInfo;
    List<dynamic>? featureArtists = songInfo['featured_artists'];
    if (featureArtists != null) {
      for (var featuredArtist in featureArtists) {
        if (featuredArtist['name'] != null) {
          _featuredArtists.add(featuredArtist['name']);
        }
      }
    }
    _artist = songInfo['primary_artist']['name'];
    _lyrics = lyrics;
    _primaryArtist = Artist(artistInfo: songInfo['primary_artist']);
    _stats = Stats(stats: songInfo['stats']);
    _annotationCount = songInfo['annotation_count'];
    _apiPath = songInfo['api_path'];
    _fullTitle = songInfo['full_title'];
    _headerImageThumbnailUrl = songInfo['header_image_thumbnail_url'];
    _headerImageUrl = songInfo['header_image_url'];
    _lyricsOwnerId = songInfo['lyrics_owner_id'];
    _releaseDate = songInfo['release_date'];
    _releaseDateForDisplay = songInfo['release_date_for_display'];
    _id = songInfo['id'];
    _lyricsState = songInfo['lyrics_state'];
    _path = songInfo['path'];
    _pyongsCount = songInfo['pyongs_count'];
    _songArtImageThumbnailUrl = songInfo['song_art_image_thumbnail_url'];
    _songArtImageUrl = songInfo['song_art_image_url'];
    _title = songInfo['title'];
    _titleWithFeatured = songInfo['title_with_featured'];
    _url = songInfo['url'];
  }

  String? get artist => _artist;

  List<String> get featuredArtists => _featuredArtists;

  String? get lyrics => _lyrics;

  Artist? get primaryArtist => _primaryArtist;

  Stats? get stats => _stats;

  int? get annotationCount => _annotationCount;

  String? get apiPath => _apiPath;

  String? get fullTitle => _fullTitle;

  String? get headerImageThumbnailUrl => _headerImageThumbnailUrl;

  String? get headerImageUrl => _headerImageUrl;

  int? get lyricsOwnerId => _lyricsOwnerId;

  String? get lyricsState => _lyricsState;

  String? get path => _path;

  int? get pyongsCount => _pyongsCount;

  int? get id => _id;

  String? get songArtImageThumbnailUrl => _songArtImageThumbnailUrl;

  String? get songArtImageUrl => _songArtImageUrl;

  String? get title => _title;

  String? get titleWithFeatured => _titleWithFeatured;

  String? get url => _url;

  String? get releaseDate => _releaseDate;

  String? get releaseDateForDisplay => _releaseDateForDisplay;

  Map<String, dynamic>? get toJson => _songInfo;

  /// Save the lyrics of the song in a filename given by `fileName`
  ///
  /// `fileName` must have '/' as separator
  Future<void> saveLyrics(
      {required String fileName,
      bool overwite = true,
      bool verbose = true}) async {
    writeTofile(
        fileName: fileName,
        data: lyrics ?? '',
        overwite: overwite,
        verbose: verbose);
  }
}
