import '../../utils/merkel_tree.dart';
import 'block_model.dart';

//todo whats this for?
class BlockModelResponse {
  final BlockModel block;
  final MerkelTree merkelTree;

  BlockModelResponse(this.block, this.merkelTree);
}
