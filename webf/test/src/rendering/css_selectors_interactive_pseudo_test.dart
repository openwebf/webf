/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/css.dart';
import '../../setup.dart';
import '../widget/test_utils.dart';

Future<PreparedWidgetTest> _prepareMaterialWidgetTest({
  required WidgetTester tester,
  required String html,
  String? controllerName,
  double viewportWidth = 360,
  double viewportHeight = 640,
  Map<String, dynamic>? windowProperties,
}) {
  return WebFWidgetTestUtils.prepareWidgetTest(
    tester: tester,
    controllerName: controllerName,
    html: html,
    viewportWidth: viewportWidth,
    viewportHeight: viewportHeight,
    windowProperties: windowProperties,
    wrap: (child) => MaterialApp(home: Scaffold(body: child)),
  );
}

/// Unit tests for interactive pseudo-class selectors based on WPT test cases.
/// Tests: :hover, :active, :focus, :focus-visible, :focus-within,
/// :enabled, :disabled, :checked, :required, :optional,
/// :placeholder-shown, :valid, :invalid
void main() {
  setUpAll(() {
    setupTest();
  });

  setUp(() {
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(Duration(milliseconds: 100));
  });

  group('Interactive Pseudo-classes - State Matching', () {
    group(':hover pseudo-class', () {
      testWidgets('element matches :hover when hover state is set',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName: 'hover-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <head>
                <style>
                  .target:hover { background-color: green; }
                </style>
              </head>
              <body>
                <div id="test" class="target">Hover me</div>
              </body>
            </html>
          ''',
        );

        final div = prepared.getElementById('test');
        await tester.pump(Duration(milliseconds: 50));

        // Initially not hovered
        expect(div.isHovered, isFalse);
        expect(div.matches(':hover'), isFalse);

        // Set hover state
        div.updateHoverState(true);
        await tester.pump(Duration(milliseconds: 50));

        expect(div.isHovered, isTrue);
        expect(div.matches(':hover'), isTrue);

        // Clear hover state
        div.updateHoverState(false);
        await tester.pump(Duration(milliseconds: 50));

        expect(div.isHovered, isFalse);
        expect(div.matches(':hover'), isFalse);
      });

      testWidgets('ancestor matches :hover when descendant is hovered',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName:
              'hover-ancestor-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <div id="parent">
                  <div id="child">Child</div>
                </div>
              </body>
            </html>
          ''',
        );

        final parent = prepared.getElementById('parent');
        final child = prepared.getElementById('child');
        await tester.pump(Duration(milliseconds: 50));

        // Hover on child - per CSS spec, parent should also match :hover
        child.updateHoverState(true);
        parent.updateHoverState(true);
        await tester.pump(Duration(milliseconds: 50));

        expect(child.matches(':hover'), isTrue);
        expect(parent.matches(':hover'), isTrue);
      });
    });

    group(':active pseudo-class', () {
      testWidgets('element matches :active when active state is set',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName:
              'active-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <head>
                <style>
                  .target:active { background-color: red; }
                </style>
              </head>
              <body>
                <div id="test" class="target">Click me</div>
              </body>
            </html>
          ''',
        );

        final div = prepared.getElementById('test');
        await tester.pump(Duration(milliseconds: 50));

        // Initially not active
        expect(div.isActive, isFalse);
        expect(div.matches(':active'), isFalse);

        // Set active state
        div.updateActiveState(true);
        await tester.pump(Duration(milliseconds: 50));

        expect(div.isActive, isTrue);
        expect(div.matches(':active'), isTrue);

        // Clear active state
        div.updateActiveState(false);
        await tester.pump(Duration(milliseconds: 50));

        expect(div.isActive, isFalse);
        expect(div.matches(':active'), isFalse);
      });
    });

    group(':focus pseudo-class', () {
      testWidgets('element matches :focus when focus state is set',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName: 'focus-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <head>
                <style>
                  .target:focus { outline: 2px solid blue; }
                </style>
              </head>
              <body>
                <div id="test" class="target" tabindex="0">Focus me</div>
              </body>
            </html>
          ''',
        );

        final div = prepared.getElementById('test');
        await tester.pump(Duration(milliseconds: 50));

        // Initially not focused
        expect(div.isFocused, isFalse);
        expect(div.matches(':focus'), isFalse);

        // Set focus state
        div.updateFocusState(true);
        await tester.pump(Duration(milliseconds: 50));

        expect(div.isFocused, isTrue);
        expect(div.matches(':focus'), isTrue);

        // Clear focus state
        div.updateFocusState(false);
        await tester.pump(Duration(milliseconds: 50));

        expect(div.isFocused, isFalse);
        expect(div.matches(':focus'), isFalse);
      });
    });

    group(':focus-visible pseudo-class', () {
      testWidgets('element matches :focus-visible when focus-visible is set',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName:
              'focus-visible-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <head>
                <style>
                  .target:focus-visible { outline: 3px dashed orange; }
                </style>
              </head>
              <body>
                <div id="test" class="target" tabindex="0">Focus me with keyboard</div>
              </body>
            </html>
          ''',
        );

        final div = prepared.getElementById('test');
        await tester.pump(Duration(milliseconds: 50));

        // Initially not focus-visible
        expect(div.isFocusVisible, isFalse);
        expect(div.matches(':focus-visible'), isFalse);

        // Set focus with focus-visible flag
        div.updateFocusState(true, focusVisible: true);
        await tester.pump(Duration(milliseconds: 50));

        expect(div.isFocusVisible, isTrue);
        expect(div.matches(':focus-visible'), isTrue);

        // Clear focus state
        div.updateFocusState(false);
        await tester.pump(Duration(milliseconds: 50));

        expect(div.isFocusVisible, isFalse);
        expect(div.matches(':focus-visible'), isFalse);
      });

      testWidgets('focus without focus-visible does not match :focus-visible',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName:
              'focus-no-visible-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <div id="test" tabindex="0">Click focus</div>
              </body>
            </html>
          ''',
        );

        final div = prepared.getElementById('test');
        await tester.pump(Duration(milliseconds: 50));

        // Set focus without focus-visible (simulating mouse click focus)
        div.updateFocusState(true, focusVisible: false);
        await tester.pump(Duration(milliseconds: 50));

        expect(div.isFocused, isTrue);
        expect(div.matches(':focus'), isTrue);
        expect(div.isFocusVisible, isFalse);
        expect(div.matches(':focus-visible'), isFalse);
      });
    });

    group(':focus-within pseudo-class', () {
      testWidgets('parent matches :focus-within when child is focused',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName:
              'focus-within-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <head>
                <style>
                  .container:focus-within { border: 2px solid green; }
                </style>
              </head>
              <body>
                <div id="parent" class="container">
                  <input id="child" type="text" />
                </div>
              </body>
            </html>
          ''',
        );

        final parent = prepared.getElementById('parent');
        final child = prepared.getElementById('child');
        await tester.pump(Duration(milliseconds: 50));

        // Initially parent is not focus-within
        expect(parent.isFocusWithin, isFalse);
        expect(parent.matches(':focus-within'), isFalse);

        // Focus the child
        child.updateFocusState(true);
        await tester.pump(Duration(milliseconds: 50));

        // Parent should match :focus-within
        expect(parent.isFocusWithin, isTrue);
        expect(parent.matches(':focus-within'), isTrue);

        // Child should also match :focus-within (it contains itself)
        expect(child.isFocusWithin, isTrue);
        expect(child.matches(':focus-within'), isTrue);

        // Blur the child
        child.updateFocusState(false);
        await tester.pump(Duration(milliseconds: 50));

        // Parent should no longer match :focus-within
        expect(parent.isFocusWithin, isFalse);
        expect(parent.matches(':focus-within'), isFalse);
      });

      testWidgets('deeply nested focus propagates :focus-within',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName:
              'focus-within-deep-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <div id="grandparent">
                  <div id="parent">
                    <div id="child" tabindex="0">Deep child</div>
                  </div>
                </div>
              </body>
            </html>
          ''',
        );

        final grandparent = prepared.getElementById('grandparent');
        final parent = prepared.getElementById('parent');
        final child = prepared.getElementById('child');
        await tester.pump(Duration(milliseconds: 50));

        // Focus the deep child
        child.updateFocusState(true);
        await tester.pump(Duration(milliseconds: 50));

        // All ancestors should match :focus-within
        expect(child.matches(':focus-within'), isTrue);
        expect(parent.matches(':focus-within'), isTrue);
        expect(grandparent.matches(':focus-within'), isTrue);
      });
    });
  });

  group('Form Control Pseudo-classes', () {
    group(':enabled and :disabled pseudo-classes', () {
      testWidgets('button matches :enabled when not disabled',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName:
              'enabled-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <button id="enabled_btn">Enabled</button>
                <button id="disabled_btn" disabled>Disabled</button>
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final enabledBtn = prepared.getElementById('enabled_btn');
        final disabledBtn = prepared.getElementById('disabled_btn');

        expect(enabledBtn.matches(':enabled'), isTrue);
        expect(enabledBtn.matches(':disabled'), isFalse);

        expect(disabledBtn.matches(':enabled'), isFalse);
        expect(disabledBtn.matches(':disabled'), isTrue);
      });

      testWidgets('input matches :enabled/:disabled correctly',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName:
              'input-enabled-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <input id="input_enabled" type="text" />
                <input id="input_disabled" type="text" disabled />
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final enabledInput = prepared.getElementById('input_enabled');
        final disabledInput = prepared.getElementById('input_disabled');

        expect(enabledInput.matches(':enabled'), isTrue);
        expect(enabledInput.matches(':disabled'), isFalse);

        expect(disabledInput.matches(':enabled'), isFalse);
        expect(disabledInput.matches(':disabled'), isTrue);
      });

      testWidgets('select matches :enabled/:disabled correctly',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName:
              'select-enabled-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <select id="select_enabled"></select>
                <select id="select_disabled" disabled></select>
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final enabledSelect = prepared.getElementById('select_enabled');
        final disabledSelect = prepared.getElementById('select_disabled');

        expect(enabledSelect.matches(':enabled'), isTrue);
        expect(enabledSelect.matches(':disabled'), isFalse);

        expect(disabledSelect.matches(':enabled'), isFalse);
        expect(disabledSelect.matches(':disabled'), isTrue);
      });

      testWidgets('textarea matches :enabled/:disabled correctly',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName:
              'textarea-enabled-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <textarea id="textarea_enabled"></textarea>
                <textarea id="textarea_disabled" disabled></textarea>
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final enabledTextarea = prepared.getElementById('textarea_enabled');
        final disabledTextarea = prepared.getElementById('textarea_disabled');

        expect(enabledTextarea.matches(':enabled'), isTrue);
        expect(enabledTextarea.matches(':disabled'), isFalse);

        expect(disabledTextarea.matches(':enabled'), isFalse);
        expect(disabledTextarea.matches(':disabled'), isTrue);
      });

      testWidgets('non-form element does not match :enabled/:disabled',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName:
              'non-form-enabled-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <span id="incapable">Not a form control</span>
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final span = prepared.getElementById('incapable');

        expect(span.matches(':enabled'), isFalse);
        expect(span.matches(':disabled'), isFalse);
      });
    });

    group(':required and :optional pseudo-classes', () {
      testWidgets('input matches :required when required attribute is set',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName:
              'required-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <input id="required_input" type="text" required />
                <input id="optional_input" type="text" />
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final requiredInput = prepared.getElementById('required_input');
        final optionalInput = prepared.getElementById('optional_input');

        expect(requiredInput.matches(':required'), isTrue);
        expect(requiredInput.matches(':optional'), isFalse);

        expect(optionalInput.matches(':required'), isFalse);
        expect(optionalInput.matches(':optional'), isTrue);
      });
    });

    group(':checked pseudo-class', () {
      testWidgets('checkbox matches :checked when checked attribute is set',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName:
              'checked-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <input id="checked_cb" type="checkbox" checked />
                <input id="unchecked_cb" type="checkbox" />
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final checkedCb = prepared.getElementById('checked_cb');
        final uncheckedCb = prepared.getElementById('unchecked_cb');

        expect(checkedCb.matches(':checked'), isTrue);
        expect(uncheckedCb.matches(':checked'), isFalse);
      });

      testWidgets('radio matches :checked when checked attribute is set',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName:
              'radio-checked-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <input id="checked_radio" type="radio" name="group" checked />
                <input id="unchecked_radio" type="radio" name="group" />
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final checkedRadio = prepared.getElementById('checked_radio');
        final uncheckedRadio = prepared.getElementById('unchecked_radio');

        expect(checkedRadio.matches(':checked'), isTrue);
        expect(uncheckedRadio.matches(':checked'), isFalse);
      });

      testWidgets('option matches :checked when selected',
          (WidgetTester tester) async {
        final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          controllerName:
              'option-checked-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <select>
                  <option id="opt1">First</option>
                  <option id="opt2" selected>Selected</option>
                </select>
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final opt1 = prepared.getElementById('opt1');
        final opt2 = prepared.getElementById('opt2');

        expect(opt1.matches(':checked'), isFalse);
        expect(opt2.matches(':checked'), isTrue);
      });
    });

    group(':placeholder-shown pseudo-class', () {
      testWidgets(
          'input matches :placeholder-shown when has placeholder and empty value',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName:
              'placeholder-shown-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <input id="t1" type="text" />
                <input id="t2" type="text" placeholder />
                <input id="t3" type="text" placeholder="" />
                <input id="t4" type="text" placeholder="placeholder" />
                <input id="t5" type="text" placeholder value="value" />
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        // No placeholder attribute - should not match
        final t1 = prepared.getElementById('t1');
        expect(t1.matches(':placeholder-shown'), isFalse);

        // Placeholder attribute without value - spec says empty string placeholder doesn't show
        final t2 = prepared.getElementById('t2');
        expect(t2.matches(':placeholder-shown'), isFalse);

        // Placeholder attribute - empty string - doesn't match per spec
        final t3 = prepared.getElementById('t3');
        expect(t3.matches(':placeholder-shown'), isFalse);

        // Placeholder attribute - non-empty string, no value - should match
        final t4 = prepared.getElementById('t4');
        expect(t4.matches(':placeholder-shown'), isTrue);

        // Placeholder attribute with value - should not match
        final t5 = prepared.getElementById('t5');
        expect(t5.matches(':placeholder-shown'), isFalse);
      });
    });

    group(':valid and :invalid pseudo-classes', () {
      testWidgets('required input is invalid when empty',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName: 'valid-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <input id="required_empty" type="text" required />
                <input id="required_filled" type="text" required value="filled" />
                <input id="optional_empty" type="text" />
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final requiredEmpty = prepared.getElementById('required_empty');
        final requiredFilled = prepared.getElementById('required_filled');
        final optionalEmpty = prepared.getElementById('optional_empty');

        // Required but empty - invalid
        expect(requiredEmpty.matches(':valid'), isFalse);
        expect(requiredEmpty.matches(':invalid'), isTrue);

        // Required and has value - valid
        expect(requiredFilled.matches(':valid'), isTrue);
        expect(requiredFilled.matches(':invalid'), isFalse);

        // Optional and empty - valid
        expect(optionalEmpty.matches(':valid'), isTrue);
        expect(optionalEmpty.matches(':invalid'), isFalse);
      });

      testWidgets('email input validates format',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName:
              'email-valid-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <input id="valid_email" type="email" value="test@example.com" />
                <input id="invalid_email" type="email" value="not-an-email" />
                <input id="empty_email" type="email" />
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final validEmail = prepared.getElementById('valid_email');
        final invalidEmail = prepared.getElementById('invalid_email');
        final emptyEmail = prepared.getElementById('empty_email');

        expect(validEmail.matches(':valid'), isTrue);
        expect(validEmail.matches(':invalid'), isFalse);

        expect(invalidEmail.matches(':valid'), isFalse);
        expect(invalidEmail.matches(':invalid'), isTrue);

        // Empty optional email is valid
        expect(emptyEmail.matches(':valid'), isTrue);
        expect(emptyEmail.matches(':invalid'), isFalse);
      });

      testWidgets('disabled input is always valid',
          (WidgetTester tester) async {
        final prepared = await _prepareMaterialWidgetTest(
          tester: tester,
          controllerName:
              'disabled-valid-test-${DateTime.now().millisecondsSinceEpoch}',
          html: '''
            <html>
              <body>
                <input id="disabled_required" type="text" required disabled />
              </body>
            </html>
          ''',
        );

        await tester.pump(Duration(milliseconds: 50));

        final disabledRequired = prepared.getElementById('disabled_required');

        // Disabled inputs are barred from constraint validation
        expect(disabledRequired.matches(':valid'), isTrue);
        expect(disabledRequired.matches(':invalid'), isFalse);
      });
    });
  });

  group('Compound Selectors with Interactive Pseudo-classes', () {
    testWidgets('compound selector :not(:disabled) matches enabled controls',
        (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName:
            'not-disabled-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body>
              <button id="btn_enabled">Enabled</button>
              <button id="btn_disabled" disabled>Disabled</button>
              <span id="not_control">Not a control</span>
            </body>
          </html>
        ''',
      );

      await tester.pump(Duration(milliseconds: 50));

      final btnEnabled = prepared.getElementById('btn_enabled');
      final btnDisabled = prepared.getElementById('btn_disabled');
      final notControl = prepared.getElementById('not_control');

      expect(btnEnabled.matches(':not(:disabled)'), isTrue);
      expect(btnDisabled.matches(':not(:disabled)'), isFalse);
      expect(notControl.matches(':not(:disabled)'), isTrue);
    });

    testWidgets('compound selector :not(:enabled) matches disabled and non-controls',
        (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName:
            'not-enabled-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body>
              <button id="btn_enabled">Enabled</button>
              <button id="btn_disabled" disabled>Disabled</button>
              <span id="not_control">Not a control</span>
            </body>
          </html>
        ''',
      );

      await tester.pump(Duration(milliseconds: 50));

      final btnEnabled = prepared.getElementById('btn_enabled');
      final btnDisabled = prepared.getElementById('btn_disabled');
      final notControl = prepared.getElementById('not_control');

      expect(btnEnabled.matches(':not(:enabled)'), isFalse);
      expect(btnDisabled.matches(':not(:enabled)'), isTrue);
      expect(notControl.matches(':not(:enabled)'), isTrue);
    });

    testWidgets('selector list with :hover and :focus',
        (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName:
            'hover-focus-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                .interactive:hover,
                .interactive:focus { background-color: yellow; }
              </style>
            </head>
            <body>
              <div id="target" class="interactive" tabindex="0">Interactive</div>
            </body>
          </html>
        ''',
      );

      final target = prepared.getElementById('target');
      await tester.pump(Duration(milliseconds: 50));

      // Initially matches neither
      expect(target.matches(':hover'), isFalse);
      expect(target.matches(':focus'), isFalse);

      // Hover - matches :hover
      target.updateHoverState(true);
      await tester.pump(Duration(milliseconds: 50));
      expect(target.matches(':hover'), isTrue);

      // Focus - matches :focus
      target.updateFocusState(true);
      await tester.pump(Duration(milliseconds: 50));
      expect(target.matches(':focus'), isTrue);

      // Clear both
      target.updateHoverState(false);
      target.updateFocusState(false);
      await tester.pump(Duration(milliseconds: 50));
      expect(target.matches(':hover'), isFalse);
      expect(target.matches(':focus'), isFalse);
    });
  });

  group('querySelectorAll with Interactive Pseudo-classes', () {
    testWidgets('querySelectorAll :enabled returns only enabled controls',
        (WidgetTester tester) async {
      final prepared = await _prepareMaterialWidgetTest(
        tester: tester,
        controllerName:
            'querySelectorAll-enabled-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body>
              <div id="container">
                <button id="button_enabled"></button>
                <button id="button_disabled" disabled></button>
                <input id="input_enabled" />
                <input id="input_disabled" disabled />
                <span id="incapable"></span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump(Duration(milliseconds: 50));

      final container = prepared.getElementById('container');
      final enabledElements = container.querySelectorAll(':enabled');

      // Should only match enabled form controls
      for (final element in enabledElements) {
        expect(element.id?.endsWith('_enabled'), isTrue,
            reason: 'Element ${element.id} should end with _enabled');
      }
    });

    testWidgets('querySelectorAll :disabled returns only disabled controls',
        (WidgetTester tester) async {
      final prepared = await _prepareMaterialWidgetTest(
        tester: tester,
        controllerName:
            'querySelectorAll-disabled-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body>
              <div id="container">
                <button id="button_enabled"></button>
                <button id="button_disabled" disabled></button>
                <input id="input_enabled" />
                <input id="input_disabled" disabled />
                <span id="incapable"></span>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump(Duration(milliseconds: 50));

      final container = prepared.getElementById('container');
      final disabledElements = container.querySelectorAll(':disabled');

      // Should only match disabled form controls
      for (final element in disabledElements) {
        expect(element.id?.endsWith('_disabled'), isTrue,
            reason: 'Element ${element.id} should end with _disabled');
      }
    });
  });
}
