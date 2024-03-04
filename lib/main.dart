
import 'package:audio_player/pages/audio_book/audio_book_page.dart';
import 'package:audio_player/services/my_audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';

import 'domain/database_helper.dart';

MyAudioHandler _audioHandler = MyAudioHandler();
DatabaseHelper dbHelper = DatabaseHelper();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.audio_player',
      androidNotificationChannelName: 'Audio Books',
      androidNotificationOngoing: true,
    ),
  );

  dbHelper.initDatabase();

  runApp(const MyApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),

      home: AudioBookPage(audioHandler: _audioHandler, dbHelper: dbHelper,),
    );
  }
}
// home: HomePage(audioHandler: _audioHandler),