/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The OpenWebF Company. All rights reserved.
 */

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

import 'base_input.dart';
import 'radio.dart';

mixin BaseCheckedElement on BaseInputElement {
  bool _checked = false;
  bool _checkedDirty = false;

  String get _earlyCheckedKey => hashCode.toString();

  void _syncCheckedStateToNative(bool checked) {
    final Pointer<NativeBindingObject>? nativePtr = pointer;
    final double? ctxId = contextId;
    if (nativePtr == null || ctxId == null) return;
    if (isBindingObjectDisposed(nativePtr)) return;
    if (nativePtr.ref.invokeBindingMethodFromDart == nullptr) return;

    final DartInvokeBindingMethodsFromDart invoke =
        nativePtr.ref.invokeBindingMethodFromDart.asFunction();

    final Pointer<NativeValue> method = malloc.allocate(sizeOf<NativeValue>());
    toNativeValue(method, '__syncCheckedState', this);
    final Pointer<NativeValue> args = makeNativeValueArguments(this, [checked]);

    final _SyncCheckedStateContext context = _SyncCheckedStateContext(method, args);
    final Pointer<NativeFunction<NativeInvokeResultCallback>> resultCallback =
        Pointer.fromFunction(_handleSyncCheckedStateResult);

    Future.microtask(() {
      invoke(nativePtr, ctxId, method, 1, args, context, resultCallback);
    });
  }

  bool getChecked() {
    if (this is FlutterInputElement) {
      FlutterInputElement input = this as FlutterInputElement;
      switch (input.type) {
        case 'radio':
          return _getRadioChecked();
        case 'checkbox':
          if (!_checkedDirty && !_checked && hasAttribute('checked')) {
            return true;
          }
          return _checked;
        default:
          if (!_checkedDirty && !_checked && hasAttribute('checked')) {
            return true;
          }
          return _checked;
      }
    }
    if (!_checkedDirty && !_checked && hasAttribute('checked')) {
      return true;
    }
    return _checked;
  }

  setChecked(bool value, {bool fromAttribute = false}) {
    if (this is FlutterInputElement) {
      FlutterInputElement input = this as FlutterInputElement;
      final bool previous = getChecked();
      if (!fromAttribute) {
        _checkedDirty = true;
      } else if (_checkedDirty) {
        return;
      }

      if (state == null) {
        if (input.type == 'radio') {
          _setRadioChecked(value);
        } else if (input.type == 'checkbox') {
          // Persist on the element immediately and also cache for restoration when state mounts.
          _checked = value;
          CheckboxElementState.setEarlyCheckboxState(_earlyCheckedKey, value);
        } else {
          _checked = value;
        }
      } else {
        switch (input.type) {
          case 'radio':
            _setRadioChecked(value);
            // _setRadioChecked updates group selection immediately; request a rebuild for the widget.
            state?.requestUpdateState();
            break;
          case 'checkbox':
          default:
            // Keep checkedness synchronous for JS reads, then rebuild the widget.
            _checked = value;
            state?.requestUpdateState();
            break;
        }
      }
      if (previous != getChecked()) {
        _markPseudoStateDirty();
        if (!fromAttribute && ownerDocument.ownerView.enableBlink) {
          _syncCheckedStateToNative(getChecked());
        }
      }
    }
  }

  bool _getRadioChecked() {
    if (this is BaseRadioElement) {
      BaseRadioElement radio = this as BaseRadioElement;
      final String groupName =
          (state as RadioElementState?)?.cachedGroupName ?? radio.selectionGroupName;
      final String expected = radio.selectionValue;

      // Before widget state mounts, honor boolean attribute presence and any group selection
      // already recorded by early checked changes.
      if (state == null) {
        if (!_checkedDirty && hasAttribute('checked')) return true;
        final bool? early = RadioElementState.getEarlyCheckedState(radio.hashCode.toString());
        if (early != null) return early;
        return RadioElementState.getGroupValueForName(groupName) == expected;
      }

      return (state as RadioElementState).groupValue == expected;
    }
    return false;
  }

  void _setRadioChecked(bool newValue) {
    if (this is BaseRadioElement) {
      BaseRadioElement radio = this as BaseRadioElement;
      String radioKey = radio.hashCode.toString();
      
      if (state == null) {
        // Update group selection immediately so `el.checked` reads correctly before mount.
        final String radioName = radio.selectionGroupName;
        if (newValue) {
          RadioElementState.setGroupValueForName(radioName, radio.selectionValue);
        } else {
          final String expected = radio.selectionValue;
          if (RadioElementState.getGroupValueForName(radioName) == expected) {
            RadioElementState.setGroupValueForName(radioName, '');
          }
        }

        RadioElementState.setEarlyCheckedState(radioKey, newValue);
        return;
      }
      
      // Use cached group name from state, fallback to current name
      String radioName =
          (state as RadioElementState).cachedGroupName ?? radio.selectionGroupName;

      if (newValue) {
        String newGroupValue = radio.selectionValue;
        // Update shared group selection immediately so all radios read consistent checkedness.
        RadioElementState.setGroupValueForName(radioName, newGroupValue);
        Map<String, String> map = <String, String>{};
        map[radioName] = newGroupValue;

        state?.groupValue = newGroupValue;

        if (state?.streamController.hasListener == true) {
          state?.streamController.sink.add(map);
        }
      } else {
        // When unchecking, only clear if this radio is currently the selected one
        String currentRadioValue = radio.selectionValue;
        String currentGroupValue = (state as RadioElementState).groupValue;
        if (currentGroupValue == currentRadioValue) {
          RadioElementState.setGroupValueForName(radioName, '');
          state?.groupValue = '';
          Map<String, String> map = <String, String>{};
          map[radioName] = '';
          
          if (state?.streamController.hasListener == true) {
            state?.streamController.sink.add(map);
          }
        }
      }
    }
  }

  double getCheckboxSize() {
    //TODO support zoom
    //width and height
    if (renderStyle.width.value != null && renderStyle.height.value != null) {
      return renderStyle.width.computedValue / 18.0;
    }
    return 1.0;
  }

  void _markPseudoStateDirty() {
    final dom.Element? root = ownerDocument.documentElement;
    if (root != null) {
      ownerDocument.markElementStyleDirty(root, reason: 'childList-pseudo');
    } else {
      ownerDocument.markElementStyleDirty(this, reason: 'childList-pseudo');
    }
  }
}

