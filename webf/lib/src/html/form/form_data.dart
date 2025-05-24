import 'dart:typed_data';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';

// FormData implementation following web standards
// https://developer.mozilla.org/en-US/docs/Web/API/FormData
class FormDataBindings extends DynamicBindingObject with StaticDefinedBindingObject {
  final Map<String, dynamic> _formStorages = {};
  Map<String, dynamic> get storage => _formStorages;

  // This is called when a new FormData object is created from the JS side
  FormDataBindings(BindingContext context): super(context);

  void setString(String key, String value) {
    _formStorages[key] = value;
  }

  void setBlob(String key, NativeByteData nativeByteData, String mimeType, String filename) {
    _formStorages[key] = MultipartFile.fromBytes(nativeByteData.bytes, filename: filename, contentType: DioMediaType.parse(mimeType));
  }

  void remove(String key) {
    _formStorages.remove(key);
  }

  static final StaticDefinedSyncBindingObjectMethodMap _elementSyncMethods = {
    'set_string': StaticDefinedSyncBindingObjectMethod(
        call: (bindingObject, args) => castToType<FormDataBindings>(bindingObject).setString(args[0], args[1])),
    'set_blob': StaticDefinedSyncBindingObjectMethod(
      call: (bindingObject, args) => castToType<FormDataBindings>(bindingObject).setBlob(args[0], args[1], args[2], args[3])
    ),
    'remove': StaticDefinedSyncBindingObjectMethod(
      call: (bindingObject, args) => castToType<FormDataBindings>(bindingObject).remove(args[0])
    )
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [...super.methods, _elementSyncMethods];
}
