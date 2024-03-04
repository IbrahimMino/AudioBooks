import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';

@immutable
sealed class AudioBookEvent {}

final class LoaderAudioBook extends AudioBookEvent {}



class AddAudioBook extends AudioBookEvent {
  final MediaItem item;
  final String localPath;

   AddAudioBook(this.item, this.localPath);

  @override
  List<Object> get props => [item, localPath];

  @override
  String toString() => 'AddAudioBook { item: $item, localPath: $localPath }';
}


