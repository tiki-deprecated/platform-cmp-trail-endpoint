/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'package:html/dom.dart';

import '../../utils/utils.dart';
import 'wasabi_model_list_ver.dart';

/// The Wasabi object data model.
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
          versionElements.map((e) => WasabiModelListVer.fromElement(e)));
    }
  }

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return 'WasabiModelList{name: $name, prefix: $prefix, keyMarker: $keyMarker, versionIdMarker: $versionIdMarker, maxKeys: $maxKeys, isTruncated: $isTruncated, nextKeyMarker: $nextKeyMarker, nextVersionIdMarker: $nextVersionIdMarker, versions: $versions}';
  }
}