import {IDLBlob} from "./IDLBlob";
import {
  ClassObject,
  FunctionArguments,
  FunctionArgumentType,
  FunctionDeclaration,
  FunctionObject,
  ParameterMode,
  PropsDeclaration,
} from "./declaration";
import {addIndent, getClassName} from "./utils";
import {ParameterType} from "./analyzer";
import _ from 'lodash';
import fs from 'fs';
import path from 'path';
import {getTemplateKind, TemplateKind} from "./generateHeader";
import {GenerateOptions} from "./generator";

function generateMethodArgumentsCheck(m: FunctionDeclaration) {
  if (m.args.length == 0) return '';

  let requiredArgsCount = 0;
  m.args.forEach(m => {
    if (m.required) requiredArgsCount++;
  });

  return `  if (argc < ${requiredArgsCount}) {
    return JS_ThrowTypeError(ctx, "Failed to execute '${m.name}' : ${requiredArgsCount} argument required, but %d present.", argc);
  }
`;
}

export function isTypeNeedAllocate(type: ParameterType[]) {
  switch(type[0]) {
    case FunctionArgumentType.undefined:
    case FunctionArgumentType.null:
    case FunctionArgumentType.int32:
    case FunctionArgumentType.int64:
    case FunctionArgumentType.boolean:
    case FunctionArgumentType.double:
      return false;
    default:
      return true;
  }
}

export function generateCoreTypeValue(type: ParameterType[]): string {
  switch (type[0]) {
    case FunctionArgumentType.int64: {
      return 'int64_t';
    }
    case FunctionArgumentType.int32: {
      return 'int32_t';
    }
    case FunctionArgumentType.void: {
      return 'void';
    }
    case FunctionArgumentType.double: {
      return 'double';
    }
    case FunctionArgumentType.boolean: {
      return 'bool';
    }
    case FunctionArgumentType.dom_string: {
      return 'AtomicString';
    }
    case FunctionArgumentType.any: {
      return 'ScriptValue';
    }
  }

  if (typeof type[0] == 'string') {
    return type[0] + '*';
  }

  return '';
}

export function generateRawTypeValue(type: ParameterType[], is32Bit: boolean = false): string {
  switch (type[0]) {
    case FunctionArgumentType.int64: {
      return 'int64_t';
    }
    case FunctionArgumentType.int32: {
      return 'int64_t';
    }
    case FunctionArgumentType.double: {
      return 'double';
    }
    case FunctionArgumentType.boolean: {
      return 'int64_t';
    }
    case FunctionArgumentType.dom_string: {
      if (is32Bit) {
        return 'int64_t';
      }

      return 'NativeString*';
    }
    default:
      if (is32Bit) {
        return 'int64_t';
      }
      return 'void*';
  }

  if (typeof type[0] == 'string') {
    if (is32Bit) {
      return 'int64_t';
    }
    return 'NativeBindingObject*';
  }

  return '';
}

export function generateIDLTypeConverter(type: ParameterType[], isOptional?: boolean): string {
  let haveNull = type.some(t => t === FunctionArgumentType.null);
  let returnValue = '';

  if (type[0] === FunctionArgumentType.array) {
    returnValue = `IDLSequence<${generateIDLTypeConverter(type.slice(1), isOptional)}>`;
  } else if (typeof type[0] === 'string') {
    returnValue = type[0];
  } else {
    switch (type[0]) {
      case FunctionArgumentType.int32:
        returnValue = `IDLInt32`;
        break;
      case FunctionArgumentType.int64:
        returnValue = 'IDLInt64';
        break;
      case FunctionArgumentType.double:
        returnValue = `IDLDouble`;
        break;
      case FunctionArgumentType.function:
        returnValue = `IDLCallback`;
        break;
      case FunctionArgumentType.boolean:
        returnValue = `IDLBoolean`;
        break;
      case FunctionArgumentType.dom_string:
        returnValue = `IDLDOMString`;
        break;
      case FunctionArgumentType.object:
        returnValue = `IDLObject`;
        break;
      case FunctionArgumentType.promise:
        returnValue = 'IDLPromise';
        break;
      default:
      case FunctionArgumentType.any:
        returnValue = `IDLAny`;
        break;
    }
  }

  if (haveNull) {
    returnValue = `IDLNullable<${returnValue}>`;
  } else if (isOptional) {
    returnValue = `IDLOptional<${returnValue}>`;
  }

  return returnValue;
}

