import ts, {HeritageClause, ScriptTarget, VariableStatement} from 'typescript';
import {IDLBlob} from './IDLBlob';
import {
  ClassObject,
  ClassObjectKind,
  FunctionArguments,
  FunctionArgumentType,
  FunctionDeclaration,
  FunctionObject,
  IndexedPropertyDeclaration,
  ParameterMode,
  PropsDeclaration,
} from './declaration';
import {isUnionType} from "./utils";

interface DefinedPropertyCollector {
  properties: Set<string>;
  files: Set<string>;
  interfaces: Set<string>;
}

export interface UnionTypeCollector {
  types: Set<ParameterType[]>;
}

// Cache for parsed source files to avoid re-parsing
const sourceFileCache = new Map<string, ts.SourceFile>();

// Cache for type conversions to avoid redundant processing
const typeConversionCache = new Map<string, ParameterType>();

// Type mapping constants for better performance
const BASIC_TYPE_MAP: Partial<Record<ts.SyntaxKind, FunctionArgumentType>> = {
  [ts.SyntaxKind.StringKeyword]: FunctionArgumentType.dom_string,
  [ts.SyntaxKind.NumberKeyword]: FunctionArgumentType.double,
  [ts.SyntaxKind.BooleanKeyword]: FunctionArgumentType.boolean,
  [ts.SyntaxKind.AnyKeyword]: FunctionArgumentType.any,
  [ts.SyntaxKind.ObjectKeyword]: FunctionArgumentType.object,
  [ts.SyntaxKind.VoidKeyword]: FunctionArgumentType.void,
  [ts.SyntaxKind.NullKeyword]: FunctionArgumentType.null,
  [ts.SyntaxKind.UndefinedKeyword]: FunctionArgumentType.undefined,
};

const TYPE_REFERENCE_MAP: Record<string, FunctionArgumentType> = {
  'Function': FunctionArgumentType.function,
  'Promise': FunctionArgumentType.promise,
  'JSArrayProtoMethod': FunctionArgumentType.js_array_proto_methods,
  'int': FunctionArgumentType.int,
  'double': FunctionArgumentType.double,
};

export function analyzer(blob: IDLBlob, definedPropertyCollector: DefinedPropertyCollector, unionTypeCollector: UnionTypeCollector) {
  try {
    // Check cache first
    let sourceFile = sourceFileCache.get(blob.source);
    if (!sourceFile) {
      sourceFile = ts.createSourceFile(blob.source, blob.raw, ScriptTarget.ES2020);
      sourceFileCache.set(blob.source, sourceFile);
    }
    
    blob.objects = sourceFile.statements
      .map(statement => {
        try {
          return walkProgram(blob, statement, definedPropertyCollector, unionTypeCollector);
        } catch (error) {
          console.error(`Error processing statement in ${blob.source}:`, error);
          return null;
        }
      })
      .filter(o => o instanceof ClassObject || o instanceof FunctionObject) as (FunctionObject | ClassObject)[];
  } catch (error) {
    console.error(`Error analyzing ${blob.source}:`, error);
    throw new Error(`Failed to analyze ${blob.source}: ${error instanceof Error ? error.message : String(error)}`);
  }
}

export function buildClassRelationship() {
  const globalClassMap = ClassObject.globalClassMap;
  const globalClassRelationMap = ClassObject.globalClassRelationMap;

  // Use more efficient for...in loop
  for (const key in globalClassMap) {
    const obj = globalClassMap[key];
    if (obj.parent) {
      if (!globalClassRelationMap[obj.parent]) {
        globalClassRelationMap[obj.parent] = [];
      }
      globalClassRelationMap[obj.parent].push(obj.name);
    }
  }
}

function getInterfaceName(statement: ts.Statement): string {
  if (!ts.isInterfaceDeclaration(statement)) {
    throw new Error('Statement is not an interface declaration');
  }
  return statement.name.escapedText as string;
}

