import 'package:sqlite3/sqlite3.dart';
import 'transaction_model.dart';

class TransactionRepository {
  final Database _db;

  TransactionRepository(this._db);

  Future<void> save(TransactionModel transaction){
    throw UnimplementedError();
  }

  TransactionModel get(String address, String signature) {
    throw UnimplementedError();
  }

  Future<void> delete(TransactionModel transaction){
    throw UnimplementedError();
  }
}
