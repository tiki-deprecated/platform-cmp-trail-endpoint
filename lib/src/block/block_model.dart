import 'block_model_body.dart';
import 'block_model_header.dart';

class BlockModel {
  final BlockModelHeader header;
  BlockModelBody? body;

  BlockModel(this.header);
}