function getHeritageType(heritage: HeritageClause): string | null {
  if (!heritage.types.length) return null;
  
  const expression = heritage.types[0].expression;
  if (ts.isIdentifier(expression)) {
    return expression.escapedText as string;
  }
  return null;
}

function getMixins(heritage: HeritageClause): string[] | null {
  if (heritage.types.length <= 1) return null;
  
  const mixins: string[] = [];
  for (let i = 1; i < heritage.types.length; i++) {
    const expression = heritage.types[i].expression;
    if (ts.isIdentifier(expression)) {
      mixins.push(expression.escapedText as string);
    }
  }
  return mixins.length > 0 ? mixins : null;
}

function getPropName(propName: ts.PropertyName, prop?: PropsDeclaration): string {
  switch (propName.kind) {
    case ts.SyntaxKind.Identifier:
      return propName.escapedText.toString();
    case ts.SyntaxKind.StringLiteral:
      return propName.text;
    case ts.SyntaxKind.NumericLiteral:
      return propName.text;
    case ts.SyntaxKind.ComputedPropertyName:
      if (ts.isPropertyAccessExpression(propName.expression)) {
        if (prop) prop.isSymbol = true;
        const expression = propName.expression;
        return `${expression.expression.getText()}_${expression.name.getText()}`;
      }
      throw new Error(`Computed property name of type ${ts.SyntaxKind[propName.expression.kind]} is not supported`);
    default:
      throw new Error(`Property name of type ${ts.SyntaxKind[propName.kind]} is not supported`);
  }
}

function getParameterName(name: ts.BindingName): string {
  if (ts.isIdentifier(name)) {
    return name.escapedText.toString();
  }
  // Handle other binding patterns if needed
  console.warn('Non-identifier parameter names are not fully supported');
  return '';
}

export type ParameterBaseType = FunctionArgumentType | string;
export type ParameterType = {
  isArray?: boolean;
  value: ParameterType | ParameterType[] | ParameterBaseType;
};

function getParameterBaseType(type: ts.TypeNode, mode?: ParameterMode): ParameterBaseType {
  // Check basic types first (most common case)
  const basicType = BASIC_TYPE_MAP[type.kind];
  if (basicType !== undefined) {
    return basicType;
  }

  if (type.kind === ts.SyntaxKind.TypeReference) {
    const typeReference = type as ts.TypeReferenceNode;
    const typeName = typeReference.typeName;
    
    if (!ts.isIdentifier(typeName)) {
      console.warn('Non-identifier type references are not supported');
      return FunctionArgumentType.any;
    }
    
    const identifier = typeName.text;
    
    // Check simple type references
    const mappedType = TYPE_REFERENCE_MAP[identifier];
    if (mappedType !== undefined) {
      return mappedType;
    }
    
    // Handle special type wrappers
    switch (identifier) {
      case 'NewObject':
        if (mode) mode.newObject = true;
        if (typeReference.typeArguments && typeReference.typeArguments[0]) {
          const argument = typeReference.typeArguments[0];
          if (ts.isTypeReferenceNode(argument) && ts.isIdentifier(argument.typeName)) {
            return argument.typeName.text;
          }
        }
        return FunctionArgumentType.any;
        
      case 'DartImpl':
        if (mode) mode.dartImpl = true;
        return handleDartImplType(typeReference, mode);
        
      case 'DependentsOnLayout':
        if (mode) mode.layoutDependent = true;
        return handleDependentsOnLayoutType(typeReference, mode);
        
      case 'StaticMember':
        if (mode) mode.static = true;
        return handleGenericWrapper(typeReference, mode);
        
      case 'StaticMethod':
        if (mode) mode.staticMethod = true;
        return handleGenericWrapper(typeReference, mode);
        
      default:
        if (identifier.includes('SupportAsync')) {
          return handleSupportAsyncType(identifier, typeReference, mode);
        }
        return identifier;
    }
  }
  
  if (type.kind === ts.SyntaxKind.LiteralType) {
    // Handle literal types - check if it's a null literal
    const literalType = type as ts.LiteralTypeNode;
    if (literalType.literal.kind === ts.SyntaxKind.NullKeyword) {
      return FunctionArgumentType.null;
    }
    return FunctionArgumentType.any;
  }
  
  return FunctionArgumentType.any;
}

