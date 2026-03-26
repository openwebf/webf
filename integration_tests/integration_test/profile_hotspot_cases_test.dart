import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:vm_service/vm_service.dart' as vm;
import 'package:vm_service/vm_service_io.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

final developer.UserTag _paragraphRebuildProfileTag =
    developer.UserTag('profile_hotspots.paragraph_rebuild');
final developer.UserTag _flexInlineLayoutProfileTag =
    developer.UserTag('profile_hotspots.flex_inline_layout');
final developer.UserTag _fiatFilterPopupProfileTag =
    developer.UserTag('profile_hotspots.fiat_filter_popup');
final developer.UserTag _paymentMethodSheetProfileTag =
    developer.UserTag('profile_hotspots.payment_method_sheet');
final developer.UserTag _paymentMethodBottomSheetProfileTag =
    developer.UserTag('profile_hotspots.payment_method_bottom_sheet');
final developer.UserTag _paymentMethodBottomSheetTightProfileTag =
    developer.UserTag('profile_hotspots.payment_method_bottom_sheet_tight');
final developer.UserTag _paymentMethodFastPathSheetProfileTag =
    developer.UserTag('profile_hotspots.payment_method_fastpath_sheet');
final developer.UserTag _paymentMethodPickerModalProfileTag =
    developer.UserTag('profile_hotspots.payment_method_picker_modal');
final developer.UserTag _paymentMethodOtcSourceSheetProfileTag =
    developer.UserTag('profile_hotspots.payment_method_otc_source_sheet');
final developer.UserTag _flexAdjustFastPathProfileTag =
    developer.UserTag('profile_hotspots.flex_adjust_fastpath');
final developer.UserTag _flexNestedGroupFastPathProfileTag =
    developer.UserTag('profile_hotspots.flex_nested_group_fastpath');
final developer.UserTag _flexRunMetricsDenseProfileTag =
    developer.UserTag('profile_hotspots.flex_runmetrics_dense');
final developer.UserTag _flexTightFastPathDenseProfileTag =
    developer.UserTag('profile_hotspots.flex_tight_fastpath_dense');
final developer.UserTag _flexHybridFastPathDenseProfileTag =
    developer.UserTag('profile_hotspots.flex_hybrid_fastpath_dense');
final developer.UserTag _flexAdjustWidgetDenseProfileTag =
    developer.UserTag('profile_hotspots.flex_adjust_widget_dense');
const String _profileCaseFilter = String.fromEnvironment(
  'WEBF_PROFILE_CASE_FILTER',
  defaultValue: '',
);

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _configureProfileTestEnvironment();
  });

  tearDownAll(() async {
    await _persistProfileArtifacts(binding.reportData);
  });

  setUp(() {
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 8,
        maxAttachedInstances: 8,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    await WebFControllerManager.instance.disposeAll();
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });

  group('profile_hotspot_cases', () {
    testWidgets('direction_inheritance',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-direction-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildDirectionInheritanceHtml(depth: 32, runCount: 56),
      );

      final dom.Element host = prepared.getElementById('host');
      expect(host.renderStyle.direction, TextDirection.rtl);

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['direction_inheritance_meta'] = <String, dynamic>{
        'depth': 32,
        'runCount': 56,
        'mutationIterations': 18,
      };

      await _toggleWidths(prepared, 'host',
          widths: const <String>['320px', '220px'], iterations: 4);

      await binding.traceAction(
        () async {
          await _toggleWidths(prepared, 'host',
              widths: const <String>['320px', '220px', '280px'],
              iterations: 18);
        },
        reportKey: 'direction_inheritance_timeline',
      );

      expect(host.renderStyle.direction, TextDirection.rtl);
    }, skip: !_shouldRunProfileCase('direction_inheritance'));

    testWidgets('text_align_inheritance',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-text-align-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildTextAlignInheritanceHtml(depth: 28, runCount: 64),
      );

      final dom.Element host = prepared.getElementById('host');
      expect(host.renderStyle.textAlign, TextAlign.center);

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['text_align_inheritance_meta'] = <String, dynamic>{
        'depth': 28,
        'runCount': 64,
        'mutationIterations': 18,
      };

      await _toggleWidths(prepared, 'host',
          widths: const <String>['300px', '210px'], iterations: 4);

      await binding.traceAction(
        () async {
          await _toggleWidths(prepared, 'host',
              widths: const <String>['300px', '210px', '260px'],
              iterations: 18);
        },
        reportKey: 'text_align_inheritance_timeline',
      );

      expect(host.renderStyle.textAlign, TextAlign.center);
    }, skip: !_shouldRunProfileCase('text_align_inheritance'));

    testWidgets('paragraph_rebuild',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-paragraph-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildParagraphRebuildHtml(chipCount: 72),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element paragraph = prepared.getElementById('paragraph');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['paragraph_rebuild_meta'] = <String, dynamic>{
        'chipCount': 72,
        'mutationIterations': 48,
        'styleMutationPhases': 4,
      };

      await _runParagraphRebuildLoop(
        prepared,
        mutationIterations: 12,
        widths: const <String>['340px', '190px', '260px', '220px'],
      );

      binding.reportData!['paragraph_rebuild_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _paragraphRebuildProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runParagraphRebuildLoop(
                prepared,
                mutationIterations: 48,
                widths: const <String>[
                  '340px',
                  '190px',
                  '260px',
                  '220px',
                ],
              );
            },
            reportKey: 'paragraph_rebuild_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(paragraph.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('paragraph_rebuild'));

    testWidgets('opacity_transition',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-opacity-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildOpacityTransitionHtml(tileCount: 144),
      );

      final dom.Element stage = prepared.getElementById('stage');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['opacity_transition_meta'] = <String, dynamic>{
        'tileCount': 144,
        'forwardFrames': 24,
        'reverseFrames': 24,
      };

      await _runOpacityCycle(prepared, 'stage',
          forwardFrames: 8, reverseFrames: 8);

      await binding.traceAction(
        () async {
          await _runOpacityCycle(prepared, 'stage',
              forwardFrames: 24, reverseFrames: 24);
        },
        reportKey: 'opacity_transition_timeline',
      );

      expect(stage.className, isEmpty);
    }, skip: !_shouldRunProfileCase('opacity_transition'));

    testWidgets('fiat_filter_popup',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-fiat-popup-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildFiatFilterPopupHtml(optionCount: 64),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element popup = prepared.getElementById('popup');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['fiat_filter_popup_meta'] = <String, dynamic>{
        'optionCount': 64,
        'mutationIterations': 40,
        'layoutMode': 'fixed-height-popup-option-list',
      };

      await _runFiatFilterPopupLoop(
        prepared,
        mutationIterations: 10,
        widths: const <String>['364px', '328px', '388px', '340px'],
      );

      binding.reportData!['fiat_filter_popup_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _fiatFilterPopupProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runFiatFilterPopupLoop(
                prepared,
                mutationIterations: 40,
                widths: const <String>['364px', '328px', '388px', '340px'],
              );
            },
            reportKey: 'fiat_filter_popup_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(popup.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('fiat_filter_popup'));

    testWidgets('payment_method_sheet',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-payment-sheet-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildPaymentMethodSheetHtml(groupCount: 4, rowsPerGroup: 9),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element sheet = prepared.getElementById('sheet');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['payment_method_sheet_meta'] = <String, dynamic>{
        'groupCount': 4,
        'rowsPerGroup': 9,
        'mutationIterations': 36,
        'layoutMode': 'bottom-sheet-grouped-payment-list',
      };

      await _runPaymentMethodSheetLoop(
        prepared,
        mutationIterations: 10,
        widths: const <String>['378px', '342px', '312px', '356px'],
      );

      binding.reportData!['payment_method_sheet_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _paymentMethodSheetProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runPaymentMethodSheetLoop(
                prepared,
                mutationIterations: 36,
                widths: const <String>['378px', '342px', '312px', '356px'],
              );
            },
            reportKey: 'payment_method_sheet_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(sheet.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('payment_method_sheet'));

    testWidgets('payment_method_bottom_sheet',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-payment-bottom-sheet-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildPaymentMethodBottomSheetHtml(
          groupCount: 4,
          rowsPerGroup: 9,
        ),
      );

      await _pumpFrames(tester, 8);

      final dom.Element host = prepared.getElementById('host');
      final dom.Element sheet = prepared.getElementById('sheet');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['payment_method_bottom_sheet_meta'] =
          <String, dynamic>{
        'groupCount': 4,
        'rowsPerGroup': 9,
        'mutationIterations': 36,
        'layoutMode': 'flutter-bottom-sheet-grouped-payment-list',
      };

      await _runPaymentMethodSheetLoop(
        prepared,
        mutationIterations: 10,
        widths: const <String>['378px', '342px', '312px', '356px'],
      );

      binding.reportData!['payment_method_bottom_sheet_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _paymentMethodBottomSheetProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runPaymentMethodSheetLoop(
                prepared,
                mutationIterations: 36,
                widths: const <String>['378px', '342px', '312px', '356px'],
              );
            },
            reportKey: 'payment_method_bottom_sheet_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(sheet.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('payment_method_bottom_sheet'));

    testWidgets('payment_method_fastpath_sheet',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-payment-fastpath-sheet-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildPaymentMethodFastPathSheetHtml(
          groupCount: 4,
          rowsPerGroup: 10,
        ),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element sheet = prepared.getElementById('sheet');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['payment_method_fastpath_sheet_meta'] =
          <String, dynamic>{
        'groupCount': 4,
        'rowsPerGroup': 10,
        'mutationIterations': 36,
        'layoutMode': 'strict-fastpath-payment-sheet',
      };

      await _runPaymentMethodSheetLoop(
        prepared,
        mutationIterations: 10,
        widths: const <String>['378px', '342px', '312px', '356px'],
      );

      binding.reportData!['payment_method_fastpath_sheet_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _paymentMethodFastPathSheetProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runPaymentMethodSheetLoop(
                prepared,
                mutationIterations: 36,
                widths: const <String>['378px', '342px', '312px', '356px'],
              );
            },
            reportKey: 'payment_method_fastpath_sheet_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(sheet.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('payment_method_fastpath_sheet'));

    testWidgets('payment_method_bottom_sheet_tight',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-payment-bottom-sheet-tight-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildPaymentMethodBottomSheetTightHtml(
          groupCount: 4,
          rowsPerGroup: 9,
        ),
      );

      await prepared.evaluate(
        '''
(() => {
  const rebuild = (id, tag) => {
    const oldNode = document.getElementById(id);
    if (!oldNode) return null;
    const parent = oldNode.parentNode;
    if (!parent) return oldNode;
    const replacement = document.createElement(tag);
    replacement.id = oldNode.id;
    replacement.className = oldNode.className;
    const attrs = oldNode.getAttributeNames ? oldNode.getAttributeNames() : [];
    for (const name of attrs) {
      if (name !== 'id' && name !== 'class') {
        replacement.setAttribute(name, oldNode.getAttribute(name));
      }
    }
    while (oldNode.firstChild) {
      replacement.appendChild(oldNode.firstChild);
    }
    parent.replaceChild(replacement, oldNode);
    return replacement;
  };

  rebuild('sheet-popup-item', 'flutter-popup-item');
  const sheet = rebuild('payment-sheet', 'flutter-bottom-sheet');
  if (sheet && typeof sheet.open === 'function') {
    sheet.open();
  }
})();
''',
      );
      await _pumpFrames(tester, 18);

      final dom.Element host = prepared.getElementById('host');
      final dom.Element sheet = prepared.getElementById('sheet');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['payment_method_bottom_sheet_tight_meta'] =
          <String, dynamic>{
        'groupCount': 4,
        'rowsPerGroup': 9,
        'mutationIterations': 36,
        'layoutMode': 'flutter-bottom-sheet-tight-payment-list',
      };

      await _runPaymentMethodSheetLoop(
        prepared,
        mutationIterations: 10,
        widths: const <String>['378px', '342px', '312px', '356px'],
      );

      binding.reportData!['payment_method_bottom_sheet_tight_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _paymentMethodBottomSheetTightProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runPaymentMethodSheetLoop(
                prepared,
                mutationIterations: 36,
                widths: const <String>['378px', '342px', '312px', '356px'],
              );
            },
            reportKey: 'payment_method_bottom_sheet_tight_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(sheet.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('payment_method_bottom_sheet_tight'));

    testWidgets('payment_method_picker_modal',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-payment-picker-modal-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildPaymentMethodPickerModalHtml(),
      );

      await prepared.evaluate(
        '''
(() => {
  const rebuild = (id, tag) => {
    const oldNode = document.getElementById(id);
    if (!oldNode) return null;
    const parent = oldNode.parentNode;
    if (!parent) return oldNode;
    const replacement = document.createElement(tag);
    replacement.id = oldNode.id;
    replacement.className = oldNode.className;
    const attrs = oldNode.getAttributeNames ? oldNode.getAttributeNames() : [];
    for (const name of attrs) {
      if (name !== 'id' && name !== 'class') {
        replacement.setAttribute(name, oldNode.getAttribute(name));
      }
    }
    while (oldNode.firstChild) {
      replacement.appendChild(oldNode.firstChild);
    }
    parent.replaceChild(replacement, oldNode);
    return replacement;
  };

  const portal = rebuild('sheet-root', 'flutter-portal-popup-item');
  const modal = rebuild('payment-modal', 'flutter-modal-popup');
  if (modal && typeof modal.show === 'function') {
    modal.show();
  }
})();
''',
      );
      await _pumpFrames(tester, 18);

      final dom.Element host = prepared.getElementById('host');
      final dom.Element sheet = prepared.getElementById('sheet-root');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['payment_method_picker_modal_meta'] =
          <String, dynamic>{
        'sectionCount': 2,
        'cardCount': 4,
        'mutationIterations': 36,
        'layoutMode': 'widget-backed-bottom-sheet-payment-picker',
      };

      await _runPaymentMethodPickerModalLoop(
        prepared,
        mutationIterations: 10,
        widths: const <String>['378px', '346px', '320px', '356px'],
      );

      binding.reportData!['payment_method_picker_modal_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _paymentMethodPickerModalProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runPaymentMethodPickerModalLoop(
                prepared,
                mutationIterations: 36,
                widths: const <String>['378px', '346px', '320px', '356px'],
              );
            },
            reportKey: 'payment_method_picker_modal_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(sheet.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('payment_method_picker_modal'));

    testWidgets('payment_method_otc_source_sheet',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-payment-otc-source-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildPaymentMethodOtcSourceSheetHtml(
          sectionCount: 1,
          cardsPerSection: 5,
          accountsPerCard: 3,
        ),
      );

      await prepared.evaluate(
        '''
(() => {
  const rebuild = (id, tag) => {
    const oldNode = document.getElementById(id);
    if (!oldNode) return null;
    const parent = oldNode.parentNode;
    if (!parent) return oldNode;
    const replacement = document.createElement(tag);
    replacement.id = oldNode.id;
    replacement.className = oldNode.className;
    const attrs = oldNode.getAttributeNames ? oldNode.getAttributeNames() : [];
    for (const name of attrs) {
      if (name !== 'id' && name !== 'class') {
        replacement.setAttribute(name, oldNode.getAttribute(name));
      }
    }
    while (oldNode.firstChild) {
      replacement.appendChild(oldNode.firstChild);
    }
    parent.replaceChild(replacement, oldNode);
    return replacement;
  };

  rebuild('sheet-popup-item', 'flutter-popup-item');
  const sheet = rebuild('payment-sheet', 'flutter-bottom-sheet');
  if (sheet && typeof sheet.open === 'function') {
    sheet.open();
  }
})();
''',
      );
      await _pumpFrames(tester, 18);

      final dom.Element host = prepared.getElementById('host');
      final dom.Element sheet = prepared.getElementById('sheet-root');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['payment_method_otc_source_sheet_meta'] =
          <String, dynamic>{
        'sectionCount': 1,
        'cardsPerSection': 5,
        'accountsPerCard': 3,
        'mutationIterations': 4,
        'layoutMode': 'otc-payment-method-item-cardoption-bottom-sheet',
      };

      await _runPaymentMethodOtcSourceSheetLoop(
        prepared,
        mutationIterations: 1,
        widths: const <String>['378px', '344px', '316px', '356px'],
      );

      binding.reportData!['payment_method_otc_source_sheet_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _paymentMethodOtcSourceSheetProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runPaymentMethodOtcSourceSheetLoop(
                prepared,
                mutationIterations: 4,
                widths: const <String>['378px', '344px', '316px', '356px'],
              );
            },
            reportKey: 'payment_method_otc_source_sheet_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(sheet.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('payment_method_otc_source_sheet'));

    testWidgets('flex_inline_layout',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-flex-inline-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildFlexInlineLayoutHtml(cardCount: 48),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element board = prepared.getElementById('board');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['flex_inline_layout_meta'] = <String, dynamic>{
        'cardCount': 48,
        'mutationIterations': 32,
        'styleMutationPhases': 4,
        'layoutMode': 'mixed-fastpath-and-runmetrics-nowrap',
      };

      await _runFlexInlineLayoutLoop(
        prepared,
        mutationIterations: 10,
        widths: const <String>['360px', '312px', '280px', '336px'],
      );

      binding.reportData!['flex_inline_layout_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _flexInlineLayoutProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runFlexInlineLayoutLoop(
                prepared,
                mutationIterations: 32,
                widths: const <String>['360px', '312px', '280px', '336px'],
              );
            },
            reportKey: 'flex_inline_layout_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(board.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('flex_inline_layout'));

    testWidgets('flex_adjust_fastpath',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-flex-adjust-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildFlexAdjustFastPathHtml(cardCount: 48),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element board = prepared.getElementById('board');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['flex_adjust_fastpath_meta'] = <String, dynamic>{
        'cardCount': 48,
        'mutationIterations': 56,
        'styleMutationPhases': 4,
        'layoutMode': 'adjust-fastpath-heavy-inline-width-mutations',
      };

      await _runFlexRunMetricsDenseLoop(
        prepared,
        mutationIterations: 14,
        widths: const <String>['432px', '388px', '352px', '408px'],
      );

      binding.reportData!['flex_adjust_fastpath_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _flexAdjustFastPathProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runFlexRunMetricsDenseLoop(
                prepared,
                mutationIterations: 56,
                widths: const <String>['432px', '388px', '352px', '408px'],
              );
            },
            reportKey: 'flex_adjust_fastpath_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(board.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('flex_adjust_fastpath'));

    testWidgets('flex_nested_group_fastpath',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-flex-nested-group-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildFlexNestedGroupFastPathHtml(cardCount: 56),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element board = prepared.getElementById('board');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['flex_nested_group_fastpath_meta'] =
          <String, dynamic>{
        'cardCount': 56,
        'mutationIterations': 56,
        'styleMutationPhases': 4,
        'layoutMode': 'nested-tight-group-fastpath-heavy-nowrap',
      };

      await _runFlexAdjustFastPathLoop(
        prepared,
        mutationIterations: 14,
        widths: const <String>['432px', '388px', '352px', '408px'],
      );

      binding.reportData!['flex_nested_group_fastpath_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _flexNestedGroupFastPathProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runFlexAdjustFastPathLoop(
                prepared,
                mutationIterations: 56,
                widths: const <String>['432px', '388px', '352px', '408px'],
              );
            },
            reportKey: 'flex_nested_group_fastpath_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(board.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('flex_nested_group_fastpath'));

    testWidgets('flex_runmetrics_dense',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-flex-runmetrics-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildFlexRunMetricsDenseHtml(cardCount: 60),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element board = prepared.getElementById('board');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['flex_runmetrics_dense_meta'] = <String, dynamic>{
        'cardCount': 60,
        'mutationIterations': 56,
        'styleMutationPhases': 4,
        'layoutMode': 'dense-runmetrics-rows-nowrap',
      };

      await _runFlexAdjustFastPathLoop(
        prepared,
        mutationIterations: 14,
        widths: const <String>['372px', '322px', '286px', '344px'],
      );

      binding.reportData!['flex_runmetrics_dense_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _flexRunMetricsDenseProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runFlexAdjustFastPathLoop(
                prepared,
                mutationIterations: 56,
                widths: const <String>['372px', '322px', '286px', '344px'],
              );
            },
            reportKey: 'flex_runmetrics_dense_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(board.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('flex_runmetrics_dense'));

    testWidgets('flex_tight_fastpath_dense',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-flex-tight-fastpath-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildFlexTightFastPathDenseHtml(cardCount: 60),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element board = prepared.getElementById('board');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['flex_tight_fastpath_dense_meta'] =
          <String, dynamic>{
        'cardCount': 60,
        'mutationIterations': 56,
        'styleMutationPhases': 4,
        'layoutMode': 'tight-fastpath-dense-rows-nowrap',
      };

      await _runFlexTightFastPathDenseLoop(
        prepared,
        mutationIterations: 14,
        widths: const <String>['372px', '322px', '286px', '344px'],
      );

      binding.reportData!['flex_tight_fastpath_dense_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _flexTightFastPathDenseProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runFlexTightFastPathDenseLoop(
                prepared,
                mutationIterations: 56,
                widths: const <String>['372px', '322px', '286px', '344px'],
              );
            },
            reportKey: 'flex_tight_fastpath_dense_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(board.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('flex_tight_fastpath_dense'));

    testWidgets('flex_hybrid_fastpath_dense',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-flex-hybrid-fastpath-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildFlexHybridFastPathDenseHtml(cardCount: 60),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element board = prepared.getElementById('board');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['flex_hybrid_fastpath_dense_meta'] =
          <String, dynamic>{
        'cardCount': 60,
        'mutationIterations': 56,
        'styleMutationPhases': 4,
        'layoutMode': 'hybrid-dense-runmetrics-tight-widget-rows-nowrap',
      };

      await _runFlexHybridFastPathDenseLoop(
        prepared,
        mutationIterations: 14,
        widths: const <String>['372px', '322px', '286px', '344px'],
      );

      binding.reportData!['flex_hybrid_fastpath_dense_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _flexHybridFastPathDenseProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runFlexHybridFastPathDenseLoop(
                prepared,
                mutationIterations: 56,
                widths: const <String>['372px', '322px', '286px', '344px'],
              );
            },
            reportKey: 'flex_hybrid_fastpath_dense_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(board.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('flex_hybrid_fastpath_dense'));

    testWidgets('flex_adjust_widget_dense',
        (WidgetTester tester) async {
      final _PreparedProfileCase prepared = await _prepareProfileCase(
        tester,
        controllerName:
            'profile-flex-adjust-widget-${DateTime.now().millisecondsSinceEpoch}',
        html: _buildFlexAdjustWidgetDenseHtml(cardCount: 56),
      );

      final dom.Element host = prepared.getElementById('host');
      final dom.Element board = prepared.getElementById('board');

      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['flex_adjust_widget_dense_meta'] = <String, dynamic>{
        'cardCount': 56,
        'mutationIterations': 56,
        'styleMutationPhases': 4,
        'layoutMode': 'widget-dense-runmetrics-and-adjust-nowrap',
      };

      await _runFlexAdjustWidgetDenseLoop(
        prepared,
        mutationIterations: 14,
        widths: const <String>['384px', '336px', '304px', '356px'],
      );

      binding.reportData!['flex_adjust_widget_dense_cpu_samples'] =
          await _captureCpuSamples(
        userTag: _flexAdjustWidgetDenseProfileTag,
        action: () async {
          await binding.traceAction(
            () async {
              await _runFlexAdjustWidgetDenseLoop(
                prepared,
                mutationIterations: 56,
                widths: const <String>['384px', '336px', '304px', '356px'],
              );
            },
            reportKey: 'flex_adjust_widget_dense_timeline',
          );
        },
      );

      expect(host.getBoundingClientRect().width, greaterThan(0));
      expect(board.getBoundingClientRect().height, greaterThan(0));
    }, skip: !_shouldRunProfileCase('flex_adjust_widget_dense'));
  });
}

bool _shouldRunProfileCase(String caseId) {
  final String trimmedFilter = _profileCaseFilter.trim();
  if (trimmedFilter.isEmpty) {
    return true;
  }

  final Set<String> enabledCaseIds = trimmedFilter
      .split(',')
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .toSet();
  return enabledCaseIds.contains(caseId);
}

Future<Map<String, dynamic>> _captureCpuSamples({
  required Future<void> Function() action,
  required developer.UserTag userTag,
}) async {
  if (_shouldCaptureCpuSamplesOnDriverSide()) {
    final developer.UserTag previousTag = userTag.makeCurrent();
    try {
      await action();
    } finally {
      previousTag.makeCurrent();
    }

    return <String, dynamic>{
      'captureMode': 'driver',
      'profileLabel': userTag.label,
    };
  }

  final developer.ServiceProtocolInfo info = await developer.Service.getInfo();
  final Uri? serviceUri = info.serverUri;
  if (serviceUri == null) {
    throw StateError('VM service URI is unavailable.');
  }

  // ignore: deprecated_member_use
  final String? isolateId = developer.Service.getIsolateID(Isolate.current);
  if (isolateId == null) {
    throw StateError('Current isolate is not visible to the VM service.');
  }

  final String vmServiceAddress =
      'ws://localhost:${serviceUri.port}${serviceUri.path}ws';
  final vm.VmService service = await vmServiceConnectUri(vmServiceAddress);
  try {
    final int startMicros = (await service.getVMTimelineMicros()).timestamp!;
    final developer.UserTag previousTag = userTag.makeCurrent();
    try {
      await action();
    } finally {
      previousTag.makeCurrent();
    }

    final int endMicros = (await service.getVMTimelineMicros()).timestamp!;
    final int timeExtentMicros =
        endMicros > startMicros ? endMicros - startMicros : 1;
    final vm.CpuSamples samples =
        await service.getCpuSamples(isolateId, startMicros, timeExtentMicros);

    return <String, dynamic>{
      'profileLabel': userTag.label,
      'isolateId': isolateId,
      'timeOriginMicros': startMicros,
      'timeExtentMicros': timeExtentMicros,
      'samples': samples.toJson(),
    };
  } finally {
    await service.dispose();
  }
}

bool _shouldCaptureCpuSamplesOnDriverSide() {
  return Platform.isAndroid || Platform.isIOS;
}

Future<void> _persistProfileArtifacts(Map<String, dynamic>? data) async {
  if (data == null || data.isEmpty) {
    return;
  }

  final Directory outputDirectory = Directory(_profileArtifactsDirectoryPath())
    ..createSync(recursive: true);

  final Map<String, dynamic> response = Map<String, dynamic>.from(data);
  final Map<String, dynamic> manifest = <String, dynamic>{};

  await _writeProfileJson(
    outputDirectory,
    response,
    outputFilename: 'all_cases',
  );

  for (final MapEntry<String, dynamic> entry in response.entries) {
    if ((entry.key.endsWith('_timeline') ||
            entry.key.endsWith('_cpu_samples')) &&
        entry.value is Map) {
      await _writeProfileJson(
        outputDirectory,
        Map<String, dynamic>.from(entry.value as Map),
        outputFilename: entry.key,
      );
      manifest[entry.key] = <String, dynamic>{
        'path': path.join(outputDirectory.path, '${entry.key}.json'),
      };
    } else {
      manifest[entry.key] = entry.value;
    }
  }

  await _writeProfileJson(
    outputDirectory,
    manifest,
    outputFilename: 'manifest',
  );
}

