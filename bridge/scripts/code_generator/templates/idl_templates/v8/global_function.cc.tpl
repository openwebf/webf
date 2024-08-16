static void ${object.declare.name}(const v8::FunctionCallbackInfo<v8::Value>& args) {
  <%= generateFunctionBody(blob, object.declare) %>
}