function handleDartImplType(typeReference: ts.TypeReferenceNode, mode?: ParameterMode): ParameterBaseType {
  if (!typeReference.typeArguments || !typeReference.typeArguments[0]) {
    return FunctionArgumentType.any;
  }
  
  let argument = typeReference.typeArguments[0];
  
  if (ts.isTypeReferenceNode(argument)) {
    const typeName = argument.typeName;
    if (ts.isIdentifier(typeName) && typeName.text === 'DependentsOnLayout') {
      if (mode) mode.layoutDependent = true;
      if (argument.typeArguments && argument.typeArguments[0]) {
        argument = argument.typeArguments[0];
      }
    }
  }
  
  return getParameterBaseType(argument, mode);
}

function handleDependentsOnLayoutType(typeReference: ts.TypeReferenceNode, mode?: ParameterMode): ParameterBaseType {
  if (!typeReference.typeArguments || !typeReference.typeArguments[0]) {
    return FunctionArgumentType.any;
  }
  
  const argument = typeReference.typeArguments[0];
  return getParameterBaseType(argument, mode);
}

function handleGenericWrapper(typeReference: ts.TypeReferenceNode, mode?: ParameterMode): ParameterBaseType {
  if (!typeReference.typeArguments || !typeReference.typeArguments[0]) {
    return FunctionArgumentType.any;
  }
  
  const argument = typeReference.typeArguments[0];
  return getParameterBaseType(argument, mode);
}

function handleSupportAsyncType(identifier: string, typeReference: ts.TypeReferenceNode, mode?: ParameterMode): ParameterBaseType {
  if (mode) {
    mode.supportAsync = true;
    if (identifier === "SupportAsyncManual") {
      mode.supportAsyncManual = true;
    }
  }
  
  if (!typeReference.typeArguments || !typeReference.typeArguments[0]) {
    return FunctionArgumentType.any;
  }
  
  let argument = typeReference.typeArguments[0];
  
  if (ts.isTypeReferenceNode(argument)) {
    const typeName = argument.typeName;
    if (ts.isIdentifier(typeName) && typeName.text === 'DartImpl') {
      if (mode) mode.dartImpl = true;
      if (argument.typeArguments && argument.typeArguments[0]) {
        argument = argument.typeArguments[0];
      }
    }
  } else if (ts.isArrayTypeNode(argument)) {
    if (mode) mode.supportAsyncArrayValue = true;
    return getParameterBaseType(argument.elementType, mode);
  }
  
  return getParameterBaseType(argument, mode);
}

function getParameterType(type: ts.TypeNode, unionTypeCollector: UnionTypeCollector, mode?: ParameterMode): ParameterType {
  // Generate cache key
  const cacheKey = `${type.kind}_${type.pos}_${type.end}`;
  
  // Check cache first (only for types without mode)
  if (!mode) {
    const cached = typeConversionCache.get(cacheKey);
    if (cached) return cached;
  }
  
  let result: ParameterType;
  
  if (type.kind === ts.SyntaxKind.ParenthesizedType) {
    const typeNode = type as ts.ParenthesizedTypeNode;
    result = getParameterType(typeNode.type, unionTypeCollector, mode);
  } else if (type.kind === ts.SyntaxKind.ArrayType) {
    const arrayType = type as ts.ArrayTypeNode;
    result = {
      isArray: true,
      value: getParameterType(arrayType.elementType, unionTypeCollector, mode)
    };
  } else if (type.kind === ts.SyntaxKind.UnionType) {
    const unionType = type as ts.UnionTypeNode;
    const types = unionType.types.map(t => getParameterType(t, unionTypeCollector, mode));
    result = {
      isArray: false,
      value: types
    };
    if (isUnionType(result)) {
      unionTypeCollector.types.add(result.value as ParameterType[]);
    }
  } else if (type.kind === ts.SyntaxKind.TypeReference) {
    result = handleTypeReferenceForParameter(type as ts.TypeReferenceNode, unionTypeCollector, mode);
  } else {
    result = {
      isArray: false,
      value: getParameterBaseType(type, mode)
    };
  }
  
  // Cache the result if no mode
  if (!mode) {
    typeConversionCache.set(cacheKey, result);
  }
  
  return result;
}

