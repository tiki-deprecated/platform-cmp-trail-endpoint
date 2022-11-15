/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Node}
import 'package:html/dom.dart';

import '../../utils/xml_parse.dart';

/// The Wasabi object data model version owner.
class SStorageModelListVerOwner {
  String? id;
  String? displayName;

  SStorageModelListVerOwner({this.id, this.displayName});

  SStorageModelListVerOwner.fromElement(Element? element) {
    if (element != null) {
      id = XmlParse.element(element, 'ID')?.text;
      displayName = XmlParse.element(element, 'DisplayName')?.text;
    }
  }

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return 'SStorageModelListVerOwner{id: $id, displayName: $displayName}';
  }
}
