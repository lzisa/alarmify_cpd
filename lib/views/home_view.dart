import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarmify_cpd/services/spotify_getItems_service.dart';
import 'package:alarmify_cpd/views/edit_alarm.dart';
import 'package:alarmify_cpd/views/ring.dart';
import 'package:alarmify_cpd/widgets/tile.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:flutter/material.dart';

import '../constants/routes.dart';
import '../services/spotify_player.dart';

class ClockHome extends StatefulWidget {
  const ClockHome({Key? key}) : super(key: key);

  @override
  State<ClockHome> createState() => _ClockHomeState();
}

class _ClockHomeState extends State<ClockHome> {
  late List<AlarmSettings> alarms;

  static StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    loadAlarms();
    loadService();
    subscription ??= Alarm.ringStream.stream.listen(
      (alarmSettings) => navigateToRingScreen(alarmSettings),
    );
  }

  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  void loadService() async {
    final spotifyService = SpotifyService();
    final artistId = '3TVXtAsR1Inumwj472S9r4?si=8kBd4ChATe-4QfUjaw4fdQ';

    final artist = await spotifyService.getArtist(artistId);
    final playlist = await spotifyService.getPlaylist();
    //final tracks = await spotifyService.getPlaylistTrackURIs();
    await spotifyService.getTracksByAlbum();

    if (playlist != null) {
      print('Artist Name: ${playlist.name}');
      // Add any additional properties you want to access from the artist object
    } else {
      print('Failed to fetch artist details.');
    }
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AlarmRingView(alarmSettings: alarmSettings),
        ));
    loadAlarms();
  }

  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.6,
            child: EditAlarmView(alarmSettings: settings),
          );
        });

    loadAlarms();
  }

  Future<void> navigateToDetail(AlarmSettings? settings) async {
    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Edit Alarm',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2.0,
                ),
              ),
              elevation: 4,
              centerTitle: true,
            ),
            body: EditAlarmView(
                alarmSettings: settings,),

          );
        },
      ),
    );

    if (result != null && result == true) {
      loadAlarms();
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    loadAlarms();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alarmify',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w300,
            letterSpacing: 4.0,
          ),
        ),
        elevation: 4,
        centerTitle: true,
    ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 40.0, bottom: 40),
              width: double.infinity,
              height: 200,
              // Customize the color as per your requirement
              child: Center(
                child: AnalogClock(),
              ),
            ),


            // Existing code for alarms list
            alarms.isNotEmpty
                ? Expanded(
                    child: ListView.separated(
                      itemCount: alarms.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return AlarmListItem(
                          key: Key(alarms[index].id.toString()),
                          title: TimeOfDay(
                            hour: alarms[index].dateTime.hour,
                            minute: alarms[index].dateTime.minute,
                          ).format(context),
                          onPressed: () => navigateToDetail(alarms[index]),
                          onDismissed: () {
                            Alarm.stop(alarms[index].id)
                                .then((_) => loadAlarms());
                          },
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      "No alarms set",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
             foregroundColor: Colors.white,
              onPressed: () => navigateToDetail(null),
              //onPressed: () => navigateToAlarmScreen(null),
              child: const Icon(Icons.alarm_add_rounded, size: 33),
            ),




          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