function isDOMStringType(type: ParameterType[]) {
  return type[0] == FunctionArgumentType.dom_string;
}

function generateNativeValueTypeConverter(type: ParameterType[]): string {
  let returnValue = '';

  if (typeof type[0] === 'string') {
    return `NativeTypePointer<${type[0]}>`;
  }

  switch (type[0]) {
    case FunctionArgumentType.int32:
      returnValue = `NativeTypeInt64`;
      break;
    case FunctionArgumentType.int64:
      returnValue = 'NativeTypeInt64';
      break;
    case FunctionArgumentType.double:
      returnValue = `NativeTypeDouble`;
      break;
    case FunctionArgumentType.boolean:
      returnValue = `NativeTypeBool`;
      break;
    case FunctionArgumentType.dom_string:
      returnValue = `NativeTypeString`;
      break;
  }

  return returnValue;
}

function generateRequiredInitBody(argument: FunctionArguments, argsIndex: number) {
  let type = generateIDLTypeConverter(argument.type);

  let hasArgumentCheck = type.indexOf('Element') >= 0 || type.indexOf('Node') >= 0 || type === 'EventTarget';

  let body = '';
  if (hasArgumentCheck) {
    body = `Converter<${type}>::ArgumentsValue(context, argv[${argsIndex}], ${argsIndex}, exception_state)`
  } else {
    body = `Converter<${type}>::FromValue(ctx, argv[${argsIndex}], exception_state)`;
  }

  return `auto&& args_${argument.name} = ${body};
if (UNLIKELY(exception_state.HasException())) {
  return exception_state.ToQuickJS();
}`;
}

function generateCallMethodName(name: string) {
  if (name === 'constructor') return 'Create';
  return name;
}

function generateDartImplCallCode(blob: IDLBlob, declare: FunctionDeclaration, args: FunctionArguments[]): string {
  let nativeArguments = args.map(i => {
    return `NativeValueConverter<${generateNativeValueTypeConverter(i.type)}>::ToNativeValue(${isDOMStringType(i.type) ? 'ctx, ' : ''}args_${i.name})`;
  });

  let returnValueAssignment = '';

  if (declare.returnType[0] != FunctionArgumentType.void) {
    returnValueAssignment = 'auto&& native_value =';
  }

  return `
auto* self = toScriptWrappable<${getClassName(blob)}>(JS_IsUndefined(this_val) ? context->Global() : this_val);
NativeValue arguments[] = {
  ${nativeArguments.join(',\n')}
};
${returnValueAssignment}self->InvokeBindingMethod(binding_call_methods::k${declare.name}, ${nativeArguments.length}, arguments, exception_state);
${returnValueAssignment.length > 0 ? `return Converter<${generateIDLTypeConverter(declare.returnType)}>::ToValue(NativeValueConverter<${generateNativeValueTypeConverter(declare.returnType)}>::FromNativeValue(native_value))` : ''};
  `.trim();
}

