import 'package:audio_player/widgets/slider_dialog.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/preferences_helper.dart';
import '../data/model/repeat_mode.dart';
import '../services/my_audio_handler.dart';

class ControlButtonsWidget extends StatefulWidget {
  final MyAudioHandler audioHandler;
  final MediaItem item;

  const ControlButtonsWidget(
      {super.key, required this.audioHandler, required this.item});

  @override
  State<ControlButtonsWidget> createState() => _ControlButtonsWidgetState();
}

class _ControlButtonsWidgetState extends State<ControlButtonsWidget> {
  bool _shuffle = false;
  RepeatMode _repeatMode = RepeatMode.none;

  @override
  void initState() {
    super.initState();
    _initPreference();
  }

  Future<void> _initPreference() async {
    _shuffle = await PreferencesHelper.getShuffle();
    await widget.audioHandler.audioPlayer.setShuffleModeEnabled(_shuffle);

    _repeatMode = await PreferencesHelper.getRepeatMode();
    await widget.audioHandler.audioPlayer
        .setLoopMode(_repeatMode == RepeatMode.repeatAll
            ? LoopMode.all
            : _repeatMode == RepeatMode.repeatSingle
                ? LoopMode.one
                : LoopMode.off);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: widget.audioHandler.playbackState.stream,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          bool playing = snapshot.data!.playing;

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () {
                      showSliderDialog(
                        context: context,
                        title: "Adjust volume",
                        divisions: 10,
                        min: 0.0,
                        max: 1.0,
                        value: widget.audioHandler.audioPlayer.volume,
                        stream: widget.audioHandler.audioPlayer.volumeStream,
                        onChanged: widget.audioHandler.audioPlayer.setVolume,
                      );
                    },
                  ),
                  StreamBuilder<double>(
                    stream: widget.audioHandler.audioPlayer.speedStream,
                    builder: (context, snapshot) => IconButton(
                      icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        showSliderDialog(
                          context: context,
                          title: "Adjust speed",
                          divisions: 10,
                          min: 0.5,
                          max: 1.5,
                          value: widget.audioHandler.audioPlayer.speed,
                          stream: widget.audioHandler.audioPlayer.speedStream,
                          onChanged: widget.audioHandler.audioPlayer.setSpeed,
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _shuffle = !_shuffle;
                        PreferencesHelper.setShuffle(_shuffle);
                        widget.audioHandler.audioPlayer
                            .setShuffleModeEnabled(_shuffle);
                      });
                    },
                    icon: _shuffle
                        ? const Icon(Icons.shuffle, color: Colors.black)
                        : const Icon(
                      Icons.shuffle,
                      color: Colors.grey,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      widget.audioHandler.skipToPrevious();
                    },
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (playing) {
                        widget.audioHandler.pause();
                      } else {
                        widget.audioHandler.play();
                      }
                    },
                    icon: playing
                        ? const Icon(
                            Icons.pause_rounded,
                            size: 75,
                          )
                        : const Icon(
                            Icons.play_arrow_rounded,
                            size: 75,
                          ),
                  ), // Skip to next track
                  IconButton.filledTonal(
                    onPressed: () {
                      widget.audioHandler.skipToNext();
                    },
                    icon: const Icon(
                      Icons.skip_next_rounded,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _handleRepeatButtonPressed();
                      });
                    },
                    icon: _repeatMode == RepeatMode.repeatAll
                        ? const Icon(Icons.repeat, color: Colors.black)
                        : (_repeatMode == RepeatMode.repeatSingle
                        ? const Icon(
                      Icons.repeat_one_sharp,
                      color: Colors.black,
                    )
                        : const Icon(
                      Icons.repeat,
                      color: Colors.grey,
                    )),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _handleRepeatButtonPressed() async {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.repeatSingle;
        break;
      case RepeatMode.repeatSingle:
        _repeatMode = RepeatMode.repeatAll;
        break;
      case RepeatMode.repeatAll:
        _repeatMode = RepeatMode.none;
        break;
    }
    await PreferencesHelper.setRepeatMode(_repeatMode);
    LoopMode loopMode;
    switch (_repeatMode) {
      case RepeatMode.repeatAll:
        loopMode = LoopMode.all;
        break;
      case RepeatMode.repeatSingle:
        loopMode = LoopMode.one;
        break;
      default:
        loopMode = LoopMode.off;
        break;
    }
    await widget.audioHandler.audioPlayer.setLoopMode(loopMode);
  }
}
