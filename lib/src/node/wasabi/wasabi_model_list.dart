/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:html/dom.dart';

import '../../utils/xml.dart' as xml;
import 'wasabi_model_list_ver.dart';

class WasabiModelList {
  String? name;
  String? prefix;
  String? keyMarker;
  String? versionIdMarker;
  int? maxKeys;
  bool? isTruncated;
  String? nextKeyMarker;
  String? nextVersionIdMarker;
  List<WasabiModelListVer>? versions;

  WasabiModelList(
      {this.name,
      this.prefix,
      this.keyMarker,
      this.versionIdMarker,
      this.maxKeys,
      this.isTruncated,
      this.nextKeyMarker,
      this.nextVersionIdMarker,
      this.versions});

  WasabiModelList.fromElement(Element? element) {
    if (element != null) {
      name = xml.element(element, 'Name')?.text;
      prefix = xml.element(element, 'Prefix')?.text;
      keyMarker = xml.element(element, 'KeyMarker')?.text;
      versionIdMarker = xml.element(element, 'VersionIdMarker')?.text;
      maxKeys = int.tryParse(xml.element(element, 'MaxKeys')?.text ?? '');
      isTruncated =
          xml.element(element, 'IsTruncated')?.text == "true" ? true : false;
      nextKeyMarker = xml.element(element, 'NextKeyMarker')?.text;
      nextVersionIdMarker = xml.element(element, 'NextVersionIdMarker')?.text;
      List<Element> versionElements = element.getElementsByTagName('Version');
      versions = List.of(
          versionElements.map((e) => WasabiModelListVer.fromElement(e)));
    }
  }

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return 'WasabiModelList{name: $name, prefix: $prefix, keyMarker: $keyMarker, versionIdMarker: $versionIdMarker, maxKeys: $maxKeys, isTruncated: $isTruncated, nextKeyMarker: $nextKeyMarker, nextVersionIdMarker: $nextVersionIdMarker, versions: $versions}';
  }
}
