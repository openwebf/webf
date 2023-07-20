import {FunctionArgumentType} from "./declaration";
import _ from "lodash";
import {generateUnionTypeHeader} from "./generateHeader";
import {
  generateCoreTypeValue,
  generateUnionTypeSource, isDictionary,
  isPointerType,
  isTypeHaveNull, isUnionType,
  trimNullTypeFromType
} from "./generateSource";
import {ParameterType} from "../analyzer";

export function generateUnionTypeFileName(unionType: ParameterType[]) {
  let filename = 'qjs_union';
  for (let i = 0; i < unionType.length; i++) {
    let v = unionType[i].value;
    if (isTypeHaveNull(unionType[i])) continue;
    if (typeof v == 'number') {
      filename += '_' + FunctionArgumentType[v];
    } else if (unionType[i].isArray && typeof v == 'object' && !Array.isArray(v)) {
      filename += '_' + 'sequence' + FunctionArgumentType[v.value as number];
    } else if (typeof v == 'string') {
      filename += _.snakeCase(v);
    }
  }
  return filename;
}

export function generateUnionTypeClassName(unionTypes: ParameterType[]) {
  let className = 'QJSUnion';
  for (let i = 0; i < unionTypes.length; i++) {
    if (isTypeHaveNull(unionTypes[i])) continue;
    className += getUnionTypeName(unionTypes[i]);
  }
  return className;
}

export function generateUnionTypes(unionType: ParameterType) {
  let header = generateUnionTypeHeader(unionType);
  let source = generateUnionTypeSource(unionType);
  return {
    header,
    source
  }
}

export function getUnionTypeName(unionType: ParameterType) {
  let v = unionType.value;
  if (typeof v == 'number') {
    return _.upperFirst(_.camelCase(FunctionArgumentType[v]));
  } else if (unionType.isArray && typeof v == 'object' && !Array.isArray(v)) {
    return 'Sequence' + _.upperFirst(_.camelCase(FunctionArgumentType[v.value as number]));
  } else if (typeof v === 'string') {
    return v;
  }
  return '';
}

export function generateUnionContentType(unionTypes: ParameterType[]) {
  let result = [];
  for (let i = 0; i < unionTypes.length; i++) {
    if (isTypeHaveNull(unionTypes[i])) continue;
    result.push('k' + getUnionTypeName(unionTypes[i]));
  }
  return result.join(',');
}

export function generateUnionMemberName(unionType: ParameterType) {
  let v = unionType.value;
  if (typeof v == 'number') {
    return FunctionArgumentType[v];
  } else if (unionType.isArray && typeof v == 'object' && !Array.isArray(v)) {
    return 'sequence' + typeof v.value === 'number' ? FunctionArgumentType[v.value as number] : v.value;
  } else if (typeof v == 'string') {
    return v;
  }
  return '';
}

export function generateUnionMemberType(unionType: ParameterType) {
  if (isDictionary(unionType)) {
    return generateCoreTypeValue(unionType);
  }

  if (isPointerType(unionType)) {
    return `Member<${generateCoreTypeValue(unionType).replace('*', '')}>`;
  }
  return generateCoreTypeValue(unionType);
}

export function generateUnionConstructor(className: string, unionType: ParameterType) {
  if (isTypeHaveNull(unionType)) return '';
  if (isDictionary(unionType)) {
    return `explicit ${className}(${generateCoreTypeValue(unionType)})`;
  }

  if (isPointerType(unionType)) {
    return `explicit ${className}(${generateCoreTypeValue(unionType)})`;
  }
  return `explicit ${className}(const ${generateCoreTypeValue(unionType)}& value)`;
}

export function generateUnionConstructorImpl(className: string, unionType: ParameterType) {
  if (isTypeHaveNull(unionType)) return '';
  if (isPointerType(unionType)) {
    return `${className}::${className}(${generateCoreTypeValue(unionType)} value): member_${generateUnionMemberName(unionType)}_(value), content_type_(ContentType::k${getUnionTypeName(unionType)}) {}`;
  }
  return `${className}::${className}(const ${generateCoreTypeValue(unionType)}& value): member_${generateUnionMemberName(unionType)}_(value), content_type_(ContentType::k${getUnionTypeName(unionType)}) {}`;
}

