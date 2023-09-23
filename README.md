# genius_lyrics: a Dart client for the Genius.com API based on [LyricsGenius](https://github.com/johnwmillr/LyricsGenius)

`genius_lyrics` provides a simple interface to the song, artist, and lyrics data stored on [Genius.com](https://www.genius.com).

Read the API reference [here](https://pub.dev/documentation/genius_lyrics/latest/).

## Setup
Before using this package you'll need to sign up for a (free) account that authorizes access to [the Genius API](https://genius.com/api-clients). The Genius account provides a `accessToken` that is required by the package. See the [Usage section](https://github.com/hbtalha/genius_lyrics#usage) below for examples.

## Usage
After create your geinius account copy the access token and paste at ```.env.example``` file and raname to ```.env```

Import the package and initiate Genius:

```dart
import 'package:genius_lyrics/genius_lyrics.dart';
Genius genius = Genius();
```

Search for songs by a given artist:

```dart
Artist? artist = await genius.searchArtist(artistName: 'Eminem', maxSongs: 5, sort: SongsSorting.release_date);
if (artist != null) {
  for (var song in artist.songs) {
    print(song.title);
  }
}
```
By default, the `searchArtist()` only returns songs where the given artist is the primary artist.
However, there may be instances where it is desirable to get all of the songs that the artist appears on.
You can do this by setting the `includeFeatures` argument to `true`.

```dart
Artist? artist = await genius.searchArtist(artistName: 'Eminem', maxSongs: 5, includeFeatures: true);
if (artist != null) {
  for (var song in artist.songs) {
    print(song.title);
  }
}
```

Search for a single song by the same artist:

```dart
artist?.song(client: genius, songName: "No Love");
# or:
# Song? song = genius.searchSong(artist: 'Eminem', title: 'No Love'));
if (song != null) {
  print(song.lyrics);
}
```

Add the song to the artist object:

```dart
artist?.addSong(newSong: song!);
```

Save the artist's songs to a file:

```dart
artist?.saveLyrics(destPath: 'D:/Music/Eminme/Lyrics');
```

Searching for an album and saving it:

```dart
Album? album = (await genius.searchAlbum(name: 'The Off-Season', artist: 'J.Cole'));
album?.saveLyrics(destPath: 'D:/Desktop/test');
```

## A complete example

```dart
import 'package:genius_lyrics/genius_lyrics.dart';

void main(List<String> args) async {
  Genius genius = Genius(accessToken: YOUR_TOKEN);

  Artist? artist = await genius.searchArtist(artistName: 'Eminem', maxSongs: 5, sort: SongsSorting.release_date, includeFeatures: true);

  if (artist != null) {
    for (var song in artist.songs) {
      print(song.title);
    }
  }

  Album? album = (await genius.searchAlbum(name: 'The Off-Season', artist: 'J.Cole'));
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
```


## Contributing
Please contribute! If you want to fix a bug, suggest improvements, or add new features to the project, just [open an issue](https://github.com/hbtalha/genius_lyrics/issues/new) or send me a pull request.
