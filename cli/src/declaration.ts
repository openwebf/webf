import {ParameterBaseType, ParameterType} from "./analyzer";

export enum FunctionArgumentType {
  // Basic types
  dom_string,
  object,
  promise,
  int,
  double,
  boolean,
  function,
  void,
  any,
  null,
  undefined,
  array,
  js_array_proto_methods,
}

export class FunctionArguments {
  name: string;
  type: ParameterType;
  isDotDotDot: boolean;
  isSymbolKey: boolean;
  typeMode: ParameterMode;
  required: boolean;
}

export class ParameterMode {
  newObject?: boolean;
  dartImpl?: boolean;
  layoutDependent?: boolean;
  static?: boolean;
  supportAsync?: boolean;
  supportAsyncManual?: boolean;
  supportAsyncArrayValue?: boolean;
  staticMethod?: boolean;
}

export class PropsDeclaration {
  type: ParameterType;
  typeMode: ParameterMode;
  async_type?: ParameterType;
  name: string;
  isSymbol?: boolean;
  readonly: boolean;
  optional: boolean;
  documentation?: string;
}

export class IndexedPropertyDeclaration extends PropsDeclaration {
  indexKeyType: 'string' | 'number';
}

export class FunctionDeclaration extends PropsDeclaration {
  args: FunctionArguments[] =  [];
  returnType: ParameterType;
  async_returnType?: ParameterType;
  returnTypeMode?: ParameterMode;
}

export enum ClassObjectKind {
  interface,
  dictionary,
  mixin
}

export class ClassObject {
  static globalClassMap: {[key: string]: ClassObject} = Object.create(null);
  static globalClassRelationMap: {[key: string]: string[]} = Object.create(null);
  name: string;
  parent: string;
  mixinParent: string[];
  props: PropsDeclaration[] = [];
  inheritedProps?: PropsDeclaration[] = [];
  indexedProp?: IndexedPropertyDeclaration;
  methods: FunctionDeclaration[] = [];
  staticMethods: FunctionDeclaration[] = [];
  construct?: FunctionDeclaration;
  kind: ClassObjectKind = ClassObjectKind.interface;
  documentation?: string;
}

export class FunctionObject {
  declare: FunctionDeclaration
}

export class TypeAliasObject {
  name: string;
  type: string;
}

export class ConstObject {
  name: string;
  type: string;
}

export class EnumMemberObject {
  name: string;
  initializer?: string;
}

export class EnumObject {
  name: string;
  members: EnumMemberObject[] = [];
}