function handleTypeReferenceForParameter(typeReference: ts.TypeReferenceNode, unionTypeCollector: UnionTypeCollector, mode?: ParameterMode): ParameterType {
  const typeName = typeReference.typeName;
  
  if (!ts.isIdentifier(typeName)) {
    return {
      isArray: false,
      value: FunctionArgumentType.any
    };
  }
  
  const identifier = typeName.text;
  
  if (identifier.includes('SupportAsync') && typeReference.typeArguments && typeReference.typeArguments[0]) {
    const argument = typeReference.typeArguments[0];
    
    if (ts.isUnionTypeNode(argument)) {
      if (mode) {
        mode.supportAsync = true;
        if (identifier === 'SupportAsyncManual') {
          mode.supportAsyncManual = true;
        }
      }
      
      const types = argument.types.map(t => getParameterType(t, unionTypeCollector, mode));
      const result = {
        isArray: false,
        value: types
      };
      
      if (isUnionType(result)) {
        unionTypeCollector.types.add(result.value as ParameterType[]);
      }
      
      return result;
    }
  }
  
  return {
    isArray: false,
    value: getParameterBaseType(typeReference, mode)
  };
}

function paramsNodeToArguments(parameter: ts.ParameterDeclaration, unionTypeCollector: UnionTypeCollector): FunctionArguments {
  const args = new FunctionArguments();
  args.name = getParameterName(parameter.name);
  
  if (!parameter.type) {
    console.warn(`Parameter ${args.name} has no type annotation, defaulting to any`);
    args.type = { isArray: false, value: FunctionArgumentType.any };
    return args;
  }
  
  const typeMode = new ParameterMode();
  args.type = getParameterType(parameter.type, unionTypeCollector, typeMode);
  args.isDotDotDot = !!parameter.dotDotDotToken;
  args.typeMode = typeMode;
  args.required = !parameter.questionToken;
  
  return args;
}

function isParamsReadOnly(m: ts.PropertySignature): boolean {
  if (!m.modifiers) return false;
  return m.modifiers.some(k => k.kind === ts.SyntaxKind.ReadonlyKeyword);
}

function walkProgram(blob: IDLBlob, statement: ts.Statement, definedPropertyCollector: DefinedPropertyCollector, unionTypeCollector: UnionTypeCollector) {
  switch(statement.kind) {
    case ts.SyntaxKind.InterfaceDeclaration:
      return processInterfaceDeclaration(statement as ts.InterfaceDeclaration, blob, definedPropertyCollector, unionTypeCollector);
      
    case ts.SyntaxKind.VariableStatement:
      return processVariableStatement(statement as VariableStatement, unionTypeCollector);
      
    default:
      return null;
  }
}

