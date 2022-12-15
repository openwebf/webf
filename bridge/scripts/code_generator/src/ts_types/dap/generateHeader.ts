import _ from "lodash";
import fs from 'fs';
import path from 'path';
import {DAPBlob} from "./DAPBlob";
import {ClassObject, FunctionArgumentType, ParameterMode} from "../idl/declaration";
import {ParameterType} from "../analyzer";
import {addIndent} from "../idl/utils";

function readDAPTemplate(name: string) {
  return fs.readFileSync(path.join(__dirname, '../../../templates/dap_templates/' + name + '.h.tpl'), {encoding: 'utf-8'});
}


export function generateDAPMembersTypes(type: ParameterType[], mode: ParameterMode, typeName: string): string {
  function generateCTypeFromType(t: ParameterType) {
    switch (t) {
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
        return 'int8_t';
      }
      case FunctionArgumentType.dom_string: {
        return 'const char*';
      }
    }
    return '';
  }

  let isNormalType = generateCTypeFromType(type[0]);
  if (isNormalType) {
    return isNormalType;
  }

  if (typeof type[0] == 'string') {
    if (mode.keyword) {
      return 'const char*';
    }

    return type[0] + '*';
  }
  if (type.length > 1) {
    return `size_t ${typeName}Len;\n ${generateCTypeFromType(type[1])}*`
  }

  return 'void*';
}

function generateProtocolMembers(object: ClassObject) {
  const props = object.props;

  return props.map(prop => {
    let type = addIndent(generateDAPMembersTypes(prop.type, prop.typeMode, prop.name), 2);
    return `${type} ${prop.name};`
  }).join('\n')
}

function generateDAPTemplateSource(blob: DAPBlob) {
  return _.template(readDAPTemplate('dap_protocol'))({
    blob: blob,
    generateProtocolMembers,
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function generateDAPHeader(blob: DAPBlob) {
  return generateDAPTemplateSource(blob);
}
