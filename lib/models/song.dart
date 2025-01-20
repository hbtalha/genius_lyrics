import 'dart:convert';

import 'package:genius_lyrics/models/models.dart';
import 'package:genius_lyrics/src/utils.dart';

enum SortSongsParamns { byDate, byName }

class Song {
  String? _artist;
  final _featuredArtists = <Artist>[];
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
  DateTime? _releaseDate;
  String? _releaseDateForDisplay;
  Map<String, dynamic> _raw = {};

  Song({required Map<String, dynamic> songInfo, required String lyrics}) {
    _raw = songInfo;
    List<dynamic>? featureArtists = songInfo['featured_artists'];
    if (featureArtists != null) {
      for (var featuredArtist in featureArtists) {
        _featuredArtists.add(Artist.fromMap(featuredArtist));
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
    _releaseDate = _getReleaseDate(songInfo);
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

  /// Returns name of the primary artist
  String? get artist => _artist;

  /// Returns a list of [Artist] objects representing the artists who are featured in the song
  ///
  /// Note that the [Artist] objects returned don't contain all the artist properties
  ///
  ///The properties available are:
  /// - [apiPath]
  /// - [headerImageUrl]
  /// - [id]
  /// - [imageUrl]
  /// - [isMemeVerified]
  /// - [isVerified]
  /// - [url]
  /// - [name]
  ///
  /// To get the artists full info you could use the function [Genius.artist]
  List<Artist> get featuredArtists => _featuredArtists;

  String? get lyrics => _lyrics;

  void set lyrics(String? lyrics) => _lyrics = lyrics;

  /// Returns an [Artist] object
  ///
  /// Note that the [Artist] object returned doesn't contain all the artist properties
  ///
  ///The properties available are:
  /// - [apiPath]
  /// - [headerImageUrl]
  /// - [id]
  /// - [imageUrl]
  /// - [isMemeVerified]
  /// - [isVerified]
  /// - [url]
  /// - [name]
  ///
  /// To get the artists full info you could use the function [Genius.artist]
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

  DateTime get releaseDate => _releaseDate!;

  String? get releaseDateForDisplay => _releaseDateForDisplay;

  /// Returns song data and this data have some fields that are not present in the [Song]
  Map<String, dynamic> get raw => _raw;

  /// Save the lyrics of the song in a filename given by `fileName`
  ///
  /// `fileName` must have '/' as separator
  Future<void> saveLyrics({
    required String fileName,
    bool overwite = true,
    bool verbose = true,
  }) async {
    writeTofile(
      fileName: fileName,
      data: lyrics ?? '',
      overwite: overwite,
      verbose: verbose,
    );
  }

  DateTime? _getReleaseDate(Map<String, dynamic> json) {
    if (json['release_date'] != null) {
      return DateTime.parse(json['release_date']);
    } else if (json['release_date_components'] != null) {
      int year = json['release_date_components']['year'];
      int month = json['release_date_components']['month'];
      int day = json['release_date_components']['day'];

      return DateTime(year, month, day);
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'artist': _artist,
      'lyrics': _lyrics,
      'primaryArtist': _primaryArtist?.toMap(),
      'stats': _stats?.toMap(),
      'annotationCount': _annotationCount,
      'apiPath': _apiPath,
      'fullTitle': _fullTitle,
      'headerImageThumbnailUrl': _headerImageThumbnailUrl,
      'headerImageUrl': _headerImageUrl,
      'lyricsOwnerId': _lyricsOwnerId,
      'lyricsState': _lyricsState,
      'path': _path,
      'pyongsCount': _pyongsCount,
      'id': _id,
      'songArtImageThumbnailUrl': _songArtImageThumbnailUrl,
      'songArtImageUrl': _songArtImageUrl,
      'title': _title,
      'titleWithFeatured': _titleWithFeatured,
      'url': _url,
      'releaseDate': _releaseDate?.millisecondsSinceEpoch,
      'releaseDateForDisplay': _releaseDateForDisplay,
    };
  }

  String toJson() => json.encode(toMap());
}
