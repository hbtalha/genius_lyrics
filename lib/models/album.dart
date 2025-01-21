import 'dart:convert';

import 'package:genius_lyrics/models/models.dart';
import 'package:genius_lyrics/src/utils.dart';

class Album {
  final Map<String, dynamic> _raw;
  final Artist? _artist;
  final List<Song> _tracks;
  final String? _apiPath;
  final int? _id;
  final String? _url;
  final String? _name;
  final String? _fullTitle;
  final String? _coverArtThumbnailUrl;
  final String? _coverArtUrl;

  Album({required Map<String, dynamic> albumInfo, required List<Song> tracks})
      : _raw = albumInfo,
        _artist = Artist(artistInfo: albumInfo['artist']),
        _tracks = tracks,
        _url = albumInfo['url'],
        _id = albumInfo['id'],
        _name = albumInfo['name'],
        _fullTitle = albumInfo['full_title'],
        _coverArtUrl = albumInfo['cover_art_url'],
        _apiPath = albumInfo['api_path'],
        _coverArtThumbnailUrl = albumInfo['cover_art_thumbnail_url'];

  /// returns song data and this data have some fields that are not present in the [Album]
  Map<String, dynamic> get raw => _raw;

  Artist? get artist => _artist;

  List<Song> get tracks => _tracks;

  String? get apiPath => _apiPath;

  String? get fullTitle => _fullTitle;

  String? get coverArtThumbnailUrl => _coverArtThumbnailUrl;

  String? get coverArtUrl => _coverArtUrl;

  String? get url => _url;

  int? get id => _id;

  String? get name => _name;

  /// Saves the lyrics of all the tracks of the album.
  ///
  /// Given the `destPath` (destination path), each track's lyrics will be saved in that location with the track title as the filename.
  /// `destPath` must have '/' as separator.
  Future<void> saveLyrics(
      {required String destPath,
      String ext = '.lrc',
      bool overwite = true,
      bool verbose = true}) async {
    saveLyricsOfMultipleSongs(
        songs: tracks,
        destPath: destPath,
        ext: ext,
        overwite: overwite,
        verbose: verbose);
  }

  Map<String, dynamic> toMap() {
    return {
      'artist': _artist?.toMap(),
      'tracks': _tracks.map((x) => x.toMap()).toList(),
      'apiPath': _apiPath,
      'id': _id,
      'url': _url,
      'name': _name,
      'fullTitle': _fullTitle,
      'coverArtThumbnail': _coverArtThumbnailUrl,
      'coverArtUrl': _coverArtUrl,
    };
  }

  String toJson() => json.encode(toMap());
}
