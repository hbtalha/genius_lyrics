import 'package:genius_lyrics/genius_lyrics.dart';

void main(List<String> args) async {
  Genius genius = Genius(
    accessToken: const String.fromEnvironment('GENIUS_TOKEN'),
  );

  Artist? artist = await genius.searchArtist(
    artistName: 'Eminem',
    maxSongs: 5,
    sort: SongsSorting.release_date,
    includeFeatures: true,
  );

  if (artist != null) {
    for (var song in artist.songs) {
      print(song.title);
    }
  }

  Album? album =
      (await genius.searchAlbum(name: 'The Off-Season', artist: 'J.Cole'));
  album?.saveLyrics(destPath: 'D:/Desktop/test');

  if (album != null) {
    print(album.tracks.length);
    for (var track in album.tracks) {
      print(track.title);
    }
  }

  Song? song = (await genius.searchSong(artist: 'J. Cole', title: 'KOD'));

  if (song != null) {
    print(song.lyrics);
  }
}