Future<void> _writeProfileJson(
  Directory outputDirectory,
  Object data, {
  required String outputFilename,
}) async {
  final File file = File(
    path.join(outputDirectory.path, '$outputFilename.json'),
  );
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(data),
  );
}

Future<void> _configureProfileTestEnvironment() async {
  NavigatorModule.setCustomUserAgent('webf/profile-tests');

  final String? externalBridgePath =
      Platform.environment['WEBF_PROFILE_EXTERNAL_BRIDGE_PATH'];
  if (externalBridgePath != null && externalBridgePath.isNotEmpty) {
    // The macOS test app already embeds libwebf.dylib. Forcing another path
    // here loads a second copy of the bridge and splits bridge globals/TLS.
    WebFDynamicLibrary.dynamicLibraryPath = path.normalize(externalBridgePath);
  }

  final Directory tempDirectory = Directory(_profileTempDirectoryPath())
    ..createSync(recursive: true);

  final MethodChannel webfChannel = getWebFMethodChannel();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    webfChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return tempDirectory.path;
      }
      throw FlutterError('Not implemented for method ${methodCall.method}.');
    },
  );

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    pathProviderChannel,
    (MethodCall methodCall) async {
      if (methodCall.method == 'getTemporaryDirectory') {
        return tempDirectory.path;
      }
      throw FlutterError('Not implemented for method ${methodCall.method}.');
    },
  );
}

String _profileArtifactsDirectoryPath() {
  return path.join(_profileFilesystemBasePath(), 'build', 'profile_hotspots');
}

String _profileTempDirectoryPath() {
  return path.join(_profileFilesystemBasePath(), 'build', 'profile_test_temp');
}

String _profileFilesystemBasePath() {
  if (Platform.isAndroid || Platform.isIOS) {
    return path.join(Directory.systemTemp.path, 'webf_profile_tests');
  }
  return Directory.current.path;
}

Future<_PreparedProfileCase> _prepareProfileCase(
  WidgetTester tester, {
  required String controllerName,
  required String html,
  double viewportWidth = 390,
  double viewportHeight = 844,
}) async {
  tester.view.physicalSize = ui.Size(viewportWidth, viewportHeight);
  tester.view.devicePixelRatio = 1.0;

  WebFController? controller;
  await tester.runAsync(() async {
    controller = await WebFControllerManager.instance.addWithPreload(
      name: controllerName,
      createController: () => WebFController(
        viewportWidth: viewportWidth,
        viewportHeight: viewportHeight,
      ),
      bundle: WebFBundle.fromContent(
        html,
        url: 'test://$controllerName/',
        contentType: htmlContentType,
      ),
    );
    await controller!.controlledInitCompleter.future;
  });

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WebF.fromControllerName(controllerName: controllerName),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));

  await tester.runAsync(() async {
    await controller!.controllerPreloadingCompleter.future;
    await Future.wait<void>(<Future<void>>[
      controller!.controllerOnDOMContentLoadedCompleter.future,
      controller!.viewportLayoutCompleter.future,
    ]);
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));

  return _PreparedProfileCase(
    controller: controller!,
    tester: tester,
  );
}

Future<void> _toggleWidths(
  _PreparedProfileCase prepared,
  String elementId, {
  required List<String> widths,
  required int iterations,
}) async {
  for (int i = 0; i < iterations; i++) {
    final String width = widths[i % widths.length];
    await prepared.evaluate(
      'document.getElementById(${jsonEncode(elementId)}).style.width = '
      '${jsonEncode(width)};',
    );
    await _pumpFrames(prepared.tester, 2);
  }
}

Future<void> _runOpacityCycle(
  _PreparedProfileCase prepared,
  String elementId, {
  required int forwardFrames,
  required int reverseFrames,
}) async {
  await prepared.evaluate(
    'document.getElementById(${jsonEncode(elementId)}).className = "dim";',
  );
  await _pumpFrames(prepared.tester, forwardFrames);

  await prepared.evaluate(
    'document.getElementById(${jsonEncode(elementId)}).className = "";',
  );
  await _pumpFrames(prepared.tester, reverseFrames);
}

Future<void> _runParagraphRebuildLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element paragraph = prepared.getElementById('paragraph');
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;

    paragraph.setInlineStyle('width', widths[phase]);
    paragraph.setInlineStyle('fontSize', phase.isEven ? '16px' : '17px');
    paragraph.setInlineStyle('lineHeight', phase >= 2 ? '24px' : '22px');
    paragraph.setInlineStyle('letterSpacing', phase == 1 ? '0.2px' : '0px');
    paragraph.style.flushPendingProperties();
    paragraph.className = 'phase-$phase';

    paragraph.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 2);
  }
}

Future<void> _runFiatFilterPopupLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element popup = prepared.getElementById('popup');
  final dom.Element trigger = prepared.getElementById('trigger');
  final dom.Element triggerValue = prepared.getElementById('trigger-value');
  final List<dynamic> options = popup.querySelectorAll(['.fiat-option']);
  final List<dynamic> icons = popup.querySelectorAll(['.fiat-icon']);
  final List<dynamic> copies = popup.querySelectorAll(['.fiat-copy']);
  final List<dynamic> codes = popup.querySelectorAll(['.fiat-code']);
  final List<dynamic> names = popup.querySelectorAll(['.fiat-name']);
  final List<dynamic> badges = popup.querySelectorAll(['.fiat-badge']);
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px' : '8px');
    popup.setInlineStyle(
      'padding',
      phase == 1 ? '8px 10px' : (phase == 2 ? '10px 12px' : '9px 11px'),
    );
    popup.setInlineStyle('gap', phase == 2 ? '6px' : '8px');
    trigger.setInlineStyle(
      'padding',
      phase == 3 ? '10px 11px' : (phase == 1 ? '8px 10px' : '9px 11px'),
    );
    triggerValue.setInlineStyle(
      'letterSpacing',
      phase == 2 ? '0.18px' : (phase == 1 ? '0.08px' : '0px'),
    );

    final int optionGap = phase == 2 ? 10 : 8;
    final int iconSize = phase == 1 ? 26 : (phase == 2 ? 30 : 28);
    final int copyWidth =
        phase == 0 ? 208 : (phase == 1 ? 192 : (phase == 2 ? 220 : 198));
    final int badgeWidth = phase == 2 ? 44 : (phase == 1 ? 36 : 40);
    final String codeSpacing =
        phase == 2 ? '0.24px' : (phase == 1 ? '0.10px' : '0px');
    final String nameSpacing = phase == 3 ? '0.18px' : '0px';

    for (int index = 0; index < options.length; index++) {
      final dom.Element element = options[index] as dom.Element;
      final bool selected = index % 8 == phase;
      element.className = selected ? 'fiat-option selected' : 'fiat-option';
      element.setInlineStyle('gap', '${optionGap}px');
      element.setInlineStyle(
        'padding',
        phase == 1 ? '8px 6px' : (phase == 2 ? '10px 8px' : '9px 7px'),
      );
    }
    for (final dynamic node in icons) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('width', '${iconSize}px');
      element.setInlineStyle('height', '${iconSize}px');
    }
    for (int index = 0; index < copies.length; index++) {
      final dom.Element element = copies[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 10 : -8);
      element.setInlineStyle('flexBasis', '${copyWidth + variance}px');
    }
    for (final dynamic node in codes) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', codeSpacing);
      element.setInlineStyle('paddingBottom', phase == 1 ? '2px' : '3px');
    }
    for (final dynamic node in names) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', nameSpacing);
      element.setInlineStyle('wordSpacing', phase == 2 ? '0.28px' : '0px');
    }
    for (final dynamic node in badges) {
      (node as dom.Element).setInlineStyle('width', '${badgeWidth}px');
    }

    popup.style.flushPendingProperties();
    popup.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 3);
  }
}

Future<void> _runPaymentMethodSheetLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element sheet = prepared.getElementById('sheet');
  final dom.Element? popupItem = prepared.controller.view.document.getElementById(
    <String>['sheet-popup-item'],
  );
  final List<dynamic> groups = sheet.querySelectorAll(['.group']);
  final List<dynamic> rows = sheet.querySelectorAll(['.payment-row']);
  final List<dynamic> icons = sheet.querySelectorAll(['.payment-icon']);
  final List<dynamic> statuses = sheet.querySelectorAll(['.payment-status']);
  final List<dynamic> copies = sheet.querySelectorAll(['.payment-copy']);
  final List<dynamic> titles = sheet.querySelectorAll(['.payment-title']);
  final List<dynamic> subtitles = sheet.querySelectorAll(['.payment-subtitle']);
  final List<dynamic> badgeRows = sheet.querySelectorAll(['.payment-badges']);
  final List<dynamic> chips = sheet.querySelectorAll(['.payment-chip']);
  final List<dynamic> rates = sheet.querySelectorAll(['.payment-rate']);
  final List<dynamic> routes = sheet.querySelectorAll(['.payment-route']);
  final List<dynamic> tails = sheet.querySelectorAll(['.payment-tail']);
  final List<dynamic> showMoreRows = sheet.querySelectorAll(['.show-more-row']);
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px 0 0' : '8px 0 0');
    if (popupItem != null) {
      popupItem.setInlineStyle(
        'width',
        phase == 0 ? '362px' : (phase == 1 ? '336px' : (phase == 2 ? '308px' : '348px')),
      );
      popupItem.setInlineStyle(
        'padding',
        phase == 2 ? '0 0 3px' : (phase == 1 ? '0 0 1px' : '0'),
      );
      popupItem.setInlineStyle('boxSizing', 'border-box');
    }
    sheet.setInlineStyle(
      'padding',
      phase == 1 ? '15px 14px 18px' : (phase == 2 ? '17px 16px 20px' : '16px 15px 18px'),
    );
    sheet.setInlineStyle('gap', phase == 2 ? '20px' : '24px');

    final int rowGap = phase == 2 ? 10 : 8;
    final int rowPadding = phase == 1 ? 9 : 10;
    final int iconWidth = phase == 2 ? 38 : 34;
    final int statusWidth = phase == 3 ? 42 : 38;
    final int copyWidth =
        phase == 0 ? 188 : (phase == 1 ? 172 : (phase == 2 ? 204 : 180));
    final int rateWidth = phase == 2 ? 52 : 46;
    final int routeWidth = phase == 1 ? 78 : (phase == 2 ? 88 : 82);
    final int tailWidth = phase == 3 ? 26 : 22;
    final int chipWidth = phase == 2 ? 42 : (phase == 1 ? 34 : 38);
    final String titleSpacing =
        phase == 2 ? '0.18px' : (phase == 1 ? '0.08px' : '0px');
    final String subtitleSpacing = phase == 3 ? '0.14px' : '0px';

    for (int index = 0; index < groups.length; index++) {
      final dom.Element element = groups[index] as dom.Element;
      final bool expanded = (iteration + index) % 3 != 0;
      element.className = expanded ? 'group expanded' : 'group collapsed';
      element.setInlineStyle('gap', phase == 2 ? '10px' : '8px');
    }
    for (int index = 0; index < rows.length; index++) {
      final dom.Element element = rows[index] as dom.Element;
      final bool selected = (index + phase) % 7 == 0;
      final bool extra = element.getAttribute('data-extra') == 'true';
      final String selectionClass = selected ? ' selected' : '';
      element.className = extra
          ? 'payment-row extra$selectionClass'
          : 'payment-row$selectionClass';
      element.setInlineStyle('gap', '${rowGap}px');
      element.setInlineStyle('padding', '${rowPadding}px 0');
    }
    for (final dynamic node in icons) {
      (node as dom.Element).setInlineStyle('width', '${iconWidth}px');
    }
    for (final dynamic node in statuses) {
      (node as dom.Element).setInlineStyle('width', '${statusWidth}px');
    }
    for (int index = 0; index < copies.length; index++) {
      final dom.Element element = copies[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 10 : -8);
      element.setInlineStyle('width', '${copyWidth + variance}px');
    }
    for (final dynamic node in titles) {
      (node as dom.Element).setInlineStyle('letterSpacing', titleSpacing);
    }
    for (final dynamic node in subtitles) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', subtitleSpacing);
      element.setInlineStyle('wordSpacing', phase == 2 ? '0.24px' : '0px');
    }
    for (final dynamic node in badgeRows) {
      (node as dom.Element).setInlineStyle('gap', phase == 2 ? '5px' : '4px');
    }
    for (final dynamic node in chips) {
      (node as dom.Element).setInlineStyle('width', '${chipWidth}px');
    }
    for (final dynamic node in rates) {
      (node as dom.Element).setInlineStyle('width', '${rateWidth}px');
    }
    for (final dynamic node in routes) {
      (node as dom.Element).setInlineStyle('width', '${routeWidth}px');
    }
    for (final dynamic node in tails) {
      (node as dom.Element).setInlineStyle('width', '${tailWidth}px');
    }
    for (final dynamic node in showMoreRows) {
      (node as dom.Element).setInlineStyle(
        'paddingTop',
        phase == 1 ? '2px' : '0px',
      );
    }

    sheet.style.flushPendingProperties();
    sheet.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 3);
  }
}

Future<void> _runPaymentMethodPickerModalLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element summary = prepared.getElementById('summary-card');
  final dom.Element sheet = prepared.getElementById('sheet-root');
  final dom.Element secondarySection = prepared.getElementById('secondary-group');
  final List<dynamic> cards = sheet.querySelectorAll(['.method-card']);
  final List<dynamic> headers = sheet.querySelectorAll(['.method-header']);
  final List<dynamic> avatars = sheet.querySelectorAll(['.method-avatar']);
  final List<dynamic> copies = sheet.querySelectorAll(['.method-copy']);
  final List<dynamic> titles = sheet.querySelectorAll(['.method-title']);
  final List<dynamic> descriptions = sheet.querySelectorAll(['.method-desc']);
  final List<dynamic> prices = sheet.querySelectorAll(['.method-price']);
  final List<dynamic> tags = sheet.querySelectorAll(['.method-tag']);
  final List<dynamic> accountRows = sheet.querySelectorAll(['.account-row']);
  final List<dynamic> accountNames = sheet.querySelectorAll(['.account-name']);
  final List<dynamic> accountRadios = sheet.querySelectorAll(['.account-radio']);
  final List<dynamic> accountBadges = sheet.querySelectorAll(['.account-badge']);
  final List<dynamic> addRows = sheet.querySelectorAll(['.add-account']);
  final List<dynamic> showMoreRows = sheet.querySelectorAll(['.show-more-row']);
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px' : '8px');
    summary.setInlineStyle(
      'padding',
      phase == 1 ? '18px 16px' : (phase == 2 ? '20px 18px' : '19px 17px'),
    );
    sheet.setInlineStyle(
      'width',
      phase == 2 ? '336px' : (phase == 1 ? '352px' : '364px'),
    );
    sheet.setInlineStyle(
      'padding',
      phase == 2 ? '4px 0 6px' : (phase == 1 ? '2px 0 4px' : '3px 0 5px'),
    );

    final int avatarWidth = phase == 2 ? 36 : 32;
    final int copyWidth =
        phase == 0 ? 188 : (phase == 1 ? 172 : (phase == 2 ? 204 : 180));
    final int priceWidth = phase == 2 ? 70 : (phase == 1 ? 58 : 64);
    final int tagWidth = phase == 3 ? 78 : (phase == 1 ? 68 : 72);
    final int radioWidth = phase == 2 ? 16 : 14;
    final int badgeWidth = phase == 3 ? 46 : 40;
    final String titleSpacing =
        phase == 2 ? '0.14px' : (phase == 1 ? '0.08px' : '0px');
    final String descSpacing = phase == 3 ? '0.12px' : '0px';
    final String accountSpacing =
        phase == 2 ? '0.10px' : (phase == 1 ? '0.06px' : '0px');

    secondarySection.className = (iteration % 3 == 0)
        ? 'section secondary-group extra-hidden'
        : 'section secondary-group extra-visible';

    for (int index = 0; index < cards.length; index++) {
      final dom.Element element = cards[index] as dom.Element;
      final String method = element.getAttribute('data-method') ?? '';
      final bool selected = index == phase;
      final bool expandable = method != 'cvpay';
      final bool expanded = expandable && ((iteration + index) % 2 == 0);
      final String selectedClass = selected ? ' selected' : '';
      final String expandedClass = expanded ? ' expanded' : ' collapsed';
      element.className = 'method-card$selectedClass$expandedClass';
    }
    for (final dynamic node in headers) {
      (node as dom.Element).setInlineStyle('padding', phase == 1 ? '14px 14px' : '15px 16px');
    }
    for (final dynamic node in avatars) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('width', '${avatarWidth}px');
      element.setInlineStyle('height', '${avatarWidth}px');
    }
    for (int index = 0; index < copies.length; index++) {
      final dom.Element element = copies[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 10 : -8);
      element.setInlineStyle('width', '${copyWidth + variance}px');
    }
    for (final dynamic node in titles) {
      (node as dom.Element).setInlineStyle('letterSpacing', titleSpacing);
    }
    for (final dynamic node in descriptions) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', descSpacing);
      element.setInlineStyle('wordSpacing', phase == 2 ? '0.20px' : '0px');
    }
    for (final dynamic node in prices) {
      (node as dom.Element).setInlineStyle('width', '${priceWidth}px');
    }
    for (final dynamic node in tags) {
      (node as dom.Element).setInlineStyle('width', '${tagWidth}px');
    }
    for (final dynamic node in accountRows) {
      (node as dom.Element).setInlineStyle('gap', phase == 2 ? '10px' : '8px');
    }
    for (final dynamic node in accountNames) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', accountSpacing);
      element.setInlineStyle('wordSpacing', phase == 2 ? '0.18px' : '0px');
    }
    for (final dynamic node in accountRadios) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('width', '${radioWidth}px');
      element.setInlineStyle('height', '${radioWidth}px');
    }
    for (final dynamic node in accountBadges) {
      (node as dom.Element).setInlineStyle('width', '${badgeWidth}px');
    }
    for (final dynamic node in addRows) {
      (node as dom.Element).setInlineStyle('paddingTop', phase == 1 ? '10px' : '8px');
    }
    for (final dynamic node in showMoreRows) {
      (node as dom.Element).setInlineStyle('paddingTop', phase == 1 ? '4px' : '2px');
    }

    sheet.style.flushPendingProperties();
    sheet.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 3);
  }
}

Future<void> _runPaymentMethodOtcSourceSheetLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element sheet = prepared.getElementById('sheet-root');
  final dom.Element? popupItem = prepared.controller.view.document.getElementById(
    <String>['sheet-popup-item'],
  );
  final List<dynamic> sections = sheet.querySelectorAll(['.otc-section']);
  final List<dynamic> cards = sheet.querySelectorAll(['.otc-card']);
  final List<dynamic> headers = sheet.querySelectorAll(['.otc-card-header']);
  final List<dynamic> leadings = sheet.querySelectorAll(['.otc-card-leading']);
  final List<dynamic> copies = sheet.querySelectorAll(['.otc-card-copy']);
  final List<dynamic> nameRows = sheet.querySelectorAll(['.otc-card-name-row']);
  final List<dynamic> names = sheet.querySelectorAll(['.otc-card-name']);
  final List<dynamic> descriptions =
      sheet.querySelectorAll(['.otc-card-description']);
  final List<dynamic> prices = sheet.querySelectorAll(['.otc-card-price']);
  final List<dynamic> tags = sheet.querySelectorAll(['.otc-card-tag']);
  final List<dynamic> accountRows = sheet.querySelectorAll(['.otc-account-row']);
  final List<dynamic> accountBoxes =
      sheet.querySelectorAll(['.otc-account-box']);
  final List<dynamic> accountItems =
      sheet.querySelectorAll(['.otc-account-item']);
  final List<dynamic> accountMains =
      sheet.querySelectorAll(['.otc-account-main']);
  final List<dynamic> accountCopies =
      sheet.querySelectorAll(['.otc-account-copy']);
  final List<dynamic> accountNames =
      sheet.querySelectorAll(['.otc-account-name']);
  final List<dynamic> accountDescriptions =
      sheet.querySelectorAll(['.otc-account-description']);
  final List<dynamic> accountStatuses =
      sheet.querySelectorAll(['.otc-account-status']);
  final List<dynamic> accountDeletes =
      sheet.querySelectorAll(['.otc-account-delete']);
  final List<dynamic> addAccounts =
      sheet.querySelectorAll(['.otc-add-account']);
  final List<dynamic> showMoreRows =
      sheet.querySelectorAll(['.otc-show-more-row']);

  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px 0 0' : '8px 0 0');
    if (popupItem != null) {
      popupItem.setInlineStyle(
        'width',
        phase == 0 ? '366px' : (phase == 1 ? '338px' : (phase == 2 ? '306px' : '352px')),
      );
      popupItem.setInlineStyle(
        'padding',
        phase == 2 ? '0 0 3px' : (phase == 1 ? '0 0 1px' : '0'),
      );
      popupItem.setInlineStyle('boxSizing', 'border-box');
    }

    sheet.setInlineStyle(
      'padding',
      phase == 2 ? '16px 14px 22px' : (phase == 1 ? '15px 13px 20px' : '16px 15px 21px'),
    );
    sheet.setInlineStyle('gap', phase == 2 ? '22px' : '24px');

    final int headerPaddingInline = phase == 2 ? 11 : 12;
    final int headerPaddingBlock = phase == 1 ? 15 : 16;
    final int leadingGap = phase == 2 ? 10 : 8;
    final int copyWidth =
        phase == 0 ? 190 : (phase == 1 ? 176 : (phase == 2 ? 206 : 184));
    final int priceWidth = phase == 2 ? 74 : (phase == 1 ? 64 : 70);
    final int tagWidth = phase == 3 ? 82 : (phase == 1 ? 68 : 74);
    final int accountStatusWidth = phase == 2 ? 52 : 44;
    final int accountDeleteWidth = phase == 3 ? 26 : 22;
    final String nameSpacing =
        phase == 2 ? '0.14px' : (phase == 1 ? '0.08px' : '0px');
    final String descriptionSpacing = phase == 3 ? '0.12px' : '0px';
    final String accountNameSpacing =
        phase == 2 ? '0.10px' : (phase == 1 ? '0.05px' : '0px');

    for (int index = 0; index < sections.length; index++) {
      final dom.Element section = sections[index] as dom.Element;
      final bool expanded = (iteration + index) % 3 != 1;
      section.className = expanded ? 'otc-section expanded' : 'otc-section collapsed';
      section.setInlineStyle('gap', phase == 2 ? '11px' : '12px');
    }

    for (int index = 0; index < cards.length; index++) {
      final dom.Element card = cards[index] as dom.Element;
      final bool extra = card.getAttribute('data-extra') == 'true';
      final bool selected = (index + phase) % 5 == 0;
      final bool expanded = selected || (index + iteration) % 3 != 1;
      final bool disabled = (index + phase) % 7 == 3;
      final List<String> classNames = <String>['otc-card'];
      if (extra) {
        classNames.add('extra');
      }
      classNames.add(expanded ? 'expanded' : 'collapsed');
      if (selected) {
        classNames.add('selected');
      }
      if (disabled) {
        classNames.add('disabled');
      }
      card.className = classNames.join(' ');
      card.setInlineStyle('order', '${(index * 5 + phase * 3) % cards.length}');
    }

    for (final dynamic node in headers) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle(
        'padding',
        '${headerPaddingBlock}px ${headerPaddingInline}px',
      );
    }
    for (final dynamic node in leadings) {
      (node as dom.Element).setInlineStyle('gap', '${leadingGap}px');
    }
    for (int index = 0; index < copies.length; index++) {
      final dom.Element element = copies[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 10 : -8);
      element.setInlineStyle('width', '${copyWidth + variance}px');
    }
    for (final dynamic node in nameRows) {
      (node as dom.Element).setInlineStyle('gap', phase == 1 ? '10px' : '8px');
    }
    for (final dynamic node in names) {
      (node as dom.Element).setInlineStyle('letterSpacing', nameSpacing);
    }
    for (final dynamic node in descriptions) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', descriptionSpacing);
      element.setInlineStyle('wordSpacing', phase == 2 ? '0.20px' : '0px');
    }
    for (final dynamic node in prices) {
      (node as dom.Element).setInlineStyle('width', '${priceWidth}px');
    }
    for (final dynamic node in tags) {
      (node as dom.Element).setInlineStyle('width', '${tagWidth}px');
    }
    for (int index = 0; index < accountRows.length; index++) {
      final dom.Element row = accountRows[index] as dom.Element;
      final bool selected = (index + iteration) % 4 == 0;
      row.className = selected ? 'otc-account-row selected' : 'otc-account-row';
      row.setInlineStyle('paddingTop', phase == 1 ? '10px' : '8px');
    }
    for (final dynamic node in accountBoxes) {
      (node as dom.Element).setInlineStyle('width', 'calc(100% - 32px)');
    }
    for (final dynamic node in accountItems) {
      (node as dom.Element).setInlineStyle('gap', phase == 2 ? '10px' : '8px');
    }
    for (final dynamic node in accountMains) {
      (node as dom.Element).setInlineStyle('gap', phase == 1 ? '10px' : '8px');
    }
    for (int index = 0; index < accountCopies.length; index++) {
      final dom.Element element = accountCopies[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 6 : -6);
      element.setInlineStyle('paddingRight', '${phase == 2 ? 2 : 0}px');
      element.setInlineStyle('width', 'calc(100% - ${accountStatusWidth + accountDeleteWidth + 18 + variance}px)');
    }
    for (final dynamic node in accountNames) {
      (node as dom.Element).setInlineStyle('letterSpacing', accountNameSpacing);
    }
    for (final dynamic node in accountDescriptions) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', phase == 3 ? '0.10px' : '0px');
      element.setInlineStyle('wordSpacing', phase == 2 ? '0.18px' : '0px');
    }
    for (final dynamic node in accountStatuses) {
      (node as dom.Element).setInlineStyle('width', '${accountStatusWidth}px');
    }
    for (final dynamic node in accountDeletes) {
      (node as dom.Element).setInlineStyle('width', '${accountDeleteWidth}px');
    }
    for (final dynamic node in addAccounts) {
      (node as dom.Element).setInlineStyle(
        'minHeight',
        phase == 2 ? '50px' : '48px',
      );
    }
    for (final dynamic node in showMoreRows) {
      (node as dom.Element).setInlineStyle(
        'paddingTop',
        phase == 1 ? '3px' : '0px',
      );
    }

    sheet.style.flushPendingProperties();
    sheet.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 3);
  }
}

