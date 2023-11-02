@Timeout(Duration(seconds: 60))

import 'package:test/test.dart';
import 'package:genius_lyrics/genius_lyrics.dart';

void main() {
  final genius = Genius(
    accessToken: const String.fromEnvironment('GENIUS_TOKEN'),
    verbose: false,
  );
  test('Testing songs search', timeout: const Timeout(Duration(minutes: 1)),
      () async {
    Song? song =
        await genius.searchSong(artist: 'Kendrick Lamar', title: 'Real');
    expect(song?.artist, equals('Kendrick Lamar'));
    expect(song?.title, equals('Real'));
    expect(song?.id, equals(90480));
    expect(song?.featuredArtists, equals(['Anna Wise']));
    expect(song?.lyrics?.isEmpty, equals(false));

    song = await genius.searchSong(artist: 'Eminem', title: 'No Love');
    expect(song?.artist, equals('Eminem'));
    expect(song?.title, equals('No Love'));
    expect(song?.id, equals(530));
    expect(song?.featuredArtists, equals(['Lil Wayne']));
    expect(song?.lyrics?.isEmpty, equals(false));
  });
  test('Testing album search', timeout: const Timeout(Duration(minutes: 1)),
      () async {
    Album? album = await genius.searchAlbum(artist: 'Eminem', name: 'Recovery');
    expect(album?.artist?.name, equals('Eminem'));
    expect(album?.fullTitle, equals("Recovery by Eminem"));
    expect(album?.name, equals('Recovery'));
    expect(album?.tracks.length, equals(19));
    expect(album?.tracks.any((element) => element.title == 'No Love'),
        equals(true));

    album = await genius.searchAlbum(artist: 'J. Cole', name: 'KOD');
    expect(album?.artist?.name, equals('J. Cole'));
    expect(album?.name, equals('KOD'));
    expect(album?.fullTitle, equals('KOD by J. Cole'));
    expect(album?.tracks.length, equals(12));
    expect(album?.tracks.any((element) => element.title == "Kevin’s Heart"),
        equals(true));
  });

  test('Testing artist search', timeout: const Timeout(Duration(seconds: 90)),
      () async {
    genius.verbose = true;
    Artist? artist =
        await genius.searchArtist(artistName: 'Eminem', maxSongs: 5);
    expect(artist?.name, equals('Eminem'));
    expect(artist?.id, equals(45));
    expect(artist?.songs.length, equals(5));
    expect(artist?.alternateNames.isNotEmpty, equals(true));
    expect(artist?.socialNetwork?.facebook, 'Eminem');
    expect(artist?.socialNetwork?.instagram, 'eminem');
    expect(artist?.socialNetwork?.twitter, 'Eminem');
    expect(artist?.about?.contains('\n'), true);

    artist =
        await genius.searchArtist(artistName: 'Kendrick Lamar', maxSongs: 5);
    expect(artist?.name, equals('Kendrick Lamar'));
    expect(artist?.id, equals(1421));
    expect(artist?.songs.length, equals(5));
  });

  test('Testing getting album tracks',
      timeout: const Timeout(Duration(minutes: 1)), () async {
    List<dynamic>? trakList =
        await genius.albumTracks(albumId: 2876, perPage: 50, page: 1);
    List<Song> tracks = [];

    if (trakList != null) {
      for (var track in trakList) {
        Map<String, dynamic>? songInfo =
            (track['song'] as Map<String, dynamic>?);
        if (songInfo != null) {
          String? songLyrics;
          if (songInfo['lyrics_state'] == 'complete' &&
              songInfo['url'] != null) {
            songLyrics = await Genius.lyrics(url: songInfo['url']);
          } else {
            songLyrics = "";
          }
          tracks.add(Song(songInfo: songInfo, lyrics: songLyrics ?? ''));
        }
      }
    }

    expect(tracks.length, equals(19));
    expect(tracks.any((element) => element.title == 'No Love'), equals(true));
    expect(tracks.any((element) => element.artist == 'Eminem'), equals(true));
    expect(tracks.any((element) => element.lyrics!.isNotEmpty), equals(true));

    trakList = await genius.albumTracks(albumId: 420709, perPage: 50, page: 1);
    tracks.clear();

    if (trakList != null) {
      for (var track in trakList) {
        Map<String, dynamic>? songInfo =
            (track['song'] as Map<String, dynamic>?);
        if (songInfo != null) {
          String? songLyrics;
          if (songInfo['lyrics_state'] == 'complete' &&
              songInfo['url'] != null) {
            songLyrics = await Genius.lyrics(url: songInfo['url']);
          } else {
            songLyrics = "";
          }
          tracks.add(Song(songInfo: songInfo, lyrics: songLyrics ?? ''));
        }
      }
    }

    expect(tracks.length, equals(12));
    expect(tracks.any((element) => element.title == 'KOD'), equals(true));
    expect(tracks.any((element) => element.artist == 'J. Cole'), equals(true));
    expect(tracks.any((element) => element.lyrics!.isNotEmpty), equals(true));
  });

  test('Testing searching songs by lyrics snippet',
      timeout: const Timeout(Duration(minutes: 1)), () async {
    List<Song>? song = (await genius.searchSongsByLyricsSnippet(
        lyricsSnippet: 'all the memories collected', getFullInfo: true));

    expect(song?.any((element) => element.title?.contains('XXX.') ?? false),
        equals(true));
  });
}