class _SyncCheckedStateContext {
  final Pointer<NativeValue> method;
  final Pointer<NativeValue> args;

  _SyncCheckedStateContext(this.method, this.args);
}

void _handleSyncCheckedStateResult(Object contextHandle, Pointer<NativeValue> returnValue) {
  final _SyncCheckedStateContext context = contextHandle as _SyncCheckedStateContext;
  malloc.free(context.method);
  malloc.free(context.args);
  malloc.free(returnValue);
}

mixin CheckboxElementState on WebFWidgetElementState {
  static final Map<String, bool> _earlyCheckboxStates = <String, bool>{}; // Track early checkbox states
  
  // Public methods to access early checked states
  static void setEarlyCheckboxState(String key, bool value) {
    _earlyCheckboxStates[key] = value;
  }
  
  static bool? getEarlyCheckboxState(String key) {
    return _earlyCheckboxStates[key];
  }

  static void clearEarlyCheckboxState(String key) {
    _earlyCheckboxStates.remove(key);
  }
  
  BaseCheckedElement get _checkedElement => widgetElement as BaseCheckedElement;

  void initCheckboxState() {
    final String checkboxKey = _checkedElement.hashCode.toString();
    final bool? early = CheckboxElementState.getEarlyCheckboxState(checkboxKey);
    // Restore early checked state and then clear it to avoid leaks/cross-page interference.
    if (early != null) {
      setState(() {
        (_checkedElement as dynamic)._checked = early;
      });
      CheckboxElementState.clearEarlyCheckboxState(checkboxKey);
      return;
    }

    // Initialize from attribute presence for HTML parsing: <input checked> yields value="".
    if ((_checkedElement as dynamic).hasAttribute('checked') == true) {
      setState(() {
        (_checkedElement as dynamic)._checked = true;
      });
    }
  }

  Widget createCheckBox(BuildContext context) {
    return Transform.scale(
      scale: _checkedElement.getCheckboxSize(),
      child: Checkbox(
        value: _checkedElement.getChecked(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        onChanged: _checkedElement.disabled
            ? null
            : (bool? newValue) {
                if (newValue == null) return;
                _checkedElement.setChecked(newValue);
                _checkedElement.dispatchEvent(dom.InputEvent(inputType: 'checkbox', data: newValue.toString()));
                _checkedElement.dispatchEvent(dom.Event('change'));
              },
      ),
    );
  }
}
