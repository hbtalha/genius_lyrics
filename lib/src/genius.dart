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
  Genius(
      {required this.accessToken,
      this.verbose = true,
      this.skipNonSongs = true});

  /// Shows `errorMsg`(error message) if `verbose` is true and returns null
  dynamic _verbosePrint(String errorMsg) {
    if (verbose) {
      // ignore: avoid_print
      print(errorMsg);
    }
    return null;
  }

  /// Returns the resulf of the GET request
  Future<Map<String, dynamic>?> _request({required String uri}) async {
    try {
      String getResponse =
          (await http.get(Uri.parse(Uri.encodeFull(uri)))).body;
      return (jsonDecode(getResponse) as Map<String, dynamic>?)?['response'];
    } catch (e) {
      return null;
    }
  }

  ///Gets the desired item from the search results.
  ///
  /// This method tries to match the `hits` of the `response` to
  /// the `response_term`, and if it finds no match, returns the first
  /// appropriate hit if there are any.
  ///
  /// Args:
  ///
  /// `response`: A response from `Genius._searchAll` to go through.
  ///
  /// `searchTerm`: The search term to match with the hit.
  ///
  /// `type`: Type of the hit we're looking for (e.g. song, artist).
  ///
  /// `resultType`: The part of the hit we want to match  (e.g. song title, artist's name).
  Map<String, dynamic>? _getItemFromSearchResponse({
    required Map<String, dynamic> response,
    required String searchTerm,
    required String type,
    required String resultType,
    String? artist,
  }) {
    if (type == 'song' && artist == null) {
      return _verbosePrint("For the [type] 'song', artist must be specified ");
    }

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
        Map<String, dynamic>? item = hit['result'];
        if (item != null) {
          if (item['artist_names'].toString().contains(artist!)) {
            return item;
          }
        }
      }

      for (var hit in hits) {
        Map<String, dynamic>? song = hit['result'];
        if (song != null) {
          if (song['lyrics_state'] == 'complete') {
            return song;
          }
        }
      }
    }

    return hits.isEmpty ? null : hits[0]['result'];
  }

  /// Searches all types.
  ///
  /// Including: albums, articles, lyrics, songs, users and videos.
  ///
  /// Note: This method will also return a ``top hits`` section alongside other types.
  Future<Map<String, dynamic>?> _searchAll({required String searchTerm}) async {
    return _request(uri: 'https://genius.com/api/search/multi?q=$searchTerm');
  }

  ///Gets data for a specific song given is id (`songId`).
  ///
  ///Example:
  /// {@tool snippet}
  ///
  /// ```dart
  ///Genius genius = Genius(accessToken: TOKEN);
  ///Map<String, dynamic>? song = await genius.song(songId: 90480);
  ///if (song != null) {
  ///  print(song['full_title']);
  ///}
  /// ```
  /// {@end-tool}
  Future<Map<String, dynamic>?> song({required int songId}) async {
    return (await _request(
            uri:
                'https://api.genius.com/songs/$songId?text_format=plain&access_token=$accessToken'))?[
        'song'];
  }

  ///Gets data for a specific artist given is id (`artistId`).
  ///
  ///Example:
  /// {@tool snippet}
  ///
  /// ```dart
  ///Genius genius = Genius(accessToken: TOKEN);
  ///Map<String, dynamic>? artist = await genius.artist(artistId: 45);
  ///if (artist != null) {
  ///  print(artist['name']);
  ///}
  /// ```
  /// {@end-tool}
  Future<Map<String, dynamic>?> artist({required int artistId}) async {
    return (await _request(
            uri:
                'https://api.genius.com/artists/$artistId?text_format=plain&access_token=$accessToken'))?[
        'artist'];
  }

  /// Returns the page with artist songs given a `artistId`
  ///
  /// `per_page` specifies of results to return per request. It can't be more than 50.
  Future<Map<String, dynamic>?> _artistSongsPage(
      {required int artistId,
      required int perPage,
      required int page,
      SongsSorting sort = SongsSorting.title}) async {
    return _request(
        uri:
            'https://api.genius.com/artists/$artistId/songs?sort=${sort.name}&perPage=$perPage&page=$page&access_token=$accessToken');
  }

  /// Gets artist's songs.
  ///
  /// `per_page` specifies of results to return per request. It can't be more than 50.
  Future<List<dynamic>?> artistSongs(
      {required int artistId,
      required int perPage,
      required int page,
      SongsSorting sort = SongsSorting.title}) async {
    return (await _artistSongsPage(
        artistId: artistId, perPage: perPage, page: page))?['songs'];
  }

  ///Gets data for a specific album given is id (`albumId`).
  ///
  ///Example:
  /// {@tool snippet}
  ///
  /// ```dart
  ///Genius genius = Genius(accessToken: TOKEN);
  ///Map<String, dynamic>? album = await genius.album(albumId: 45);
  ///if (album != null) {
  ///  print(album['name']);
  ///}
  /// ```
  /// {@end-tool}
  Future<Map<String, dynamic>?> album({required int albumId}) async {
    return (await _request(
            uri:
                'https://api.genius.com/albums/$albumId?text_format=plain&access_token=$accessToken'))?[
        'album'];
  }

  /// Returns the page with album tracks given a `albumId`
  ///
  /// `per_page` specifies of results to return per request. It can't be more than 50.
  Future<Map<String, dynamic>?> _albumTracksPage(
      {required int albumId, required int perPage, required int page}) async {
    return await _request(
        uri:
            'https://api.genius.com/albums/$albumId/tracks?per_page=$perPage&page=$page&text_format=plain&access_token=$accessToken');
  }

  /// Gets album's tracks.
  ///
  /// `per_page` specifies of results to return per request. It can't be more than 50.
  Future<List<dynamic>?> albumTracks(
      {required int albumId, required int perPage, required int page}) async {
    return (await _albumTracksPage(
        albumId: albumId, perPage: perPage, page: page))?['tracks'];
  }

  /// Uses beautiful_soup to scrape song lyrics off of a Genius song URL
  static Future<String?> lyrics({required String url}) async {
    String responseBody = (await http.get(Uri.parse(Uri.encodeFull(url)))).body;

    BeautifulSoup bs = BeautifulSoup(responseBody.replaceAll('<br/>', '\n'));

    return bs
        .findAll('div', class_: 'Lyrics__Container')
        .map((e) => e.getText().trim())
        .join('\n');
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
  Future<Song?> searchSong(
      {String? artist,
      String? title,
      int? songId,
      bool getFullInfo = true}) async {
    try {
      Map<String, dynamic>? songInfo;

      if (songId == null && title == null) {
        return _verbosePrint(
            'Specified song does not contain lyrics. Rejecting.');
      }

      if (songId != null) {
        getFullInfo = false;
        songInfo = (await song(songId: songId));
      } else {
        Map<String, dynamic>? serachResponse =
            (await _searchAll(searchTerm: '$title $artist'));

        if (serachResponse != null) {
          songInfo = _getItemFromSearchResponse(
            response: serachResponse,
            searchTerm: title!,
            type: 'song',
            resultType: 'title',
            artist: artist,
          );
        }
      }

      if (songInfo == null) {
        return _verbosePrint('No result found');
      }

      if (songInfo['lyrics_state'] != 'complete' && skipNonSongs) {
        return _verbosePrint(
            'Specified song does not contain lyrics. Rejecting.');
      }

      songId = songInfo['id'];

      if (songId != null && getFullInfo) {
        Map<String, dynamic>? fullSongInfo = await song(songId: songId);

        if (fullSongInfo != null) {
          songInfo = fullSongInfo;
        } else {
          _verbosePrint('error getting full song info');
        }
      }

      String? url = (songInfo['url']);

      if (url == null) {
        return _verbosePrint('Song url not found. Rejecting.');
      }

      return Song(songInfo: songInfo, lyrics: (await lyrics(url: url)) ?? "");
    } catch (e) {
      return _verbosePrint('Error: ${e.toString()}');
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
  Future<Album?> searchAlbum(
      {String? name,
      int? albumId,
      String artist = '',
      bool getFullInfo = true}) async {
    if (name == null && albumId == null) {
      return _verbosePrint("You must pass either a `name` or an `albumId`.");
    }

    Map<String, dynamic>? albumInfo;
    if (albumId != null) {
      getFullInfo = false;
      albumInfo = await album(albumId: albumId);
    } else {
      Map<String, dynamic>? response =
          (await _searchAll(searchTerm: '$name $artist'));

      if (response != null) {
        albumInfo = _getItemFromSearchResponse(
            response: response,
            searchTerm: name!,
            type: 'album',
            resultType: 'name');
      }
    }

    if (albumInfo == null) {
      return _verbosePrint('No results for $name $artist. Rejecting.');
    }

    albumId = albumInfo['id'];

    if (albumId == null) {
      return _verbosePrint('Something wrong with the album id. Rejecting.');
    }

    List<Song> tracks = [];
    int? nextPage = 1;

    while (nextPage != null) {
      Map<String, dynamic>? albumTracksResponse =
          await _albumTracksPage(albumId: albumId, perPage: 50, page: nextPage);

      if (albumTracksResponse == null) {
        return _verbosePrint('Error getting album tracks. Rejecting.');
      }

      List<dynamic>? trakList = await albumTracksResponse['tracks'];

      if (trakList != null) {
        for (var track in trakList) {
          Map<String, dynamic>? songInfo =
              (track['song'] as Map<String, dynamic>?);
          if (songInfo != null) {
            String? songLyrics;
            if (songInfo['lyrics_state'] == 'complete' &&
                songInfo['url'] != null) {
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
      Map<String, dynamic>? fullAlbumInfo = await album(albumId: albumId);
      if (fullAlbumInfo != null) {
        albumInfo = fullAlbumInfo;
      } else {
        _verbosePrint('error getting full album info');
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
  Future<Artist?> searchArtist({
    required String artistName,
    int? maxSongs,
    SongsSorting sort = SongsSorting.popularity,
    int perPage = 20,
    bool getFullInfo = true,
    int? artistId,
    bool includeFeatures = false,
  }) async {
    if (artistId == null) {
      _verbosePrint('Searching for songs by $artistName');

      Map<String, dynamic>? response =
          (await _searchAll(searchTerm: artistName));

      if (response != null) {
        artistId = _getItemFromSearchResponse(
            response: response,
            searchTerm: artistName,
            type: 'artist',
            resultType: 'name')?['id'];
      }
    }

    if (artistId == null) {
      return _verbosePrint("No results found for $artistName");
    }

    Map<String, dynamic>? artistInfo = (await artist(artistId: artistId));

    if (artistInfo == null) {
      return _verbosePrint("No results found for the artist");
    }

    Artist artistFound = Artist(artistInfo: artistInfo);

    int? page = 1;

    if (maxSongs != null) {
      if (maxSongs > 50) {
        maxSongs = 50;
      }

      bool reachedMaxSongs = (maxSongs == 0);

      while (!reachedMaxSongs) {
        Map<String, dynamic>? artistSongsResponse = await _artistSongsPage(
            artistId: artistId, perPage: perPage, page: page!, sort: sort);

        if (artistSongsResponse == null) {
          return _verbosePrint('Error getting artist songs. Rejecting.');
        }

        List<dynamic>? songsOnPage = await artistSongsResponse['songs'];

        if (songsOnPage != null) {
          for (var songInfo in songsOnPage) {
            if (songInfo != null) {
              String? songLyrics;
              if (songInfo['lyrics_state'] == 'complete' &&
                  songInfo['url'] != null) {
                songLyrics = await lyrics(url: songInfo['url']);
              } else {
                if (skipNonSongs) {
                  _verbosePrint(
                      "${(songInfo['title'] ?? 'a song')} is not valid. Skipping.");

                  continue;
                }
                songLyrics = '';
              }

              if (getFullInfo) {
                if (songInfo['id'] != null) {
                  Map<String, dynamic>? fullSongInfo =
                      await song(songId: songInfo['id']);
                  songInfo = fullSongInfo;
                } else {
                  _verbosePrint(
                      'error getting full song info for ${songInfo['title'] ?? 'a song'}');
                }
              }

              Song newSong = Song(songInfo: songInfo, lyrics: songLyrics ?? '');
              artistFound.addSong(
                  newSong: newSong,
                  verbose: verbose,
                  includeFeatures: includeFeatures);

              reachedMaxSongs = (artistFound.numSongs >= maxSongs);
              if (reachedMaxSongs) {
                _verbosePrint(
                    '\nReached user-specified song limit ($maxSongs).');
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