Future<void> _runFlexInlineLayoutLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element board = prepared.getElementById('board');
  final List<dynamic> fastlaneA = board.querySelectorAll(['.fastlane-a']);
  final List<dynamic> fastlaneB = board.querySelectorAll(['.fastlane-b']);
  final List<dynamic> fastlaneD = board.querySelectorAll(['.fastlane-d']);
  final List<dynamic> handoffA = board.querySelectorAll(['.handoff-a']);
  final List<dynamic> handoffD = board.querySelectorAll(['.handoff-d']);
  final List<dynamic> ribbonB = board.querySelectorAll(['.ribbon-b']);
  final List<dynamic> trailA = board.querySelectorAll(['.trail-a']);
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px' : '8px');
    board.className = 'phase-$phase';
    final String fastlaneAWidth =
        phase == 1 ? '58px' : (phase == 2 ? '56px' : (phase == 3 ? '60px' : '52px'));
    final String fastlaneBWidth =
        phase == 1 || phase == 3 ? '52px' : '48px';
    final String fastlaneDWidth = phase == 2 ? '50px' : '46px';
    final String handoffAWidth =
        phase == 1 || phase == 3 ? '54px' : '50px';
    final String handoffDWidth =
        phase == 3 ? '62px' : ((phase == 1 || phase == 2) ? '60px' : '56px');
    final String ribbonBWidth = phase == 1 ? '52px' : '48px';
    final String trailAWidth = phase == 3 ? '58px' : '54px';
    for (final dynamic node in fastlaneA) {
      (node as dom.Element).setInlineStyle('width', fastlaneAWidth);
    }
    for (final dynamic node in fastlaneB) {
      (node as dom.Element).setInlineStyle('width', fastlaneBWidth);
    }
    for (final dynamic node in fastlaneD) {
      (node as dom.Element).setInlineStyle('width', fastlaneDWidth);
    }
    for (final dynamic node in handoffA) {
      (node as dom.Element).setInlineStyle('width', handoffAWidth);
    }
    for (final dynamic node in handoffD) {
      (node as dom.Element).setInlineStyle('width', handoffDWidth);
    }
    for (final dynamic node in ribbonB) {
      (node as dom.Element).setInlineStyle('width', ribbonBWidth);
    }
    for (final dynamic node in trailA) {
      (node as dom.Element).setInlineStyle('width', trailAWidth);
    }
    board.setInlineStyle('letterSpacing', phase == 1 ? '0.12px' : '0px');
    board.setInlineStyle('wordSpacing', phase == 2 ? '0.35px' : '0px');
    board.style.flushPendingProperties();
    board.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 2);
  }
}

Future<void> _runFlexAdjustFastPathLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element board = prepared.getElementById('board');
  final List<dynamic> cards = board.querySelectorAll(['.card']);
  final List<dynamic> severities = board.querySelectorAll(['.severity']);
  final List<dynamic> lanes = board.querySelectorAll(['.lane']);
  final List<dynamic> badges = board.querySelectorAll(['.badge']);
  final List<dynamic> owners = board.querySelectorAll(['.owner']);
  final List<dynamic> etas = board.querySelectorAll(['.eta']);
  final List<dynamic> subtleChips = board.querySelectorAll(['.chip.subtle']);
  final List<dynamic> pickers = board.querySelectorAll(['.picker']);
  final List<dynamic> routeSelects = board.querySelectorAll(['.route-select']);
  final List<dynamic> miniActions = board.querySelectorAll(['.mini-action']);
  final List<dynamic> copyBoxes = board.querySelectorAll(['.copy-box']);
  final List<dynamic> noteBoxes = board.querySelectorAll(['.note-box']);
  final List<dynamic> packBoxes = board.querySelectorAll(['.pack-box']);
  final List<dynamic> groupBoxes = board.querySelectorAll(['.group-box']);
  final List<dynamic> segTags = board.querySelectorAll(['.seg-tag']);
  final List<dynamic> segCopies = board.querySelectorAll(['.seg-copy']);
  final List<dynamic> segNotes = board.querySelectorAll(['.seg-note']);
  final List<dynamic> segTails = board.querySelectorAll(['.seg-tail']);
  final List<dynamic> autoBodies = board.querySelectorAll(['.auto-copy']);
  final List<dynamic> autoNotes = board.querySelectorAll(['.auto-note']);
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px' : '8px');
    board.setInlineStyle('gap', phase == 2 ? '7px' : '8px');
    final int cardMinWidth =
        phase == 0 ? 144 : (phase == 1 ? 136 : (phase == 2 ? 152 : 140));
    final int cardMaxWidth =
        phase == 0 ? 170 : (phase == 1 ? 160 : (phase == 2 ? 178 : 166));
    final int severityWidth = phase == 2 ? 36 : 34;
    final int laneWidth = phase == 1 ? 46 : (phase == 2 ? 50 : 44);
    final int badgeWidth = phase == 3 ? 38 : 36;
    final int ownerWidth = phase == 2 ? 54 : 50;
    final int etaWidth = phase == 1 ? 44 : 42;
    final int subtleChipWidth = phase == 3 ? 38 : 34;
    final int pickerWidth = phase == 2 ? 78 : (phase == 1 ? 68 : 72);
    final int routeSelectWidth = phase == 3 ? 74 : (phase == 2 ? 70 : 66);
    final int miniActionWidth = phase == 1 ? 42 : 38;
    final int copyBoxWidth = phase == 2 ? 76 : (phase == 1 ? 62 : (phase == 3 ? 70 : 66));
    final int noteBoxWidth = phase == 3 ? 60 : (phase == 2 ? 56 : 52);
    final int packBoxWidth = phase == 2 ? 42 : (phase == 1 ? 32 : 36);
    final int groupBoxWidth = phase == 2 ? 78 : (phase == 1 ? 64 : (phase == 3 ? 72 : 68));
    final int segTagWidth = phase == 1 ? 16 : 14;
    final int segCopyWidth = phase == 2 ? 40 : (phase == 1 ? 32 : 36);
    final int segNoteWidth = phase == 3 ? 32 : (phase == 2 ? 30 : 28);
    final int segTailWidth = phase == 2 ? 14 : 12;
    final String bodySpacing = phase == 1 ? '0.14px' : (phase == 2 ? '0.28px' : '0px');
    final String noteSpacing = phase == 3 ? '0.22px' : '0px';
    final String packGap = phase == 2 ? '3px' : '2px';
    final String groupGap = phase == 2 ? '3px' : '2px';
    for (int index = 0; index < cards.length; index++) {
      final dom.Element element = cards[index] as dom.Element;
      final int variance = index % 3 == 0 ? 0 : (index % 3 == 1 ? -4 : 4);
      element.setInlineStyle('minWidth', '${cardMinWidth + variance}px');
      element.setInlineStyle('maxWidth', '${cardMaxWidth + variance}px');
    }
    for (final dynamic node in severities) {
      (node as dom.Element).setInlineStyle('width', '${severityWidth}px');
    }
    for (final dynamic node in lanes) {
      (node as dom.Element).setInlineStyle('width', '${laneWidth}px');
    }
    for (final dynamic node in badges) {
      (node as dom.Element).setInlineStyle('width', '${badgeWidth}px');
    }
    for (final dynamic node in owners) {
      (node as dom.Element).setInlineStyle('width', '${ownerWidth}px');
    }
    for (final dynamic node in etas) {
      (node as dom.Element).setInlineStyle('width', '${etaWidth}px');
    }
    for (final dynamic node in subtleChips) {
      (node as dom.Element).setInlineStyle('width', '${subtleChipWidth}px');
    }
    for (final dynamic node in pickers) {
      (node as dom.Element).setInlineStyle('width', '${pickerWidth}px');
    }
    for (final dynamic node in routeSelects) {
      (node as dom.Element).setInlineStyle('width', '${routeSelectWidth}px');
    }
    for (final dynamic node in miniActions) {
      (node as dom.Element).setInlineStyle('width', '${miniActionWidth}px');
    }
    for (int index = 0; index < copyBoxes.length; index++) {
      final dom.Element element = copyBoxes[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 6 : -4);
      element.setInlineStyle('width', '${copyBoxWidth + variance}px');
      element.setInlineStyle('letterSpacing', bodySpacing);
    }
    for (int index = 0; index < noteBoxes.length; index++) {
      final dom.Element element = noteBoxes[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 4 : -2);
      element.setInlineStyle('width', '${noteBoxWidth + variance}px');
      element.setInlineStyle('letterSpacing', noteSpacing);
    }
    for (int index = 0; index < packBoxes.length; index++) {
      final dom.Element element = packBoxes[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 2 : -2);
      element.setInlineStyle('width', '${packBoxWidth + variance}px');
      element.setInlineStyle('gap', packGap);
    }
    for (int index = 0; index < groupBoxes.length; index++) {
      final dom.Element element = groupBoxes[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 4 : -2);
      element.setInlineStyle('width', '${groupBoxWidth + variance}px');
      element.setInlineStyle('gap', groupGap);
    }
    for (int index = 0; index < segTags.length; index++) {
      final dom.Element element = segTags[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 2 : 0);
      element.setInlineStyle('width', '${segTagWidth + variance}px');
    }
    for (int index = 0; index < segCopies.length; index++) {
      final dom.Element element = segCopies[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 4 : -2);
      element.setInlineStyle('width', '${segCopyWidth + variance}px');
      element.setInlineStyle('letterSpacing', bodySpacing);
    }
    for (int index = 0; index < segNotes.length; index++) {
      final dom.Element element = segNotes[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 2 : -2);
      element.setInlineStyle('width', '${segNoteWidth + variance}px');
      element.setInlineStyle('letterSpacing', noteSpacing);
    }
    for (final dynamic node in segTails) {
      (node as dom.Element).setInlineStyle('width', '${segTailWidth}px');
    }
    for (final dynamic node in autoBodies) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', bodySpacing);
      element.setInlineStyle('wordSpacing', phase == 2 ? '0.35px' : '0px');
    }
    for (final dynamic node in autoNotes) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', noteSpacing);
    }
    board.style.flushPendingProperties();
    board.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 3);
  }
}

Future<void> _runFlexRunMetricsDenseLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element board = prepared.getElementById('board');
  final List<dynamic> cards = board.querySelectorAll(['.card']);
  final List<dynamic> severities = board.querySelectorAll(['.severity']);
  final List<dynamic> lanes = board.querySelectorAll(['.lane']);
  final List<dynamic> badges = board.querySelectorAll(['.badge']);
  final List<dynamic> owners = board.querySelectorAll(['.owner']);
  final List<dynamic> etas = board.querySelectorAll(['.eta']);
  final List<dynamic> subtleChips = board.querySelectorAll(['.chip.subtle']);
  final List<dynamic> autoBodies = board.querySelectorAll(['.auto-copy']);
  final List<dynamic> autoNotes = board.querySelectorAll(['.auto-note']);
  final List<dynamic> autoPacks = board.querySelectorAll(['.auto-pack']);
  final List<dynamic> toolInputs = board.querySelectorAll(['.tool-input']);
  final List<dynamic> toolSelects = board.querySelectorAll(['.tool-select']);
  final List<dynamic> miniActions = board.querySelectorAll(['.mini-action']);
  final List<dynamic> summaryCopies = board.querySelectorAll(['.summary-copy']);
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px' : '8px');
    board.setInlineStyle('gap', phase == 2 ? '7px' : '8px');
    final int cardMinWidth =
        phase == 0 ? 168 : (phase == 1 ? 160 : (phase == 2 ? 176 : 164));
    final int cardMaxWidth =
        phase == 0 ? 192 : (phase == 1 ? 184 : (phase == 2 ? 200 : 188));
    final int severityWidth = phase == 2 ? 36 : 34;
    final int laneWidth = phase == 1 ? 46 : (phase == 2 ? 50 : 44);
    final int badgeWidth = phase == 3 ? 38 : 36;
    final int ownerWidth = phase == 2 ? 54 : 50;
    final int etaWidth = phase == 1 ? 44 : 42;
    final int subtleChipWidth = phase == 3 ? 38 : 34;
    final int toolInputWidth = phase == 2 ? 66 : (phase == 1 ? 56 : 60);
    final int toolSelectWidth = phase == 3 ? 60 : (phase == 2 ? 64 : 56);
    final int miniActionWidth = phase == 1 ? 40 : 36;
    final String bodySpacing = phase == 1 ? '0.06px' : (phase == 2 ? '0.12px' : '0px');
    final String noteSpacing = phase == 3 ? '0.08px' : '0px';
    final String summarySpacing = phase == 2 ? '0.10px' : '0px';
    final String packGap = phase == 2 ? '4px' : '3px';
    for (int index = 0; index < cards.length; index++) {
      final dom.Element element = cards[index] as dom.Element;
      final int variance = index % 3 == 0 ? 0 : (index % 3 == 1 ? -4 : 4);
      element.setInlineStyle('minWidth', '${cardMinWidth + variance}px');
      element.setInlineStyle('maxWidth', '${cardMaxWidth + variance}px');
    }
    for (final dynamic node in severities) {
      (node as dom.Element).setInlineStyle('width', '${severityWidth}px');
    }
    for (final dynamic node in lanes) {
      (node as dom.Element).setInlineStyle('width', '${laneWidth}px');
    }
    for (final dynamic node in badges) {
      (node as dom.Element).setInlineStyle('width', '${badgeWidth}px');
    }
    for (final dynamic node in owners) {
      (node as dom.Element).setInlineStyle('width', '${ownerWidth}px');
    }
    for (final dynamic node in etas) {
      (node as dom.Element).setInlineStyle('width', '${etaWidth}px');
    }
    for (final dynamic node in subtleChips) {
      (node as dom.Element).setInlineStyle('width', '${subtleChipWidth}px');
    }
    for (final dynamic node in toolInputs) {
      (node as dom.Element).setInlineStyle('width', '${toolInputWidth}px');
    }
    for (final dynamic node in toolSelects) {
      (node as dom.Element).setInlineStyle('width', '${toolSelectWidth}px');
    }
    for (final dynamic node in miniActions) {
      (node as dom.Element).setInlineStyle('width', '${miniActionWidth}px');
    }
    for (final dynamic node in autoBodies) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', bodySpacing);
      element.setInlineStyle('wordSpacing', '0px');
    }
    for (final dynamic node in autoNotes) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', noteSpacing);
    }
    for (final dynamic node in summaryCopies) {
      (node as dom.Element).setInlineStyle('letterSpacing', summarySpacing);
    }
    for (final dynamic node in autoPacks) {
      (node as dom.Element).setInlineStyle('gap', packGap);
    }
    board.style.flushPendingProperties();
    board.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 3);
  }
}

Future<void> _runFlexAdjustWidgetDenseLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element board = prepared.getElementById('board');
  final List<dynamic> cards = board.querySelectorAll(['.card']);
  final List<dynamic> severities = board.querySelectorAll(['.severity']);
  final List<dynamic> lanes = board.querySelectorAll(['.lane']);
  final List<dynamic> badges = board.querySelectorAll(['.badge']);
  final List<dynamic> owners = board.querySelectorAll(['.owner']);
  final List<dynamic> etas = board.querySelectorAll(['.eta']);
  final List<dynamic> subtleChips = board.querySelectorAll(['.chip.subtle']);
  final List<dynamic> toolInputA = board.querySelectorAll(['.tool-input-a']);
  final List<dynamic> toolInputB = board.querySelectorAll(['.tool-input-b']);
  final List<dynamic> toolSelectA = board.querySelectorAll(['.tool-select-a']);
  final List<dynamic> toolSelectB = board.querySelectorAll(['.tool-select-b']);
  final List<dynamic> toolChips = board.querySelectorAll(['.tool-chip']);
  final List<dynamic> autoBodies = board.querySelectorAll(['.auto-copy']);
  final List<dynamic> autoNotes = board.querySelectorAll(['.auto-note']);
  final List<dynamic> summaryCopies = board.querySelectorAll(['.summary-copy']);
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px' : '8px');
    board.setInlineStyle('gap', phase == 2 ? '7px' : '8px');
    final int cardMinWidth =
        phase == 0 ? 152 : (phase == 1 ? 144 : (phase == 2 ? 160 : 148));
    final int cardMaxWidth =
        phase == 0 ? 178 : (phase == 1 ? 170 : (phase == 2 ? 186 : 174));
    final int severityWidth = phase == 2 ? 36 : 34;
    final int laneWidth = phase == 1 ? 46 : (phase == 2 ? 50 : 44);
    final int badgeWidth = phase == 3 ? 38 : 36;
    final int ownerWidth = phase == 2 ? 54 : 50;
    final int etaWidth = phase == 1 ? 44 : 42;
    final int subtleChipWidth = phase == 3 ? 38 : 34;
    final int inputAWidth = phase == 2 ? 78 : (phase == 1 ? 68 : 72);
    final int inputBWidth = phase == 3 ? 66 : (phase == 2 ? 62 : 58);
    final int selectAWidth = phase == 3 ? 74 : (phase == 2 ? 70 : 66);
    final int selectBWidth = phase == 1 ? 62 : (phase == 2 ? 66 : 58);
    final int toolChipWidth = phase == 2 ? 36 : 32;
    final String bodySpacing =
        phase == 1 ? '0.10px' : (phase == 2 ? '0.18px' : '0px');
    final String noteSpacing = phase == 3 ? '0.12px' : '0px';
    final String summarySpacing = phase == 2 ? '0.14px' : '0px';
    for (int index = 0; index < cards.length; index++) {
      final dom.Element element = cards[index] as dom.Element;
      final int variance = index % 3 == 0 ? 0 : (index % 3 == 1 ? -4 : 4);
      element.setInlineStyle('minWidth', '${cardMinWidth + variance}px');
      element.setInlineStyle('maxWidth', '${cardMaxWidth + variance}px');
    }
    for (final dynamic node in severities) {
      (node as dom.Element).setInlineStyle('width', '${severityWidth}px');
    }
    for (final dynamic node in lanes) {
      (node as dom.Element).setInlineStyle('width', '${laneWidth}px');
    }
    for (final dynamic node in badges) {
      (node as dom.Element).setInlineStyle('width', '${badgeWidth}px');
    }
    for (final dynamic node in owners) {
      (node as dom.Element).setInlineStyle('width', '${ownerWidth}px');
    }
    for (final dynamic node in etas) {
      (node as dom.Element).setInlineStyle('width', '${etaWidth}px');
    }
    for (final dynamic node in subtleChips) {
      (node as dom.Element).setInlineStyle('width', '${subtleChipWidth}px');
    }
    for (final dynamic node in toolInputA) {
      (node as dom.Element).setInlineStyle('width', '${inputAWidth}px');
    }
    for (final dynamic node in toolInputB) {
      (node as dom.Element).setInlineStyle('width', '${inputBWidth}px');
    }
    for (final dynamic node in toolSelectA) {
      (node as dom.Element).setInlineStyle('width', '${selectAWidth}px');
    }
    for (final dynamic node in toolSelectB) {
      (node as dom.Element).setInlineStyle('width', '${selectBWidth}px');
    }
    for (final dynamic node in toolChips) {
      (node as dom.Element).setInlineStyle('width', '${toolChipWidth}px');
    }
    for (final dynamic node in autoBodies) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', bodySpacing);
      element.setInlineStyle('wordSpacing', phase == 2 ? '0.24px' : '0px');
    }
    for (final dynamic node in autoNotes) {
      (node as dom.Element).setInlineStyle('letterSpacing', noteSpacing);
    }
    for (final dynamic node in summaryCopies) {
      (node as dom.Element).setInlineStyle('letterSpacing', summarySpacing);
    }
    board.style.flushPendingProperties();
    board.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 3);
  }
}

Future<void> _runFlexTightFastPathDenseLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element board = prepared.getElementById('board');
  final List<dynamic> cards = board.querySelectorAll(['.card']);
  final List<dynamic> severities = board.querySelectorAll(['.severity']);
  final List<dynamic> lanes = board.querySelectorAll(['.lane']);
  final List<dynamic> badges = board.querySelectorAll(['.badge']);
  final List<dynamic> owners = board.querySelectorAll(['.owner']);
  final List<dynamic> etas = board.querySelectorAll(['.eta']);
  final List<dynamic> subtleChips = board.querySelectorAll(['.chip.subtle']);
  final List<dynamic> tightCopies = board.querySelectorAll(['.tight-copy']);
  final List<dynamic> tightNotes = board.querySelectorAll(['.tight-note']);
  final List<dynamic> tightPacks = board.querySelectorAll(['.tight-pack']);
  final List<dynamic> toolInputA = board.querySelectorAll(['.tool-input-a']);
  final List<dynamic> toolInputB = board.querySelectorAll(['.tool-input-b']);
  final List<dynamic> toolSelectA = board.querySelectorAll(['.tool-select-a']);
  final List<dynamic> toolSelectB = board.querySelectorAll(['.tool-select-b']);
  final List<dynamic> miniActions = board.querySelectorAll(['.mini-action']);
  final List<dynamic> summaryCopies = board.querySelectorAll(['.summary-copy']);
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px' : '8px');
    board.setInlineStyle('gap', phase == 2 ? '7px' : '8px');
    final int cardMinWidth =
        phase == 0 ? 164 : (phase == 1 ? 156 : (phase == 2 ? 172 : 160));
    final int cardMaxWidth =
        phase == 0 ? 190 : (phase == 1 ? 182 : (phase == 2 ? 198 : 186));
    final int severityWidth = phase == 2 ? 36 : 34;
    final int laneWidth = phase == 1 ? 46 : (phase == 2 ? 50 : 44);
    final int badgeWidth = phase == 3 ? 38 : 36;
    final int ownerWidth = phase == 2 ? 54 : 50;
    final int etaWidth = phase == 1 ? 44 : 42;
    final int subtleChipWidth = phase == 3 ? 38 : 34;
    final int tightCopyWidth = phase == 2 ? 70 : (phase == 1 ? 58 : 64);
    final int tightNoteWidth = phase == 3 ? 54 : (phase == 2 ? 50 : 46);
    final int tightPackWidth = phase == 2 ? 42 : (phase == 1 ? 34 : 38);
    final int inputAWidth = phase == 2 ? 74 : (phase == 1 ? 66 : 70);
    final int inputBWidth = phase == 3 ? 64 : (phase == 2 ? 60 : 56);
    final int selectAWidth = phase == 3 ? 70 : (phase == 2 ? 66 : 62);
    final int selectBWidth = phase == 1 ? 64 : (phase == 2 ? 68 : 60);
    final int miniActionWidth = phase == 1 ? 40 : 36;
    final String summarySpacing = phase == 2 ? '0.12px' : '0px';
    for (int index = 0; index < cards.length; index++) {
      final dom.Element element = cards[index] as dom.Element;
      final int variance = index % 3 == 0 ? 0 : (index % 3 == 1 ? -4 : 4);
      element.setInlineStyle('minWidth', '${cardMinWidth + variance}px');
      element.setInlineStyle('maxWidth', '${cardMaxWidth + variance}px');
    }
    for (final dynamic node in severities) {
      (node as dom.Element).setInlineStyle('width', '${severityWidth}px');
    }
    for (final dynamic node in lanes) {
      (node as dom.Element).setInlineStyle('width', '${laneWidth}px');
    }
    for (final dynamic node in badges) {
      (node as dom.Element).setInlineStyle('width', '${badgeWidth}px');
    }
    for (final dynamic node in owners) {
      (node as dom.Element).setInlineStyle('width', '${ownerWidth}px');
    }
    for (final dynamic node in etas) {
      (node as dom.Element).setInlineStyle('width', '${etaWidth}px');
    }
    for (final dynamic node in subtleChips) {
      (node as dom.Element).setInlineStyle('width', '${subtleChipWidth}px');
    }
    for (int index = 0; index < tightCopies.length; index++) {
      final dom.Element element = tightCopies[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 4 : -4);
      element.setInlineStyle('flexBasis', '${tightCopyWidth + variance}px');
    }
    for (int index = 0; index < tightNotes.length; index++) {
      final dom.Element element = tightNotes[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 2 : -2);
      element.setInlineStyle('flexBasis', '${tightNoteWidth + variance}px');
    }
    for (int index = 0; index < tightPacks.length; index++) {
      final dom.Element element = tightPacks[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 2 : -2);
      element.setInlineStyle('flexBasis', '${tightPackWidth + variance}px');
    }
    for (final dynamic node in toolInputA) {
      (node as dom.Element).setInlineStyle('width', '${inputAWidth}px');
    }
    for (final dynamic node in toolInputB) {
      (node as dom.Element).setInlineStyle('width', '${inputBWidth}px');
    }
    for (final dynamic node in toolSelectA) {
      (node as dom.Element).setInlineStyle('width', '${selectAWidth}px');
    }
    for (final dynamic node in toolSelectB) {
      (node as dom.Element).setInlineStyle('width', '${selectBWidth}px');
    }
    for (final dynamic node in miniActions) {
      (node as dom.Element).setInlineStyle('width', '${miniActionWidth}px');
    }
    for (final dynamic node in summaryCopies) {
      (node as dom.Element).setInlineStyle('letterSpacing', summarySpacing);
    }
    board.style.flushPendingProperties();
    board.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 3);
  }
}

