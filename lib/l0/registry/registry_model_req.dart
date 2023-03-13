/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

/// A Registry Registration Request
///
/// A POJO style model representing a JSON object for
/// the registry service.
class RegistryModelReq {
  /// The [id] to register the [address] to
  String? id;

  /// The wallet [address] to register
  String? address;

  RegistryModelReq({this.id, this.address});

  Map<String, dynamic> toMap() => {'id': id, 'address': address};

  @override
  String toString() {
    return 'RegistryModelReq{id: $id, address: $address}';
  }
}
