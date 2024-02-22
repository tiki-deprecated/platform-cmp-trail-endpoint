/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:html/dom.dart';

import '../../utils/xml_parse.dart';
import 'storage_model_list_obj_owner.dart';

/// A version of a stored object
///
/// A POJO style model representing an XML response object returned
/// by the hosted storage.
class StorageModelListObj {
  String? key;
  String? versionId;
  bool? isLatest;
  DateTime? lastModified;
  String? eTag;
  int? size;
  StorageModelListObjOwner? owner;
  String? storageClass;

  StorageModelListObj(
      {this.key,
      this.versionId,
      this.isLatest,
      this.lastModified,
      this.eTag,
      this.size,
      this.owner,
      this.storageClass});

  StorageModelListObj.fromElement(Element? element) {
    if (element != null) {
      key = XmlParse.element(element, 'Key')?.text;
      versionId = XmlParse.element(element, 'VersionId')?.text;
      isLatest =
          XmlParse.element(element, 'IsLatest')?.text == "true" ? true : false;
      if (XmlParse.element(element, 'LastModified') != null) {
        lastModified = DateTime.tryParse(
            XmlParse.element(element, 'LastModified')?.text ?? '');
      }
      eTag = XmlParse.element(element, 'ETag')?.text;
      size = int.tryParse(XmlParse.element(element, 'Size')?.text ?? '');
      owner = StorageModelListObjOwner.fromElement(
          XmlParse.element(element, 'Owner'));
      storageClass = XmlParse.element(element, 'StorageClass')?.text;
    }
  }

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return 'StorageModelListObj{key: $key, versionId: $versionId, isLatest: $isLatest, lastModified: $lastModified, eTag: $eTag, size: $size, owner: $owner, storageClass: $storageClass}';
  }
}
