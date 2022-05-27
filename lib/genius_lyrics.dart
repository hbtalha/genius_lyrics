library genius_lyrics;

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:genius_lyrics/models/album.dart';
import 'package:genius_lyrics/models/artist.dart';
import 'package:genius_lyrics/models/song.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: constant_identifier_names
enum SongsSorting { popularity, title, release_date }

class Genius {
  String accessToken;
  bool verbose;
  bool skipNonSongs;
  Genius({required this.accessToken, this.verbose = true, this.skipNonSongs = true});

  dynamic _error(String errorMsg) {
    if (verbose) {
      print(errorMsg);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _request({required String uri}) async {
    try {
      String getResponse = (await http.get(Uri.parse(Uri.encodeFull(uri)))).body;
      return jsonDecode(getResponse);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getItemFromSearchResponse(
      {required Map<String, dynamic> response, required String searchTerm, required String type, required String resultType}) async {
    List<dynamic> topHits = response['sections'][0]['hits'];

    List<Map<String, dynamic>> hits = [];

    for (var hit in topHits) {
      if (hit['type'] != null) {
        if (hit['type'] == type) {
          hits.add(hit);
        }
      }
    }

    List<dynamic> sections = response['sections'];

    for (var section in sections) {
      if (section['hits'] != null) {
        for (var hit in section['hits']) {
          if (hit['type'] != null) {
            if (hit['type'] == type) {
              hits.add(hit);
            }
          }
        }
      }
    }

    for (var hit in hits) {
      Map<String, dynamic>? item = hit['result'];
      if (item != null) {
        if (item[resultType] == searchTerm) {
          return item;
        }
      }
    }

    if (type == 'song' && skipNonSongs) {
      for (var hit in hits) {
        Map<String, dynamic>? song = hit['result'];
        if (song != null) {
          if (song['lyrics_state'] == 'complete') {
            return song;
          }
        }
      }
    }

    return jsonDecode(hits[0]['result']);
  }

  Future<Map<String, dynamic>?> _searchAll({required String searchTerm}) async {
    return _request(uri: 'https://genius.com/api/search/multi?q=$searchTerm');
  }

  Future<Map<String, dynamic>?> song({required int songId}) async {
    return _request(uri: 'https://api.genius.com/songs/$songId?text_format=plain&access_token=$accessToken');
  }

  Future<Map<String, dynamic>?> artist({required int artistId}) async {
    return _request(uri: 'https://api.genius.com/artists/$artistId?text_format=plain&access_token=$accessToken');
  }

  Future<Map<String, dynamic>?> artistSongs(
      {required int artistId, required int perPage, required int page, SongsSorting sort = SongsSorting.title}) async {
    try {
      String getResponse = (await http.get(Uri.parse(
              Uri.encodeFull('https://api.genius.com/artists/$artistId/songs?sort=${sort.name}&$perPage=20&page=$page&access_token=$accessToken'))))
          .body;
      return jsonDecode(getResponse);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> album({required int albumId}) async {
    return _request(uri: 'https://api.genius.com/albums/$albumId?text_format=plain&access_token=$accessToken');
  }

  Future<Map<String, dynamic>?> albumTracks({required int albumId, required int perPage, required int page}) async {
    try {
      String getResponse = (await http.get(Uri.parse(Uri.encodeFull(
              'https://api.genius.com/albums/$albumId/tracks?per_page=$perPage&page=$page&text_format=plain&access_token=$accessToken'))))
          .body;
      return jsonDecode(getResponse);
    } catch (e) {
      return null;
    }
  }

  Future<String?> lyrics({required String url}) async {
    String getResponse = (await http.get(Uri.parse(Uri.encodeFull(url)))).body;

    BeautifulSoup bs = BeautifulSoup(getResponse.replaceAll('<br/>', '\n'));

    return bs.find("div", class_: "Lyrics__Root")?.getText() ?? bs.find("div", class_: "lyrics")?.getText().trim();
  }

  /// Searches for a specific song and gets its lyrics returning [Song] in case it's successful and `null` otherwise .
  ///
  /// You must pass either a `title` or a `songId`.
  ///
  ///title: Song title to search for.
  ///
  ///Args:
  ///
  /// `artist` (optional): Name of the artist.
  ///
  /// `getFullInfo` (optional): Get full info for each song (slower), if songId is provided full info of the song will be obtained by deafult.
  ///
  /// `songId` (optional): Song ID.
  ///
  ///Example:
  /// {@tool snippet}
  ///
  /// ```dart
  ///Genius genius = Genius(accessToken: TOKEN);
  ///Song? song = (await genius.searchSong(artist: 'Eminem', title: 'Beautiful'));
  ///if (song != null) {
  ///  print(song.lyrics);
  ///}
  /// ```
  /// {@end-tool}
  Future<Song?> searchSong({String? artist, String? title, int? songId, bool getFullInfo = true}) async {
    try {
      Map<String, dynamic>? songInfo;

      if (songId == null && title == null) {
        return _error('Specified song does not contain lyrics. Rejecting.');
      }

      if (songId != null) {
        getFullInfo = false;
        songInfo = (await song(songId: songId))?['response']['song'];
      } else {
        Map<String, dynamic>? serachResponse = (await _searchAll(searchTerm: '$title $artist'))?['response'];

        if (serachResponse != null) {
          songInfo = await _getItemFromSearchResponse(response: serachResponse, searchTerm: title!, type: 'song', resultType: 'title');
        }
      }

      if (songInfo == null) {
        return _error('No result found');
      }

      if (songInfo['lyrics_state'] != 'complete' && skipNonSongs) {
        return _error('Specified song does not contain lyrics. Rejecting.');
      }

      songId = songInfo['id'];

      if (songId != null && getFullInfo) {
        Map<String, dynamic>? fullSong = await song(songId: songId);
        if (fullSong != null) {
          var fullSongInfo = (fullSong['response']['song'] as Map<String, dynamic>?);
          if (fullSongInfo == null) {
            _error('error getting full song info');
          } else {
            songInfo = fullSongInfo;
          }
        }
      }

      String? url = (songInfo['url']);

      if (url == null) {
        return _error('Song url not found. Rejecting.');
      }

      return Song(songInfo: songInfo, lyrics: (await lyrics(url: url)) ?? "");
    } catch (e) {
      return _error('Error: ${e.toString()}');
    }
  }

  ///Searches for a specific album and gets its songs.
  ///
  ///You must pass either a `name` or an `albumId`.
  ///
  ///You use `name` to search for the album name and optionally along with `artist` wich is the artist name
  ///
  ///If you use the `albumId` then there's no need for either a `name` or a `artist`
  ///
  ///If `getFullInfo` is true it gets the full info for the album (slower), if albumId is provided full info of the song will be obtained by deafult.
  ///
  ///Example:
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  ///Genius genius = Genius(accessToken: TOKEN);
  ///Album? album = (await genius.searchAlbum(name: 'Relapse', artist: 'Eminem'));
  ///if (album != null) {
  ///  print(album.name);
  ///}
  /// ```
  /// {@end-tool}
  Future<Album?> searchAlbum({String? name, int? albumId, String artist = '', bool getFullInfo = true}) async {
    if (name == null && albumId == null) {
      return _error("You must pass either a `name` or an `albumId`.");
    }

    Map<String, dynamic>? albumInfo;
    if (albumId != null) {
      getFullInfo = false;
      albumInfo = await album(albumId: albumId);
    } else {
      Map<String, dynamic>? response = (await _searchAll(searchTerm: '$name $artist'))?['response'];

      if (response != null) {
        albumInfo = (await _getItemFromSearchResponse(response: response, searchTerm: name!, type: 'album', resultType: 'name'));
      }
    }

    if (albumInfo == null) {
      return _error('No results for $name $artist. Rejecting.');
    }

    albumId = albumInfo['id'];

    if (albumId == null) {
      return _error('Something wrong with the album id. Rejecting.');
    }

    List<Song> tracks = [];
    int? nextPage = 1;

    while (nextPage != null) {
      Map<String, dynamic>? albumTracksResponse = await albumTracks(albumId: albumId, perPage: 50, page: nextPage);

      if (albumTracksResponse == null) {
        return _error('Error getting album tracks. Rejecting.');
      }

      List<dynamic>? trakList = await albumTracksResponse['response']['tracks'];

      if (trakList != null) {
        for (var track in trakList) {
          Map<String, dynamic>? songInfo = (track['song'] as Map<String, dynamic>?);
          if (songInfo != null) {
            String? songLyrics;
            if (songInfo['lyrics_state'] == 'complete' && songInfo['url'] != null) {
              songLyrics = await lyrics(url: songInfo['url']);
            } else {
              songLyrics = "";
            }

            track = Song(songInfo: songInfo, lyrics: songLyrics ?? '');
            tracks.add(track);
          }
        }
      }

      nextPage = albumTracksResponse['next_page'];
    }

    if (getFullInfo) {
      Map<String, dynamic>? fullAlbum = await album(albumId: albumId);
      if (fullAlbum != null) {
        var fullAlbumInfo = (fullAlbum['response']['album'] as Map<String, dynamic>?);
        if (fullAlbumInfo == null) {
          _error('error getting full album info');
        } else {
          albumInfo = fullAlbumInfo;
        }
      }
    }

    return Album(albumInfo: albumInfo, tracks: tracks);
  }

  ///Searches for a specific artist and gets their songs.
  ///
  /// This method looks for the artist by the name or by the ID if it's provided in ``artistId``.
  ///
  /// It returrns an [Artist] object if the search is successful and `null` otherwise.
  ///
  /// `maxSongs` specifies the max number of songs it should get
  ///
  /// `sort` to sort the songs obtained by popularity, title or release date
  ///
  /// `artistId` allows user to pass an artist ID.
  ///
  /// `includeFeatures` f True, includes tracks featuring the artist
  ///
  /// ///Example:
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// Genius genius = Genius(accessToken: TOKEN);
  /// Artist? artist = await genius.searchArtist(artistName: 'Eminem', maxSongs: 10);

  /// if (artist != null) {
  ///   for (var song in artist.songs) {
  ///     print(song.lyrics);
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  Future<Artist?> searchArtist(
      {required String artistName,
      int? maxSongs,
      SongsSorting sort = SongsSorting.popularity,
      int perPage = 20,
      bool getFullInfo = true,
      int? artistId,
      bool includeFeatures = false}) async {
    if (artistId == null) {
      _error('Searching for songs by $artistName');

      Map<String, dynamic>? response = (await _searchAll(searchTerm: artistName))?['response'];

      if (response != null) {
        artistId = (await _getItemFromSearchResponse(response: response, searchTerm: artistName, type: 'artist', resultType: 'name'))?['id'];
      }
    }

    if (artistId == null) {
      return _error("No results found for $artistName");
    }

    Map<String, dynamic>? artistInfo = (await artist(artistId: artistId))?['response']['artist'];

    if (artistInfo == null) {
      return _error("No results found for the artist");
    }

    Artist artistFound = Artist(artistInfo: artistInfo);

    int? page = 1;

    if (maxSongs != null) {
      if (maxSongs > 50) {
        maxSongs = 50;
      }

      bool reachedMaxSongs = (maxSongs == 0) ? true : false;

      while (!reachedMaxSongs) {
        Map<String, dynamic>? artistSongsResponse = await artistSongs(artistId: artistId, perPage: perPage, page: page!, sort: sort);

        if (artistSongsResponse == null) {
          return _error('Error getting artist songs. Rejecting.');
        }

        List<dynamic>? songsOnPage = await artistSongsResponse['response']['songs'];

        if (songsOnPage != null) {
          for (var songInfo in songsOnPage) {
            if (songInfo != null) {
              String? songLyrics;
              if (songInfo['lyrics_state'] == 'complete' && songInfo['url'] != null) {
                songLyrics = await lyrics(url: songInfo['url']);
              } else {
                if (skipNonSongs) {
                  _error("${(songInfo['title'] ?? 'a song')} is not valid. Skipping.");

                  continue;
                }
                songLyrics = '';
              }

              if (getFullInfo) {
                if (songInfo['id'] != null) {
                  Map<String, dynamic>? fullSong = await song(songId: songInfo['id']);
                  if (fullSong != null) {
                    Map<String, dynamic>? fullSongInfo = (fullSong['response']['song'] as Map<String, dynamic>?);
                    if (fullSongInfo == null) {
                      _error('error getting full song info for ${songInfo['title'] ?? 'a song'}');
                    } else {
                      songInfo = fullSongInfo;
                    }
                  }
                } else {
                  _error('error getting full song info for ${songInfo['title'] ?? 'a song'}');
                }
              }

              Song newSong = Song(songInfo: songInfo, lyrics: songLyrics ?? '');
              artistFound.addSong(newSong: newSong, verbose: verbose, includeFeatures: includeFeatures);

              reachedMaxSongs = (artistFound.numSongs >= maxSongs);
              if (reachedMaxSongs) {
                _error('\nReached user-specified song limit ($maxSongs).');
                break;
              }
            }
          }
        }

        page = artistSongsResponse['next_page'];
        if (page == null) break;
      }
    }
    return artistFound;
  }
}
