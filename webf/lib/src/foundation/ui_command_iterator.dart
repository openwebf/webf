/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/bridge.dart';

class UICommandIterator extends Iterator<UICommand> {
  final List<List<UICommand>> _commandChunks = [];
  int _chunkIndex = 0;
  int _commandIndex = -1;
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
    _commandIndex = -1;
    commandFlag = 0;
    _commandSize = 0;
  }

  int size() {
    return _commandSize;
  }

  @override
  UICommand get current  {
    return _commandChunks[_chunkIndex][_commandIndex];
  }

  @override
  bool moveNext() {
    if (_commandChunks.isEmpty) return false;

    if (_commandIndex < _commandChunks[_chunkIndex].length - 1) {
      _commandIndex++;
    } else {
      _commandIndex = 0;
      _chunkIndex++;
    }

    return _chunkIndex < _commandChunks.length && _commandIndex < _commandChunks[_chunkIndex].length;
  }
}

class UICommandIterable extends Iterable<UICommand> {
  final UICommandIterator _iterator;
  UICommandIterable(this._iterator);

  @override
  Iterator<UICommand> get iterator => _iterator;
}
