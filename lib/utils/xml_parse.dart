/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
import 'package:html/dom.dart';

/// Utility methods for XML parsing.
class XmlParse {
  static Element? first(List<Element> elements) {
    if (elements.isNotEmpty) {
      return elements.first;
    } else {
      return null;
    }
  }

  static Element? element(Element element, String name) {
    return first(element.getElementsByTagName(name));
  }
}
