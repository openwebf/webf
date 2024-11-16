import {IDLBlob} from './IDLBlob';
import {generateCppHeader} from "./generateHeader";
import {generateCppSource} from "./generateSource";

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

  let source = generateCppSource(blob, options);
  let header = generateCppHeader(blob, options);
  return {
    header,
    source
  };
}
