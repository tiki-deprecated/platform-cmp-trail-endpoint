/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}

import 'package:html/dom.dart';

import '../../utils/xml.dart' as xml;
import 'wasabi_model_list_ver_owner.dart';

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
      key = xml.element(element, 'Key')?.text;
      versionId = xml.element(element, 'VersionId')?.text;
      isLatest =
          xml.element(element, 'IsLatest')?.text == "true" ? true : false;
      if (xml.element(element, 'LastModified') != null) {
        lastModified =
            DateTime.tryParse(xml.element(element, 'LastModified')?.text ?? '');
      }
      eTag = xml.element(element, 'ETag')?.text;
      size = int.tryParse(xml.element(element, 'Size')?.text ?? '');
      owner =
          WasabiModelListVerOwner.fromElement(xml.element(element, 'Owner'));
      storageClass = xml.element(element, 'StorageClass')?.text;
    }
  }

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return 'WasabiModelListVer{key: $key, versionId: $versionId, isLatest: $isLatest, lastModified: $lastModified, eTag: $eTag, size: $size, owner: $owner, storageClass: $storageClass}';
  }
}