function generateOptionalInitBody(blob: IDLBlob, declare: FunctionDeclaration, argument: FunctionArguments, argsIndex: number, previousArguments: string[], options: GenFunctionBodyOptions) {
  let call = '';
  let returnValueAssignment = '';
  if (declare.returnType[0] != FunctionArgumentType.void) {
    returnValueAssignment = 'return_value =';
  }
  if (declare.returnTypeMode?.dartImpl) {
    call = generateDartImplCallCode(blob, declare, declare.args.slice(0, argsIndex + 1));
  } else if (options.isInstanceMethod) {
    call = `auto* self = toScriptWrappable<${getClassName(blob)}>(this_val);
${returnValueAssignment} self->${generateCallMethodName(declare.name)}(${[...previousArguments, `args_${argument.name}`, 'exception_state'].join(',')});`;
  } else {
    call = `${returnValueAssignment} ${getClassName(blob)}::${generateCallMethodName(declare.name)}(context, ${[...previousArguments, `args_${argument.name}`].join(',')}, exception_state);`;
  }


  return `auto&& args_${argument.name} = Converter<IDLOptional<${generateIDLTypeConverter(argument.type)}>>::FromValue(ctx, argv[${argsIndex}], exception_state);
if (UNLIKELY(exception_state.HasException())) {
  return exception_state.ToQuickJS();
}

if (argc <= ${argsIndex + 1}) {
  ${call}
  break;
}`;
}

function generateFunctionCallBody(blob: IDLBlob, declaration: FunctionDeclaration, options: GenFunctionBodyOptions = {
  isConstructor: false,
  isInstanceMethod: false
}) {
  if (options.isConstructor && declaration.returnType[0] == FunctionArgumentType.void) {
    return 'return JS_ThrowTypeError(ctx, "Illegal constructor");';
  }

  let minimalRequiredArgc = 0;
  declaration.args.forEach(m => {
    if (m.required) minimalRequiredArgc++;
  });

  let requiredArguments: string[] = [];
  let requiredArgumentsInit: string[] = [];
  if (minimalRequiredArgc > 0) {
    requiredArgumentsInit = declaration.args.filter((a, i) => a.required).map((a, i) => {
      requiredArguments.push(`args_${a.name}`);
      return generateRequiredInitBody(a, i);
    });
  }

  let optionalArgumentsInit: string[] = [];
  let totalArguments: string[] = requiredArguments.slice();

  for (let i = minimalRequiredArgc; i < declaration.args.length; i++) {
    optionalArgumentsInit.push(generateOptionalInitBody(blob, declaration, declaration.args[i], i, totalArguments, options));
    totalArguments.push(`args_${declaration.args[i].name}`);
  }

  requiredArguments.push('exception_state');

  let call = '';
  let returnValueAssignment = '';
  if (declaration.returnType[0] != FunctionArgumentType.void) {
    returnValueAssignment = 'return_value =';
  }
  if (declaration.returnTypeMode?.dartImpl) {
    call = generateDartImplCallCode(blob, declaration, declaration.args.slice(0, minimalRequiredArgc));
  } else if (options.isInstanceMethod) {
    call = `auto* self = toScriptWrappable<${getClassName(blob)}>(JS_IsUndefined(this_val) ? context->Global() : this_val);
${returnValueAssignment} self->${generateCallMethodName(declaration.name)}(${minimalRequiredArgc > 0 ? `${requiredArguments.join(',')}` : 'exception_state'});`;
  } else {
    call = `${returnValueAssignment} ${getClassName(blob)}::${generateCallMethodName(declaration.name)}(context, ${requiredArguments.join(',')});`;
  }

  let minimalRequiredCall = declaration.args.length == 0 ? call : `if (argc <= ${minimalRequiredArgc}) {
  ${call}
  break;
}`;

  return `${requiredArgumentsInit.join('\n')}
${minimalRequiredCall}

${optionalArgumentsInit.join('\n')}
`;
}

function generateOverLoadSwitchBody(overloadMethods: FunctionDeclaration[]) {
  let callBodyList = overloadMethods.map((overload, index) => {
    return `if (${overload.args.length} == argc) {
  return ${overload.name}_overload_${index}(ctx, this_val, argc, argv);
}
    `;
  });

  return `
${callBodyList.join('\n')}

return ${overloadMethods[0].name}_overload_${0}(ctx, this_val, argc, argv);
`;
}

function generateDictionaryInit(blob: IDLBlob, props: PropsDeclaration[]) {
  let initExpression = props.map(prop => {
    switch (prop.type[0]) {
      case FunctionArgumentType.boolean: {
        return `${prop.name}_(false)`;
      }
    }
    return ''
  });

  // Remove empty.
  initExpression = initExpression.filter(i => !!i);

  if (initExpression.length == 0) return '';

  return ': ' + initExpression.join(',');
}

