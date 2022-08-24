import 'dart:typed_data';

import 'merkel_node.dart';

class MerkelTree {
  List<List<MerkelNode>> nodes = [];
  Uint8List? root;
  int height = 0;
}
