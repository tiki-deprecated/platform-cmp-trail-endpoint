import 'package:sqlite3/sqlite3.dart';
import 'block_model.dart';

class BlockRepository {
  final Database _db;

  BlockRepository(this._db);

  Future<void> save(BlockModel block) {
    throw UnimplementedError();
  }

  BlockModel get(String hash, String chain) {
    throw UnimplementedError();
  }

  Future<void> delete(BlockModel block) {
    throw UnimplementedError();
  }
}
