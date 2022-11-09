import {ParameterBaseType, ParameterType} from "./analyzer";

export enum FunctionArgumentType {
  // Basic types
  dom_string,
  object,
  promise,
  int32,
  int64,
  double,
  boolean,
  function,
  void,
  any,
  null,
  undefined,
}

export class FunctionArguments {
  name: string;
  type: ParameterType;
  typeMode: ParameterMode;
  required: boolean;
}

export class ParameterMode {
  newObject?: boolean;
  dartImpl?: boolean;
  static?: boolean;
}

export class PropsDeclaration {
  type: ParameterType;
  typeMode: ParameterMode;
  name: string;
  readonly: boolean;
  optional: boolean;
}

export class IndexedPropertyDeclaration extends PropsDeclaration {
  indexKeyType: 'string' | 'number';
}

export class FunctionDeclaration extends PropsDeclaration {
  args: FunctionArguments[] =  [];
  returnType: ParameterType;
  returnTypeMode?: ParameterMode;
}

export enum ClassObjectKind {
  interface,
  dictionary,
  mixin
}

export class ClassObject {
  static globalClassMap = new Map<string, ClassObject>();
  name: string;
  parent: string;
  mixinParent: string[];
  props: PropsDeclaration[] = [];
  indexedProp?: IndexedPropertyDeclaration;
  methods: FunctionDeclaration[] = [];
  construct?: FunctionDeclaration;
  kind: ClassObjectKind = ClassObjectKind.interface
}

export class FunctionObject {
  declare: FunctionDeclaration
}
