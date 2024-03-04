import 'package:audio_player/data/model/audio_book.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/data_source/remote_datasource.dart';
import '../../../domain/database_helper.dart';
import 'audio_book_event.dart';
import 'audio_book_state.dart';

class AudioBookBloc extends Bloc<AudioBookEvent, AudioBookState> {
  final DatabaseHelper dbHelper;

  final RemoteDataSource remoteDataSource;

  AudioBookBloc({required this.remoteDataSource, required this.dbHelper})
      : super(AudioBookInitial()) {
    on<LoaderAudioBook>((event, emit) async {
      emit(AudioBookLoading());
      try {
        final result = await remoteDataSource.getAudioBooks();

        emit(AudioBookLoaded(
            audioBooks: await audioBookParseMediaItem(result.music)));
      } catch (error) {
        emit(AudioBookLoaded(audioBooks: await _fetchLocal()));
        // emit(AudioBookError(error: error.toString()));
      }
    });
  }

  Future<List<MediaItem>> audioBookParseMediaItem(List<AudioBook> songs) async {
    List<MediaItem> items = [];

    for (AudioBook song in songs) {
      if (song.source!.endsWith('.mp3')) {
        Map<String, dynamic> book =
            await dbHelper.getSingleAudioBook(song.id.toString());

        if (book.isNotEmpty) {
          items.add(
            MediaItem(
              id: book['local_path'].toString(),
              title: book['title'].toString(),
              artist: book['artist'].toString(),
              genre: book['remote_id'],
              duration: Duration(seconds: int.parse(book['duration'].toString())),
              artUri: null,
              extras: {'local': true, 'duration': book['duration']},
            ),
          );
        } else {

          items.add(
            MediaItem(
                id: song.source.toString(),
                title: song.title!,
                artist: song.artist,
                genre: song.id.toString(),
                duration: Duration(seconds: song.duration!),
                artUri: song.image != null ? Uri.parse(song.image!) : null,
                extras: {
                  'local': false,
                  'duration': song.duration,
                }),
          );
        }
      }
    }
    return items;
  }

  Future<List<MediaItem>> _fetchLocal() async {
    List<MediaItem> items = [];

    List<Map<String, dynamic>> bookList = await dbHelper.getAudioBooks();

    if (bookList != null && bookList.isNotEmpty) {
      for (Map<String, dynamic> book in bookList) {
        items.add(
          MediaItem(
              id: book['local_path'].toString(),
              title: book['title'].toString(),
              artist: book['artist'].toString(),
              genre: book['id'].toString(),
              duration: Duration(seconds: int.parse(book['duration'].toString())),
              artUri: null,
              extras: {'local': true}),
        );
      }
    }
    return items;
  }

}
