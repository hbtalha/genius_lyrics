@Timeout(Duration(seconds: 60))
import 'package:test/test.dart';
import 'package:genius_lyrics/models/artist.dart';
import 'package:genius_lyrics/genius_lyrics.dart';
import 'package:genius_lyrics/models/album.dart';
import 'package:genius_lyrics/models/song.dart';

void main() {
  final genius = Genius(accessToken: '', verbose: false);
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
    expect(album?.tracks.length, equals(20));
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

    artist =
        await genius.searchArtist(artistName: 'Kendrick Lamar', maxSongs: 5);
    expect(artist?.name, equals('Kendrick Lamar'));
    expect(artist?.id, equals(1421));
    expect(artist?.songs.length, equals(5));
  });
}
