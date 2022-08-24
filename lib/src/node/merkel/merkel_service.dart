import 'dart:typed_data';

import '../../utils/utils.dart';
import '../transaction/transaction_model.dart';
import 'merkel_node.dart';
import 'merkel_tree.dart';

class MerkelService {
  MerkelTree buildTree(List<TransactionModel> txns) {
    MerkelTree tree = MerkelTree();
    List<MerkelNode> nodes = level0(txns);
    tree.nodes.add(nodes);
    int l = 1;
    while (nodes.length > 1) {
      nodes = level(nodes, l);
      tree.nodes.add(nodes);
      l++;
    }
    tree.height = tree.nodes.length;
    tree.root = tree.nodes[tree.height - 1].first.hash;
    return tree;
  }

  List<MerkelNode> level0(List<TransactionModel> txns) {
    List<MerkelNode> nodeList = [];
    TransactionModel? previous;
    int order = 0;
    for (TransactionModel txn in txns) {
      if (previous == null) {
        previous = txn;
        continue;
      }
      nodeList.add(MerkelNode()
        ..includedTransactions.addAll([previous, txn])
        ..level = 0
        ..hash = sha256(Uint8List.fromList([...previous.id!, ...txn.id!]))
        ..order = order);
      previous = null;
      order++;
    }
    if (previous != null) {
      nodeList.add(MerkelNode()
        ..includedTransactions.addAll([previous])
        ..level = 0
        ..hash = previous.id!
        ..order = order);
    }
    return nodeList;
  }

  List<MerkelNode> level(List<MerkelNode> nodes, int level) {
    List<MerkelNode> nodeList = [];
    MerkelNode? previous;
    int order = 0;
    for (MerkelNode node in nodes) {
      if (previous == null) {
        previous = node;
        continue;
      }
      nodeList.add(MerkelNode()
        ..includedTransactions.addAll(
            [...previous.includedTransactions, ...node.includedTransactions])
        ..level = level
        ..hash = sha256(Uint8List.fromList([...previous.hash!, ...node.hash!]))
        ..order = order);
      previous = null;
      order++;
    }
    if (previous != null) {
      nodeList.add(MerkelNode()
        ..includedTransactions.addAll([...previous.includedTransactions])
        ..level = level
        ..hash = previous.hash!
        ..order = order);
    }
    return nodeList;
  }

}
