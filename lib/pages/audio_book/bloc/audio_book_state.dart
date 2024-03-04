import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';

@immutable
sealed class AudioBookState {}

final class AudioBookInitial extends AudioBookState {}

final class AudioBookLoading extends AudioBookState {}

final class AudioBookLoaded extends AudioBookState {
  final List<MediaItem> audioBooks;

  AudioBookLoaded({required this.audioBooks});
}

final class AudioBookError extends AudioBookState {
  final String error;

  AudioBookError({required this.error});
}


///* LOCAL
class AudioBookLoadedLocal extends AudioBookState {
  final List<Map<String, dynamic>> books;

  AudioBookLoadedLocal(this.books);
}