export function generateUnionTypeSetter(className: string, unionType: ParameterType): string {
  if (isTypeHaveNull(unionType)) return '';
  if (isPointerType(unionType)) {
    return `void ${className}::Set(${generateCoreTypeValue(unionType)} value) {
  Clear();
  member_${generateUnionMemberName(unionType)}_ = value;
  content_type_ = ContentType::k${getUnionTypeName(unionType)};
}`;
  }
  return `void ${className}::Set(${generateCoreTypeValue(unionType)}&& value) {
  Clear();
  member_${generateUnionMemberName(unionType)}_ = value;
  content_type_ = ContentType::k${getUnionTypeName(unionType)};
}

void ${className}::Set(const ${generateCoreTypeValue(unionType)}& value) {
  Clear();
  member_${generateUnionMemberName(unionType)}_ = value;
  content_type_ = ContentType::k${getUnionTypeName(unionType)};
}`;
}

export function generateTypeRawChecker(unionType: ParameterType): string {
  let returnValue = '';

  if (unionType.isArray) {
    return `JS_IsArray(ctx, value)`;
  } else if (isPointerType(unionType)) {
    return `JS_IsObject(value)`;
  } else {
    unionType = trimNullTypeFromType(unionType);
    switch (unionType.value) {
      case FunctionArgumentType.int32:
        returnValue = `JS_IsNumber(value)`;
        break;
      case FunctionArgumentType.int64:
        returnValue = 'JS_IsNumber(value)';
        break;
      case FunctionArgumentType.double:
        returnValue = `JS_IsNumber(value)`;
        break;
      case FunctionArgumentType.function:
        returnValue = `JS_IsFunction(ctx, value)`;
        break;
      case FunctionArgumentType.boolean:
        returnValue = `JS_IsBool(value)`;
        break;
      case FunctionArgumentType.dom_string:
        returnValue = `JS_IsString(value)`;
        break;
      case FunctionArgumentType.object:
        returnValue = `JS_IsObject(ctx, value)`;
        break;
      case FunctionArgumentType.null:
        returnValue = `JS_IsNull(value)`;
        break;
      default:
      case FunctionArgumentType.any:
        throw new Error('Can not generate type checker code for any type');
    }
  }

  return returnValue;
}

export function generateUnionTypeClear(unionType: ParameterType): string {
  let returnValue = '';

  if (unionType.isArray) {
    return `.clear()`;
  } else if (isPointerType(unionType)) {
    return `= nullptr`;
  } else {
    unionType = trimNullTypeFromType(unionType);
    switch (unionType.value) {
      case FunctionArgumentType.int32:
        returnValue = `= 0`;
        break;
      case FunctionArgumentType.int64:
        returnValue = '= 0';
        break;
      case FunctionArgumentType.double:
        returnValue = `= 0.0`;
        break;
      case FunctionArgumentType.boolean:
        returnValue = `= false`;
        break;
      case FunctionArgumentType.dom_string:
        returnValue = `= AtomicString::Empty()`;
        break;
      case FunctionArgumentType.object:
        returnValue = `= ScriptValue::Empty(ctx)`;
        break;
      default:
      case FunctionArgumentType.any:
        throw new Error('Can not generate type checker code for any type');
    }
  }

  return returnValue;
}

export function generateUnionPropertyHeaders(unionTypes: ParameterType[]) {
  return unionTypes.map(unionType => {
    let nativeType = '';
    let setter = '';
    if (isTypeHaveNull(unionType)) return '';
    if (isPointerType(unionType)) {
      nativeType = `${generateCoreTypeValue(unionType)}`;
      setter = `void Set(${generateCoreTypeValue(unionType)} value);`;
    } else {
      nativeType = `const ${generateCoreTypeValue(unionType)}&`;
      setter = `void Set(const ${generateCoreTypeValue(unionType)}& value);
  void Set(${generateCoreTypeValue(unionType)}&& value);`;
    }

    return `bool Is${getUnionTypeName(unionType)}() const { return content_type_ == ContentType::k${getUnionTypeName(unionType)}; }
  ${nativeType} GetAs${getUnionTypeName(unionType)}() const {
    assert(content_type_ == ContentType::k${getUnionTypeName(unionType)});
    return member_${generateUnionMemberName(unionType)}_;
  }
  ${setter}`;
  }).join('\n  ');
}
