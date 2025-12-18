/*
 * Tests for CDP incremental DOM events to ensure no duplication between
 * DOM.setChildNodes and DOM.childNodeInserted for the same node, and that
 * whitespace-only text becomes visible once populated.
 */


import 'package:flutter_test/flutter_test.dart';
import 'package:webf/bridge.dart';
import 'package:webf/devtools.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/devtools/cdp_service/debugging_context.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });


  setUp(() async {
    // Keep DevTools manager disabled; we'll attach our own ChromeDevToolsService
    WebFControllerManager.instance.initialize(const WebFControllerManagerConfig(
      enableDevTools: false,
    ));
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(const Duration(milliseconds: 50));
  });

  testWidgets('No duplicate insert after seed for non-empty text', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'cdp-incr-nodup-1',
      html: '<html><body><div id="root"></div></body></html>',
    );

    // Attach DevTools service to this controller
    final dev = ChromeDevToolsService();
    dev.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    // Allow unified service delayed tasks (DOM.documentUpdated) to run
    await tester.pump(const Duration(milliseconds: 300));

    // Capture outgoing events from the unified service
    final events = <InspectorEvent>[];
    ChromeDevToolsService.unifiedService.clearEventListenersForTest();
    ChromeDevToolsService.unifiedService.addEventListenerForTest(events.add);

    final view = prepared.controller.view;
    final doc = prepared.document;
    final root = doc.getElementById(['root'])!;

    // Create <p id=p></p> and append via view to trigger devtools callbacks
    final p = doc.createElement('p', BindingContext(view, view.contextId, allocateNewBindingObject()));
    (p).setAttribute('id', 'p');
    view.insertAdjacentNode(root.pointer!, 'beforeend', p.pointer!);

    // Append a non-empty text node via view to trigger devtools callbacks
    final t = doc.createTextNode('hello', BindingContext(view, view.contextId, allocateNewBindingObject()));
    view.insertAdjacentNode(p.pointer!, 'beforeend', t.pointer!);

    // Allow microtasks/DOM mutations to flush
    await tester.pump(const Duration(milliseconds: 50));

    final pId = view.forDevtoolsNodeId(p);
    final tId = view.forDevtoolsNodeId(t);

    bool sawSeedWithText = false;
    bool sawInsertOfText = false;

    for (final e in events) {
      if (e is DOMSetChildNodesEvent && e.parentId == pId) {
        for (final m in e.nodes) {
          if (m['nodeId'] == tId) {
            sawSeedWithText = true;
          }
        }
      } else if (e is DOMChildNodeInsertedEvent) {
        final id = e.node.ownerView.forDevtoolsNodeId(e.node);
        if (id == tId) {
          sawInsertOfText = true;
        }
      }
    }

    expect(sawSeedWithText, isTrue, reason: 'Expected text node to be included in initial seed');
    expect(sawInsertOfText, isFalse, reason: 'Should not also emit childNodeInserted for the same text');
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets('Whitespace text later populated inserts then modifies', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'cdp-incr-nodup-2',
      html: '<html><body><div id="root"></div></body></html>',
    );

    final dev = ChromeDevToolsService();
    dev.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    await tester.pump(const Duration(milliseconds: 300));

    final events = <InspectorEvent>[];
    ChromeDevToolsService.unifiedService.clearEventListenersForTest();
    ChromeDevToolsService.unifiedService.addEventListenerForTest(events.add);

    final view = prepared.controller.view;
    final doc = prepared.document;
    final root = doc.getElementById(['root'])!;

    // Create <span id=s></span> and append via view to trigger devtools callbacks
    final span = doc.createElement('span', BindingContext(view, view.contextId, allocateNewBindingObject()));
    (span).setAttribute('id', 's');
    view.insertAdjacentNode(root.pointer!, 'beforeend', span.pointer!);

    // Append a whitespace-only text node via view
    final ws = doc.createTextNode('   ', BindingContext(view, view.contextId, allocateNewBindingObject()));
    view.insertAdjacentNode(span.pointer!, 'beforeend', ws.pointer!);

    await tester.pump(const Duration(milliseconds: 30));

    // Clear captured events before the population step to focus on the transition
    events.clear();

    // Populate the whitespace text through view to invoke devtoolsCharacterDataModified
    view.setAttribute(ws.pointer!, 'data', 'abc');

    await tester.pump(const Duration(milliseconds: 50));

    final wsId = view.forDevtoolsNodeId(ws);

    int? insertIndex;
    int? modifyIndex;

    for (int i = 0; i < events.length; i++) {
      final e = events[i];
      if (e is DOMChildNodeInsertedEvent) {
        final id = e.node.ownerView.forDevtoolsNodeId(e.node);
        if (id == wsId) insertIndex = i;
      } else if (e is DOMCharacterDataModifiedEvent) {
        final id = e.node.ownerView.forDevtoolsNodeId(e.node);
        if (id == wsId) modifyIndex = i;
      }
    }

    expect(insertIndex, isNotNull, reason: 'Should insert the text node once it becomes non-empty');
    expect(modifyIndex, isNotNull, reason: 'Should then modify the character data to the new value');
    expect(insertIndex! < modifyIndex!, isTrue, reason: 'Insert must precede characterDataModified for the same node');
    await tester.pump(const Duration(milliseconds: 350));
  });
}
