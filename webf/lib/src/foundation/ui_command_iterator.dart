/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/bridge.dart';

class UICommandIterator extends Iterator<UICommand?> {
  final List<List<UICommand>> _commandChunks = [];
  int _chunkIndex = 0;
  int _commandIndex = 0;
  int _commandSize = 0;
  int commandFlag = 0;

  void addCommandChunks(List<UICommand> chunk, int flag) {
    _commandChunks.add(chunk);
    _commandSize += chunk.length;
    commandFlag = commandFlag | flag;
  }

  bool isEmpty() {
    return _commandSize == 0;
  }

  void clear() {
    _commandChunks.clear();
    _chunkIndex = 0;
    _commandIndex = 0;
    commandFlag = 0;
    _commandSize = 0;
  }

  int size() {
    return _commandSize;
  }

  @override
  UICommand? get current {
    if (_commandChunks.isEmpty) return null;

    List<UICommand> currentCommandChunk = _commandChunks[_chunkIndex];
    if (currentCommandChunk.isEmpty) return null;

    UICommand result = currentCommandChunk[_commandIndex];

    int nextCommandIndex = _commandIndex + 1;
    if (nextCommandIndex == currentCommandChunk.length) {
      _commandIndex = 0;
      _chunkIndex++;
    } else {
      _commandIndex++;
    }

    return result;
  }

  @override
  bool moveNext() {
    if (_commandChunks.isEmpty) return false;
    if (_chunkIndex >= _commandChunks.length) {
      return false;
    }

    List<UICommand> currentCommandChunk = _commandChunks[_chunkIndex];
    if (currentCommandChunk.isEmpty) return false;
    if (_commandIndex < currentCommandChunk.length) {
      return true;
    }
    return false;
  }
}

class UICommandIterable extends Iterable<UICommand?> {
  final UICommandIterator _iterator;
  UICommandIterable(this._iterator);

  @override
  Iterator<UICommand?> get iterator => _iterator;
}
