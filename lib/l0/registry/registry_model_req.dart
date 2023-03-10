/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class RegistryModelReq {
  String? id;
  String? address;

  RegistryModelReq({this.id, this.address});

  Map<String, dynamic> toMap() => {'id': id, 'address': address};

  @override
  String toString() {
    return 'RegistryModelReq{id: $id, address: $address}';
  }
}
