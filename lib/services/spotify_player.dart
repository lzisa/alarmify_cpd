/*import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyPlayer {
  static Future<void> playSong(String trackId) async {
    print("play song");
    await SpotifySdk.connectToSpotifyRemote(
        clientId: '1595f911487941ef98bba77a8e0e8a66',
        redirectUrl: 'alarmify://callback');

    final playerState = await SpotifySdk.getPlayerState();
    if (playerState == null || playerState.track?.uri != trackId) {
      await SpotifySdk.play(spotifyUri: 'spotify:track:$trackId');
    }
  }
  static Future<void> connectToSpotifyRemote(String clientId, String redirectUri) async {
    await SpotifySdk.connectToSpotifyRemote(clientId: clientId, redirectUrl: redirectUri);
  }

  static Future<void> pauseSong() async {
    await SpotifySdk.pause();
    }
}*/
