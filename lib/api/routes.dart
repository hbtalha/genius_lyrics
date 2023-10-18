class GeniusRoutes {
  static const String _apiBaseUrl = 'https://api.genius.com';
  static const String _geniusBaseUrl = 'https://genius.com/api';

  GeniusRoutes._();

  static String searchAll = '$_geniusBaseUrl/search/multi';
  static String getSong = '$_apiBaseUrl/songs';
  static String artists = '$_apiBaseUrl/artists';
  static String albuns = '$_apiBaseUrl/albums';
}
