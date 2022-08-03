/*
Copyright 2013, the Dart project authors. 

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google LLC nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

part of 'parser.dart';

abstract class Visitor {
  dynamic visitSelectorGroup(SelectorGroup node);
  dynamic visitSelector(Selector node);
  dynamic visitSimpleSelectorSequence(SimpleSelectorSequence node);
  dynamic visitSimpleSelector(SimpleSelector node);
  dynamic visitElementSelector(ElementSelector node);
  dynamic visitAttributeSelector(AttributeSelector node);
  dynamic visitIdSelector(IdSelector node);
  dynamic visitClassSelector(ClassSelector node);
  dynamic visitPseudoClassSelector(PseudoClassSelector node);
  dynamic visitPseudoElementSelector(PseudoElementSelector node);
  dynamic visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node);
  dynamic visitPseudoElementFunctionSelector(PseudoElementFunctionSelector node);
  dynamic visitNegationSelector(NegationSelector node);
}

class SelectorVisitor implements Visitor {
  /// Helper function to walk a list of nodes.
  void _visitNodeList(List<TreeNode> list) {
    // Don't use iterable otherwise the list can't grow while using Visitor.
    // It certainly can't have items deleted before the index being iterated
    // but items could be added after the index.
    for (var index = 0; index < list.length; index++) {
      list[index].visit(this);
    }
  }

  @override
  dynamic visitSelectorGroup(SelectorGroup node) {
    _visitNodeList(node.selectors);
  }

  @override
  dynamic visitSelector(Selector node) {
    _visitNodeList(node.simpleSelectorSequences);
  }

  @override
  dynamic visitSimpleSelectorSequence(SimpleSelectorSequence node) {
    node.simpleSelector.visit(this);
  }

  @override
  dynamic visitSimpleSelector(SimpleSelector node) => (node._name as TreeNode).visit(this);

  @override
  dynamic visitElementSelector(ElementSelector node) => visitSimpleSelector(node);

  @override
  dynamic visitAttributeSelector(AttributeSelector node) {
    visitSimpleSelector(node);
  }

  @override
  dynamic visitIdSelector(IdSelector node) => visitSimpleSelector(node);

  @override
  dynamic visitClassSelector(ClassSelector node) => visitSimpleSelector(node);

  @override
  dynamic visitPseudoClassSelector(PseudoClassSelector node) => visitSimpleSelector(node);

  @override
  dynamic visitPseudoElementSelector(PseudoElementSelector node) => visitSimpleSelector(node);

  @override
  dynamic visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node) => visitSimpleSelector(node);

  @override
  dynamic visitPseudoElementFunctionSelector(PseudoElementFunctionSelector node) => visitSimpleSelector(node);

  @override
  dynamic visitNegationSelector(NegationSelector node) => visitSimpleSelector(node);
}