function processInterfaceDeclaration(
  statement: ts.InterfaceDeclaration,
  blob: IDLBlob,
  definedPropertyCollector: DefinedPropertyCollector,
  unionTypeCollector: UnionTypeCollector
): ClassObject | null {
  const interfaceName = statement.name.escapedText.toString();
  const obj = new ClassObject();
  
  // Process heritage clauses
  if (statement.heritageClauses) {
    const heritage = statement.heritageClauses[0];
    const heritageType = getHeritageType(heritage);
    const mixins = getMixins(heritage);
    
    if (heritageType) obj.parent = heritageType;
    if (mixins) obj.mixinParent = mixins;
  }
  
  obj.name = interfaceName;
  
  if (obj.kind === ClassObjectKind.interface) {
    definedPropertyCollector.interfaces.add('QJS' + interfaceName);
    definedPropertyCollector.files.add(blob.filename);
    definedPropertyCollector.properties.add(interfaceName);
  }
  
  // Process members in batches for better performance
  const members = Array.from(statement.members);
  processMembersBatch(members, obj, definedPropertyCollector, unionTypeCollector);
  
  ClassObject.globalClassMap[interfaceName] = obj;
  
  return obj;
}

function processMembersBatch(
  members: ts.TypeElement[],
  obj: ClassObject,
  definedPropertyCollector: DefinedPropertyCollector,
  unionTypeCollector: UnionTypeCollector
): void {
  for (const member of members) {
    try {
      processMember(member, obj, definedPropertyCollector, unionTypeCollector);
    } catch (error) {
      console.error(`Error processing member:`, error);
    }
  }
}

function processMember(
  member: ts.TypeElement,
  obj: ClassObject,
  definedPropertyCollector: DefinedPropertyCollector,
  unionTypeCollector: UnionTypeCollector
): void {
  switch(member.kind) {
    case ts.SyntaxKind.PropertySignature:
      processPropertySignature(member as ts.PropertySignature, obj, definedPropertyCollector, unionTypeCollector);
      break;
      
    case ts.SyntaxKind.MethodSignature:
      processMethodSignature(member as ts.MethodSignature, obj, unionTypeCollector);
      break;
      
    case ts.SyntaxKind.IndexSignature:
      processIndexSignature(member as ts.IndexSignatureDeclaration, obj, unionTypeCollector);
      break;
      
    case ts.SyntaxKind.ConstructSignature:
      processConstructSignature(member as ts.ConstructSignatureDeclaration, obj, unionTypeCollector);
      break;
  }
}

function processPropertySignature(
  member: ts.PropertySignature,
  obj: ClassObject,
  definedPropertyCollector: DefinedPropertyCollector,
  unionTypeCollector: UnionTypeCollector
): void {
  const prop = new PropsDeclaration();
  prop.name = getPropName(member.name!, prop);
  prop.readonly = isParamsReadOnly(member);
  
  definedPropertyCollector.properties.add(prop.name);
  
  if (!member.type) {
    console.warn(`Property ${prop.name} has no type annotation`);
    return;
  }
  
  const mode = new ParameterMode();
  prop.type = getParameterType(member.type, unionTypeCollector, mode);
  prop.typeMode = mode;
  prop.optional = !!member.questionToken;
  
  if (prop.type.value === FunctionArgumentType.function && ts.isFunctionTypeNode(member.type)) {
    const functionProps = prop as FunctionDeclaration;
    functionProps.args = member.type.parameters.map(params => 
      paramsNodeToArguments(params, unionTypeCollector)
    );
    obj.methods.push(functionProps);
  } else {
    obj.props.push(prop);
    
    // Handle async properties
    if (prop.typeMode.supportAsync) {
      const asyncProp = createAsyncProperty(prop, mode);
      definedPropertyCollector.properties.add(asyncProp.name);
      obj.props.push(asyncProp);
    }
  }
}

function createAsyncProperty(prop: PropsDeclaration, mode: ParameterMode): PropsDeclaration {
  const asyncProp = Object.assign({}, prop);
  const syncMode = Object.assign({}, mode);
  
  syncMode.supportAsync = false;
  syncMode.supportAsyncManual = false;
  prop.typeMode = syncMode;
  
  asyncProp.name = asyncProp.name + '_async';
  asyncProp.async_type = {
    isArray: false,
    value: FunctionArgumentType.promise
  };
  
  return asyncProp;
}

