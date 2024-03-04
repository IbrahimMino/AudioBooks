import 'package:audio_player/data/model/audio_book.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  AudioPlayer audioPlayer = AudioPlayer();

  UriAudioSource _createAudioSource(MediaItem item) {
    return ProgressiveAudioSource(Uri.parse(item.id));
  }

  void _listenForCurrentIndexChanges() {
    audioPlayer.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      mediaItem.add(playlist[index]);
    });
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (audioPlayer.playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward
          },
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[audioPlayer.processingState]!,
          playing: audioPlayer.playing,
          updatePosition: audioPlayer.position,
          bufferedPosition: audioPlayer.bufferedPosition,
          speed: audioPlayer.speed,
          queueIndex: event.currentIndex),
    );
  }

  Future<void> initSongs({required List<MediaItem> songs}) async {
    audioPlayer.playbackEventStream.listen(_broadcastState);

    final audioSource = songs.map((e) => _createAudioSource(e));
    print(audioSource);

    await audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: audioSource.toList()));

    final newQueue = queue.value..addAll(songs);
    queue.add(newQueue);

    _listenForCurrentIndexChanges();

    audioPlayer.processingStateStream.listen((event) {
      if (event == ProcessingState.completed) skipToNext();
    });
  }


  Future<List<AudioSource>> bookParseAudiSource(List<AudioBook> books) async {
    List<AudioSource> children = [];

    for (AudioBook book in books) {
      children.add(
        AudioSource.uri(
          Uri.parse(book.source!),
          tag: MediaItem(
            id: book.id!,
            album: book.album,
            title: book.title!,
            artist: book.artist,
            duration: Duration(milliseconds: book.duration!),
            artUri: Uri.parse(book.image!),
            extras: {
              'trackNumber': book.trackNumber,
              'totalTrackCount': book.totalTrackCount,
              'site': book.site,
              'source': book.source,
              'localPath': book.localPath,
            },
          ),
        ),
      );
    }

    return children;
  }

  Future<void> initSongsOnline({required List<AudioSource> books}) async {
    audioPlayer.playbackEventStream.listen(_broadcastState);

    await audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: books));

    _listenForCurrentIndexChanges();

    audioPlayer.processingStateStream.listen((event) {
      if (event == ProcessingState.completed) skipToNext();
    });
  }


  @override
  Future<void> play() => audioPlayer.play();

  @override
  Future<void> pause() => audioPlayer.pause();

  @override
  Future<void> seek(Duration position) => audioPlayer.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    await audioPlayer.seek(Duration.zero, index: index);
    play();
  }

  @override
  Future<void> skipToNext() async => audioPlayer.seekToNext();

  @override
  Future<void> skipToPrevious() async => audioPlayer.seekToPrevious();
}
