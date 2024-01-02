/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:ffi';

import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';
import 'package:test/test.dart';

void main() {
  group('CommandIterator', () {
    test('iterator with for loop', () async {
      UICommandIterator iterator = UICommandIterator();
      List<UICommand> source = [
        UICommand.from(UICommandType.createElement, 'div', nullptr, nullptr),
        UICommand.from(UICommandType.createElement, 'span', nullptr, nullptr),
        UICommand.from(UICommandType.createElement, 'p', nullptr, nullptr),
      ];

      List<UICommand> source2 = [
        UICommand.from(UICommandType.insertAdjacentNode, 'q', nullptr, nullptr),
      ];

      iterator.addCommandChunks(source, 0);
      iterator.addCommandChunks(source2, 0);

      UICommandIterable iterable = UICommandIterable(iterator);

      List<UICommand> results = [];
      for(UICommand command in iterable) {
        results.add(command);
      }

      expect(results, [
        source[0],
        source[1],
        source[2],
        source2[0],
      ]);
    });

    test('iterator with flags', () async {
      UICommandIterator iterator = UICommandIterator();

      iterator.addCommandChunks([], nodeCreationFlag);

      expect(isCommandsContainsNodeCreation(iterator.commandFlag), true);
      expect(isCommandsContainsNodeMutation(iterator.commandFlag), false);
      expect(isCommandsContainsStyleUpdate(iterator.commandFlag), false);

      iterator.addCommandChunks([], nodeMutationFlag);

      expect(isCommandsContainsNodeCreation(iterator.commandFlag), true);
      expect(isCommandsContainsNodeMutation(iterator.commandFlag), true);
      expect(isCommandsContainsStyleUpdate(iterator.commandFlag), false);

      iterator.addCommandChunks([], styleUpdateFlag);

      expect(isCommandsContainsNodeCreation(iterator.commandFlag), true);
      expect(isCommandsContainsNodeMutation(iterator.commandFlag), true);
      expect(isCommandsContainsStyleUpdate(iterator.commandFlag), true);
    });
  });
}
