import {IDLBlob} from './IDLBlob';
import {generateQuickJSCppHeader} from "./IDLAPIGenerator/quickjs/generateHeader";
import {
  generateCoreTypeValue,
  generateQuickJSCppSource,
  generateUnionTypeSource, getPointerType, isPointerType,
  isTypeHaveNull
} from "./IDLAPIGenerator/quickjs/generateSource";
import {ParameterType} from "./analyzer";
import {FunctionArgumentType} from "./declaration";
import _ from "lodash";
import {
  generateUnionConstructor,
  generateUnionContentType, generateUnionMemberName, generateUnionMemberType, generateUnionPropertyHeaders,
  generateUnionTypeClassName
} from "./IDLAPIGenerator/quickjs/generateUnionTypes";
import fs from "fs";
import path from "path";

export function generateSupportedOptions(): GenerateOptions {
  let globalFunctionInstallList: string[] = [];
  let classMethodsInstallList: string[] = [];
  let constructorInstallList: string[] = [];
  let classPropsInstallList: string[] = [];
  let staticMethodsInstallList: string[] = [];
  let indexedProperty: string = '';
  let wrapperTypeInfoInit = '';

  return {
    globalFunctionInstallList,
    classPropsInstallList,
    classMethodsInstallList,
    staticMethodsInstallList,
    constructorInstallList,
    indexedProperty,
    wrapperTypeInfoInit
  };
}

export type GenerateOptions = {
  globalFunctionInstallList: string[];
  classMethodsInstallList: string[];
  constructorInstallList: string[];
  classPropsInstallList: string[];
  staticMethodsInstallList: string[];
  wrapperTypeInfoInit: string;
  indexedProperty: string;
};

export function generatorSource(blob: IDLBlob) {
  let options = generateSupportedOptions();

  let source = generateQuickJSCppSource(blob, options);
  let header = generateQuickJSCppHeader(blob, options);
  return {
    header,
    source
  };
}

export function readTemplate(platform: string, name: string) {
  return fs.readFileSync(path.join(__dirname, `../../templates/idl_templates/${platform}/` + name + '.h.tpl'), {encoding: 'utf-8'});
}

export function generateUnionTypeHeader(platform: string, unionType: ParameterType): string {
  return _.template(readTemplate(platform, 'union'))({
    unionType,
    generateUnionTypeClassName,
    generateUnionTypeFileName,
    generateUnionContentType,
    generateUnionConstructor,
    generateUnionPropertyHeaders,
    generateCoreTypeValue,
    generateUnionMemberType,
    generateUnionMemberName,
    isTypeHaveNull,
    isPointerType,
    getPointerType,
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function generateUnionTypes(platform: string, unionType: ParameterType) {
  let header = generateUnionTypeHeader(platform, unionType);
  let source = generateUnionTypeSource(unionType);
  return {
    header,
    source
  }
}

export function generateUnionTypeFileName(platform: string, unionType: ParameterType[]) {
  let filename = `${platform == 'quickjs' ? 'qjs' : 'v8'}_union`;
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
