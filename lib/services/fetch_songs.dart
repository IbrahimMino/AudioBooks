import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

OnAudioQuery onAudioQuery = OnAudioQuery();

Future<bool> _requestPermission(Permission permission) async {
  AndroidDeviceInfo androidDeviceInfo = await DeviceInfoPlugin().androidInfo;

  if (androidDeviceInfo.version.sdkInt >= 30) {
    var request = await Permission.audio.request();
    if (request.isGranted) {
      return true;
    } else {
      return false;
    }
  } else {
    var result = await permission.request();
    if (result.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}

Future<void> accessStorage() async =>
    await Permission.storage.status.isGranted.then(
      (granted) async {
        if (granted == false) {
          // request  storage permission and open app settings if denied permanently

          PermissionStatus permissionStatus =
              await Permission.storage.request();
          if (permissionStatus == PermissionStatus.permanentlyDenied) {
            await openAppSettings();
          }
        }
      },
    );

Future<void> accessStorage13() async =>
    await Permission.audio.status.isGranted.then(
      (granted) async {
        if (granted == false) {
          // request  storage permission and open app settings if denied permanently

          PermissionStatus permissionStatus = await Permission.audio.request();
          if (permissionStatus == PermissionStatus.permanentlyDenied) {
            await openAppSettings();
          }
        }
      },
    );

Future<Uint8List?> art({required int id}) async {
  return await onAudioQuery.queryArtwork(id, ArtworkType.AUDIO, quality: 100);
}

Future<Uint8List?> toImage({required Uri uri}) async {
  return base64.decode(uri.data!.toString().split(',').last);
}

class FetchSongs {
  static Future<List<MediaItem>> execute() async {
    List<MediaItem> items = [];
    AndroidDeviceInfo androidDeviceInfo = await DeviceInfoPlugin().androidInfo;

    if (androidDeviceInfo.version.sdkInt > 30) {
      await accessStorage13().then(
        (_) async {
          List<SongModel> songs = await onAudioQuery.querySongs();

          if (songs.isNotEmpty) {
            for (SongModel song in songs) {
              if (song.isMusic == true) {
                Uint8List? uint8list = await art(id: song.id);
                List<int> bytes = [];
                if (uint8list != null) {
                  bytes = uint8list.toList();
                }

                // add the converted song to the list of MediaItems
                items.add(
                  MediaItem(
                    id: song.uri!,
                    title: song.title,
                    artist: song.artist,
                    duration: Duration(milliseconds: song.duration!),
                    artUri: uint8list == null ? null : Uri.dataFromBytes(bytes),
                  ),
                );
              }
            }
          }
        },
      );
    } else {
      await accessStorage().then(
        (_) async {
          List<SongModel> songs = await onAudioQuery.querySongs();

          if (songs.isNotEmpty) {
            for (SongModel song in songs) {
              if (song.isMusic == true) {
                Uint8List? uint8list = await art(id: song.id);
                List<int> bytes = [];
                if (uint8list != null) {
                  bytes = uint8list.toList();
                }

                // add the converted song to the list of MediaItems
                items.add(
                  MediaItem(
                    id: song.uri!,
                    title: song.title,
                    artist: song.artist,
                    duration: Duration(milliseconds: song.duration!),
                    artUri: uint8list == null ? null : Uri.dataFromBytes(bytes),
                  ),
                );
              }
            }
          }
        },
      );
    }
    return items;
  }
}