Future<void> _runFlexHybridFastPathDenseLoop(
  _PreparedProfileCase prepared, {
  required int mutationIterations,
  required List<String> widths,
}) async {
  final dom.Element host = prepared.getElementById('host');
  final dom.Element board = prepared.getElementById('board');
  final List<dynamic> cards = board.querySelectorAll(['.card']);
  final List<dynamic> severities = board.querySelectorAll(['.severity']);
  final List<dynamic> lanes = board.querySelectorAll(['.lane']);
  final List<dynamic> badges = board.querySelectorAll(['.badge']);
  final List<dynamic> owners = board.querySelectorAll(['.owner']);
  final List<dynamic> etas = board.querySelectorAll(['.eta']);
  final List<dynamic> subtleChips = board.querySelectorAll(['.chip.subtle']);
  final List<dynamic> autoBodies = board.querySelectorAll(['.auto-copy']);
  final List<dynamic> autoNotes = board.querySelectorAll(['.auto-note']);
  final List<dynamic> autoPacks = board.querySelectorAll(['.auto-pack']);
  final List<dynamic> summaryCopies = board.querySelectorAll(['.summary-copy']);
  final List<dynamic> toolInputs = board.querySelectorAll(['.tool-input']);
  final List<dynamic> toolSelects = board.querySelectorAll(['.tool-select']);
  final List<dynamic> miniActions = board.querySelectorAll(['.mini-action']);
  final List<dynamic> tightCopies = board.querySelectorAll(['.tight-copy']);
  final List<dynamic> tightNotes = board.querySelectorAll(['.tight-note']);
  final List<dynamic> tightPacks = board.querySelectorAll(['.tight-pack']);
  final List<dynamic> tightInputA = board.querySelectorAll(['.tight-input-a']);
  final List<dynamic> tightInputB = board.querySelectorAll(['.tight-input-b']);
  final List<dynamic> tightSelectA = board.querySelectorAll(['.tight-select-a']);
  final List<dynamic> tightSelectB = board.querySelectorAll(['.tight-select-b']);
  final List<dynamic> miniTight = board.querySelectorAll(['.mini-tight']);
  for (int iteration = 0; iteration < mutationIterations; iteration++) {
    final int phase = iteration % widths.length;
    host.setInlineStyle('width', widths[phase]);
    host.setInlineStyle('padding', phase.isEven ? '10px' : '8px');
    board.setInlineStyle('gap', phase == 2 ? '7px' : '8px');
    final int cardMinWidth =
        phase == 0 ? 166 : (phase == 1 ? 158 : (phase == 2 ? 174 : 162));
    final int cardMaxWidth =
        phase == 0 ? 190 : (phase == 1 ? 182 : (phase == 2 ? 198 : 186));
    final int severityWidth = phase == 2 ? 36 : 34;
    final int laneWidth = phase == 1 ? 46 : (phase == 2 ? 50 : 44);
    final int badgeWidth = phase == 3 ? 38 : 36;
    final int ownerWidth = phase == 2 ? 54 : 50;
    final int etaWidth = phase == 1 ? 44 : 42;
    final int subtleChipWidth = phase == 3 ? 38 : 34;
    final int toolInputWidth = phase == 2 ? 66 : (phase == 1 ? 56 : 60);
    final int toolSelectWidth = phase == 3 ? 60 : (phase == 2 ? 64 : 56);
    final int miniActionWidth = phase == 1 ? 40 : 36;
    final int tightCopyWidth = phase == 2 ? 66 : (phase == 1 ? 54 : 60);
    final int tightNoteWidth = phase == 3 ? 52 : (phase == 2 ? 48 : 44);
    final int tightPackWidth = phase == 2 ? 40 : (phase == 1 ? 32 : 36);
    final int tightInputAWidth = phase == 2 ? 72 : (phase == 1 ? 60 : 66);
    final int tightInputBWidth = phase == 3 ? 64 : (phase == 2 ? 58 : 54);
    final int tightSelectAWidth = phase == 3 ? 70 : (phase == 2 ? 64 : 60);
    final int tightSelectBWidth = phase == 1 ? 62 : (phase == 2 ? 66 : 58);
    final int miniTightWidth = phase == 1 ? 38 : 34;
    final String bodySpacing =
        phase == 1 ? '0.06px' : (phase == 2 ? '0.12px' : '0px');
    final String noteSpacing = phase == 3 ? '0.08px' : '0px';
    final String summarySpacing = phase == 2 ? '0.10px' : '0px';
    final String packGap = phase == 2 ? '4px' : '3px';
    for (int index = 0; index < cards.length; index++) {
      final dom.Element element = cards[index] as dom.Element;
      final int variance = index % 3 == 0 ? 0 : (index % 3 == 1 ? -4 : 4);
      element.setInlineStyle('minWidth', '${cardMinWidth + variance}px');
      element.setInlineStyle('maxWidth', '${cardMaxWidth + variance}px');
    }
    for (final dynamic node in severities) {
      (node as dom.Element).setInlineStyle('width', '${severityWidth}px');
    }
    for (final dynamic node in lanes) {
      (node as dom.Element).setInlineStyle('width', '${laneWidth}px');
    }
    for (final dynamic node in badges) {
      (node as dom.Element).setInlineStyle('width', '${badgeWidth}px');
    }
    for (final dynamic node in owners) {
      (node as dom.Element).setInlineStyle('width', '${ownerWidth}px');
    }
    for (final dynamic node in etas) {
      (node as dom.Element).setInlineStyle('width', '${etaWidth}px');
    }
    for (final dynamic node in subtleChips) {
      (node as dom.Element).setInlineStyle('width', '${subtleChipWidth}px');
    }
    for (final dynamic node in toolInputs) {
      (node as dom.Element).setInlineStyle('width', '${toolInputWidth}px');
    }
    for (final dynamic node in toolSelects) {
      (node as dom.Element).setInlineStyle('width', '${toolSelectWidth}px');
    }
    for (final dynamic node in miniActions) {
      (node as dom.Element).setInlineStyle('width', '${miniActionWidth}px');
    }
    for (final dynamic node in autoBodies) {
      final dom.Element element = node as dom.Element;
      element.setInlineStyle('letterSpacing', bodySpacing);
      element.setInlineStyle('wordSpacing', phase == 2 ? '0.24px' : '0px');
    }
    for (final dynamic node in autoNotes) {
      (node as dom.Element).setInlineStyle('letterSpacing', noteSpacing);
    }
    for (final dynamic node in autoPacks) {
      (node as dom.Element).setInlineStyle('gap', packGap);
    }
    for (final dynamic node in summaryCopies) {
      (node as dom.Element).setInlineStyle('letterSpacing', summarySpacing);
    }
    for (int index = 0; index < tightCopies.length; index++) {
      final dom.Element element = tightCopies[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 4 : -4);
      element.setInlineStyle('flexBasis', '${tightCopyWidth + variance}px');
    }
    for (int index = 0; index < tightNotes.length; index++) {
      final dom.Element element = tightNotes[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 2 : -2);
      element.setInlineStyle('flexBasis', '${tightNoteWidth + variance}px');
    }
    for (int index = 0; index < tightPacks.length; index++) {
      final dom.Element element = tightPacks[index] as dom.Element;
      final int variance = index.isEven ? 0 : (index % 3 == 0 ? 2 : -2);
      element.setInlineStyle('flexBasis', '${tightPackWidth + variance}px');
    }
    for (final dynamic node in tightInputA) {
      (node as dom.Element).setInlineStyle('width', '${tightInputAWidth}px');
    }
    for (final dynamic node in tightInputB) {
      (node as dom.Element).setInlineStyle('width', '${tightInputBWidth}px');
    }
    for (final dynamic node in tightSelectA) {
      (node as dom.Element).setInlineStyle('width', '${tightSelectAWidth}px');
    }
    for (final dynamic node in tightSelectB) {
      (node as dom.Element).setInlineStyle('width', '${tightSelectBWidth}px');
    }
    for (final dynamic node in miniTight) {
      (node as dom.Element).setInlineStyle('width', '${miniTightWidth}px');
    }
    board.style.flushPendingProperties();
    board.ownerDocument.updateStyleIfNeeded();
    await _pumpFrames(prepared.tester, 3);
  }
}

Future<void> _pumpFrames(
  WidgetTester tester,
  int frames, {
  Duration frameDuration = const Duration(milliseconds: 16),
}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(frameDuration);
  }
}

String _buildDirectionInheritanceHtml({
  required int depth,
  required int runCount,
}) {
  final String openNodes =
      List<String>.filled(depth, '<div class="level">').join();
  final String closeNodes = List<String>.filled(depth, '</div>').join();
  final String content = List<String>.generate(
    runCount,
    (int index) =>
        '<span class="token">مرحبا اتجاه ${index + 1} nested text sample</span>',
  ).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 16px/1.4 AlibabaSans, sans-serif;
    }
    #host {
      width: 320px;
      padding: 8px;
      border: 1px solid #d8dde6;
      direction: rtl;
    }
    .level {
      display: block;
      padding-inline-start: 1px;
    }
    .token {
      display: inline;
      margin-inline-end: 4px;
    }
  </style>
</head>
<body>
  <div id="host">$openNodes$content$closeNodes</div>
</body>
</html>
''';
}

String _buildTextAlignInheritanceHtml({
  required int depth,
  required int runCount,
}) {
  final String openNodes =
      List<String>.filled(depth, '<div class="level">').join();
  final String closeNodes = List<String>.filled(depth, '</div>').join();
  final String content = List<String>.generate(
    runCount,
    (int index) => '<span class="token">alignment sample ${index + 1}</span>',
  ).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 16px/1.4 AlibabaSans, sans-serif;
    }
    #host {
      width: 300px;
      padding: 8px;
      border: 1px solid #d8dde6;
      text-align: center;
    }
    .level {
      display: block;
      padding-left: 1px;
    }
    .token {
      display: inline;
      margin: 0 3px;
    }
  </style>
</head>
<body>
  <div id="host">$openNodes$content$closeNodes</div>
</body>
</html>
''';
}

String _buildParagraphRebuildHtml({
  required int chipCount,
}) {
  final String chips = List<String>.generate(
    chipCount,
    (int index) {
      final int tone = index % 4;
      final int badge = index % 3;
      return '''
<span class="run tone$tone">
  <span class="label">series ${index + 1}</span>
  <span class="pill badge$badge">item ${index + 1}</span>
  <span class="value">wrapped inline metrics sample ${index + 1}</span>
</span>
''';
    },
  ).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 16px/1.4 AlibabaSans, sans-serif;
    }
    #host {
      width: 340px;
      padding: 8px;
      border: 1px solid #d8dde6;
    }
    #paragraph {
      width: 340px;
      line-height: 22px;
      word-break: normal;
    }
    #paragraph.phase-1 {
      letter-spacing: 0.15px;
    }
    #paragraph.phase-2 .pill {
      margin: 0 6px;
      padding: 1px 8px;
      font-size: 12px;
      vertical-align: baseline;
    }
    #paragraph.phase-3 .value {
      font-style: normal;
      font-weight: 700;
      letter-spacing: 0.2px;
    }
    #paragraph.phase-3 .pill {
      padding: 3px 8px;
    }
    #paragraph.phase-1 .label {
      font-weight: 700;
    }
    #paragraph.phase-2 .value {
      font-style: normal;
    }
    #paragraph.phase-0 .pill {
      vertical-align: middle;
    }
    .run {
      display: inline;
      margin-right: 6px;
      padding: 0 2px;
      border-right: 1px solid rgba(80, 108, 144, 0.2);
    }
    .label {
      color: #4b5563;
      letter-spacing: 0.15px;
    }
    .value {
      color: #0f172a;
      font-style: italic;
    }
    .pill {
      display: inline-block;
      margin: 0 4px;
      padding: 2px 6px;
      border-radius: 999px;
      border: 1px solid rgba(59, 130, 246, 0.28);
      vertical-align: middle;
      font-size: 13px;
      line-height: 18px;
      background: rgba(191, 219, 254, 0.35);
    }
    .tone0 .label {
      font-weight: 600;
    }
    .tone1 .value {
      text-decoration: underline;
    }
    .tone2 .label {
      letter-spacing: 0.35px;
    }
    .tone3 .value {
      font-weight: 700;
    }
    .badge0 {
      background: rgba(253, 230, 138, 0.55);
    }
    .badge1 {
      background: rgba(187, 247, 208, 0.55);
    }
    .badge2 {
      background: rgba(216, 180, 254, 0.4);
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="paragraph">$chips</div>
  </div>
</body>
</html>
''';
}

String _buildOpacityTransitionHtml({
  required int tileCount,
}) {
  final String tiles = List<String>.generate(
    tileCount,
    (int index) =>
        '<span class="tile" style="background-color: hsl(${(index * 11) % 360}, 70%, 55%);"></span>',
  ).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      padding: 0;
      background: #ffffff;
    }
    #stage {
      width: 360px;
      padding: 8px;
      transition: opacity 180ms linear;
      opacity: 1;
    }
    #stage.dim {
      opacity: 0.2;
    }
    .tile {
      display: inline-block;
      width: 24px;
      height: 24px;
      margin: 1px;
    }
  </style>
</head>
<body>
  <div id="stage">$tiles</div>
</body>
</html>
''';
}

