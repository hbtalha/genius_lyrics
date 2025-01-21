import 'dart:convert';

import 'package:genius_lyrics/models/models.dart';
import 'package:genius_lyrics/src/genius.dart';
import 'package:genius_lyrics/src/utils.dart';

typedef SocialNetwork = ({
  String? instagram,
  String? facebook,
  String? twitter
});

class Artist {
  String? _apiPath;
  String? _headerImageUrl;
  String? _imageUrl;
  int? _id;
  int? _iq;
  bool? _isMemeVerified;
  bool? _isVerified;
  String? _name;
  SocialNetwork _socialNetwork =
      (facebook: null, instagram: null, twitter: null);
  List<String> _alternateNames = [];
  String? _url;
  final List<Song> _songs = [];
  int _numSongs = 0;
  Map<String, dynamic> _raw = {};
  String? _about;

  Artist({required Map<String, dynamic> artistInfo}) {
    _raw = artistInfo;
    _apiPath = artistInfo['api_path'];
    _headerImageUrl = artistInfo['header_image_url'];
    _imageUrl = artistInfo['image_url'];
    _iq = artistInfo['iq'];
    _id = artistInfo['id'];
    _isMemeVerified = artistInfo['is_meme_verified'];
    _isVerified = artistInfo['is_verified'];
    _name = artistInfo['name'];
    _url = artistInfo['url'];
    _alternateNames = List<String>.from(artistInfo['alternate_names'] ?? []);
    _socialNetwork = (
      facebook: artistInfo['facebook_name'],
      instagram: artistInfo['instagram_name'],
      twitter: artistInfo['twitter_name']
    );
    _about = artistInfo['description']?['plain'];
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      artistInfo: json,
    );
  }

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(artistInfo: map);
  }

  /// Returns song data and this data have some fields that are not present in the [Artist]
  Map<String, dynamic> get raw => _raw;

  String? get apiPath => _apiPath;

  String? get headerImageUrl => _headerImageUrl;

  String? get imageUrl => _imageUrl;

  int? get iq => _iq;

  int? get id => _id;

  bool? get isMemeVerified => _isMemeVerified;

  bool? get isVerified => _isVerified;

  String? get name => _name;

  List<String> get alternateNames => _alternateNames;

  String? get url => _url;

  List<Song> get songs => _songs;

  /// return the artist description that is on the artist page on genius
  String? get about => _about;

  int get numSongs => _numSongs;

  SocialNetwork get socialNetwork => _socialNetwork;

  ///Gets the artist's song return a [Song] in case of success and null otherwise.
  ///
  /// If the song is in the artist's songs, returns the song. Otherwise searches
  /// Genius for the song and then returns the song.

  Future<Song?> song({required Genius client, required String songName}) async {
    for (var song in songs) {
      if (song.title != null) {
        if (song.title == songName) {
          return song;
        }
      }
    }

    return await client.searchSong(artist: name, title: songName);
  }

  ///Adds a song to the Artist.
  ///
  /// This method adds a new song to the artist object. It checks if the song is already in artist's songs
  /// and whether the song's artist is the same as the `Artist` object.

  void addSong(
      {required Song newSong,
      bool verbose = true,
      bool includeFeatures = false}) {
    if (newSong.title != null) {
      if (_songs.any((element) => element.title! == newSong.title)) {
        if (verbose) {
          print('${newSong.title} already in $name, not adding song.');
        }
      }

      if (name != null || newSong.artist != null) {
        if (newSong.artist == name ||
            (includeFeatures && newSong.featuredArtists.contains(name))) {
          _songs.add(newSong);
          ++_numSongs;
          if (verbose) {
            print('Song $_numSongs: ${newSong.title}');
          }
        }
      }
    } else {
      if (verbose) {
        print("Can't add song by ${newSong.artist}, artist must be $name.");
      }
    }
  }

  /// Save the lyrics of all the artist songs
  ///
  ///Given the `destPath` (destination path), each song lyrics will be saved in that location with the song title as the filename
  ///
  ///`destPath` must have '/' as separator
  Future<void> saveLyrics(
      {required String destPath,
      String ext = '.lrc',
      bool overwite = true,
      bool verbose = true}) async {
    saveLyricsOfMultipleSongs(
      songs: songs,
      destPath: destPath,
      ext: ext,
      overwite: overwite,
      verbose: verbose,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apiPath': _apiPath,
      'headerImageUrl': _headerImageUrl,
      'imageUrl': _imageUrl,
      'id': _id,
      'iq': _iq,
      'isMemeVerified': _isMemeVerified,
      'isVerified': _isVerified,
      'name': _name,
      'socialNetwork': {
        'instagram': socialNetwork.instagram,
        'facebook': socialNetwork.facebook,
        'twitter': socialNetwork.twitter,
      },
      'alternateNames': _alternateNames,
      'url': _url,
      'numSongs': _numSongs,
      'about': _about,
    };
  }

  String toJson() => json.encode(toMap());

  // factory Artist.fromJson(String source) => Artist.fromMap(json.decode(source));
}
