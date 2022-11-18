import 'package:genius_lyrics/src/genius.dart';
import 'package:genius_lyrics/models/song.dart';
import 'package:genius_lyrics/src/utils.dart';

class Artist {
  String? _apiPath;
  String? _headerImageUrl;
  String? _imageUrl;
  int? _id;
  int? _iq;
  bool? _isMemeVerified;
  bool? _isVerified;
  String? _name;
  String? _url;
  final List<Song> _songs = [];
  int _numSongs = 0;
  Map<String, dynamic> _artistInfo = {};

  Artist({required Map<String, dynamic> artistInfo}) {
    _artistInfo = artistInfo;
    _apiPath = artistInfo['api_path'];
    _headerImageUrl = artistInfo['header_image_url'];
    _imageUrl = artistInfo['image_url'];
    _iq = artistInfo['iq'];
    _id = artistInfo['id'];
    _isMemeVerified = artistInfo['is_meme_verified'];
    _isVerified = artistInfo['is_verified'];
    _name = artistInfo['name'];
    _url = artistInfo['url'];
  }

  /// Returns song data and this data have some fields that are not present in the [Artist]
  Map<String, dynamic> get toJson => _artistInfo;

  String? get apiPath => _apiPath;

  String? get headerImageUrl => _headerImageUrl;

  String? get imageUrl => _imageUrl;

  int? get iq => _iq;

  int? get id => _id;

  bool? get isMemeVerified => _isMemeVerified;

  bool? get isVerified => _isVerified;

  String? get name => _name;

  String? get url => _url;

  List<Song> get songs => _songs;

  int get numSongs => _numSongs;

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
        verbose: verbose);
  }
}
