import 'dart:convert';

import 'package:spotify/spotify.dart';
import 'package:http/http.dart' as http;

const clientId = 'secret';
const clientSecret = 'secret';

class SpotifyService {
  final SpotifyApi _spotify;

  SpotifyService()
      : _spotify = SpotifyApi(SpotifyApiCredentials(clientId, clientSecret));

  Future getArtist(String id) async {
    try {
      final artist = await _spotify.artists.get(id);
      return artist;
    } catch (e) {
      // Handle any errors that occur during the API call
      print('Error getting artist: $e');
      return null;
    }
  }

  Future getPlaylist() async {
    const playlistID = '37i9dQZF1DX1WhyP6stXXl?si=86731543ade7418e&nd=1';
    try {
      final playlist = await _spotify.playlists.get(playlistID);

      return playlist;
    } catch (e) {
// Handle any errors that occur during the API call
      print('Error getting artist: $e');
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    final url = Uri.parse('https://accounts.spotify.com/api/token');
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    const body = 'grant_type=client_credentials';

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final accessToken = responseData['access_token'];
      return accessToken;
    } else {
      print('Failed to retrieve access token. Status code: ${response.statusCode}');
      return null;
    }
  }


  Future<void> playSong(String songUri) async {
    final url = Uri.parse('https://api.spotify.com/v1/me/player/play');
    final accessToken = await getAccessToken();

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = '{"uris": ["$songUri"]}';
    print(headers);

    final response = await http.put(url, headers: headers, body: body);
    print(response.body);
    print(accessToken);
    print(body);
    if (response.statusCode == 204) {
      print('Song played successfully');
    } else {
      print('Failed to play song. Status code: ${response.statusCode}');
    }
  }

  Future getTracksByAlbum() async {
    const albumID = '5duyQokC4FMcWPYTV9Gpf9';
    try {
      final album = await _spotify.albums.getTracks(albumID).all();
      final trackID=album.first.uri;
      print(trackID);
      print('Test');
      playSong(trackID!);
      /*album.forEach((element) {
        if (element.uri != null) {
          playSong(element.uri!);
          print(element.uri);
        }
      });*/
      return album;
    } catch (e) {
// Handle any errors that occur during the API call
      print('Error getting artist: $e');
      return null;
    }
  }

  Future<Iterable<Track>> getPlaylistTrackURIs() async {
    const playlistID = '37i9dQZF1DX1WhyP6stXXl?si=86731543ade7418e&nd=1';
    try {
      var playlist =
          await _spotify.playlists.getTracksByPlaylistId(playlistID).all();
      print(playlist);
      if (playlist != null) return playlist;
      return [];
    } catch (e) {
      print('Error getting playlist track URIs: $e');
      return [];
    }
  }
}
