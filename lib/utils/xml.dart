/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */
/// {@category Utils}
import 'package:html/dom.dart';

Element? first(List<Element> elements) {
  if (elements.isNotEmpty) {
    return elements.first;
  } else {
    return null;
  }
}

Element? element(Element element, String name) {
  return first(element.getElementsByTagName(name));
}
