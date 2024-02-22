/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:html/dom.dart';

import '../../utils/xml_parse.dart';
import 'storage_model_list_obj.dart';

class StorageModelList {
  String? name;
  String? prefix;
  String? marker;
  int? maxKeys;
  bool? isTruncated;
  List<StorageModelListObj>? contents;

  StorageModelList(
      {this.name,
      this.prefix,
      this.marker,
      this.maxKeys,
      this.isTruncated,
      this.contents});

  StorageModelList.fromElement(Element? element) {
    if (element != null) {
      name = XmlParse.element(element, 'Name')?.text;
      prefix = XmlParse.element(element, 'Prefix')?.text;
      marker = XmlParse.element(element, 'Marker')?.text;
      maxKeys = int.tryParse(XmlParse.element(element, 'MaxKeys')?.text ?? '');
      isTruncated = XmlParse.element(element, 'IsTruncated')?.text == "true"
          ? true
          : false;
      List<Element> versionElements = element.getElementsByTagName('Contents');
      contents = List.of(
          versionElements.map((e) => StorageModelListObj.fromElement(e)));
    }
  }

  @override
  String toString() {
    return 'StorageModelList{name: $name, prefix: $prefix, marker: $marker, maxKeys: $maxKeys, isTruncated: $isTruncated, contents: $contents}';
  }
}
