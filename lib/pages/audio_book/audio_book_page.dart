import 'package:audio_player/data/data_source/remote_datasource.dart';
import 'package:audio_player/domain/database_helper.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main.dart';
import '../../services/my_audio_handler.dart';
import '../../widgets/song_widget.dart';
import 'bloc/audio_book_bloc.dart';
import 'bloc/audio_book_event.dart';
import 'bloc/audio_book_state.dart';

class AudioBookPage extends StatefulWidget {
  final MyAudioHandler audioHandler;
  final DatabaseHelper dbHelper;

  const AudioBookPage(
      {super.key, required this.audioHandler, required this.dbHelper});

  @override
  State<AudioBookPage> createState() => _AudioBookPageState();
}

class _AudioBookPageState extends State<AudioBookPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioBookBloc(
          remoteDataSource: RemoteDataSource(), dbHelper: dbHelper)
        ..add(LoaderAudioBook()),
      child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 20,
          title: const Text("Audio Books"),
          backgroundColor: Colors.white,
        ),
        body: BlocBuilder<AudioBookBloc, AudioBookState>(
          builder: (context, state) {
            if (state is AudioBookLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AudioBookLoaded) {
              widget.audioHandler.initSongs(songs: state.audioBooks);
              final data = state.audioBooks;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AudioBookBloc>().add(LoaderAudioBook());
                  await context.read<AudioBookBloc>().stream.firstWhere(
                        (state) => state is! AudioBookLoading,
                  );
                  return Future<void>.delayed(const Duration(seconds: 3));
                },
                color: Colors.black,
                backgroundColor: Colors.white,
                strokeWidth: 3.0,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    MediaItem item = data[index];
                    return SongWidget(
                      audioHandler: widget.audioHandler,
                      item: item,
                      index: index,
                      dbHelper: dbHelper,
                    );
                  },
                ),
              );
            } else if (state is AudioBookError) {
              return Center(child: Text(state.error));
            }
            return const SizedBox();
          },
        ),
      )),
    );
  }
}
