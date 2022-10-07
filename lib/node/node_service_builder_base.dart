/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'node_service.dart';

abstract class NodeServiceBuilderBase {
  late NodeService nodeService;

  Future<NodeService> build();

  Future<void> loadPrimaryKey([String? address]);
}