function generateReturnValueInit(blob: IDLBlob, type: ParameterType[], options: GenFunctionBodyOptions = {
  isConstructor: false,
  isInstanceMethod: false
}) {
  if (type[0] == FunctionArgumentType.void) return '';

  if (options.isConstructor) {
    return `${getClassName(blob)}* return_value = nullptr;`
  }
  if (typeof type[0] === 'string') {
    if (type[0] === 'Promise') {
      return 'ScriptPromise return_value;';
    } else {
      return `${type[0]}* return_value = nullptr;`;
    }
  }
  return `Converter<${generateIDLTypeConverter(type)}>::ImplType return_value;`;
}

function generateReturnValueResult(blob: IDLBlob, type: ParameterType[], mode?: ParameterMode, options: GenFunctionBodyOptions = {
  isConstructor: false,
  isInstanceMethod: false
}): string {
  if (type[0] == FunctionArgumentType.void) return 'JS_NULL';
  let method = 'ToQuickJS';

  if (options.isConstructor) {
    return `return_value->${method}()`;
  }

  return `Converter<${generateIDLTypeConverter(type)}>::ToValue(ctx, std::move(return_value))`;
}

type GenFunctionBodyOptions = { isConstructor?: boolean, isInstanceMethod?: boolean };

function generateFunctionBody(blob: IDLBlob, declare: FunctionDeclaration, options: GenFunctionBodyOptions = {
  isConstructor: false,
  isInstanceMethod: false
}) {
  let paramCheck = generateMethodArgumentsCheck(declare);
  let callBody = generateFunctionCallBody(blob, declare, options);
  let returnValueInit = generateReturnValueInit(blob, declare.returnType, options);
  let returnValueResult = generateReturnValueResult(blob, declare.returnType, declare.returnTypeMode, options);

  let constructorPrototypeInit = (options.isConstructor && returnValueInit.length > 0) ? `JSValue proto = JS_GetPropertyStr(ctx, this_val, "prototype");
  JS_SetPrototype(ctx, return_value->ToQuickJSUnsafe(), proto);
  JS_FreeValue(ctx, proto);` : '';

  return `${paramCheck}

  ExceptionState exception_state;
  ${returnValueInit}
  ExecutingContext* context = ExecutingContext::From(ctx);
  MemberMutationScope scope{ExecutingContext::From(ctx)};

  do {  // Dummy loop for use of 'break'.
${addIndent(callBody, 4)}
  } while (false);

  if (UNLIKELY(exception_state.HasException())) {
    return exception_state.ToQuickJS();
  }
  ${constructorPrototypeInit}
  return ${returnValueResult};
`;
}

function readTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../../templates/idl_templates/' + name + '.cc.tpl'), {encoding: 'utf-8'});
}

