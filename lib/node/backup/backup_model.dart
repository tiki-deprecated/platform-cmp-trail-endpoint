/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'dart:typed_data';

import 'backup_repository.dart';

/// The backup control entity model.
///
/// This model keeps the state of a backup request for an asset identified by
/// its fully qualified [path].
/// The [signature] is the RSA signature of the bytes sent to L0 storage using
/// the author's private key.
/// The [timestamp] is the [DateTime] that the asset was backed up in L0. If it
/// is not set that means the backup was not done yet.
class BackupModel {
  late String
      path; 
  Uint8List? signature;
  DateTime? timestamp;

  /// Builds a [BackupModel].
  BackupModel({required this.path, this.signature, this.timestamp});

  /// Builds a [BackupModel] from a [map].
  ///
  /// It is used mainly for retrieving data from [BackupRepository].
  /// The map strucure is
  /// ```
  ///   Map<String, dynamic> map = {
  ///     BackupRepository.columnPath : String,
  ///     BackupRepository.columnSignature : String
  ///     BackupRepository.columnTimestamp : int? // seconds since epoch
  ///    }
  /// ```
  BackupModel.fromMap(Map<String, dynamic> map)
      : path = map[BackupRepository.columnPath],
        signature = map[BackupRepository.columnSignature],
        timestamp = map[BackupRepository.columnTimestamp] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                map[BackupRepository.columnTimestamp] * 1000);

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return '''BackupModel
      path : $path,
      timestamp : $timestamp
      signature : $signature,
    ''';
  }
}
