/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:html/dom.dart';

import '../../utils/xml.dart' as xml;

class WasabiModelListVerOwner {
  String? id;
  String? displayName;

  WasabiModelListVerOwner({this.id, this.displayName});

  WasabiModelListVerOwner.fromElement(Element? element) {
    if (element != null) {
      id = xml.element(element, 'ID')?.text;
      displayName = xml.element(element, 'DisplayName')?.text;
    }
  }

  /// Overrides toString() method for useful error messages
  @override
  String toString() {
    return 'WasabiModelListVerOwner{id: $id, displayName: $displayName}';
  }
}
