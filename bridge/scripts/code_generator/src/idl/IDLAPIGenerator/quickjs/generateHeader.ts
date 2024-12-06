import {ClassObject, ClassObjectKind, FunctionObject} from "../../declaration";
import _ from "lodash";
import {IDLBlob} from "../../IDLBlob";
import {getClassName} from "../../utils";
import fs from 'fs';
import path from 'path';
import {
  generateCoreTypeValue,
  generateRawTypeValue,
  getPointerType,
  isPointerType,
  isTypeHaveNull
} from "./generateSource";
import {GenerateOptions, readTemplate} from "../../generator";

export enum TemplateKind {
  globalFunction,
  Dictionary,
  Interface,
  null
}

export function getTemplateKind(object: ClassObject | FunctionObject | null): TemplateKind {
  if (object instanceof FunctionObject) {
    return TemplateKind.globalFunction;
  } else if (object instanceof ClassObject) {
    if (object.kind === ClassObjectKind.dictionary) {
      return TemplateKind.Dictionary;
    } else if(object.kind === ClassObjectKind.mixin) {
      return TemplateKind.null;
    }
    return TemplateKind.Interface;
  }
  return TemplateKind.null;
}

export function generateQuickJSCppHeader(blob: IDLBlob, options: GenerateOptions) {
  const baseTemplate = fs.readFileSync(path.join(__dirname, '../../../../templates/idl_templates/quickjs/base.h.tpl'), {encoding: 'utf-8'});
  let headerOptions = {
    interface: false,
    dictionary: false,
    global_function: false,
  };
  const contents = blob.objects.map(object => {
    const templateKind = getTemplateKind(object);
    if (templateKind === TemplateKind.null) return '';

    switch(templateKind) {
      case TemplateKind.Interface: {
        if (!headerOptions.interface) {
          object = (object as ClassObject);
          headerOptions.interface = true;
          return _.template(readTemplate('quickjs', 'interface'))({
            className: getClassName(blob),
            parentClassName: object.parent,
            blob: blob,
            object,
            generateRawTypeValue,
            ...options
          });
        }
        return '';
      }
      case TemplateKind.Dictionary: {
        if (!headerOptions.dictionary) {
          headerOptions.dictionary = true;
          let props = (object as ClassObject).props;
          return _.template(readTemplate('quickjs', 'dictionary'))({
            className: getClassName(blob),
            blob: blob,
            object: object,
            props,
            generateCoreTypeValue
          });
        }
        return '';
      }
      case TemplateKind.globalFunction: {
        if (!headerOptions.global_function) {
          headerOptions.global_function = true;
          return _.template(readTemplate('quickjs', 'global_function'))({
            className: getClassName(blob),
            blob: blob
          });
        }
        return '';
      }
    }
  });

  return _.template(baseTemplate)({
    content: contents.join('\n'),
    blob: blob
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}