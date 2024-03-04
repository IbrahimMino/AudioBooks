import 'package:audio_service/audio_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'audio_books.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE books "
          "(id INTEGER PRIMARY KEY AUTOINCREMENT, "
          "title TEXT, "
          "artist TEXT, "
          "remote_id TEXT, "
          "source TEXT, "
          "duration INTEGER, "
          "local_path TEXT, "
          "img_path TEXT)",
        );
      },
    );
  }

  Future<int> insertAudioBook(MediaItem item, String localPath) async {
    Map<String, dynamic> book = {};
    book['title'] = item.title.toString();
    book['artist'] = item.artist.toString();
    book['remote_id'] = item.genre.toString();
    book['source'] = item.id.toString();
    book['duration'] = item.extras?['duration'];
    book['local_path'] = localPath.toString();
    book['img_path'] = item.artUri.toString();

    Database db = await database;
    return await db.insert('books', book);
  }

  Future<List<Map<String, dynamic>>> getAudioBooks() async {
    Database db = await database;
    return await db.query('books');
  }

  Future<Map<String, dynamic>> getSingleAudioBook(String remoteId) async {
    Database db = await database;

    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT * FROM books WHERE remote_id = ?', [remoteId]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return <String, dynamic>{};
    }
  }

  Future<int> updateAudioBook(Map<String, dynamic> task) async {
    Database db = await database;
    return await db.update(
      'books',
      task,
      where: 'id = ?',
      whereArgs: [task['id']],
    );
  }

  Future<int> deleteAudioBook(int id) async {
    Database db = await database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAudioBookRemoteId(String remoteId) async {
    Database db = await database;
    return await db.delete(
      'books',
      where: 'remote_id = ?',
      whereArgs: [remoteId],
    );
  }
}
