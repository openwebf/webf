import 'package:webf/bridge.dart';

class TestBindingObject extends DynamicBindingObject with StaticDefinedBindingObject {
  int _value = 0;

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
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [...super.properties, _props];

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _syncMethods];

  @override
  List<StaticDefinedAsyncBindingObjectMethodMap> get asyncMethods => [...super.asyncMethods, _asyncMethods];
}

