import 'dart:typed_data';

class MerkelProof {
  List<Uint8List> hashes = [];
  List<int> path = [];
  int depth = 0;
}
