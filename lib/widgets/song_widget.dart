import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import '../domain/database_helper.dart';
import '../pages/audio_book/bloc/audio_book_bloc.dart';
import '../pages/audio_book/bloc/audio_book_event.dart';
import '../pages/audio_book/bloc/audio_book_state.dart';
import '../pages/player/player_page.dart';
import '../services/my_audio_handler.dart';

class SongWidget extends StatefulWidget {
  final MyAudioHandler audioHandler;
  final DatabaseHelper dbHelper;

  final MediaItem item;

  final int index;

  const SongWidget(
      {super.key,
      required this.audioHandler,
      required this.dbHelper,
      required this.item,
      required this.index});

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  late double? _progress = null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: widget.audioHandler.mediaItem,
      builder: (context, itemSnapshot) {
        if (itemSnapshot.data != null) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: itemSnapshot.data! == widget.item
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
            ),
            child: ListTile(
              onTap: () {
                if (itemSnapshot.data! != widget.item) {
                  widget.audioHandler.skipToQueueItem(widget.index);
                }
                Get.to(
                  () => PlayerPage(audioHandler: widget.audioHandler),
                  duration: const Duration(milliseconds: 300),
                );
              },
              leading: Stack(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: itemSnapshot.data!.artUri == null ||
                            widget.item.artUri == null
                        ? const Icon(Icons.music_note)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.item.artUri.toString(),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _progress != null
                        ? const CircularProgressIndicator()
                        : (!widget.item.extras?['local']
                            ? InkWell(
                                onTap: () {
                                  setState(() {

                                    FileDownloader.downloadFile(
                                        url: widget.item.id,
                                        onProgress: (name, progress) {
                                          setState(() {
                                            _progress = progress;
                                          });
                                        },
                                        onDownloadCompleted: (value) {
                                          if (kDebugMode) {
                                            print('path $value');
                                          }
                                          setState(() {
                                            widget.dbHelper.insertAudioBook(
                                                widget.item, value);
                                            _progress = null;

                                            context
                                                .read<AudioBookBloc>()
                                                .add(LoaderAudioBook());
                                            context
                                                .read<AudioBookBloc>()
                                                .stream
                                                .firstWhere(
                                                  (state) => state
                                                      is! AudioBookLoading,
                                                );
                                          });
                                        },
                                        notificationType: NotificationType.all);
                                  });
                                },
                                child: const Icon(
                                  Icons.download,
                                  color: Colors.black,
                                ),
                              )
                            : const SizedBox.shrink()),
                  ),
                ],
              ),
              title: Text(
                widget.item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(widget.item.artist.toString()),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
