/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:html/dom.dart';

import '../../utils/xml_parse.dart';
import 'storage_model_list_obj.dart';

/// The list of versions for a stored object
///
/// A POJO style model representing an XML response object returned
/// by the hosted storage.
class StorageModelVList {
  String? name;
  String? prefix;
  String? keyMarker;
  String? versionIdMarker;
  int? maxKeys;
  bool? isTruncated;
  String? nextKeyMarker;
  String? nextVersionIdMarker;
  List<StorageModelListObj>? versions;

  StorageModelVList(
      {this.name,
      this.prefix,
      this.keyMarker,
      this.versionIdMarker,
      this.maxKeys,
      this.isTruncated,
      this.nextKeyMarker,
      this.nextVersionIdMarker,
      this.versions});

  StorageModelVList.fromElement(Element? element) {
    if (element != null) {
      name = XmlParse.element(element, 'Name')?.text;
      prefix = XmlParse.element(element, 'Prefix')?.text;
      keyMarker = XmlParse.element(element, 'KeyMarker')?.text;
      versionIdMarker = XmlParse.element(element, 'VersionIdMarker')?.text;
      maxKeys = int.tryParse(XmlParse.element(element, 'MaxKeys')?.text ?? '');
      isTruncated = XmlParse.element(element, 'IsTruncated')?.text == "true"
          ? true
          : false;
      nextKeyMarker = XmlParse.element(element, 'NextKeyMarker')?.text;
      nextVersionIdMarker =
          XmlParse.element(element, 'NextVersionIdMarker')?.text;
      List<Element> versionElements = element.getElementsByTagName('Version');
      versions = List.of(
          versionElements.map((e) => StorageModelListObj.fromElement(e)));
    }
  }

  @override
  String toString() {
    return 'StorageModelVList{name: $name, prefix: $prefix, keyMarker: $keyMarker, versionIdMarker: $versionIdMarker, maxKeys: $maxKeys, isTruncated: $isTruncated, nextKeyMarker: $nextKeyMarker, nextVersionIdMarker: $nextVersionIdMarker, versions: $versions}';
  }
}
