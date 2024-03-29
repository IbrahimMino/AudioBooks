import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../services/fetch_songs.dart';
import '../services/my_audio_handler.dart';

class CoverWidget extends StatelessWidget {
  final MyAudioHandler audioHandler;
  final MediaItem item;
  const CoverWidget(
      {super.key, required this.audioHandler, required this.item});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.width * 0.7,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: item.artUri == null
            ? const Icon(Icons.music_note)
            : ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.artUri.toString(),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}