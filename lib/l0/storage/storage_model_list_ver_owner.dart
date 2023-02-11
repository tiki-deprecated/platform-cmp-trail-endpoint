/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:html/dom.dart';

import '../../utils/xml_parse.dart';

/// A owner of a stored object version
///
/// A POJO style model representing an XML response object returned
/// by the hosted storage.
class StorageModelListVerOwner {
  String? id;
  String? displayName;

  StorageModelListVerOwner({this.id, this.displayName});

  StorageModelListVerOwner.fromElement(Element? element) {
    if (element != null) {
      id = XmlParse.element(element, 'ID')?.text;
      displayName = XmlParse.element(element, 'DisplayName')?.text;
    }
  }

  @override
  String toString() {
    return 'StorageModelListVerOwner{id: $id, displayName: $displayName}';
  }
}
