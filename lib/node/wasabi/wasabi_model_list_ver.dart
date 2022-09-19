/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}

import 'package:html/dom.dart';

import '../../utils/utils.dart';
import 'wasabi_model_list_ver_owner.dart';

/// The Wasabi object data model versions.
class WasabiModelListVer {
  String? key;
  String? versionId;
  bool? isLatest;
  DateTime? lastModified;
  String? eTag;
  int? size;
  WasabiModelListVerOwner? owner;
  String? storageClass;

  WasabiModelListVer(
      {this.key,
      this.versionId,
      this.isLatest,
      this.lastModified,
      this.eTag,
      this.size,
      this.owner,
      this.storageClass});

  WasabiModelListVer.fromElement(Element? element) {
    if (element != null) {
      key = UtilsXml.element(element, 'Key')?.text;
      versionId = UtilsXml.element(element, 'VersionId')?.text;
      isLatest =
          UtilsXml.element(element, 'IsLatest')?.text == "true" ? true : false;
      if (UtilsXml.element(element, 'LastModified') != null) {
        lastModified = DateTime.tryParse(
            UtilsXml.element(element, 'LastModified')?.text ?? '');
      }
      eTag = UtilsXml.element(element, 'ETag')?.text;
      size = int.tryParse(UtilsXml.element(element, 'Size')?.text ?? '');
      owner = WasabiModelListVerOwner.fromElement(
          UtilsXml.element(element, 'Owner'));
      storageClass = UtilsXml.element(element, 'StorageClass')?.text;
    }
  }

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return 'WasabiModelListVer{key: $key, versionId: $versionId, isLatest: $isLatest, lastModified: $lastModified, eTag: $eTag, size: $size, owner: $owner, storageClass: $storageClass}';
  }
}