String _buildFiatFilterPopupHtml({
  required int optionCount,
}) {
  const List<String> currencies = <String>[
    'USD',
    'EUR',
    'SAR',
    'THB',
    'BRL',
    'JPY',
    'AED',
    'GBP',
  ];
  const List<String> names = <String>[
    'United States Dollar',
    'Euro العربية',
    'Saudi Riyal العربية',
    'Baht ไทย',
    'Real do Brasil',
    'Japanese Yen 日本語',
    'UAE Dirham العربية',
    'Pound Sterling',
  ];

  final String options = List<String>.generate(optionCount, (int index) {
    final String currency = currencies[index % currencies.length];
    final String name = names[index % names.length];
    final String badge = index % 3 == 0 ? 'Hot' : (index % 3 == 1 ? 'OTC' : 'New');
    final String iconLabel = currency.substring(0, 1);
    return '''
<div class="fiat-option${index == 0 ? ' selected' : ''}" data-option="${index + 1}">
  <span class="fiat-icon">${iconLabel}</span>
  <div class="fiat-copy">
    <span class="fiat-code">${currency}</span>
    <span class="fiat-name">${name} ${index + 1}</span>
  </div>
  <span class="fiat-badge">${badge}</span>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.4 AlibabaSans, sans-serif;
      background: #f8fafc;
      color: #0f172a;
    }
    #host {
      width: 364px;
      padding: 10px;
      box-sizing: border-box;
    }
    #shell {
      border: 1px solid rgba(148, 163, 184, 0.32);
      border-radius: 20px;
      background: #ffffff;
      box-shadow: 0 18px 32px rgba(15, 23, 42, 0.08);
      padding: 12px;
      box-sizing: border-box;
    }
    #trigger {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 9px 11px;
      border: 1px solid rgba(148, 163, 184, 0.32);
      border-radius: 14px;
      box-sizing: border-box;
      background: rgba(248, 250, 252, 0.95);
    }
    #trigger-icon,
    .fiat-icon {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 28px;
      height: 28px;
      border-radius: 999px;
      background: linear-gradient(135deg, #0f766e, #38bdf8);
      color: #ffffff;
      flex: 0 0 auto;
      box-sizing: border-box;
    }
    #trigger-copy {
      display: flex;
      flex-direction: column;
      min-width: 0;
      flex: 1 1 auto;
    }
    #trigger-label {
      color: #64748b;
      font-size: 12px;
      line-height: 16px;
    }
    #trigger-value {
      color: #0f172a;
      font-size: 16px;
      line-height: 22px;
      font-weight: 600;
    }
    #trigger-caret {
      flex: 0 0 auto;
      color: #64748b;
    }
    #popup {
      margin-top: 12px;
      display: flex;
      flex-direction: column;
      gap: 8px;
      height: 372px;
      padding: 9px 11px;
      overflow: hidden;
      border: 1px solid rgba(148, 163, 184, 0.24);
      border-radius: 16px;
      box-sizing: border-box;
      background: rgba(255, 255, 255, 0.98);
    }
    .fiat-option {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 9px 7px;
      border-radius: 12px;
      box-sizing: border-box;
      background: rgba(248, 250, 252, 0.8);
    }
    .fiat-option.selected {
      background: rgba(224, 242, 254, 0.92);
    }
    .fiat-copy {
      display: flex;
      flex-direction: column;
      min-width: 0;
      width: 208px;
      flex: 0 1 auto;
    }
    .fiat-code {
      padding-bottom: 3px;
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    .fiat-name {
      color: #64748b;
      font-size: 13px;
      line-height: 18px;
    }
    .fiat-badge {
      width: 40px;
      flex: 0 0 auto;
      text-align: center;
      color: #0369a1;
      font-size: 11px;
      line-height: 18px;
      border-radius: 999px;
      background: rgba(186, 230, 253, 0.72);
      box-sizing: border-box;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="shell">
      <div id="trigger">
        <span id="trigger-icon">F</span>
        <div id="trigger-copy">
          <span id="trigger-label">Fiat currency</span>
          <span id="trigger-value">USD</span>
        </div>
        <span id="trigger-caret">▾</span>
      </div>
      <div id="popup">$options</div>
    </div>
  </div>
</body>
</html>
''';
}

String _buildPaymentMethodSheetHtml({
  required int groupCount,
  required int rowsPerGroup,
}) {
  const List<String> groupTitles = <String>[
    'Bank transfer',
    'Digital wallet',
    'Local rails',
    'Express payout',
  ];
  const List<String> paymentTitles = <String>[
    'Bank Express',
    'Wallet Direct',
    'Instant Local',
    'Verified Transfer',
    'Priority Cash',
    'Merchant Route',
  ];
  const List<String> subtitles = <String>[
    'T+0 العربية ไทย',
    'Fast rail 日本語',
    'Local settle عربى',
    'Wide coverage ไทย',
    'Low fee English',
    'High success 日本語',
  ];

  final String groups = List<String>.generate(groupCount, (int groupIndex) {
    final String rows = List<String>.generate(rowsPerGroup, (int rowIndex) {
      final int absoluteIndex = groupIndex * rowsPerGroup + rowIndex;
      final bool extra = rowIndex >= 4;
      final String title = paymentTitles[absoluteIndex % paymentTitles.length];
      final String subtitle = subtitles[absoluteIndex % subtitles.length];
      return '''
<div class="payment-row${extra ? ' extra' : ''}" data-extra="${extra ? 'true' : 'false'}">
  <span class="payment-icon">P${(absoluteIndex % 7) + 1}</span>
  <span class="payment-status">${absoluteIndex % 3 == 0 ? 'Hot' : 'On'}</span>
  <div class="payment-copy">
    <span class="payment-title">${title} ${(absoluteIndex % 5) + 1}</span>
    <span class="payment-subtitle">${subtitle} ${(absoluteIndex % 8) + 1}</span>
    <div class="payment-badges">
      <span class="payment-chip">KYC</span>
      <span class="payment-chip">T+0</span>
      <span class="payment-chip">FX</span>
    </div>
  </div>
  <span class="payment-rate">${2 + (absoluteIndex % 6)}m</span>
  <select class="payment-route">
    <option>Route ${(absoluteIndex % 4) + 1}</option>
    <option>Route ${(absoluteIndex % 4) + 2}</option>
  </select>
  <span class="payment-tail">›</span>
</div>
''';
    }).join();

    return '''
<div class="group${groupIndex == 0 ? ' expanded' : ' collapsed'}">
  <div class="group-header">
    <span class="group-title">${groupTitles[groupIndex % groupTitles.length]}</span>
    <span class="group-count">${rowsPerGroup}</span>
  </div>
  <div class="group-body">$rows</div>
  <div class="show-more-row">
    <span class="show-more-label">Show more options</span>
    <span class="show-more-icon">▾</span>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.42 AlibabaSans, sans-serif;
      background: #e2e8f0;
      color: #0f172a;
    }
    #host {
      width: 378px;
      padding: 10px 0 0;
      box-sizing: border-box;
      display: flex;
      justify-content: center;
    }
    #sheet {
      width: 100%;
      display: flex;
      flex-direction: column;
      gap: 24px;
      padding: 16px 15px 18px;
      border-radius: 24px 24px 0 0;
      background: #ffffff;
      box-shadow: 0 -6px 28px rgba(15, 23, 42, 0.1);
      box-sizing: border-box;
    }
    #sheet-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    #sheet-title {
      font-size: 19px;
      line-height: 26px;
      font-weight: 600;
    }
    #sheet-action {
      color: #475569;
      font-size: 13px;
    }
    #content {
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
    .group {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .group-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .group-title {
      font-size: 16px;
      line-height: 22px;
      font-weight: 600;
    }
    .group-count {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .group-body {
      display: flex;
      flex-direction: column;
    }
    .payment-row {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 0;
      border-bottom: 1px solid rgba(226, 232, 240, 0.92);
      box-sizing: border-box;
    }
    .payment-row.selected {
      background: rgba(240, 249, 255, 0.9);
    }
    .payment-icon {
      width: 34px;
      height: 34px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex: 0 0 auto;
      border-radius: 999px;
      background: linear-gradient(135deg, #2563eb, #0ea5e9);
      color: #ffffff;
      box-sizing: border-box;
    }
    .payment-status {
      width: 38px;
      flex: 0 0 auto;
      text-align: center;
      color: #0369a1;
      font-size: 11px;
      line-height: 18px;
      border-radius: 999px;
      background: rgba(186, 230, 253, 0.78);
      box-sizing: border-box;
    }
    .payment-copy {
      display: flex;
      min-width: 0;
      width: 188px;
      flex: 0 0 auto;
      flex-direction: column;
    }
    .payment-title {
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    .payment-subtitle {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .payment-badges {
      display: flex;
      flex-wrap: nowrap;
      align-items: center;
      gap: 4px;
      margin-top: 4px;
    }
    .payment-chip {
      width: 38px;
      flex: 0 0 auto;
      color: #475569;
      font-size: 10px;
      line-height: 16px;
      text-align: center;
      border-radius: 999px;
      background: rgba(226, 232, 240, 0.82);
      box-sizing: border-box;
    }
    .payment-rate {
      width: 46px;
      flex: 0 0 auto;
      color: #334155;
      font-size: 12px;
      line-height: 18px;
      text-align: center;
      box-sizing: border-box;
    }
    .payment-route {
      width: 82px;
      flex: 0 0 auto;
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
    }
    .payment-tail {
      width: 22px;
      flex: 0 0 auto;
      text-align: center;
      color: #94a3b8;
      box-sizing: border-box;
    }
    .show-more-row {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
      color: #0f172a;
      font-size: 13px;
      line-height: 18px;
    }
    .group.expanded .show-more-row {
      display: none;
    }
    .group.collapsed .payment-row.extra {
      display: none;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="sheet">
      <div id="sheet-header">
        <span id="sheet-title">Select payment method</span>
        <span id="sheet-action">Confirm</span>
      </div>
      <div id="content">$groups</div>
    </div>
  </div>
</body>
</html>
''';
}

String _buildPaymentMethodBottomSheetHtml({
  required int groupCount,
  required int rowsPerGroup,
}) {
  const List<String> groupTitles = <String>[
    'Bank transfer',
    'Digital wallet',
    'Local rails',
    'Express payout',
  ];
  const List<String> paymentTitles = <String>[
    'Bank Express',
    'Wallet Direct',
    'Instant Local',
    'Verified Transfer',
    'Priority Cash',
    'Merchant Route',
  ];
  const List<String> subtitles = <String>[
    'T+0 العربية ไทย',
    'Fast rail 日本語',
    'Local settle عربى',
    'Wide coverage ไทย',
    'Low fee English',
    'High success 日本語',
  ];

  final String groups = List<String>.generate(groupCount, (int groupIndex) {
    final String rows = List<String>.generate(rowsPerGroup, (int rowIndex) {
      final int absoluteIndex = groupIndex * rowsPerGroup + rowIndex;
      final bool extra = rowIndex >= 4;
      final String title = paymentTitles[absoluteIndex % paymentTitles.length];
      final String subtitle = subtitles[absoluteIndex % subtitles.length];
      return '''
<div class="payment-row${extra ? ' extra' : ''}" data-extra="${extra ? 'true' : 'false'}">
  <span class="payment-icon">P${(absoluteIndex % 7) + 1}</span>
  <span class="payment-status">${absoluteIndex % 3 == 0 ? 'Hot' : 'On'}</span>
  <div class="payment-copy">
    <span class="payment-title">${title} ${(absoluteIndex % 5) + 1}</span>
    <span class="payment-subtitle">${subtitle} ${(absoluteIndex % 8) + 1}</span>
    <div class="payment-badges">
      <span class="payment-chip">KYC</span>
      <span class="payment-chip">T+0</span>
      <span class="payment-chip">FX</span>
    </div>
  </div>
  <span class="payment-rate">${2 + (absoluteIndex % 6)}m</span>
  <select class="payment-route">
    <option>Route ${(absoluteIndex % 4) + 1}</option>
    <option>Route ${(absoluteIndex % 4) + 2}</option>
  </select>
  <span class="payment-tail">›</span>
</div>
''';
    }).join();

    return '''
<div class="group${groupIndex == 0 ? ' expanded' : ' collapsed'}">
  <div class="group-header">
    <span class="group-title">${groupTitles[groupIndex % groupTitles.length]}</span>
    <span class="group-count">${rowsPerGroup}</span>
  </div>
  <div class="group-body">$rows</div>
  <div class="show-more-row">
    <span class="show-more-label">Show more options</span>
    <span class="show-more-icon">▾</span>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.42 AlibabaSans, sans-serif;
      background: #e2e8f0;
      color: #0f172a;
    }
    #host {
      width: 378px;
      padding: 10px 0 0;
      box-sizing: border-box;
      display: flex;
      justify-content: center;
    }
    #summary-card {
      width: 100%;
      min-height: 72px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 18px 16px;
      border-radius: 16px;
      background: rgba(241, 245, 249, 0.92);
      box-sizing: border-box;
    }
    #summary-leading {
      display: flex;
      align-items: center;
      gap: 8px;
      min-width: 0;
    }
    #summary-avatar {
      width: 32px;
      height: 32px;
      border-radius: 999px;
      background: linear-gradient(135deg, #2563eb, #0ea5e9);
      flex: 0 0 auto;
    }
    #summary-copy {
      display: flex;
      flex-direction: column;
      min-width: 0;
    }
    #summary-title {
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    #summary-subtitle {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    #summary-caret {
      color: #64748b;
      font-size: 16px;
    }
    #sheet {
      width: 100%;
      display: flex;
      flex-direction: column;
      gap: 24px;
      padding: 16px 15px 18px;
      border-radius: 24px 24px 0 0;
      background: #ffffff;
      box-shadow: 0 -6px 28px rgba(15, 23, 42, 0.1);
      box-sizing: border-box;
    }
    #sheet-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    #sheet-title {
      font-size: 19px;
      line-height: 26px;
      font-weight: 600;
    }
    #sheet-action {
      color: #475569;
      font-size: 13px;
    }
    #content {
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
    .group {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .group-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .group-title {
      font-size: 16px;
      line-height: 22px;
      font-weight: 600;
    }
    .group-count {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .group-body {
      display: flex;
      flex-direction: column;
    }
    .payment-row {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 0;
      border-bottom: 1px solid rgba(226, 232, 240, 0.92);
      box-sizing: border-box;
    }
    .payment-row.selected {
      background: rgba(240, 249, 255, 0.9);
    }
    .payment-icon {
      width: 34px;
      height: 34px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      flex: 0 0 auto;
      border-radius: 999px;
      background: linear-gradient(135deg, #2563eb, #0ea5e9);
      color: #ffffff;
      box-sizing: border-box;
    }
    .payment-status {
      width: 38px;
      flex: 0 0 auto;
      text-align: center;
      color: #0369a1;
      font-size: 11px;
      line-height: 18px;
      border-radius: 999px;
      background: rgba(186, 230, 253, 0.78);
      box-sizing: border-box;
    }
    .payment-copy {
      display: flex;
      min-width: 0;
      width: 188px;
      flex: 0 0 auto;
      flex-direction: column;
    }
    .payment-title {
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    .payment-subtitle {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .payment-badges {
      display: flex;
      flex-wrap: nowrap;
      align-items: center;
      gap: 4px;
      margin-top: 4px;
    }
    .payment-chip {
      width: 38px;
      flex: 0 0 auto;
      color: #475569;
      font-size: 10px;
      line-height: 16px;
      text-align: center;
      border-radius: 999px;
      background: rgba(226, 232, 240, 0.82);
      box-sizing: border-box;
    }
    .payment-rate {
      width: 46px;
      flex: 0 0 auto;
      color: #334155;
      font-size: 12px;
      line-height: 18px;
      text-align: center;
      box-sizing: border-box;
    }
    .payment-route {
      width: 82px;
      flex: 0 0 auto;
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
    }
    .payment-tail {
      width: 22px;
      flex: 0 0 auto;
      text-align: center;
      color: #94a3b8;
      box-sizing: border-box;
    }
    .show-more-row {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
      color: #0f172a;
      font-size: 13px;
      line-height: 18px;
    }
    .group.expanded .show-more-row {
      display: none;
    }
    .group.collapsed .payment-row.extra {
      display: none;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="summary-card">
      <div id="summary-leading">
        <span id="summary-avatar"></span>
        <div id="summary-copy">
          <span id="summary-title">Card</span>
          <span id="summary-subtitle">Visa **** 1234</span>
        </div>
      </div>
      <span id="summary-caret">▾</span>
    </div>
    <flutter-bottom-sheet id="payment-sheet" title="Select Payment Method" primary-btn-title="Confirm">
      <flutter-popup-item id="sheet-popup-item">
        <div id="sheet">
          <div id="sheet-header">
            <span id="sheet-title">Select payment method</span>
            <span id="sheet-action">Confirm</span>
          </div>
          <div id="content">$groups</div>
        </div>
      </flutter-popup-item>
    </flutter-bottom-sheet>
  </div>
</body>
</html>
''';
}

String _buildPaymentMethodFastPathSheetHtml({
  required int groupCount,
  required int rowsPerGroup,
}) {
  const List<String> groupTitles = <String>[
    'Bank transfer',
    'Digital wallet',
    'Local rails',
    'Express payout',
  ];
  const List<String> paymentTitles = <String>[
    'Bank Express',
    'Wallet Direct',
    'Instant Local',
    'Verified Transfer',
    'Priority Cash',
    'Merchant Route',
  ];
  const List<String> subtitles = <String>[
    'T+0 العربية ไทย',
    'Fast rail 日本語',
    'Local settle عربى',
    'Wide coverage ไทย',
    'Low fee English',
    'High success 日本語',
  ];

  final String groups = List<String>.generate(groupCount, (int groupIndex) {
    final String rows = List<String>.generate(rowsPerGroup, (int rowIndex) {
      final int absoluteIndex = groupIndex * rowsPerGroup + rowIndex;
      final bool extra = rowIndex >= 5;
      final String title = paymentTitles[absoluteIndex % paymentTitles.length];
      final String subtitle = subtitles[absoluteIndex % subtitles.length];
      return '''
<div class="payment-row${extra ? ' extra' : ''}" data-extra="${extra ? 'true' : 'false'}">
  <div class="payment-icon"></div>
  <div class="payment-status">${absoluteIndex % 3 == 0 ? 'Hot' : 'On'}</div>
  <div class="payment-copy">
    <div class="payment-title">${title} ${(absoluteIndex % 5) + 1}</div>
    <div class="payment-subtitle">${subtitle} ${(absoluteIndex % 8) + 1}</div>
    <div class="payment-badges">
      <div class="payment-chip">KYC</div>
      <div class="payment-chip">T+0</div>
      <div class="payment-chip">FX</div>
    </div>
  </div>
  <div class="payment-rate">${2 + (absoluteIndex % 6)}m</div>
  <div class="payment-route">${absoluteIndex % 2 == 0 ? 'AUTO' : 'FAST'}</div>
  <div class="payment-tail"></div>
</div>
''';
    }).join();

    return '''
<div class="group${groupIndex == 0 ? ' expanded' : ' collapsed'}">
  <div class="group-title">${groupTitles[groupIndex % groupTitles.length]}</div>
  <div class="group-body">$rows</div>
  <div class="show-more-row">Show more options</div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.42 AlibabaSans, sans-serif;
      background: #e2e8f0;
      color: #0f172a;
    }
    #host {
      width: 378px;
      padding: 10px 0 0;
      box-sizing: border-box;
      display: block;
    }
    #sheet {
      width: 100%;
      padding: 16px 15px 18px;
      border-radius: 24px 24px 0 0;
      background: #ffffff;
      box-shadow: 0 -6px 28px rgba(15, 23, 42, 0.1);
      box-sizing: border-box;
    }
    #sheet-header {
      display: block;
      margin-bottom: 18px;
    }
    #sheet-title {
      display: block;
      font-size: 19px;
      line-height: 26px;
      font-weight: 600;
    }
    #sheet-action {
      display: block;
      margin-top: 4px;
      color: #475569;
      font-size: 13px;
      line-height: 18px;
    }
    #content {
      display: block;
    }
    .group {
      display: block;
      margin-bottom: 22px;
    }
    .group-title {
      display: block;
      margin-bottom: 8px;
      font-size: 16px;
      line-height: 22px;
      font-weight: 600;
    }
    .group-body {
      display: block;
    }
    .payment-row {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 0;
      border-bottom: 1px solid rgba(226, 232, 240, 0.92);
      box-sizing: border-box;
    }
    .payment-row.selected {
      background: rgba(240, 249, 255, 0.9);
    }
    .payment-icon {
      width: 34px;
      height: 34px;
      flex: 0 0 auto;
      border-radius: 999px;
      background: linear-gradient(135deg, #2563eb, #0ea5e9);
      box-sizing: border-box;
    }
    .payment-status {
      width: 38px;
      flex: 0 0 auto;
      text-align: center;
      color: #0369a1;
      font-size: 11px;
      line-height: 18px;
      border-radius: 999px;
      background: rgba(186, 230, 253, 0.78);
      box-sizing: border-box;
    }
    .payment-copy {
      display: block;
      width: 188px;
      min-width: 0;
      flex: 0 0 auto;
    }
    .payment-title {
      display: block;
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    .payment-subtitle {
      display: block;
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .payment-badges {
      display: flex;
      flex-wrap: nowrap;
      align-items: center;
      gap: 4px;
      margin-top: 4px;
    }
    .payment-chip {
      width: 38px;
      flex: 0 0 auto;
      color: #475569;
      font-size: 10px;
      line-height: 16px;
      text-align: center;
      border-radius: 999px;
      background: rgba(226, 232, 240, 0.82);
      box-sizing: border-box;
    }
    .payment-rate {
      width: 46px;
      flex: 0 0 auto;
      color: #334155;
      font-size: 12px;
      line-height: 18px;
      text-align: center;
      box-sizing: border-box;
    }
    .payment-route {
      width: 82px;
      flex: 0 0 auto;
      color: #475569;
      font-size: 11px;
      line-height: 18px;
      text-align: center;
      border-radius: 999px;
      background: rgba(226, 232, 240, 0.84);
      box-sizing: border-box;
    }
    .payment-tail {
      width: 22px;
      height: 18px;
      flex: 0 0 auto;
      box-sizing: border-box;
      background: linear-gradient(180deg, #94a3b8, #cbd5e1);
      clip-path: polygon(25% 0%, 100% 50%, 25% 100%, 0% 82%, 48% 50%, 0% 18%);
    }
    .show-more-row {
      display: block;
      margin-top: 8px;
      color: #0f172a;
      font-size: 13px;
      line-height: 18px;
      text-align: center;
    }
    .group.expanded .show-more-row {
      display: none;
    }
    .group.collapsed .payment-row.extra {
      display: none;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="sheet">
      <div id="sheet-header">
        <div id="sheet-title">Select payment method</div>
        <div id="sheet-action">Confirm</div>
      </div>
      <div id="content">$groups</div>
    </div>
  </div>
</body>
</html>
''';
}

String _buildPaymentMethodBottomSheetTightHtml({
  required int groupCount,
  required int rowsPerGroup,
}) {
  const List<String> groupTitles = <String>[
    'Bank transfer',
    'Digital wallet',
    'Local rails',
    'Express payout',
  ];
  const List<String> paymentTitles = <String>[
    'Bank Express',
    'Wallet Direct',
    'Instant Local',
    'Verified Transfer',
    'Priority Cash',
    'Merchant Route',
  ];
  const List<String> subtitles = <String>[
    'T+0 العربية ไทย',
    'Fast rail 日本語',
    'Local settle عربى',
    'Wide coverage ไทย',
    'Low fee English',
    'High success 日本語',
  ];

  final String groups = List<String>.generate(groupCount, (int groupIndex) {
    final String rows = List<String>.generate(rowsPerGroup, (int rowIndex) {
      final int absoluteIndex = groupIndex * rowsPerGroup + rowIndex;
      final bool extra = rowIndex >= 4;
      final String title = paymentTitles[absoluteIndex % paymentTitles.length];
      final String subtitle = subtitles[absoluteIndex % subtitles.length];
      return '''
<div class="payment-row${extra ? ' extra' : ''}" data-extra="${extra ? 'true' : 'false'}">
  <div class="payment-icon"></div>
  <div class="payment-status">${absoluteIndex % 3 == 0 ? 'Hot' : 'On'}</div>
  <div class="payment-copy">
    <div class="payment-title">${title} ${(absoluteIndex % 5) + 1}</div>
    <div class="payment-subtitle">${subtitle} ${(absoluteIndex % 8) + 1}</div>
    <div class="payment-badges">
      <div class="payment-chip">KYC</div>
      <div class="payment-chip">T+0</div>
      <div class="payment-chip">FX</div>
    </div>
  </div>
  <div class="payment-rate">${2 + (absoluteIndex % 6)}m</div>
  <div class="payment-route">Route ${(absoluteIndex % 4) + 1}</div>
  <div class="payment-tail"></div>
</div>
''';
    }).join();

    return '''
<div class="group${groupIndex == 0 ? ' expanded' : ' collapsed'}">
  <div class="group-header">
    <div class="group-title">${groupTitles[groupIndex % groupTitles.length]}</div>
    <div class="group-count">${rowsPerGroup}</div>
  </div>
  <div class="group-body">$rows</div>
  <div class="show-more-row">
    <div class="show-more-label">Show more options</div>
    <div class="show-more-icon"></div>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.42 AlibabaSans, sans-serif;
      background: #e2e8f0;
      color: #0f172a;
    }
    #host {
      width: 378px;
      padding: 10px 0 0;
      box-sizing: border-box;
      display: flex;
      justify-content: center;
    }
    #summary-card {
      width: 100%;
      min-height: 72px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 18px 16px;
      border-radius: 16px;
      background: rgba(241, 245, 249, 0.92);
      box-sizing: border-box;
    }
    #summary-leading {
      display: flex;
      align-items: center;
      gap: 8px;
      min-width: 0;
      width: 240px;
      flex: 0 0 auto;
    }
    #summary-avatar {
      width: 32px;
      height: 32px;
      border-radius: 999px;
      background: linear-gradient(135deg, #2563eb, #0ea5e9);
      flex: 0 0 auto;
    }
    #summary-copy {
      display: block;
      width: 188px;
      min-width: 0;
      flex: 0 0 auto;
    }
    #summary-title {
      display: block;
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    #summary-subtitle {
      display: block;
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    #summary-caret {
      width: 20px;
      height: 18px;
      flex: 0 0 auto;
      background: linear-gradient(180deg, #94a3b8, #cbd5e1);
      clip-path: polygon(20% 0%, 100% 50%, 20% 100%, 0% 82%, 52% 50%, 0% 18%);
    }
    #sheet {
      width: 100%;
      display: flex;
      flex-direction: column;
      gap: 24px;
      padding: 16px 15px 18px;
      border-radius: 24px 24px 0 0;
      background: #ffffff;
      box-shadow: 0 -6px 28px rgba(15, 23, 42, 0.1);
      box-sizing: border-box;
    }
    #sheet-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    #sheet-title {
      width: 220px;
      flex: 0 0 auto;
      font-size: 19px;
      line-height: 26px;
      font-weight: 600;
    }
    #sheet-action {
      width: 60px;
      flex: 0 0 auto;
      color: #475569;
      font-size: 13px;
      line-height: 18px;
      text-align: right;
    }
    #content {
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
    .group {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .group-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .group-title {
      width: 220px;
      flex: 0 0 auto;
      font-size: 16px;
      line-height: 22px;
      font-weight: 600;
    }
    .group-count {
      width: 32px;
      flex: 0 0 auto;
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
      text-align: right;
    }
    .group-body {
      display: flex;
      flex-direction: column;
    }
    .payment-row {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 0;
      border-bottom: 1px solid rgba(226, 232, 240, 0.92);
      box-sizing: border-box;
    }
    .payment-row.selected {
      background: rgba(240, 249, 255, 0.9);
    }
    .payment-icon {
      width: 34px;
      height: 34px;
      flex: 0 0 auto;
      border-radius: 999px;
      background: linear-gradient(135deg, #2563eb, #0ea5e9);
      box-sizing: border-box;
    }
    .payment-status {
      width: 38px;
      flex: 0 0 auto;
      text-align: center;
      color: #0369a1;
      font-size: 11px;
      line-height: 18px;
      border-radius: 999px;
      background: rgba(186, 230, 253, 0.78);
      box-sizing: border-box;
    }
    .payment-copy {
      display: block;
      width: 188px;
      min-width: 0;
      flex: 0 0 auto;
    }
    .payment-title {
      display: block;
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    .payment-subtitle {
      display: block;
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .payment-badges {
      display: flex;
      flex-wrap: nowrap;
      align-items: center;
      gap: 4px;
      margin-top: 4px;
    }
    .payment-chip {
      width: 38px;
      flex: 0 0 auto;
      color: #475569;
      font-size: 10px;
      line-height: 16px;
      text-align: center;
      border-radius: 999px;
      background: rgba(226, 232, 240, 0.82);
      box-sizing: border-box;
    }
    .payment-rate {
      width: 46px;
      flex: 0 0 auto;
      color: #334155;
      font-size: 12px;
      line-height: 18px;
      text-align: center;
      box-sizing: border-box;
    }
    .payment-route {
      width: 82px;
      flex: 0 0 auto;
      color: #475569;
      font-size: 11px;
      line-height: 18px;
      text-align: center;
      border-radius: 999px;
      background: rgba(226, 232, 240, 0.84);
      box-sizing: border-box;
    }
    .payment-tail {
      width: 22px;
      height: 18px;
      flex: 0 0 auto;
      box-sizing: border-box;
      background: linear-gradient(180deg, #94a3b8, #cbd5e1);
      clip-path: polygon(20% 0%, 100% 50%, 20% 100%, 0% 82%, 52% 50%, 0% 18%);
    }
    .show-more-row {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
      color: #0f172a;
      font-size: 13px;
      line-height: 18px;
    }
    .show-more-label {
      width: 140px;
      flex: 0 0 auto;
      text-align: center;
    }
    .show-more-icon {
      width: 16px;
      height: 16px;
      flex: 0 0 auto;
      background: linear-gradient(180deg, #94a3b8, #cbd5e1);
      clip-path: polygon(50% 100%, 0 25%, 18% 0, 50% 56%, 82% 0, 100% 25%);
    }
    .group.expanded .show-more-row {
      display: none;
    }
    .group.collapsed .payment-row.extra {
      display: none;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="summary-card">
      <div id="summary-leading">
        <div id="summary-avatar"></div>
        <div id="summary-copy">
          <div id="summary-title">Card</div>
          <div id="summary-subtitle">Visa **** 1234</div>
        </div>
      </div>
      <div id="summary-caret"></div>
    </div>
    <flutter-bottom-sheet id="payment-sheet" title="Select Payment Method" primary-btn-title="Confirm">
      <flutter-popup-item id="sheet-popup-item">
        <div id="sheet">
          <div id="sheet-header">
            <div id="sheet-title">Select payment method</div>
            <div id="sheet-action">Confirm</div>
          </div>
          <div id="content">$groups</div>
        </div>
      </flutter-popup-item>
    </flutter-bottom-sheet>
  </div>
</body>
</html>
''';
}

String _buildPaymentMethodPickerModalHtml() {
  String buildAccounts(String prefix, int count) {
    return List<String>.generate(count, (int index) {
      final bool selected = index == 0;
      final String selectedClass = selected ? ' selected' : '';
      return '''
<div class="account-row$selectedClass">
  <span class="account-radio"></span>
  <div class="account-name">${prefix} ${(index % 2 == 0) ? 'IBAN' : 'Acct'} ****${4200 + index}</div>
  <span class="account-badge">${index.isEven ? 'Ready' : 'Saved'}</span>
</div>
''';
    }).join();
  }

  String buildMethodCard({
    required String id,
    required String title,
    required String price,
    required String description,
    required String accounts,
    String? tag,
    bool selected = false,
    bool expanded = false,
  }) {
    final String selectedClass = selected ? ' selected' : '';
    final String expandedClass = expanded ? ' expanded' : ' collapsed';
    final String tagHtml = tag == null
        ? ''
        : '<span class="method-tag">$tag</span>';
    return '''
<div class="method-card$selectedClass$expandedClass" data-method="$id">
  <div class="method-header">
    <div class="method-leading">
      <div class="method-avatar"></div>
      <div class="method-copy">
        <div class="method-topline">
          <div class="method-title">$title</div>
          $tagHtml
        </div>
        <div class="method-desc">$description</div>
      </div>
    </div>
    <div class="method-side">
      <div class="method-price">$price</div>
      <div class="method-expand">▾</div>
    </div>
  </div>
  <div class="account-panel">
    $accounts
    <div class="add-account">
      <span class="add-account-icon">＋</span>
      <span class="add-account-label">Add account</span>
    </div>
  </div>
</div>
''';
  }

  final String openBankingCard = buildMethodCard(
    id: 'open-banking',
    title: 'Open Banking',
    price: '1.002 EUR',
    description: '到账约 1-10 分钟 Fast settle العربية',
    accounts: buildAccounts('Barclays', 3),
    tag: 'Best Price',
    selected: true,
    expanded: true,
  );
  final String cardPayCard = buildMethodCard(
    id: 'card-pay',
    title: 'Card',
    price: '1.008 EUR',
    description: 'Visa / Mastercard ไทย immediate',
    accounts: buildAccounts('Visa', 4),
    tag: 'Recommended',
  );
  final String bankTransferCard = buildMethodCard(
    id: 'bank-transfer',
    title: 'Bank Transfer',
    price: '1.011 EUR',
    description: 'SEPA rail payout 日本語 review',
    accounts: buildAccounts('SEPA', 4),
  );
  final String cvPayCard = buildMethodCard(
    id: 'cvpay',
    title: 'CVPAY',
    price: '1.013 EUR',
    description: 'Pending maintenance in 2 hours',
    accounts: buildAccounts('VietQR', 2),
  );

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.42 AlibabaSans, sans-serif;
      background: #f8fafc;
      color: #0f172a;
    }
    #host {
      width: 378px;
      padding: 10px;
      box-sizing: border-box;
    }
    #summary-card {
      min-height: 76px;
      padding: 19px 17px;
      border-radius: 12px;
      background: rgba(241, 245, 249, 0.92);
      box-sizing: border-box;
    }
    #summary-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }
    #summary-leading {
      display: flex;
      min-width: 0;
      flex: 1 1 auto;
      align-items: center;
      gap: 8px;
      padding-inline-end: 16px;
    }
    #summary-avatar {
      width: 32px;
      height: 32px;
      border-radius: 999px;
      background: #dbeafe;
      flex: 0 0 auto;
    }
    #summary-copy {
      display: flex;
      min-width: 0;
      flex: 1 1 auto;
      flex-direction: column;
      gap: 4px;
    }
    #summary-title {
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    #summary-subtitle {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    #summary-side {
      position: relative;
      flex: 0 0 auto;
      font-weight: 600;
    }
    #summary-caret {
      padding-inline-end: 24px;
      color: #64748b;
    }
    #summary-badge {
      position: absolute;
      top: 0;
      inset-inline-end: 0;
      width: 8px;
      height: 8px;
      border-radius: 999px;
      background: #ef4444;
    }
    #payment-modal {
      display: block;
    }
    #sheet-root {
      display: block;
      width: 364px;
      padding: 3px 0 5px;
      box-sizing: border-box;
    }
    .section {
      display: flex;
      flex-direction: column;
      gap: 12px;
      margin-bottom: 24px;
    }
    .section-title {
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    .cards {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .method-card {
      overflow: hidden;
      border: 1px solid transparent;
      border-radius: 12px;
      background: rgba(248, 250, 252, 0.96);
      box-sizing: border-box;
    }
    .method-card.selected {
      border-color: #3b82f6;
    }
    .method-header {
      display: flex;
      width: 100%;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
      padding: 15px 16px;
      box-sizing: border-box;
    }
    .method-leading {
      display: flex;
      min-width: 0;
      flex: 1 1 auto;
      align-items: center;
      gap: 8px;
      padding-inline-end: 14px;
    }
    .method-avatar {
      width: 32px;
      height: 32px;
      border-radius: 999px;
      background: linear-gradient(135deg, #2563eb, #38bdf8);
      flex: 0 0 auto;
    }
    .method-copy {
      display: flex;
      min-width: 0;
      width: 188px;
      flex: 0 1 auto;
      flex-direction: column;
      gap: 4px;
    }
    .method-topline {
      display: flex;
      align-items: center;
      gap: 8px;
      min-width: 0;
    }
    .method-title {
      min-width: 0;
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 500;
    }
    .method-tag {
      width: 72px;
      flex: 0 0 auto;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border-radius: 4px 4px 0 0;
      background: #2563eb;
      color: #ffffff;
      font-size: 11px;
      line-height: 16px;
      padding: 2px 6px;
      box-sizing: border-box;
    }
    .method-desc {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .method-side {
      display: flex;
      align-items: center;
      gap: 8px;
      flex: 0 0 auto;
    }
    .method-price {
      width: 64px;
      color: #0f172a;
      font-size: 14px;
      line-height: 20px;
      font-weight: 600;
      text-align: right;
    }
    .method-expand {
      width: 18px;
      color: #64748b;
      text-align: center;
      flex: 0 0 auto;
    }
    .account-panel {
      border-top: 1px solid rgba(203, 213, 225, 0.9);
      padding: 0 16px 10px;
      box-sizing: border-box;
    }
    .method-card.collapsed .account-panel {
      display: none;
    }
    .account-row {
      display: flex;
      align-items: center;
      gap: 8px;
      padding-top: 8px;
      opacity: 0.96;
    }
    .account-row.selected {
      opacity: 1;
    }
    .account-radio {
      width: 14px;
      height: 14px;
      border-radius: 999px;
      border: 1px solid #94a3b8;
      background: #ffffff;
      flex: 0 0 auto;
      box-sizing: border-box;
    }
    .account-row.selected .account-radio {
      border-color: #2563eb;
      background: #2563eb;
    }
    .account-name {
      width: calc(100% - 96px);
      min-width: 0;
      color: #0f172a;
      font-size: 14px;
      line-height: 20px;
    }
    .account-badge {
      width: 40px;
      color: #64748b;
      font-size: 11px;
      line-height: 16px;
      text-align: center;
      flex: 0 0 auto;
    }
    .add-account {
      display: inline-flex;
      min-height: 44px;
      align-items: center;
      color: #2563eb;
      padding-top: 8px;
    }
    .add-account-icon {
      margin-inline-end: 8px;
      font-size: 14px;
    }
    .extra-cards {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .secondary-group.extra-hidden .extra-cards {
      display: none;
    }
    .show-more-row {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
      color: #0f172a;
      font-size: 13px;
      line-height: 18px;
      padding-top: 2px;
    }
    .secondary-group.extra-visible .show-more-row {
      display: none;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="summary-card">
      <div id="summary-row">
        <div id="summary-leading">
          <div id="summary-avatar"></div>
          <div id="summary-copy">
            <div id="summary-title">Card</div>
            <div id="summary-subtitle">Visa **** 1234</div>
          </div>
        </div>
        <div id="summary-side">
          <span id="summary-caret">▾</span>
          <span id="summary-badge"></span>
        </div>
      </div>
    </div>
    <flutter-modal-popup id="payment-modal">
      <flutter-portal-popup-item id="sheet-root">
        <div class="section recommended-group">
          <div class="section-title">Recommended</div>
          <div class="cards">$openBankingCard</div>
        </div>
        <div id="secondary-group" class="section secondary-group extra-hidden">
          <div class="section-title">Bank cards and transfer</div>
          <div class="cards">
            $cardPayCard
            $bankTransferCard
          </div>
          <div class="extra-cards">$cvPayCard</div>
          <div class="show-more-row">
            <span class="show-more-label">Show more</span>
            <span class="show-more-icon">▾</span>
          </div>
        </div>
      </flutter-portal-popup-item>
    </flutter-modal-popup>
  </div>
</body>
</html>
''';
}

String _buildPaymentMethodOtcSourceSheetHtml({
  required int sectionCount,
  required int cardsPerSection,
  required int accountsPerCard,
}) {
  const List<String> sectionTitles = <String>[
    'Recommended methods',
    'More payment methods',
    'Popular rails',
  ];
  const List<String> cardTitles = <String>[
    'Open Banking',
    'Bank Transfer',
    'Card',
    'PIX',
    'SEPA',
    'Wallet Pay',
    'Ideal',
  ];
  const List<String> cardDescriptions = <String>[
    '到账约 1-10 分钟 العربية',
    'Fast settle ไทย',
    'Low fee 日本語',
    'Pending review عربى',
    'Wide coverage English',
    'Priority rail ไทย',
  ];
  const List<String> accountPrefixes = <String>[
    'Barclays',
    'HSBC',
    'SEPA',
    'PIX',
    'Ideal',
    'Visa',
  ];

  String buildAccountRows(int cardIndex) {
    return List<String>.generate(accountsPerCard, (int accountIndex) {
      final bool selected = accountIndex == 0 && cardIndex.isEven;
      final String selectedClass = selected ? ' selected' : '';
      final String statusText =
          accountIndex % 3 == 0 ? 'Ready' : (accountIndex % 3 == 1 ? 'Pending' : 'Saved');
      return '''
<div class="otc-account-row$selectedClass">
  <div class="otc-account-radio"></div>
  <div class="otc-account-box">
    <div class="otc-account-item">
      <div class="otc-account-main">
        <div class="otc-account-icon"></div>
        <div class="otc-account-copy">
          <div class="otc-account-name-row">
            <span class="otc-account-name">${accountPrefixes[(cardIndex + accountIndex) % accountPrefixes.length]} IBAN ****${4200 + cardIndex * 7 + accountIndex}</span>
          </div>
          <div class="otc-account-description">${cardDescriptions[(cardIndex + accountIndex) % cardDescriptions.length]}</div>
        </div>
        <div class="otc-account-status">$statusText</div>
      </div>
      <div class="otc-account-delete"></div>
    </div>
  </div>
</div>
''';
    }).join();
  }

  String buildCards(int sectionIndex) {
    return List<String>.generate(cardsPerSection, (int cardIndex) {
      final int absoluteIndex = sectionIndex * cardsPerSection + cardIndex;
      final bool extra = cardIndex >= 4;
      final bool selected = absoluteIndex == 1;
      final bool expanded = cardIndex < 3;
      final String extraClass = extra ? ' extra' : '';
      final String selectedClass = selected ? ' selected' : '';
      final String expandedClass = expanded ? ' expanded' : ' collapsed';
      final String title = cardTitles[absoluteIndex % cardTitles.length];
      final String description =
          '${cardDescriptions[absoluteIndex % cardDescriptions.length]} ${(absoluteIndex % 4) + 1}';
      final String tag = absoluteIndex % 3 == 0
          ? 'Best Price'
          : (absoluteIndex % 3 == 1 ? '0 Fee' : 'Popular');
      return '''
<div class="otc-card$extraClass$selectedClass$expandedClass" data-extra="${extra ? 'true' : 'false'}" style="order: ${absoluteIndex % cardsPerSection};">
  <div class="otc-card-header">
    <div class="otc-card-leading">
      <div class="otc-card-icon"></div>
      <div class="otc-card-copy">
        <div class="otc-card-title-shell">
          <div class="otc-card-name-row">
            <span class="otc-card-name">$title</span>
            <span class="otc-card-expand"></span>
          </div>
          <span class="otc-card-tag">$tag</span>
        </div>
        <div class="otc-card-description">$description</div>
      </div>
    </div>
    <div class="otc-card-price">${(1 + ((absoluteIndex % 7) / 1000)).toStringAsFixed(3)} EUR</div>
  </div>
  <div class="otc-card-divider"></div>
  <div class="otc-card-children">
    ${buildAccountRows(absoluteIndex)}
    <div class="otc-add-account">
      <span class="otc-add-account-icon">＋</span>
      <span class="otc-add-account-label">Add account</span>
    </div>
  </div>
</div>
''';
    }).join();
  }

  final String sections = List<String>.generate(sectionCount, (int sectionIndex) {
    final bool expanded = sectionIndex == 0;
    return '''
<div class="otc-section${expanded ? ' expanded' : ' collapsed'}" data-section="${sectionIndex + 1}">
  <div class="otc-section-header">
    <div class="otc-section-title-row">
      <div class="otc-section-title">${sectionTitles[sectionIndex % sectionTitles.length]}</div>
      <div class="otc-section-tooltip"></div>
    </div>
    <div class="otc-section-description">Grouped quote list with order-based card rendering</div>
  </div>
  <div class="otc-section-body">
    ${buildCards(sectionIndex)}
    <div class="otc-show-more-row">
      <span class="otc-show-more-label">Show more</span>
      <span class="otc-show-more-icon"></span>
    </div>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.42 AlibabaSans, sans-serif;
      background: #e2e8f0;
      color: #0f172a;
    }
    #host {
      width: 378px;
      padding: 10px 0 0;
      box-sizing: border-box;
      display: flex;
      justify-content: center;
    }
    #sheet-root {
      width: 100%;
      display: flex;
      flex-direction: column;
      gap: 24px;
      padding: 16px 15px 21px;
      border-radius: 24px 24px 0 0;
      background: #ffffff;
      box-sizing: border-box;
      box-shadow: 0 -6px 28px rgba(15, 23, 42, 0.1);
    }
    #sections {
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
    .otc-section {
      position: relative;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .otc-section-header {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .otc-section-title-row {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .otc-section-title {
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
    }
    .otc-section-tooltip {
      width: 14px;
      height: 14px;
      flex: 0 0 auto;
      border-radius: 999px;
      background: rgba(148, 163, 184, 0.9);
    }
    .otc-section-description {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .otc-section-body {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .otc-card {
      overflow: hidden;
      border: 1px solid transparent;
      border-radius: 12px;
      background: rgba(248, 250, 252, 0.96);
      box-sizing: border-box;
    }
    .otc-card.selected {
      border-color: #3b82f6;
    }
    .otc-card.disabled {
      background: rgba(241, 245, 249, 0.92);
    }
    .otc-card.extra {
      display: none;
    }
    .otc-section.expanded .otc-card.extra {
      display: block;
    }
    .otc-card.collapsed .otc-card-children,
    .otc-card.collapsed .otc-card-divider {
      display: none;
    }
    .otc-card-header {
      position: relative;
      box-sizing: border-box;
      display: flex;
      align-items: center;
      justify-content: space-between;
      overflow-x: hidden;
      padding: 16px 12px;
    }
    .otc-card-leading {
      display: flex;
      min-height: 32px;
      min-width: 0;
      flex-shrink: 1;
      align-items: center;
      gap: 8px;
      padding-right: 16px;
    }
    .otc-card-icon {
      width: 32px;
      height: 32px;
      flex: 0 0 auto;
      border-radius: 999px;
      background: linear-gradient(135deg, #2563eb, #38bdf8);
    }
    .otc-card-copy {
      display: flex;
      min-width: 0;
      width: 190px;
      flex-direction: column;
      gap: 4px;
    }
    .otc-card-title-shell {
      position: relative;
      display: flex;
      min-width: 0;
      align-items: center;
      gap: 8px;
    }
    .otc-card-name-row {
      display: flex;
      min-width: 0;
      align-items: center;
      gap: 8px;
      overflow: hidden;
    }
    .otc-card-name {
      min-width: 0;
      color: #0f172a;
      font-size: 15px;
      line-height: 20px;
      font-weight: 600;
      white-space: nowrap;
    }
    .otc-card-expand {
      width: 18px;
      height: 18px;
      flex: 0 0 auto;
      background: linear-gradient(180deg, #94a3b8, #cbd5e1);
      clip-path: polygon(50% 100%, 0 25%, 18% 0, 50% 56%, 82% 0, 100% 25%);
    }
    .otc-card-tag {
      width: 74px;
      flex: 0 0 auto;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border-radius: 4px 4px 0 0;
      background: #2563eb;
      color: #ffffff;
      font-size: 11px;
      line-height: 16px;
      padding: 2px 6px;
      box-sizing: border-box;
    }
    .otc-card-description {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .otc-card-price {
      width: 70px;
      flex: 0 0 auto;
      color: #0f172a;
      font-size: 14px;
      line-height: 20px;
      text-align: right;
      font-weight: 600;
    }
    .otc-card-divider {
      border-top: 1px solid rgba(203, 213, 225, 0.9);
    }
    .otc-card-children {
      display: flex;
      flex-direction: column;
      padding: 0 12px 10px;
      box-sizing: border-box;
    }
    .otc-account-row {
      display: flex;
      align-items: center;
      gap: 8px;
      padding-top: 8px;
    }
    .otc-account-radio {
      width: 14px;
      height: 14px;
      flex: 0 0 auto;
      border-radius: 999px;
      border: 1px solid #94a3b8;
      box-sizing: border-box;
      background: #ffffff;
    }
    .otc-account-row.selected .otc-account-radio {
      border-color: #2563eb;
      background: #2563eb;
    }
    .otc-account-box {
      position: relative;
      overflow-x: hidden;
      width: calc(100% - 32px);
      color: #0f172a;
      font-size: 14px;
      line-height: 20px;
    }
    .otc-account-item {
      display: flex;
      min-width: 0;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
    }
    .otc-account-main {
      display: flex;
      min-width: 0;
      flex: 1 1 auto;
      align-items: center;
      gap: 8px;
    }
    .otc-account-icon {
      width: 18px;
      height: 18px;
      flex: 0 0 auto;
      border-radius: 999px;
      background: linear-gradient(135deg, #22c55e, #14b8a6);
    }
    .otc-account-copy {
      display: flex;
      min-width: 0;
      flex: 1 1 auto;
      flex-direction: column;
      gap: 4px;
    }
    .otc-account-name-row {
      display: flex;
      min-width: 0;
      align-items: center;
      gap: 4px;
    }
    .otc-account-name {
      min-width: 0;
      color: #0f172a;
      font-size: 14px;
      line-height: 20px;
      white-space: nowrap;
    }
    .otc-account-description {
      color: #64748b;
      font-size: 12px;
      line-height: 18px;
    }
    .otc-account-status {
      width: 44px;
      flex: 0 0 auto;
      color: #64748b;
      font-size: 11px;
      line-height: 16px;
      text-align: center;
    }
    .otc-account-delete {
      width: 22px;
      height: 18px;
      flex: 0 0 auto;
      background: linear-gradient(180deg, #94a3b8, #cbd5e1);
      clip-path: polygon(20% 0%, 80% 0%, 100% 18%, 84% 100%, 16% 100%, 0% 18%);
    }
    .otc-add-account {
      display: inline-flex;
      min-height: 48px;
      align-items: center;
      color: #2563eb;
      padding-top: 8px;
    }
    .otc-add-account-icon {
      margin-right: 8px;
      font-size: 14px;
    }
    .otc-show-more-row {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 6px;
      color: #0f172a;
      font-size: 13px;
      line-height: 18px;
    }
    .otc-show-more-label {
      width: 90px;
      text-align: center;
      flex: 0 0 auto;
    }
    .otc-show-more-icon {
      width: 16px;
      height: 16px;
      flex: 0 0 auto;
      background: linear-gradient(180deg, #94a3b8, #cbd5e1);
      clip-path: polygon(50% 100%, 0 25%, 18% 0, 50% 56%, 82% 0, 100% 25%);
    }
    .otc-section.expanded .otc-show-more-row {
      display: none;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="sheet-root">
      <div id="sections">$sections</div>
    </div>
  </div>
</body>
</html>
''';
}

String _buildFlexInlineLayoutHtml({
  required int cardCount,
}) {
  final String cards = List<String>.generate(cardCount, (int index) {
    final int tone = index % 4;
    return '''
<div class="card tone$tone" data-card="${index + 1}">
  <div class="headline">
    <a class="eyebrow" href="#series-${index + 1}">series ${index + 1}</a>
    <span class="title">issue cluster ${index + 1}</span>
    <span class="chip priority">p${(index % 3) + 1}</span>
  </div>
  <div class="summary">
    <span class="copy">Long wrapped summary for inline layout and flex relayout sample ${index + 1}</span>
    <span class="chip status">active</span>
    <span class="copy emphasis">baseline measurement path ${index + 1}</span>
  </div>
  <div class="controls">
    <select class="picker">
      <option ${index.isEven ? 'selected' : ''}>watch</option>
      <option ${index.isOdd ? 'selected' : ''}>mute</option>
    </select>
    <input class="note" type="text" value="S${index + 1}" />
    <span class="chip status control-chip">active</span>
    <button class="mini-action" type="button">ack</button>
    <input class="flag" type="checkbox" ${index.isEven ? 'checked' : ''} />
  </div>
  <div class="meta">
    <span class="metric eta">ETA ${12 + (index % 9)}h</span>
    <span class="metric owner">owner ${index + 3}</span>
    <span class="chip soft">series-${(index % 5) + 1}</span>
    <span class="metric trailing">needs follow-up</span>
  </div>
  <div class="signals">
    <span class="signal owner-signal">triage ${index + 1}</span>
    <span class="signal route-signal">queue ${(index % 4) + 1}</span>
    <span class="chip signal-chip">hot</span>
    <span class="signal window-signal">w${(index % 6) + 2}</span>
  </div>
  <div class="badges">
    <span class="badge sprint-badge">sprint ${(index % 3) + 1}</span>
    <span class="badge lane-badge">lane ${(index % 5) + 1}</span>
    <span class="badge review-badge">review</span>
  </div>
  <div class="fastlane">
    <div class="slot fastlane-a">
      <span class="slot-copy">alpha issue ${index + 1}</span>
      <span class="slot-copy emphasis"> queue ${(index % 4) + 1}</span>
    </div>
    <div class="slot fastlane-b">
      <span class="slot-copy emphasis">مرحبا فريق ${(index % 7) + 1}</span>
      <span class="slot-copy"> window ${(index % 6) + 2}</span>
    </div>
    <div class="slot fastlane-c">
      <span class="chip slot-chip">lane ${(index % 5) + 1}</span>
      <span class="slot-copy"> hot</span>
    </div>
    <div class="slot fastlane-d">
      <span class="slot-copy">queue ${(index % 4) + 1} follow-up</span>
    </div>
  </div>
  <div class="handoff">
    <div class="slot handoff-a">
      <span class="slot-copy">owner ${(index % 6) + 2}</span>
      <span class="slot-copy emphasis"> review</span>
    </div>
    <div class="slot handoff-b">
      <span class="slot-copy">ไทย ${(index % 5) + 1}</span>
      <span class="slot-copy"> status</span>
    </div>
    <div class="slot handoff-c">
      <span class="chip slot-chip">p${(index % 3) + 1}</span>
      <span class="slot-copy"> audit</span>
    </div>
    <div class="slot handoff-d">
      <span class="slot-copy emphasis">follow-up detail ${(index % 8) + 1}</span>
    </div>
  </div>
  <div class="ribbon">
    <div class="cell ribbon-a">intl copy ${index + 1}</div>
    <div class="cell ribbon-b">مرحبا ${(index % 7) + 1}</div>
    <div class="cell ribbon-c">ไทย ${(index % 5) + 1}</div>
    <div class="cell ribbon-d">नमस्ते ${(index % 4) + 1}</div>
  </div>
  <div class="ledger">
    <div class="cell ledger-a">owner ${(index % 6) + 2}</div>
    <div class="cell ledger-b">queue ${(index % 4) + 1}</div>
    <div class="cell ledger-c">series ${(index % 5) + 1}</div>
    <div class="cell ledger-d">window ${(index % 8) + 3}</div>
  </div>
  <div class="trail">
    <div class="cell trail-a">alpha ${(index % 9) + 1}</div>
    <div class="cell trail-b">beta ${(index % 7) + 1}</div>
    <div class="cell trail-c">gamma ${(index % 6) + 1}</div>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.45 AlibabaSans, sans-serif;
      background: #ffffff;
    }
    #host {
      width: 360px;
      padding: 10px;
      border: 1px solid #d8dde6;
      box-sizing: border-box;
    }
    #board {
      display: flex;
      flex-wrap: nowrap;
      gap: 8px;
      align-items: flex-start;
      align-content: flex-start;
    }
    .card {
      display: flex;
      flex-direction: column;
      align-items: stretch;
      flex: 0 1 auto;
      width: 156px;
      min-width: 140px;
      padding: 8px 10px;
      border: 1px solid rgba(148, 163, 184, 0.45);
      border-radius: 12px;
      color: #0f172a;
      text-decoration: none;
      background: rgba(248, 250, 252, 0.96);
      box-sizing: border-box;
    }
    .headline,
    .controls,
    .signals,
    .badges,
    .fastlane,
    .handoff,
    .ribbon,
    .ledger,
    .trail,
    .summary,
    .meta {
      display: block;
    }
    .headline,
    .controls,
    .signals,
    .badges,
    .fastlane,
    .handoff,
    .ribbon,
    .ledger,
    .trail,
    .meta {
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 4px;
    }
    .headline {
      margin-bottom: 6px;
      line-height: 1.35;
    }
    .summary {
      text-indent: 6px;
      line-height: 1.55;
    }
    .controls {
      margin-top: 6px;
      line-height: 1.4;
    }
    .meta {
      margin-top: 6px;
      color: #475569;
      line-height: 1.4;
    }
    .signals,
    .badges,
    .fastlane,
    .handoff {
      margin-top: 6px;
      color: #334155;
      line-height: 1.35;
    }
    .ribbon,
    .ledger,
    .trail {
      margin-top: 6px;
      color: #334155;
      line-height: 1.35;
    }
    .headline > *,
    .signals > *,
    .badges > *,
    .fastlane > *,
    .handoff > *,
    .ribbon > *,
    .ledger > *,
    .trail > *,
    .meta > * {
      flex: 0 0 auto;
    }
    .controls > * {
      flex: 0 1 auto;
    }
    .eyebrow {
      width: 56px;
    }
    .title {
      display: block;
      width: 72px;
    }
    .priority {
      width: 42px;
      box-sizing: border-box;
    }
    .picker {
      width: 58px;
      min-width: 48px;
    }
    .note {
      width: 48px;
      min-width: 40px;
    }
    .control-chip {
      width: 52px;
      box-sizing: border-box;
      text-align: center;
    }
    .mini-action {
      width: 44px;
      min-width: 38px;
      height: 22px;
    }
    .flag {
      width: 18px;
      min-width: 18px;
    }
    .eta {
      width: 40px;
    }
    .owner {
      width: 48px;
    }
    .soft {
      width: 60px;
      box-sizing: border-box;
    }
    .trailing {
      width: 74px;
    }
    .owner-signal {
      width: 50px;
    }
    .route-signal {
      width: 54px;
    }
    .signal-chip {
      width: 38px;
      box-sizing: border-box;
      text-align: center;
    }
    .window-signal {
      width: 34px;
    }
    .sprint-badge {
      width: 58px;
      box-sizing: border-box;
    }
    .lane-badge {
      width: 52px;
      box-sizing: border-box;
    }
    .review-badge {
      width: 46px;
      box-sizing: border-box;
    }
    .slot {
      display: block;
    }
    .fastlane-a {
      width: 52px;
    }
    .fastlane-b {
      width: 48px;
    }
    .fastlane-c {
      width: 50px;
      box-sizing: border-box;
    }
    .fastlane-d {
      width: 46px;
    }
    .handoff-a {
      width: 50px;
    }
    .handoff-b {
      width: 40px;
    }
    .handoff-c {
      width: 36px;
      box-sizing: border-box;
      text-align: center;
    }
    .handoff-d {
      width: 56px;
    }
    .cell {
      display: block;
    }
    .ribbon-a {
      width: 50px;
    }
    .ribbon-b {
      width: 48px;
    }
    .ribbon-c {
      width: 38px;
    }
    .ribbon-d {
      width: 46px;
    }
    .ledger-a {
      width: 46px;
    }
    .ledger-b {
      width: 44px;
    }
    .ledger-c {
      width: 46px;
    }
    .ledger-d {
      width: 52px;
    }
    .trail-a {
      width: 54px;
    }
    .trail-b {
      width: 48px;
    }
    .trail-c {
      width: 52px;
    }
    .eyebrow {
      color: #64748b;
      text-decoration: none;
    }
    .title {
      font-weight: 700;
    }
    .copy {
      color: #1e293b;
    }
    .slot-copy {
      color: #1e293b;
    }
    .copy.emphasis {
      font-style: italic;
    }
    .slot-copy.emphasis {
      font-style: italic;
    }
    .metric.trailing {
      font-style: italic;
    }
    .chip {
      display: block;
      padding: 1px 7px;
      border-radius: 999px;
      border: 1px solid rgba(59, 130, 246, 0.24);
      background: rgba(191, 219, 254, 0.38);
      font-size: 12px;
      line-height: 18px;
      vertical-align: middle;
    }
    .picker,
    .note,
    .mini-action {
      vertical-align: middle;
      font: inherit;
      line-height: 18px;
      height: 22px;
    }
    .note {
      padding: 0 4px;
      box-sizing: border-box;
    }
    .flag {
      display: block;
      margin: 0 auto;
      vertical-align: middle;
    }
    #board.phase-1 .card {
      width: 148px;
    }
    #board.phase-1 .headline {
      font-style: italic;
    }
    #board.phase-1 .summary {
      text-indent: 10px;
      line-height: 1.62;
    }
    #board.phase-1 .title {
      width: 68px;
    }
    #board.phase-1 .trailing {
      width: 68px;
    }
    #board.phase-1 .fastlane-a {
      width: 58px;
    }
    #board.phase-1 .fastlane-b {
      width: 52px;
    }
    #board.phase-1 .handoff-a {
      width: 54px;
    }
    #board.phase-1 .handoff-d {
      width: 60px;
    }
    #board.phase-1 .ribbon-b {
      width: 52px;
    }
    #board.phase-1 .ledger-a {
      width: 50px;
    }
    #board.phase-2 .card {
      width: 168px;
    }
    #board.phase-2 .chip {
      padding: 2px 9px;
      font-size: 13px;
    }
    #board.phase-2 .control-chip {
      width: 58px;
    }
    #board.phase-2 .soft {
      width: 66px;
    }
    #board.phase-2 .route-signal {
      width: 58px;
    }
    #board.phase-2 .lane-badge {
      width: 56px;
    }
    #board.phase-2 .fastlane-a {
      width: 56px;
    }
    #board.phase-2 .fastlane-c {
      width: 54px;
    }
    #board.phase-2 .fastlane-d {
      width: 50px;
    }
    #board.phase-2 .handoff-b {
      width: 44px;
    }
    #board.phase-2 .handoff-c {
      width: 40px;
    }
    #board.phase-2 .handoff-d {
      width: 60px;
    }
    #board.phase-2 .ribbon-a {
      width: 54px;
    }
    #board.phase-2 .ribbon-c {
      width: 42px;
    }
    #board.phase-2 .ledger-d {
      width: 56px;
    }
    #board.phase-2 .note {
      width: 54px;
    }
    #board.phase-2 .trail-b {
      width: 52px;
    }
    #board.phase-2 .copy.emphasis {
      font-weight: 700;
    }
    #board.phase-3 .summary {
      word-break: break-word;
      line-height: 1.7;
    }
    #board.phase-3 .meta {
      letter-spacing: 0.2px;
    }
    #board.phase-3 .headline {
      gap: 3px;
    }
    #board.phase-3 .controls {
      gap: 3px;
    }
    #board.phase-3 .owner-signal {
      width: 54px;
    }
    #board.phase-3 .review-badge {
      width: 42px;
    }
    #board.phase-3 .fastlane-b {
      width: 52px;
    }
    #board.phase-3 .fastlane-c {
      width: 46px;
    }
    #board.phase-3 .handoff-a {
      width: 54px;
    }
    #board.phase-3 .handoff-d {
      width: 62px;
    }
    #board.phase-3 .ledger-c {
      width: 50px;
    }
    #board.phase-3 .trail-a {
      width: 58px;
    }
    #board.phase-3 .trail-c {
      width: 56px;
    }
    #board.phase-3 .picker {
      width: 62px;
    }
    #board.phase-3 .mini-action {
      width: 40px;
    }
    .tone0 .priority {
      background: rgba(253, 230, 138, 0.55);
    }
    .tone1 .priority {
      background: rgba(187, 247, 208, 0.55);
    }
    .tone2 .priority {
      background: rgba(216, 180, 254, 0.45);
    }
    .tone3 .priority {
      background: rgba(254, 205, 211, 0.5);
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="board">$cards</div>
  </div>
</body>
</html>
''';
}

String _buildFlexAdjustFastPathHtml({
  required int cardCount,
}) {
  final String cards = List<String>.generate(cardCount, (int index) {
    return '''
<div class="card tone${index % 4}" data-card="${index + 1}">
  <div class="queue">
    <div class="fixed pill severity">p${(index % 3) + 1}</div>
    <div class="fixed lane">lane ${(index % 5) + 1}</div>
    <div class="fixed zone">z${(index % 4) + 1}</div>
    <div class="copy-box copy-a">alpha issue ${index + 1} window ${(index % 6) + 2}</div>
    <div class="copy-box copy-b emphasis">queue ${(index % 4) + 1} review ${(index % 3) + 2}</div>
    <div class="fixed ack">ack ${(index % 3) + 1}</div>
    <div class="fixed badge">hot</div>
  </div>
  <div class="owners">
    <div class="fixed owner">owner ${(index % 6) + 2}</div>
    <div class="fixed shift">shift ${(index % 3) + 1}</div>
    <div class="copy-box copy-c emphasis">مرحبا ${(index % 7) + 1} handoff ${(index % 5) + 1}</div>
    <div class="note-box note-a">watch ${(index % 4) + 1} sync ${(index % 3) + 1}</div>
    <div class="fixed eta">ETA ${12 + (index % 8)}h</div>
    <div class="fixed score">s${(index % 5) + 3}</div>
  </div>
  <div class="notes">
    <div class="fixed chip chip-fixed">ไทย ${(index % 5) + 1}</div>
    <div class="fixed chip chip-fixed">k${(index % 4) + 2}</div>
    <div class="note-box note-b">follow-up ${(index % 8) + 1} stays pending</div>
    <div class="pack-box pack-a">
      <span class="swatch short"></span>
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <div class="fixed chip subtle">w${(index % 4) + 2}</div>
  </div>
  <div class="signals">
    <div class="fixed marker">m${(index % 6) + 1}</div>
    <div class="fixed marker">r${(index % 5) + 2}</div>
    <div class="copy-box copy-d">signal ${(index % 7) + 1} review ${(index % 3) + 1}</div>
    <div class="note-box note-c">route ${(index % 4) + 1} hold ${(index % 5) + 1}</div>
    <div class="fixed marker">g${(index % 4) + 3}</div>
  </div>
  <div class="controls">
    <input class="fixed picker" value="slot ${(index % 5) + 1}" />
    <select class="fixed route-select">
      <option>route ${(index % 4) + 1}</option>
      <option>route ${(index % 4) + 2}</option>
    </select>
    <div class="fixed mini-action">go</div>
    <div class="note-box note-d">gate ${(index % 4) + 1} check ${(index % 5) + 1}</div>
    <div class="fixed mini-action">ok</div>
  </div>
  <div class="rack">
    <input class="fixed picker picker-b" value="ack ${(index % 4) + 1}" />
    <div class="copy-box copy-e">handoff ${(index % 4) + 1} queue ${(index % 3) + 1}</div>
    <select class="fixed route-select route-select-b">
      <option>lane ${(index % 4) + 1}</option>
      <option>lane ${(index % 4) + 2}</option>
    </select>
    <div class="pack-box pack-b">
      <span class="swatch"></span>
      <span class="swatch short"></span>
      <span class="swatch"></span>
    </div>
    <div class="note-box note-e">trace ${(index % 5) + 2} hold ${(index % 4) + 1}</div>
    <div class="fixed marker">x${(index % 4) + 2}</div>
  </div>
  <div class="rack">
    <div class="fixed marker">j${(index % 6) + 1}</div>
    <div class="copy-box copy-f">merge ${(index % 5) + 1} queue ${(index % 4) + 1}</div>
    <div class="note-box note-f">watch ${(index % 6) + 1} lane ${(index % 3) + 1}</div>
    <input class="fixed picker picker-c" value="w${(index % 4) + 1}" />
    <div class="pack-box pack-c">
      <span class="swatch short"></span>
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <div class="fixed marker">v${(index % 3) + 3}</div>
  </div>
  <div class="rack review">
    <select class="fixed route-select route-select-c">
      <option>node ${(index % 4) + 1}</option>
      <option>node ${(index % 4) + 2}</option>
    </select>
    <div class="copy-box copy-g emphasis">مرحبا ${(index % 6) + 2} lane ${(index % 3) + 1}</div>
    <div class="note-box note-g">lag ${(index % 6) + 1} review ${(index % 4) + 1}</div>
    <div class="pack-box pack-d">
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <div class="fixed mini-action">hi</div>
  </div>
  <div class="rack ops">
    <div class="fixed marker">c${(index % 6) + 1}</div>
    <div class="copy-box copy-h">packet ${(index % 5) + 1} queue ${(index % 4) + 2}</div>
    <div class="note-box note-h">hold ${(index % 5) + 1} lane ${(index % 3) + 1}</div>
    <input class="fixed picker picker-c" value="g${(index % 4) + 1}" />
    <div class="pack-box pack-e">
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <select class="fixed route-select route-select-b">
      <option>mesh ${(index % 4) + 1}</option>
      <option>mesh ${(index % 4) + 2}</option>
    </select>
  </div>
  <div class="rack ops">
    <select class="fixed route-select route-select-c">
      <option>cell ${(index % 4) + 1}</option>
      <option>cell ${(index % 4) + 2}</option>
    </select>
    <div class="copy-box copy-i emphasis">مرحبا ${(index % 6) + 2} route ${(index % 3) + 1}</div>
    <div class="note-box note-i">sync ${(index % 4) + 1} gate ${(index % 5) + 1}</div>
    <div class="fixed mini-action">ok</div>
    <div class="pack-box pack-f">
      <span class="swatch short"></span>
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <div class="fixed marker">q${(index % 4) + 2}</div>
  </div>
  <div class="rack ops">
    <input class="fixed picker picker-b" value="m${(index % 5) + 1}" />
    <div class="copy-box copy-j">queue ${(index % 6) + 1} watch ${(index % 4) + 1}</div>
    <div class="pack-box pack-g">
      <span class="swatch"></span>
      <span class="swatch"></span>
    </div>
    <div class="note-box note-j">gate ${(index % 5) + 1} sync ${(index % 4) + 1}</div>
    <select class="fixed route-select route-select-c">
      <option>flow ${(index % 4) + 1}</option>
      <option>flow ${(index % 4) + 2}</option>
    </select>
    <div class="fixed marker">r${(index % 4) + 1}</div>
  </div>
  <div class="summary">
    <span class="copy">Inline sample ${index + 1}</span>
    <span class="chip status">active</span>
    <span class="copy emphasis">baseline ${index + 1}</span>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.45 AlibabaSans, sans-serif;
      background: #ffffff;
    }
    #host {
      width: 360px;
      padding: 10px;
      border: 1px solid #d8dde6;
      box-sizing: border-box;
    }
    #board {
      display: flex;
      flex-wrap: nowrap;
      gap: 8px;
      align-items: flex-start;
      align-content: flex-start;
    }
    .card {
      display: block;
      flex: 0 0 auto;
      min-width: 136px;
      max-width: 170px;
      padding: 8px 10px;
      border: 1px solid rgba(148, 163, 184, 0.45);
      border-radius: 12px;
      color: #0f172a;
      background: rgba(248, 250, 252, 0.96);
      box-sizing: border-box;
    }
    .queue,
    .owners,
    .notes,
    .signals,
    .controls,
    .rack {
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 4px;
      margin-top: 6px;
      line-height: 1.35;
      color: #334155;
    }
    .queue {
      margin-top: 0;
    }
    .summary {
      margin-top: 6px;
      text-indent: 6px;
      line-height: 1.55;
    }
    .fixed {
      flex: 0 0 auto;
    }
    .copy-box,
    .note-box,
    .pack-box {
      flex: 0 0 auto;
      display: block;
      min-width: 0;
      box-sizing: border-box;
      color: #1e293b;
    }
    .copy-box,
    .note-box,
    .copy {
      overflow-wrap: anywhere;
      word-break: break-word;
    }
    .copy-box.emphasis,
    .copy.emphasis {
      font-style: italic;
    }
    .copy-box {
      width: 64px;
    }
    .note-box {
      width: 52px;
    }
    .pack-box {
      width: 34px;
      display: flex;
      align-items: flex-start;
      gap: 2px;
      padding: 1px 2px;
      border-radius: 999px;
      background: rgba(203, 213, 225, 0.35);
    }
    .picker,
    .route-select,
    .mini-action {
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
    }
    .picker {
      width: 72px;
    }
    .picker-b {
      width: 66px;
    }
    .picker-c {
      width: 58px;
    }
    .route-select {
      width: 66px;
    }
    .route-select-b {
      width: 58px;
    }
    .route-select-c {
      width: 62px;
    }
    .mini-action {
      width: 38px;
      padding: 2px 4px;
    }
    .severity {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .lane {
      width: 44px;
    }
    .zone {
      width: 30px;
    }
    .ack {
      width: 36px;
    }
    .badge {
      width: 36px;
      text-align: center;
      box-sizing: border-box;
    }
    .owner {
      width: 50px;
    }
    .shift {
      width: 42px;
    }
    .eta {
      width: 42px;
    }
    .score {
      width: 26px;
    }
    .marker {
      width: 28px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip.subtle {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip-fixed {
      width: 24px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip {
      display: block;
      padding: 1px 7px;
      border-radius: 999px;
      border: 1px solid rgba(59, 130, 246, 0.24);
      background: rgba(191, 219, 254, 0.38);
      font-size: 12px;
      line-height: 18px;
      vertical-align: middle;
    }
    .copy {
      color: #1e293b;
    }
    .swatch {
      flex: 0 0 auto;
      display: block;
      width: 10px;
      height: 10px;
      border-radius: 999px;
      background: rgba(59, 130, 246, 0.55);
    }
    .swatch.short {
      width: 8px;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="board">$cards</div>
  </div>
</body>
</html>
''';
}

String _buildFlexNestedGroupFastPathHtml({
  required int cardCount,
}) {
  final String cards = List<String>.generate(cardCount, (int index) {
    return '''
<div class="card tone${index % 4}" data-card="${index + 1}">
  <div class="queue">
    <div class="fixed pill severity">p${(index % 3) + 1}</div>
    <div class="fixed lane">lane ${(index % 5) + 1}</div>
    <div class="group-box group-a">
      <div class="seg seg-tag">a${(index % 4) + 1}</div>
      <div class="seg seg-copy">issue ${index + 1}</div>
      <div class="seg seg-tail">q${(index % 3) + 1}</div>
    </div>
    <div class="group-box group-b emphasis">
      <div class="seg seg-tag">b${(index % 4) + 1}</div>
      <div class="seg seg-copy">queue ${(index % 6) + 2}</div>
      <div class="seg seg-tail">r${(index % 3) + 2}</div>
    </div>
    <div class="fixed badge">hot</div>
  </div>
  <div class="owners">
    <div class="fixed owner">owner ${(index % 6) + 2}</div>
    <div class="fixed shift">shift ${(index % 3) + 1}</div>
    <div class="group-box group-c emphasis">
      <div class="seg seg-tag">م</div>
      <div class="seg seg-copy">مرحبا ${(index % 7) + 1}</div>
      <div class="seg seg-tail">h${(index % 5) + 1}</div>
    </div>
    <div class="group-box group-d">
      <div class="seg seg-tag">n${(index % 4) + 1}</div>
      <div class="seg seg-note">watch ${(index % 4) + 1}</div>
      <div class="seg seg-tail">s${(index % 3) + 1}</div>
    </div>
    <div class="fixed eta">ETA ${12 + (index % 8)}h</div>
  </div>
  <div class="signals">
    <div class="fixed marker">m${(index % 6) + 1}</div>
    <div class="group-box group-e">
      <div class="seg seg-tag">g${(index % 4) + 1}</div>
      <div class="seg seg-copy">signal ${(index % 7) + 1}</div>
      <div class="seg seg-tail">x${(index % 3) + 1}</div>
    </div>
    <div class="group-box group-f">
      <div class="seg seg-tag">r${(index % 4) + 1}</div>
      <div class="seg seg-note">review ${(index % 3) + 1}</div>
      <div class="seg seg-tail">k${(index % 4) + 1}</div>
    </div>
    <div class="fixed marker">g${(index % 4) + 3}</div>
  </div>
  <div class="controls">
    <input class="fixed picker" value="slot ${(index % 5) + 1}" />
    <select class="fixed route-select">
      <option>route ${(index % 4) + 1}</option>
      <option>route ${(index % 4) + 2}</option>
    </select>
    <div class="group-box group-g">
      <div class="seg seg-tag">t${(index % 4) + 1}</div>
      <div class="seg seg-note">gate ${(index % 4) + 1}</div>
      <div class="seg seg-tail">c${(index % 3) + 1}</div>
    </div>
    <button class="fixed mini-action">go</button>
  </div>
  <div class="rack">
    <div class="group-box group-h">
      <div class="seg seg-tag">h${(index % 5) + 1}</div>
      <div class="seg seg-copy">handoff ${(index % 4) + 1}</div>
      <div class="seg seg-tail">q${(index % 3) + 1}</div>
    </div>
    <input class="fixed picker picker-b" value="ack ${(index % 4) + 1}" />
    <div class="group-box group-i">
      <div class="seg seg-tag">p${(index % 4) + 1}</div>
      <div class="seg seg-note">trace ${(index % 5) + 2}</div>
      <div class="seg seg-tail">w${(index % 4) + 1}</div>
    </div>
    <select class="fixed route-select route-select-b">
      <option>lane ${(index % 4) + 1}</option>
      <option>lane ${(index % 4) + 2}</option>
    </select>
    <div class="fixed marker">x${(index % 4) + 2}</div>
  </div>
  <div class="rack review">
    <div class="group-box group-j emphasis">
      <div class="seg seg-tag">j${(index % 4) + 1}</div>
      <div class="seg seg-copy">merge ${(index % 5) + 1}</div>
      <div class="seg seg-tail">v${(index % 3) + 3}</div>
    </div>
    <select class="fixed route-select route-select-c">
      <option>node ${(index % 4) + 1}</option>
      <option>node ${(index % 4) + 2}</option>
    </select>
    <div class="group-box group-k">
      <div class="seg seg-tag">z${(index % 4) + 1}</div>
      <div class="seg seg-note">lag ${(index % 6) + 1}</div>
      <div class="seg seg-tail">d${(index % 4) + 2}</div>
    </div>
    <button class="fixed mini-action">ok</button>
  </div>
  <div class="summary">
    <span class="copy">Inline sample ${index + 1} mixed text</span>
    <span class="chip status">active</span>
    <span class="copy emphasis">baseline ${(index % 7) + 1} مرحبا</span>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.4 AlibabaSans, sans-serif;
      background: #ffffff;
    }
    #host {
      width: 364px;
      padding: 10px;
      border: 1px solid #d8dde6;
      box-sizing: border-box;
    }
    #board {
      display: flex;
      flex-wrap: nowrap;
      gap: 8px;
      align-items: flex-start;
      align-content: flex-start;
    }
    .card {
      display: block;
      flex: 0 1 auto;
      min-width: 142px;
      max-width: 176px;
      padding: 8px 10px;
      border: 1px solid rgba(148, 163, 184, 0.45);
      border-radius: 12px;
      color: #0f172a;
      background: rgba(248, 250, 252, 0.96);
      box-sizing: border-box;
    }
    .queue,
    .owners,
    .signals,
    .controls,
    .rack {
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 4px;
      margin-top: 6px;
      line-height: 1.3;
      color: #334155;
    }
    .queue {
      margin-top: 0;
    }
    .summary {
      margin-top: 6px;
      text-indent: 4px;
      line-height: 1.5;
    }
    .fixed {
      flex: 0 0 auto;
    }
    .group-box {
      flex: 0 0 auto;
      width: 68px;
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 2px;
      padding: 1px 2px;
      border-radius: 8px;
      background: rgba(226, 232, 240, 0.56);
      box-sizing: border-box;
    }
    .seg {
      flex: 0 0 auto;
      display: block;
      min-width: 0;
      box-sizing: border-box;
      overflow-wrap: anywhere;
      word-break: break-word;
      color: #1e293b;
    }
    .seg-tag {
      width: 14px;
      text-align: center;
    }
    .seg-copy {
      width: 34px;
    }
    .seg-note {
      width: 28px;
    }
    .seg-tail {
      width: 12px;
      text-align: center;
    }
    .group-box.emphasis .seg-copy,
    .group-box.emphasis .seg-note,
    .copy.emphasis {
      font-style: italic;
    }
    .picker,
    .route-select,
    .mini-action {
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
    }
    .picker {
      width: 72px;
    }
    .picker-b {
      width: 64px;
    }
    .route-select {
      width: 66px;
    }
    .route-select-b {
      width: 58px;
    }
    .route-select-c {
      width: 62px;
    }
    .mini-action {
      width: 38px;
      padding: 2px 4px;
    }
    .severity {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .lane {
      width: 44px;
    }
    .badge {
      width: 36px;
      text-align: center;
      box-sizing: border-box;
    }
    .owner {
      width: 50px;
    }
    .shift {
      width: 42px;
    }
    .eta {
      width: 42px;
    }
    .marker {
      width: 28px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip {
      display: block;
      padding: 1px 7px;
      border-radius: 999px;
      border: 1px solid rgba(59, 130, 246, 0.24);
      background: rgba(191, 219, 254, 0.38);
      font-size: 12px;
      line-height: 18px;
      vertical-align: middle;
    }
    .copy {
      color: #1e293b;
      overflow-wrap: anywhere;
      word-break: break-word;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="board">$cards</div>
  </div>
</body>
</html>
''';
}

String _buildFlexRunMetricsDenseHtml({
  required int cardCount,
}) {
  final String cards = List<String>.generate(cardCount, (int index) {
    return '''
<div class="card tone${index % 4}" data-card="${index + 1}">
  <div class="queue">
    <span class="fixed pill severity">p${(index % 3) + 1}</span>
    <span class="fixed lane">lane ${(index % 5) + 1}</span>
    <span class="fixed zone">z${(index % 4) + 1}</span>
    <span class="tight-copy">issue ${index + 1}</span>
    <span class="tight-copy emphasis">w${(index % 6) + 2} queue</span>
    <span class="fixed ack">a${(index % 3) + 1}</span>
    <span class="fixed badge">hot</span>
  </div>
  <div class="owners">
    <span class="fixed owner">owner ${(index % 6) + 2}</span>
    <span class="fixed shift">s${(index % 3) + 1}</span>
    <span class="tight-copy emphasis">مرحبا ${(index % 7) + 1}</span>
    <span class="tight-note">h${(index % 5) + 1} review</span>
    <span class="fixed eta">ETA ${12 + (index % 8)}h</span>
    <span class="fixed score">c${(index % 5) + 3}</span>
  </div>
  <div class="notes">
    <span class="fixed chip chip-fixed">t${(index % 5) + 1}</span>
    <span class="fixed chip chip-fixed">k${(index % 4) + 2}</span>
    <span class="tight-note">follow ${(index % 8) + 1}</span>
    <div class="tight-pack">
      <span class="swatch short"></span>
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <span class="fixed chip subtle">w${(index % 4) + 2}</span>
  </div>
  <div class="signals">
    <span class="fixed marker">m${(index % 6) + 1}</span>
    <span class="fixed marker">r${(index % 5) + 2}</span>
    <span class="tight-copy">signal ${(index % 7) + 1}</span>
    <span class="tight-note">r${(index % 3) + 1} hold</span>
    <span class="fixed marker">g${(index % 4) + 3}</span>
  </div>
  <div class="controls">
    <input class="fixed auto-field tool-input" value="s${(index % 5) + 1}" />
    <select class="fixed auto-field tool-select">
      <option>r${(index % 4) + 1}</option>
      <option>r${(index % 4) + 2}</option>
    </select>
    <button class="fixed mini-action">go</button>
    <span class="auto-note">gate ${(index % 4) + 1}</span>
    <span class="fixed marker">k${(index % 4) + 1}</span>
  </div>
  <div class="rack">
    <input class="fixed auto-field tool-input" value="a${(index % 5) + 1}" />
    <select class="fixed auto-field tool-select">
      <option>w${(index % 4) + 1}</option>
      <option>w${(index % 4) + 2}</option>
    </select>
    <span class="fixed mini-action">go</span>
    <span class="fixed marker">n${(index % 4) + 1}</span>
    <input class="fixed auto-field tool-input" value="b${(index % 4) + 1}" />
    <select class="fixed auto-field tool-select">
      <option>m${(index % 4) + 1}</option>
      <option>m${(index % 4) + 2}</option>
    </select>
    <span class="fixed marker">p${(index % 4) + 1}</span>
  </div>
  <div class="rack">
    <span class="fixed chip chip-fixed">q${(index % 5) + 1}</span>
    <input class="fixed auto-field tool-input" value="c${(index % 5) + 2}" />
    <span class="fixed mini-action">ok</span>
    <select class="fixed auto-field tool-select">
      <option>s${(index % 4) + 1}</option>
      <option>s${(index % 4) + 2}</option>
    </select>
    <span class="fixed chip subtle">x${(index % 4) + 2}</span>
    <input class="fixed auto-field tool-input" value="d${(index % 4) + 2}" />
  </div>
  <div class="rack">
    <select class="fixed auto-field tool-select">
      <option>u${(index % 4) + 1}</option>
      <option>u${(index % 4) + 2}</option>
    </select>
    <span class="fixed mini-action">hi</span>
    <input class="fixed auto-field tool-input" value="e${(index % 5) + 1}" />
    <span class="fixed marker">r${(index % 4) + 1}</span>
    <select class="fixed auto-field tool-select">
      <option>v${(index % 4) + 1}</option>
      <option>v${(index % 4) + 2}</option>
    </select>
    <span class="fixed chip chip-fixed">m${(index % 5) + 1}</span>
    <input class="fixed auto-field tool-input" value="f${(index % 4) + 1}" />
  </div>
  <div class="rack">
    <input class="fixed auto-field tool-input" value="g${(index % 5) + 1}" />
    <span class="fixed chip subtle">y${(index % 4) + 2}</span>
    <span class="fixed mini-action">lo</span>
    <select class="fixed auto-field tool-select">
      <option>z${(index % 4) + 1}</option>
      <option>z${(index % 4) + 2}</option>
    </select>
    <input class="fixed auto-field tool-input" value="h${(index % 4) + 2}" />
    <span class="fixed marker">s${(index % 4) + 1}</span>
    <select class="fixed auto-field tool-select">
      <option>n${(index % 4) + 1}</option>
      <option>n${(index % 4) + 2}</option>
    </select>
  </div>
  <div class="summary">
    <span class="summary-copy">Inline sample ${index + 1} mixed text</span>
    <span class="chip status">active</span>
    <span class="summary-copy emphasis">baseline ${(index % 7) + 1} مرحبا</span>
  </div>
  <div class="packets">
    <div class="auto-pack">
      <div class="pod">
        <span class="swatch"></span>
        <span class="swatch short"></span>
      </div>
      <div class="pod">
        <span class="swatch"></span>
        <span class="swatch"></span>
      </div>
    </div>
    <span class="fixed marker">p${(index % 4) + 1}</span>
    <div class="auto-pack compact">
      <div class="pod">
        <span class="swatch short"></span>
        <span class="swatch"></span>
      </div>
      <div class="pod">
        <span class="swatch"></span>
        <span class="swatch short"></span>
      </div>
    </div>
    <span class="auto-note">trace ${(index % 5) + 2} hold</span>
  </div>
  <div class="handoff">
    <span class="fixed marker">h${(index % 5) + 1}</span>
    <span class="auto-copy">handoff ${(index % 4) + 1} queue ${(index % 3) + 1}</span>
    <div class="auto-pack compact">
      <div class="pod">
        <span class="swatch"></span>
        <span class="swatch short"></span>
      </div>
      <div class="pod">
        <span class="swatch"></span>
      </div>
    </div>
    <span class="auto-note">sync ${(index % 4) + 1}</span>
    <span class="fixed marker">x${(index % 4) + 2}</span>
  </div>
  <div class="controls review">
    <input class="fixed auto-field tool-input" value="q${(index % 4) + 1}" />
    <select class="fixed auto-field tool-select">
      <option>lane ${(index % 3) + 1}</option>
      <option>lane ${(index % 3) + 2}</option>
    </select>
    <span class="auto-note">lag ${(index % 6) + 1}</span>
    <button class="fixed mini-action">ok</button>
    <span class="auto-copy">slot ${(index % 4) + 1}</span>
    <span class="fixed marker">u${(index % 4) + 4}</span>
  </div>
  <div class="signals trail">
    <span class="fixed marker">j${(index % 6) + 1}</span>
    <span class="auto-copy">merge ${(index % 5) + 1} queue ${(index % 4) + 1}</span>
    <span class="auto-note">watch ${(index % 6) + 1}</span>
    <span class="fixed marker">v${(index % 3) + 3}</span>
  </div>
  <div class="handoff tail">
    <span class="auto-copy">packet ${(index % 4) + 2} queue ${(index % 5) + 1}</span>
    <span class="auto-note">hold ${(index % 5) + 1} lane ${(index % 3) + 1}</span>
    <span class="fixed marker">d${(index % 4) + 2}</span>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.35 AlibabaSans, sans-serif;
      background: #ffffff;
    }
    #host {
      width: 372px;
      padding: 10px;
      border: 1px solid #d8dde6;
      box-sizing: border-box;
    }
    #board {
      display: flex;
      flex-wrap: nowrap;
      gap: 8px;
      align-items: flex-start;
      align-content: flex-start;
    }
    .card {
      display: block;
      flex: 0 1 auto;
      min-width: 136px;
      max-width: 170px;
      padding: 8px 10px;
      border: 1px solid rgba(148, 163, 184, 0.45);
      border-radius: 12px;
      color: #0f172a;
      background: rgba(248, 250, 252, 0.96);
      box-sizing: border-box;
    }
    .queue,
    .owners,
    .notes,
    .signals,
    .handoff,
    .packets,
    .controls,
    .rack {
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 4px;
      margin-top: 6px;
      line-height: 1.25;
      color: #334155;
    }
    .queue {
      margin-top: 0;
    }
    .summary {
      margin-top: 6px;
      text-indent: 4px;
      line-height: 1.5;
    }
    .fixed {
      flex: 0 0 auto;
    }
    .auto-copy,
    .auto-note {
      flex: 0 1 auto;
      min-width: 0;
      display: block;
      color: #1e293b;
    }
    .auto-field {
      display: block;
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
    }
    .tool-input {
      width: 58px;
    }
    .tool-select {
      width: 54px;
    }
    .mini-action {
      width: 36px;
      padding: 2px 4px;
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
    }
    .auto-pack {
      flex: 0 1 auto;
      min-width: 0;
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 3px;
      padding: 1px 2px;
      border-radius: 999px;
      background: rgba(203, 213, 225, 0.35);
      box-sizing: border-box;
    }
    .auto-pack.compact {
      gap: 2px;
      padding-inline: 1px;
    }
    .pod {
      flex: 0 1 auto;
      min-width: 0;
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 2px;
    }
    .swatch {
      flex: 0 0 auto;
      width: 10px;
      height: 10px;
      border-radius: 999px;
      background: rgba(59, 130, 246, 0.55);
    }
    .swatch.short {
      width: 8px;
    }
    .summary-copy {
      color: #1e293b;
    }
    .auto-copy.emphasis {
      font-style: italic;
    }
    .summary-copy.emphasis {
      font-style: italic;
    }
    .severity {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .lane {
      width: 44px;
    }
    .zone {
      width: 30px;
    }
    .ack {
      width: 36px;
    }
    .badge {
      width: 36px;
      text-align: center;
      box-sizing: border-box;
    }
    .owner {
      width: 50px;
    }
    .shift {
      width: 42px;
    }
    .eta {
      width: 42px;
    }
    .score {
      width: 26px;
    }
    .marker {
      width: 28px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip.subtle {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip-fixed {
      width: 24px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip {
      display: block;
      padding: 1px 7px;
      border-radius: 999px;
      border: 1px solid rgba(59, 130, 246, 0.24);
      background: rgba(191, 219, 254, 0.38);
      font-size: 12px;
      line-height: 18px;
      vertical-align: middle;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="board">$cards</div>
  </div>
</body>
</html>
''';
}

String _buildFlexTightFastPathDenseHtml({
  required int cardCount,
}) {
  final String cards = List<String>.generate(cardCount, (int index) {
    return '''
<div class="card tone${index % 4}" data-card="${index + 1}">
  <div class="queue">
    <span class="fixed pill severity">p${(index % 3) + 1}</span>
    <span class="fixed lane">lane ${(index % 5) + 1}</span>
    <span class="tight-copy copy-a">issue ${index + 1} queue ${(index % 6) + 2} مرحبا ${(index % 4) + 1}</span>
    <span class="tight-copy emphasis copy-b">window ${(index % 6) + 2} alert ${(index % 5) + 1} review</span>
    <span class="fixed badge">hot</span>
  </div>
  <div class="owners">
    <span class="fixed owner">owner ${(index % 6) + 2}</span>
    <input class="fixed auto-field tool-input-a" value="s${(index % 5) + 1}" />
    <span class="tight-copy emphasis copy-c">مرحبا ${(index % 7) + 1} handoff ${(index % 5) + 1} shift</span>
    <select class="fixed auto-field tool-select-a">
      <option>route ${(index % 4) + 1}</option>
      <option>route ${(index % 4) + 2}</option>
    </select>
    <span class="fixed eta">ETA ${12 + (index % 8)}h</span>
  </div>
  <div class="signals">
    <span class="fixed marker">m${(index % 6) + 1}</span>
    <span class="tight-copy copy-d">signal ${(index % 7) + 1} review ${(index % 3) + 1}</span>
    <span class="tight-note note-a">r${(index % 3) + 1} hold queue ${(index % 4) + 1}</span>
    <span class="fixed marker">g${(index % 4) + 3}</span>
  </div>
  <div class="controls">
    <input class="fixed auto-field tool-input-b" value="q${(index % 4) + 1}" />
    <select class="fixed auto-field tool-select-b">
      <option>lane ${(index % 3) + 1}</option>
      <option>lane ${(index % 3) + 2}</option>
    </select>
    <span class="fixed mini-action">go</span>
    <span class="tight-note note-b">gate ${(index % 4) + 1} check ${(index % 5) + 1}</span>
    <span class="fixed marker">k${(index % 4) + 1}</span>
  </div>
  <div class="packets">
    <div class="tight-pack pack-a">
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <span class="fixed marker">p${(index % 4) + 1}</span>
    <div class="tight-pack pack-b">
      <span class="swatch short"></span>
      <span class="swatch"></span>
    </div>
    <span class="tight-note note-c">trace ${(index % 5) + 2} hold ${(index % 3) + 1}</span>
  </div>
  <div class="handoff">
    <span class="fixed marker">h${(index % 5) + 1}</span>
    <span class="tight-copy copy-e">handoff ${(index % 4) + 1} queue ${(index % 3) + 1}</span>
    <div class="tight-pack pack-c">
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <span class="tight-note note-d">sync ${(index % 4) + 1} lane ${(index % 3) + 1}</span>
    <span class="fixed marker">x${(index % 4) + 2}</span>
  </div>
  <div class="summary">
    <span class="summary-copy">Inline sample ${index + 1} mixed text</span>
    <span class="chip status">active</span>
    <span class="summary-copy emphasis">baseline ${(index % 7) + 1} مرحبا</span>
  </div>
  <div class="trail">
    <span class="fixed marker">j${(index % 6) + 1}</span>
    <span class="tight-copy copy-f">merge ${(index % 5) + 1} queue ${(index % 4) + 1}</span>
    <span class="tight-note note-e">watch ${(index % 6) + 1} hold</span>
    <span class="fixed marker">v${(index % 3) + 3}</span>
  </div>
  <div class="review">
    <input class="fixed auto-field tool-input-a" value="slot ${(index % 5) + 1}" />
    <select class="fixed auto-field tool-select-a">
      <option>r${(index % 4) + 1}</option>
      <option>r${(index % 4) + 2}</option>
    </select>
    <span class="tight-note note-f">lag ${(index % 6) + 1} review ${(index % 4) + 1}</span>
    <span class="fixed mini-action">ok</span>
    <span class="tight-copy copy-g">slot ${(index % 4) + 1} route ${(index % 3) + 2}</span>
    <span class="fixed marker">u${(index % 4) + 4}</span>
  </div>
  <div class="widgetrack">
    <input class="fixed auto-field tool-input-a" value="w${(index % 5) + 1}" />
    <select class="fixed auto-field tool-select-a">
      <option>a${(index % 4) + 1}</option>
      <option>a${(index % 4) + 2}</option>
    </select>
    <div class="tight-pack pack-e">
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <span class="fixed mini-action">go</span>
    <input class="fixed auto-field tool-input-b" value="x${(index % 4) + 1}" />
    <select class="fixed auto-field tool-select-b">
      <option>b${(index % 4) + 1}</option>
      <option>b${(index % 4) + 2}</option>
    </select>
    <div class="tight-pack pack-f">
      <span class="swatch short"></span>
      <span class="swatch"></span>
    </div>
  </div>
  <div class="widgetrack">
    <select class="fixed auto-field tool-select-b">
      <option>c${(index % 4) + 1}</option>
      <option>c${(index % 4) + 2}</option>
    </select>
    <div class="tight-pack pack-g">
      <span class="swatch"></span>
      <span class="swatch"></span>
    </div>
    <input class="fixed auto-field tool-input-a" value="y${(index % 5) + 2}" />
    <span class="fixed mini-action">ok</span>
    <div class="tight-pack pack-h">
      <span class="swatch short"></span>
      <span class="swatch"></span>
    </div>
    <input class="fixed auto-field tool-input-b" value="z${(index % 4) + 2}" />
    <select class="fixed auto-field tool-select-a">
      <option>d${(index % 4) + 1}</option>
      <option>d${(index % 4) + 2}</option>
    </select>
  </div>
  <div class="burst">
    <input class="fixed auto-field tool-input-a" value="n${(index % 5) + 1}" />
    <span class="tight-copy copy-h">queue ${(index % 6) + 1} watch ${(index % 4) + 1}</span>
    <span class="tight-note note-g">gate ${(index % 5) + 1} sync</span>
    <select class="fixed auto-field tool-select-b">
      <option>b${(index % 4) + 1}</option>
      <option>b${(index % 4) + 2}</option>
    </select>
    <span class="fixed marker">q${(index % 4) + 1}</span>
  </div>
  <div class="burst">
    <span class="fixed marker">c${(index % 5) + 1}</span>
    <span class="tight-copy emphasis copy-i">مرحبا ${(index % 6) + 2} lane ${(index % 3) + 1}</span>
    <div class="tight-pack pack-d">
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <span class="tight-note note-h">hold ${(index % 5) + 2} trace</span>
    <input class="fixed auto-field tool-input-b" value="m${(index % 4) + 2}" />
  </div>
  <div class="burst">
    <select class="fixed auto-field tool-select-a">
      <option>lane ${(index % 4) + 1}</option>
      <option>lane ${(index % 4) + 2}</option>
    </select>
    <span class="tight-copy copy-j">packet ${(index % 5) + 1} queue ${(index % 4) + 2}</span>
    <span class="fixed mini-action">go</span>
    <span class="tight-note note-i">lag ${(index % 6) + 1} review</span>
    <span class="fixed marker">z${(index % 4) + 2}</span>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.35 AlibabaSans, sans-serif;
      background: #ffffff;
    }
    #host {
      width: 372px;
      padding: 10px;
      border: 1px solid #d8dde6;
      box-sizing: border-box;
    }
    #board {
      display: flex;
      flex-wrap: nowrap;
      gap: 8px;
      align-items: flex-start;
      align-content: flex-start;
    }
    .card {
      display: block;
      flex: 0 1 auto;
      min-width: 140px;
      max-width: 174px;
      padding: 8px 10px;
      border: 1px solid rgba(148, 163, 184, 0.45);
      border-radius: 12px;
      color: #0f172a;
      background: rgba(248, 250, 252, 0.96);
      box-sizing: border-box;
    }
    .queue,
    .owners,
    .signals,
    .controls,
    .packets,
    .handoff,
    .trail,
    .review,
    .widgetrack,
    .burst {
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 4px;
      margin-top: 6px;
      line-height: 1.25;
      color: #334155;
    }
    .queue {
      margin-top: 0;
    }
    .summary {
      margin-top: 6px;
      text-indent: 4px;
      line-height: 1.5;
    }
    .fixed {
      flex: 0 0 auto;
    }
    .tight-copy,
    .tight-note {
      flex: 0 0 auto;
      min-width: 0;
      display: block;
      box-sizing: border-box;
      color: #1e293b;
    }
    .tight-copy {
      flex-basis: 58px;
    }
    .tight-note {
      flex-basis: 44px;
      overflow-wrap: anywhere;
      word-break: break-word;
    }
    .tight-pack {
      flex: 0 0 auto;
      flex-basis: 34px;
      min-width: 0;
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 2px;
      padding: 1px 2px;
      border-radius: 999px;
      background: rgba(203, 213, 225, 0.35);
      box-sizing: border-box;
    }
    .auto-field {
      display: block;
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
    }
    .tool-input-a {
      width: 70px;
    }
    .tool-input-b {
      width: 56px;
    }
    .tool-select-a {
      width: 62px;
    }
    .tool-select-b {
      width: 60px;
    }
    .mini-action {
      width: 36px;
      display: block;
      padding: 2px 4px;
      text-align: center;
      box-sizing: border-box;
      border-radius: 8px;
      background: rgba(191, 219, 254, 0.35);
      border: 1px solid rgba(59, 130, 246, 0.18);
    }
    .swatch {
      flex: 0 0 auto;
      width: 10px;
      height: 10px;
      border-radius: 999px;
      background: rgba(59, 130, 246, 0.55);
    }
    .swatch.short {
      width: 8px;
    }
    .summary-copy {
      color: #1e293b;
    }
    .tight-copy.emphasis,
    .summary-copy.emphasis {
      font-style: italic;
    }
    .tight-copy,
    .tight-note,
    .summary-copy {
      overflow-wrap: anywhere;
      word-break: break-word;
    }
    .severity {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .lane {
      width: 44px;
    }
    .badge {
      width: 36px;
      text-align: center;
      box-sizing: border-box;
    }
    .owner {
      width: 50px;
    }
    .eta {
      width: 42px;
    }
    .marker {
      width: 28px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip.subtle {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip {
      display: block;
      padding: 1px 7px;
      border-radius: 999px;
      border: 1px solid rgba(59, 130, 246, 0.24);
      background: rgba(191, 219, 254, 0.38);
      font-size: 12px;
      line-height: 18px;
      vertical-align: middle;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="board">$cards</div>
  </div>
</body>
</html>
''';
}

String _buildFlexHybridFastPathDenseHtml({
  required int cardCount,
}) {
  final String cards = List<String>.generate(cardCount, (int index) {
    return '''
<div class="card tone${index % 4}" data-card="${index + 1}">
  <div class="queue">
    <span class="fixed pill severity">p${(index % 3) + 1}</span>
    <span class="fixed lane">lane ${(index % 5) + 1}</span>
    <span class="fixed zone">z${(index % 4) + 1}</span>
    <span class="auto-copy">issue ${index + 1}</span>
    <span class="auto-copy emphasis">w${(index % 6) + 2} queue</span>
    <span class="fixed ack">a${(index % 3) + 1}</span>
    <span class="fixed badge">hot</span>
  </div>
  <div class="owners">
    <span class="fixed owner">owner ${(index % 6) + 2}</span>
    <span class="fixed shift">s${(index % 3) + 1}</span>
    <span class="auto-copy emphasis">مرحبا ${(index % 7) + 1}</span>
    <span class="auto-note">h${(index % 5) + 1} review</span>
    <span class="fixed eta">ETA ${12 + (index % 8)}h</span>
    <span class="fixed score">c${(index % 5) + 3}</span>
  </div>
  <div class="notes">
    <span class="fixed chip chip-fixed">t${(index % 5) + 1}</span>
    <span class="fixed chip chip-fixed">k${(index % 4) + 2}</span>
    <span class="auto-note">follow ${(index % 8) + 1}</span>
    <div class="auto-pack compact">
      <span class="swatch short"></span>
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <span class="fixed chip subtle">w${(index % 4) + 2}</span>
  </div>
  <div class="signals">
    <span class="fixed marker">m${(index % 6) + 1}</span>
    <span class="fixed marker">r${(index % 5) + 2}</span>
    <span class="auto-copy">signal ${(index % 7) + 1}</span>
    <span class="auto-note">r${(index % 3) + 1} hold</span>
    <span class="fixed marker">g${(index % 4) + 3}</span>
  </div>
  <div class="controls">
    <input class="fixed auto-field tool-input" value="s${(index % 5) + 1}" />
    <select class="fixed auto-field tool-select">
      <option>r${(index % 4) + 1}</option>
      <option>r${(index % 4) + 2}</option>
    </select>
    <span class="fixed mini-action">go</span>
    <span class="tight-note">gate ${(index % 4) + 1}</span>
    <span class="fixed marker">k${(index % 4) + 1}</span>
  </div>
  <div class="tighttools">
    <input class="fixed auto-field tight-input-a" value="t${(index % 5) + 1}" />
    <span class="tight-copy tight-copy-a">queue ${(index % 6) + 1}</span>
    <select class="fixed auto-field tight-select-a">
      <option>lane ${(index % 4) + 1}</option>
      <option>lane ${(index % 4) + 2}</option>
    </select>
    <span class="tight-note tight-note-a">hold ${(index % 5) + 1}</span>
    <span class="fixed mini-tight">ok</span>
  </div>
  <div class="summary">
    <span class="summary-copy">Inline sample ${index + 1} mixed text</span>
    <span class="chip status">active</span>
    <span class="summary-copy emphasis">baseline ${(index % 7) + 1} مرحبا</span>
  </div>
  <div class="packets">
    <div class="tight-pack">
      <span class="swatch"></span>
      <span class="swatch short"></span>
      <span class="swatch"></span>
    </div>
    <span class="fixed marker">p${(index % 4) + 1}</span>
    <div class="tight-pack">
      <span class="swatch short"></span>
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <span class="tight-note">trace ${(index % 5) + 2} hold</span>
  </div>
  <div class="tightsignal">
    <span class="fixed marker">h${(index % 5) + 1}</span>
    <span class="tight-copy tight-copy-b emphasis">مرحبا ${(index % 6) + 1}</span>
    <input class="fixed auto-field tight-input-b" value="m${(index % 4) + 1}" />
    <div class="tight-pack tight-pack-a">
      <span class="swatch short"></span>
      <span class="swatch"></span>
    </div>
    <span class="tight-note tight-note-b">sync ${(index % 4) + 1}</span>
    <select class="fixed auto-field tight-select-b">
      <option>x${(index % 4) + 2}</option>
      <option>x${(index % 4) + 3}</option>
    </select>
  </div>
  <div class="handoff">
    <span class="fixed marker">h${(index % 5) + 1}</span>
    <span class="tight-copy">handoff ${(index % 4) + 1} queue ${(index % 3) + 1}</span>
    <div class="tight-pack">
      <span class="swatch"></span>
      <span class="swatch short"></span>
      <span class="swatch"></span>
    </div>
    <span class="tight-note">sync ${(index % 4) + 1}</span>
    <span class="fixed marker">x${(index % 4) + 2}</span>
  </div>
  <div class="controls review">
    <input class="fixed auto-field tool-input" value="q${(index % 4) + 1}" />
    <select class="fixed auto-field tool-select">
      <option>lane ${(index % 3) + 1}</option>
      <option>lane ${(index % 3) + 2}</option>
    </select>
    <span class="tight-note">lag ${(index % 6) + 1}</span>
    <span class="fixed mini-action">ok</span>
    <span class="tight-copy">slot ${(index % 4) + 1}</span>
    <span class="fixed marker">u${(index % 4) + 4}</span>
  </div>
  <div class="tightreview">
    <select class="fixed auto-field tight-select-a">
      <option>q${(index % 4) + 1}</option>
      <option>q${(index % 4) + 2}</option>
    </select>
    <span class="tight-copy tight-copy-c">packet ${(index % 5) + 1}</span>
    <div class="tight-pack tight-pack-b">
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <span class="tight-note tight-note-c">watch ${(index % 6) + 1}</span>
    <input class="fixed auto-field tight-input-a" value="u${(index % 4) + 2}" />
    <span class="fixed mini-tight">go</span>
  </div>
  <div class="widgetrack">
    <input class="fixed auto-field tight-input-a" value="a${(index % 5) + 1}" />
    <select class="fixed auto-field tight-select-a">
      <option>w${(index % 4) + 1}</option>
      <option>w${(index % 4) + 2}</option>
    </select>
    <div class="tight-pack">
      <span class="swatch"></span>
      <span class="swatch short"></span>
    </div>
    <span class="fixed mini-tight">g${(index % 4) + 1}</span>
    <input class="fixed auto-field tight-input-b" value="b${(index % 4) + 1}" />
    <div class="tight-pack">
      <span class="swatch short"></span>
      <span class="swatch"></span>
    </div>
    <select class="fixed auto-field tight-select-b">
      <option>m${(index % 4) + 1}</option>
      <option>m${(index % 4) + 2}</option>
    </select>
  </div>
  <div class="widgetrack">
    <select class="fixed auto-field tight-select-b">
      <option>s${(index % 4) + 1}</option>
      <option>s${(index % 4) + 2}</option>
    </select>
    <div class="tight-pack">
      <span class="swatch"></span>
      <span class="swatch"></span>
    </div>
    <input class="fixed auto-field tight-input-a" value="c${(index % 5) + 2}" />
    <span class="fixed mini-tight">h${(index % 3) + 1}</span>
    <div class="tight-pack">
      <span class="swatch short"></span>
      <span class="swatch"></span>
    </div>
    <input class="fixed auto-field tight-input-b" value="d${(index % 4) + 2}" />
    <select class="fixed auto-field tight-select-a">
      <option>t${(index % 4) + 1}</option>
      <option>t${(index % 4) + 2}</option>
    </select>
  </div>
  <div class="signals trail">
    <span class="fixed marker">j${(index % 6) + 1}</span>
    <span class="tight-copy">merge ${(index % 5) + 1} queue ${(index % 4) + 1}</span>
    <span class="tight-note">watch ${(index % 6) + 1}</span>
    <span class="fixed marker">v${(index % 3) + 3}</span>
  </div>
  <div class="handoff tail">
    <span class="tight-copy">packet ${(index % 4) + 2} queue ${(index % 5) + 1}</span>
    <span class="tight-note">hold ${(index % 5) + 1} lane ${(index % 3) + 1}</span>
    <span class="fixed marker">d${(index % 4) + 2}</span>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.35 AlibabaSans, sans-serif;
      background: #ffffff;
    }
    #host {
      width: 372px;
      padding: 10px;
      border: 1px solid #d8dde6;
      box-sizing: border-box;
    }
    #board {
      display: flex;
      flex-wrap: nowrap;
      gap: 8px;
      align-items: flex-start;
      align-content: flex-start;
    }
    .card {
      display: block;
      flex: 0 1 auto;
      min-width: 136px;
      max-width: 170px;
      padding: 8px 10px;
      border: 1px solid rgba(148, 163, 184, 0.45);
      border-radius: 12px;
      color: #0f172a;
      background: rgba(248, 250, 252, 0.96);
      box-sizing: border-box;
    }
    .queue,
    .owners,
    .notes,
    .signals,
    .handoff,
    .packets,
    .controls,
    .tighttools,
    .tightsignal,
    .tightreview,
    .widgetrack {
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 4px;
      margin-top: 6px;
      line-height: 1.25;
      color: #334155;
    }
    .queue {
      margin-top: 0;
    }
    .summary {
      margin-top: 6px;
      text-indent: 4px;
      line-height: 1.5;
    }
    .fixed {
      flex: 0 0 auto;
    }
    .auto-copy,
    .auto-note {
      flex: 0 1 auto;
      min-width: 0;
      display: block;
      color: #1e293b;
    }
    .tight-copy,
    .tight-note {
      flex: 0 0 auto;
      min-width: 0;
      display: block;
      color: #1e293b;
      overflow-wrap: anywhere;
      word-break: break-word;
    }
    .tight-copy {
      flex-basis: 58px;
    }
    .tight-note {
      flex-basis: 44px;
    }
    .auto-field {
      display: block;
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
    }
    .tool-input {
      width: 58px;
    }
    .tool-select {
      width: 54px;
    }
    .tight-input-a {
      width: 64px;
    }
    .tight-input-b {
      width: 54px;
    }
    .tight-select-a {
      width: 58px;
    }
    .tight-select-b {
      width: 56px;
    }
    .mini-action,
    .mini-tight {
      width: 36px;
      display: block;
      padding: 2px 4px;
      text-align: center;
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
      border-radius: 8px;
      background: rgba(191, 219, 254, 0.35);
      border: 1px solid rgba(59, 130, 246, 0.18);
    }
    .auto-pack {
      flex: 0 1 auto;
      min-width: 0;
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 3px;
      padding: 1px 2px;
      border-radius: 999px;
      background: rgba(203, 213, 225, 0.35);
      box-sizing: border-box;
    }
    .auto-pack.compact {
      gap: 2px;
      padding-inline: 1px;
    }
    .tight-pack {
      flex: 0 0 auto;
      flex-basis: 34px;
      min-width: 0;
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 2px;
      padding: 1px 2px;
      border-radius: 999px;
      background: rgba(203, 213, 225, 0.35);
      box-sizing: border-box;
    }
    .pod {
      flex: 0 1 auto;
      min-width: 0;
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 2px;
    }
    .swatch {
      flex: 0 0 auto;
      width: 10px;
      height: 10px;
      border-radius: 999px;
      background: rgba(59, 130, 246, 0.55);
    }
    .swatch.short {
      width: 8px;
    }
    .summary-copy {
      color: #1e293b;
    }
    .auto-copy.emphasis,
    .tight-copy.emphasis,
    .summary-copy.emphasis {
      font-style: italic;
    }
    .severity {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .lane {
      width: 44px;
    }
    .zone {
      width: 30px;
    }
    .ack {
      width: 36px;
    }
    .badge {
      width: 36px;
      text-align: center;
      box-sizing: border-box;
    }
    .owner {
      width: 50px;
    }
    .shift {
      width: 42px;
    }
    .eta {
      width: 42px;
    }
    .score {
      width: 26px;
    }
    .marker {
      width: 28px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip.subtle {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip-fixed {
      width: 24px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip {
      display: block;
      padding: 1px 7px;
      border-radius: 999px;
      border: 1px solid rgba(59, 130, 246, 0.24);
      background: rgba(191, 219, 254, 0.38);
      font-size: 12px;
      line-height: 18px;
      vertical-align: middle;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="board">$cards</div>
  </div>
</body>
</html>
''';
}

String _buildFlexAdjustWidgetDenseHtml({
  required int cardCount,
}) {
  final String cards = List<String>.generate(cardCount, (int index) {
    return '''
<div class="card tone${index % 4}" data-card="${index + 1}">
  <div class="queue">
    <span class="fixed pill severity">p${(index % 3) + 1}</span>
    <span class="fixed lane">lane ${(index % 5) + 1}</span>
    <span class="fixed zone">z${(index % 4) + 1}</span>
    <span class="auto-copy">issue ${index + 1} window ${(index % 6) + 2}</span>
    <span class="fixed ack">a${(index % 3) + 1}</span>
    <span class="fixed badge">hot</span>
  </div>
  <div class="owners">
    <span class="fixed owner">owner ${(index % 6) + 2}</span>
    <span class="fixed shift">s${(index % 3) + 1}</span>
    <span class="auto-copy emphasis">مرحبا ${(index % 7) + 1} handoff ${(index % 5) + 1}</span>
    <span class="auto-note">review ${(index % 5) + 1}</span>
    <span class="fixed eta">ETA ${12 + (index % 8)}h</span>
  </div>
  <div class="notes">
    <span class="fixed chip chip-fixed">ไทย ${(index % 5) + 1}</span>
    <span class="fixed chip chip-fixed">k${(index % 4) + 2}</span>
    <span class="auto-note">follow ${(index % 8) + 1} stays auto</span>
    <span class="fixed chip subtle">w${(index % 4) + 2}</span>
  </div>
  <div class="signals">
    <span class="fixed marker">m${(index % 6) + 1}</span>
    <span class="fixed marker">r${(index % 5) + 2}</span>
    <span class="auto-copy">signal ${(index % 7) + 1} review ${(index % 3) + 1}</span>
    <span class="fixed marker">g${(index % 4) + 3}</span>
  </div>
  <div class="controls">
    <input class="fixed tool-field tool-input-a" value="slot ${(index % 5) + 1}" />
    <select class="fixed tool-field tool-select-a">
      <option>route ${(index % 4) + 1}</option>
      <option>route ${(index % 4) + 2}</option>
    </select>
    <input class="fixed tool-field tool-input-b" value="r${(index % 6) + 2}" />
    <span class="fixed tool-chip">k${(index % 4) + 1}</span>
  </div>
  <div class="controls review">
    <select class="fixed tool-field tool-select-b">
      <option>lane ${(index % 3) + 1}</option>
      <option>lane ${(index % 3) + 2}</option>
    </select>
    <span class="auto-note">guard ${(index % 6) + 1}</span>
    <input class="fixed tool-field tool-input-b" value="a${(index % 4) + 1}" />
    <span class="fixed tool-chip">t${(index % 5) + 2}</span>
  </div>
  <div class="summary">
    <span class="summary-copy">Inline sample ${index + 1} mixed text</span>
    <span class="chip status">active</span>
    <span class="summary-copy emphasis">baseline ${(index % 7) + 1} مرحبا</span>
  </div>
  <div class="handoff">
    <span class="fixed marker">h${(index % 5) + 1}</span>
    <span class="auto-copy">handoff ${(index % 4) + 1} ledger ${(index % 5) + 1}</span>
    <span class="auto-note">lag ${(index % 6) + 1}</span>
    <span class="fixed marker">x${(index % 4) + 2}</span>
  </div>
</div>
''';
  }).join();

  return '''
<!doctype html>
<html>
<head>
  <style>
    body {
      margin: 0;
      font: 15px/1.45 AlibabaSans, sans-serif;
      background: #ffffff;
    }
    #host {
      width: 368px;
      padding: 10px;
      border: 1px solid #d8dde6;
      box-sizing: border-box;
    }
    #board {
      display: flex;
      flex-wrap: nowrap;
      gap: 8px;
      align-items: flex-start;
      align-content: flex-start;
    }
    .card {
      display: block;
      flex: 0 1 auto;
      min-width: 140px;
      max-width: 172px;
      padding: 8px 10px;
      border: 1px solid rgba(148, 163, 184, 0.45);
      border-radius: 12px;
      color: #0f172a;
      background: rgba(248, 250, 252, 0.96);
      box-sizing: border-box;
    }
    .queue,
    .owners,
    .notes,
    .signals,
    .controls,
    .handoff {
      display: flex;
      flex-wrap: nowrap;
      align-items: flex-start;
      gap: 4px;
      margin-top: 6px;
      line-height: 1.35;
      color: #334155;
    }
    .queue {
      margin-top: 0;
    }
    .summary {
      margin-top: 6px;
      text-indent: 4px;
      line-height: 1.55;
    }
    .fixed {
      flex: 0 0 auto;
    }
    .auto-copy,
    .auto-note {
      flex: 0 1 auto;
      min-width: 0;
      display: block;
      color: #1e293b;
    }
    .summary-copy {
      color: #1e293b;
    }
    .auto-copy.emphasis,
    .summary-copy.emphasis {
      font-style: italic;
    }
    .tool-field {
      font: inherit;
      line-height: 1.2;
      box-sizing: border-box;
    }
    .tool-input-a {
      width: 72px;
    }
    .tool-input-b {
      width: 58px;
    }
    .tool-select-a {
      width: 66px;
    }
    .tool-select-b {
      width: 58px;
    }
    .tool-chip {
      width: 32px;
      text-align: center;
      box-sizing: border-box;
    }
    .severity {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .lane {
      width: 44px;
    }
    .zone {
      width: 30px;
    }
    .ack {
      width: 36px;
    }
    .badge {
      width: 36px;
      text-align: center;
      box-sizing: border-box;
    }
    .owner {
      width: 50px;
    }
    .shift {
      width: 42px;
    }
    .eta {
      width: 42px;
    }
    .marker {
      width: 28px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip.subtle {
      width: 34px;
      text-align: center;
      box-sizing: border-box;
    }
    .chip {
      display: inline-block;
      padding: 1px 7px;
      border-radius: 999px;
      border: 1px solid rgba(59, 130, 246, 0.24);
      background: rgba(191, 219, 254, 0.38);
      font-size: 12px;
      line-height: 18px;
      vertical-align: middle;
    }
  </style>
</head>
<body>
  <div id="host">
    <div id="board">$cards</div>
  </div>
</body>
</html>
''';
}

class _PreparedProfileCase {
  const _PreparedProfileCase({
    required this.controller,
    required this.tester,
  });

  final WebFController controller;
  final WidgetTester tester;

  dom.Element getElementById(String id) {
    final dom.Element? element =
        controller.view.document.getElementById(<String>[id]);
    expect(element, isNotNull, reason: 'Expected element with id "$id".');
    return element!;
  }

  Future<void> evaluate(String script) async {
    await tester.runAsync(() async {
      await controller.view.evaluateJavaScripts(script);
    });
  }
}
