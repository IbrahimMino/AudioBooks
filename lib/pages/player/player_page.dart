import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../../services/my_audio_handler.dart';
import '../../widgets/control_button_widget.dart';
import '../../widgets/cover_widget.dart';
import '../../widgets/progress_bar_widget.dart';

class PlayerPage extends StatefulWidget {
  final MyAudioHandler audioHandler;

  const PlayerPage({super.key, required this.audioHandler});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Player"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: StreamBuilder<MediaItem?>(
          stream: widget.audioHandler.mediaItem,
          builder: (context, mediaSnapshot) {
            if (mediaSnapshot.data != null) {
              MediaItem item = mediaSnapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CoverWidget(audioHandler: widget.audioHandler, item: item),
                  Column(
                    children: [
                      Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        item.artist!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  ProgressBarWidget(
                    audioHandler: widget.audioHandler,
                    item: item,
                  ),

                  // ControlButtonsWidget for playback control buttons
                  ControlButtonsWidget(
                      audioHandler: widget.audioHandler, item: item)
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