export function generateCppSource(blob: IDLBlob, options: GenerateOptions) {
  const baseTemplate = fs.readFileSync(path.join(__dirname, '../../templates/idl_templates/base.cc.tpl'), {encoding: 'utf-8'});

  const contents = blob.objects.map(object => {
    const templateKind = getTemplateKind(object);
    if (templateKind === TemplateKind.null) return '';

    switch (templateKind) {
      case TemplateKind.Interface: {
        object = object as ClassObject;

        function addObjectProps(prop: PropsDeclaration) {
          options.classMethodsInstallList.push(`{"${prop.name}", ${prop.name}AttributeGetCallback, ${prop.readonly ? 'nullptr' : `${prop.name}AttributeSetCallback`}}`)
        }
        function addObjectMethods(method: FunctionDeclaration, i: number) {
          if (overloadMethods.hasOwnProperty(method.name)) {
            overloadMethods[method.name].push(method)
          } else {
            overloadMethods[method.name] = [method];
            filtedMethods.push(method);
            options.classPropsInstallList.push(`{"${method.name}", ${method.name}, ${method.args.length}}`)
          }
        }

        object.props.forEach(addObjectProps);

        let overloadMethods = {};
        let filtedMethods: FunctionDeclaration[] = [];
        object.methods.forEach(addObjectMethods);

        if (object.construct) {
          options.constructorInstallList.push(`{"${getClassName(blob)}", nullptr, nullptr, constructor}`)
        }

        let wrapperTypeRegisterList = [
          `JS_CLASS_${_.snakeCase(getClassName(blob)).toUpperCase()}`,                        // ClassId
          `"${getClassName(blob)}"`,                                                          // ClassName
          object.parent != null ? `${object.parent}::GetStaticWrapperTypeInfo()` : 'nullptr', // parentClassWrapper
          object.construct ? `QJS${getClassName(blob)}::ConstructorCallback` : 'nullptr',     // ConstructorCallback
        ];

        // Generate indexed property callback.
        if (object.indexedProp) {
          if (object.indexedProp.indexKeyType == 'number') {
            wrapperTypeRegisterList.push(`IndexedPropertyGetterCallback`);
            if (!object.indexedProp.readonly) {
              wrapperTypeRegisterList.push(`IndexedPropertySetterCallback`);
            } else {
              wrapperTypeRegisterList.push('nullptr');
            }
            wrapperTypeRegisterList.push('nullptr');
            wrapperTypeRegisterList.push('nullptr');
          } else {
            wrapperTypeRegisterList.push('nullptr');
            wrapperTypeRegisterList.push('nullptr');

            wrapperTypeRegisterList.push(`StringPropertyGetterCallback`);
            if (!object.indexedProp.readonly) {
              wrapperTypeRegisterList.push(`StringPropertySetterCallback`);
            } else {
              wrapperTypeRegisterList.push('nullptr');
            }
          }

          wrapperTypeRegisterList.push('PropertyCheckerCallback');
          wrapperTypeRegisterList.push('PropertyEnumerateCallback');
        }

        let mixinParent = object.mixinParent;
        let mixinObjects: ClassObject[] | null = null;
        if (mixinParent) {
          mixinObjects = mixinParent.map(mixinName => ClassObject.globalClassMap[mixinName]).filter(o => !!o);

          mixinObjects.forEach(mixinObject => {
            mixinObject.methods.forEach(addObjectMethods);
            mixinObject.props.forEach(addObjectProps);
          });
        }

        options.wrapperTypeInfoInit = `
const WrapperTypeInfo QJS${getClassName(blob)}::wrapper_type_info_ {${wrapperTypeRegisterList.join(', ')}};
const WrapperTypeInfo& ${getClassName(blob)}::wrapper_type_info_ = QJS${getClassName(blob)}::wrapper_type_info_;`;
        return _.template(readTemplate('interface'))({
          className: getClassName(blob),
          blob: blob,
          object: object,
          mixinObjects,
          generateFunctionBody,
          generateCoreTypeValue,
          generateRawTypeValue,
          generateOverLoadSwitchBody,
          isTypeNeedAllocate,
          overloadMethods,
          filtedMethods,
          generateIDLTypeConverter,
          generateNativeValueTypeConverter,
          isDOMStringType,
        });
      }
      case TemplateKind.Dictionary: {
        let props = (object as ClassObject).props;
        return _.template(readTemplate('dictionary'))({
          className: getClassName(blob),
          blob: blob,
          props: props,
          object: object,
          generateIDLTypeConverter,
          generateDictionaryInit
        });
      }
      case TemplateKind.globalFunction: {
        object = object as FunctionObject;
        options.globalFunctionInstallList.push(` {"${object.declare.name}", ${object.declare.name}, ${object.declare.args.length}}`);
        return _.template(readTemplate('global_function'))({
          className: getClassName(blob),
          blob: blob,
          object: object,
          generateFunctionBody
        });
      }
    }
    return '';
  });

  return _.template(baseTemplate)({
    content: contents.join('\n'),
    className: getClassName(blob),
    blob: blob,
    ...options
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}
