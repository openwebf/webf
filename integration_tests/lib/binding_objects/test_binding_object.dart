import 'package:webf/bridge.dart';

class TestBindingObject extends DynamicBindingObject with StaticDefinedBindingObject {
  int _value = 0;
  JSFunction? _callback;

  TestBindingObject(BindingContext context, List<dynamic> args) : super(context) {
    if (args.isNotEmpty && args[0] is int) {
      _value = args[0] as int;
    }
  }

  static final StaticDefinedBindingPropertyMap _props = {
    'value': StaticDefinedBindingProperty(
      getter: (obj) => (obj as TestBindingObject)._value,
      setter: (obj, dynamic value) {
        if (value is int) {
          (obj as TestBindingObject)._value = value;
        }
      },
    ),
  };

  static final StaticDefinedSyncBindingObjectMethodMap _syncMethods = {
    'add': StaticDefinedSyncBindingObjectMethod(
      call: (obj, args) {
        final instance = obj as TestBindingObject;
        if (args.isNotEmpty && args[0] is int) {
          return instance._value + (args[0] as int);
        }
        return instance._value;
      },
    ),
    'readOtherValue': StaticDefinedSyncBindingObjectMethod(
      call: (obj, args) {
        if (args.isEmpty) return null;
        final other = args[0];
        if (other is TestBindingObject) {
          return other._value;
        }
        return null;
      },
    ),
    'isSameInstance': StaticDefinedSyncBindingObjectMethod(
      call: (obj, args) {
        if (args.isEmpty) return false;
        return identical(obj, args[0]);
      },
    ),
    'setOtherValue': StaticDefinedSyncBindingObjectMethod(
      call: (obj, args) {
        if (args.length < 2) return null;
        final other = args[0];
        final nextValue = args[1];
        if (other is TestBindingObject && nextValue is int) {
          other._value = nextValue;
          return other._value;
        }
        return null;
      },
    ),
    'setCallback': StaticDefinedSyncBindingObjectMethod(
      call: (obj, args) {
        final instance = obj as TestBindingObject;
        if (args.isEmpty) return false;

        final callback = args[0];
        if (callback == null) {
          instance._callback?.dispose();
          instance._callback = null;
          return true;
        }

        if (callback is JSFunction) {
          instance._callback?.dispose();
          instance._callback = callback;
          return true;
        }

        return false;
      },
    ),
  };

  static final StaticDefinedAsyncBindingObjectMethodMap _asyncMethods = {
    'asyncAdd': StaticDefinedAsyncBindingObjectMethod(
      call: (obj, args) async {
        final instance = obj as TestBindingObject;
        if (args.isNotEmpty && args[0] is int) {
          return instance._value + (args[0] as int);
        }
        return instance._value;
      },
    ),
    'asyncReadOtherValue': StaticDefinedAsyncBindingObjectMethod(
      call: (obj, args) async {
        if (args.isEmpty) return null;
        final other = args[0];
        if (other is TestBindingObject) {
          return other._value;
        }
        return null;
      },
    ),
    'callCallback': StaticDefinedAsyncBindingObjectMethod(
      call: (obj, args) async {
        final instance = obj as TestBindingObject;
        final callback = instance._callback;
        if (callback == null) return null;
        return await callback.invoke(args);
      },
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _props];

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _syncMethods];

  @override
  List<StaticDefinedAsyncBindingObjectMethodMap> get asyncMethods => [...super.asyncMethods, _asyncMethods];

  @override
  void dispose() {
    _callback?.dispose();
    _callback = null;
    super.dispose();
  }
}