function processMethodSignature(
  member: ts.MethodSignature,
  obj: ClassObject,
  unionTypeCollector: UnionTypeCollector
): void {
  const f = new FunctionDeclaration();
  f.name = getPropName(member.name!);
  f.args = member.parameters.map(params => 
    paramsNodeToArguments(params, unionTypeCollector)
  );
  
  if (member.type) {
    const mode = new ParameterMode();
    f.returnType = getParameterType(member.type, unionTypeCollector, mode);
    
    if (mode.supportAsyncArrayValue) {
      f.returnType = {
        isArray: true,
        value: f.returnType
      };
    }
    
    f.returnTypeMode = mode;
    
    if (f.returnTypeMode.staticMethod) {
      obj.staticMethods.push(f);
    }
  }
  
  obj.methods.push(f);
  
  // Handle async methods
  if (f.returnTypeMode?.supportAsync) {
    const asyncFunc = createAsyncMethod(member, f, unionTypeCollector);
    obj.methods.push(asyncFunc);
  }
}

function createAsyncMethod(
  member: ts.MethodSignature,
  originalFunc: FunctionDeclaration,
  unionTypeCollector: UnionTypeCollector
): FunctionDeclaration {
  const asyncFunc = Object.assign({}, originalFunc);
  const mode = Object.assign({}, originalFunc.returnTypeMode);
  
  mode.supportAsync = false;
  mode.supportAsyncManual = false;
  originalFunc.returnTypeMode = mode;
  
  asyncFunc.name = getPropName(member.name!) + '_async';
  asyncFunc.args = member.parameters.map(params => 
    paramsNodeToArguments(params, unionTypeCollector)
  );
  asyncFunc.async_returnType = {
    isArray: false,
    value: FunctionArgumentType.promise
  };
  
  return asyncFunc;
}

function processIndexSignature(
  member: ts.IndexSignatureDeclaration,
  obj: ClassObject,
  unionTypeCollector: UnionTypeCollector
): void {
  const prop = new IndexedPropertyDeclaration();
  const modifier = member.modifiers;
  prop.readonly = !!(modifier && modifier[0].kind === ts.SyntaxKind.ReadonlyKeyword);
  
  const params = member.parameters;
  if (params.length > 0 && params[0].type) {
    prop.indexKeyType = params[0].type.kind === ts.SyntaxKind.NumberKeyword ? 'number' : 'string';
  }
  
  const mode = new ParameterMode();
  prop.type = getParameterType(member.type, unionTypeCollector, mode);
  prop.typeMode = mode;
  obj.indexedProp = prop;
}

function processConstructSignature(
  member: ts.ConstructSignatureDeclaration,
  obj: ClassObject,
  unionTypeCollector: UnionTypeCollector
): void {
  const c = new FunctionDeclaration();
  c.name = 'constructor';
  c.args = member.parameters.map(params => 
    paramsNodeToArguments(params, unionTypeCollector)
  );
  
  if (member.type) {
    c.returnType = getParameterType(member.type, unionTypeCollector);
  }
  
  obj.construct = c;
}

function processVariableStatement(
  statement: VariableStatement,
  unionTypeCollector: UnionTypeCollector
): FunctionObject | null {
  const declaration = statement.declarationList.declarations[0];
  
  if (!ts.isIdentifier(declaration.name)) {
    console.warn('Variable declaration with non-identifier name is not supported');
    return null;
  }
  
  const methodName = declaration.name.text;
  const type = declaration.type;
  
  if (!type || !ts.isFunctionTypeNode(type)) {
    return null;
  }
  
  const functionObject = new FunctionObject();
  functionObject.declare = new FunctionDeclaration();
  functionObject.declare.name = methodName;
  functionObject.declare.args = type.parameters.map(param => 
    paramsNodeToArguments(param, unionTypeCollector)
  );
  functionObject.declare.returnType = getParameterType(type.type, unionTypeCollector);
  
  return functionObject;
}

// Clear caches when needed (e.g., between runs)
export function clearCaches() {
  sourceFileCache.clear();
  typeConversionCache.clear();
}