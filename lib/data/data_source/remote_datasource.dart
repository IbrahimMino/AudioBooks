import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../model/audio_book.dart';

class RemoteDataSource {
  Dio dio = Dio();


  Future<DataAudio> getAudioBooks() async {
    try {
      final response = await dio.get('https://storage.googleapis.com/uamp/catalog.json');
      if (kDebugMode) {
        print(response.data);
      }
      return DataAudio.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      rethrow;
    }
  }
}
