/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:source_span/source_span.dart';
import 'package:webf/css.dart';

class CSSCalcValue {
  final CalcExpressionNode? _expression;
  CSSCalcValue(this._expression);

  // Get the lazy calculated CSS resolved value.
  dynamic computedValue(String propertyName) {
    double? value = _expression?.computedValue;
    return value;
  }

  // Try to parse CSSCalcValue.
  static CSSCalcValue? tryParse(RenderStyle renderStyle, String propertyName, String propertyValue) {
    if (CSSFunction.isFunction(propertyValue, functionName: CALC)) {
      List<CSSFunctionalNotation> fns = CSSFunction.parseFunction(propertyValue);
      if (fns.first.args.isNotEmpty) {
        assert(fns.first.args.length == 1, 'Calc parameters count must be = 1');
        final expression = fns.first.args.first;
        final _CSSCalcParser parser = _CSSCalcParser(propertyName, renderStyle, expression);
        CalcExpressionNode? node = parser.processCalcExpression();
        return CSSCalcValue(node);
      }
    }
    return null;
  }
}

abstract class CalcExpressionNode {
  double get computedValue;
}

class CalcInvertNode extends CalcExpressionNode {
  final CalcExpressionNode node;
  CalcInvertNode(this.node);

  @override
  double get computedValue {
    return 1 / node.computedValue;
  }
}

class CalcNegateNode extends CalcExpressionNode {
  final CalcExpressionNode node;
  CalcNegateNode(this.node);

  @override
  double get computedValue {
    return -1 * node.computedValue;
  }
}

class CalcVariableNode extends CalcExpressionNode {
  final CSSVariable value;
  final RenderStyle _renderStyle;
  CalcVariableNode(this.value, this._renderStyle);

  @override
  double get computedValue {
    String text = value.computedValue('');
    if (CSSLength.isLength(text)) {
      return CSSLength.parseLength(text, _renderStyle).computedValue;
    }
    return 0;
  }
}

class CalcLengthNode extends CalcExpressionNode {
  final CSSLengthValue value;
  CalcLengthNode(this.value);

  @override
  double get computedValue => value.computedValue;
}

class CalcNumberNode extends CalcExpressionNode {
  final double value;
  CalcNumberNode(this.value);

  @override
  double get computedValue => value;
}

class CalcOperationExpressionNode extends CalcExpressionNode {
  int operator;
  final CalcExpressionNode leftNode;
  final CalcExpressionNode rightNode;
  CalcOperationExpressionNode(this.operator, this.leftNode, this.rightNode);

  @override
  double get computedValue {
    if (operator == TokenKind.PLUS) {
      return leftNode.computedValue + rightNode.computedValue;
    }
    if (operator == TokenKind.ASTERISK) {
      return leftNode.computedValue * rightNode.computedValue;
    }
    assert(false, 'This operator should not be used');
    return 0;
  }
}

class _CSSCalcParser {
  final String propertyName;
  final RenderStyle _renderStyle;
  final Tokenizer tokenizer;

  late Token _peekToken;

  _CSSCalcParser(this.propertyName, this._renderStyle, String text, {int start = 0})
      : tokenizer = Tokenizer(SourceFile.fromString(text), text, true, start) {
    _peekToken = tokenizer.next();
  }

  CalcExpressionNode? processCalcExpression() {
    return processCalcSum();
  }

  CalcExpressionNode? processFunction() {
    var name = _peekToken.text;
    if (_maybeEat(TokenKind.LPAREN)) {
      final node = processCalcExpression();
      _maybeEat(TokenKind.RPAREN);
      return node;
    }
    switch (name) {
      case 'var':
        while (_peek() != TokenKind.RPAREN) {
          _next();
          name += _peekToken.text;
        }
        _maybeEat(TokenKind.RPAREN);
        CSSVariable? variable = CSSVariable.tryParse(_renderStyle, name);
        if (variable != null) {
          return CalcVariableNode(variable, _renderStyle);
        }
        return null;
      case 'calc':
        _next();
        _maybeEat(TokenKind.LPAREN);
        final node = processCalcExpression();
        _maybeEat(TokenKind.RPAREN);
        return node;
    }
    return null;
  }

  CalcExpressionNode? processCalcSum() {
    List<CalcExpressionNode> nodes = [];
    CalcExpressionNode? firstNode = processCalcProduct();
    CalcExpressionNode? secondNode;
    if (firstNode == null) {
      return null;
    }
    nodes.add(firstNode);
    while (_peek() != TokenKind.END_OF_FILE) {
      String operator = _peekToken.text;
      if (_peekToken.text != '+' && _peekToken.text != '-') {
        return null;
      }
      _next();
      secondNode = processCalcProduct();
      if (secondNode == null) {
        return null;
      }
      if (operator == '-') {
        secondNode = CalcNegateNode(secondNode);
      }
      nodes.add(secondNode);
    }
    if (nodes.isEmpty) {
      return firstNode;
    }
    final sumNode = nodes.reduce((value, element) {
      return CalcOperationExpressionNode(TokenKind.PLUS, value, element);
    });
    return sumNode;
  }

  CalcExpressionNode? processCalcProduct() {
    List<CalcExpressionNode> nodes = [];

    CalcExpressionNode? firstNode = processCalcValue();
    CalcExpressionNode? secondNode;
    if (firstNode == null) {
      return null;
    }
    nodes.add(firstNode);
    while (_peek() != TokenKind.END_OF_FILE) {
      String operator = _peekToken.text;
      if (_peekToken.text != '*' && _peekToken.text != '/') {
        break;
      }
      _next();
      secondNode = processCalcValue();
      if (secondNode == null) {
        return null;
      }
      if (operator == '/') {
        secondNode = CalcInvertNode(secondNode);
      }
      nodes.add(secondNode);
    }
    if (nodes.isEmpty) {
      return firstNode;
    }
    final productNode = nodes.reduce((value, element) {
      return CalcOperationExpressionNode(TokenKind.ASTERISK, value, element);
    });
    return productNode;
  }

  CalcExpressionNode? processCalcValue() {
    CalcExpressionNode? func = processFunction();
    if (func != null) {
      return func;
    }
    String value = _next().text;
    String unit = _peekToken.text;
    // ignore unit type
    if (TokenKind.matchUnits(unit, 0, unit.length) == -1) {
      double? numberValue = double.tryParse(value);
      if (numberValue == null) {
        return null;
      }
      return CalcNumberNode(numberValue);
    }
    value += unit;
    CSSLengthValue lengthValue = CSSLength.parseLength(value, _renderStyle, propertyName);
    _next();
    return CalcLengthNode(lengthValue);
  }

  int _peek() {
    return _peekToken.kind;
  }

  Token _next({bool unicodeRange = false}) {
    final next = _peekToken;
    _peekToken = tokenizer.next(unicodeRange: unicodeRange);
    return next;
  }

  bool _maybeEat(int kind, {bool unicodeRange = false}) {
    if (_peekToken.kind == kind) {
      _peekToken = tokenizer.next(unicodeRange: unicodeRange);
      return true;
    } else {
      return false;
    }
  }
}
