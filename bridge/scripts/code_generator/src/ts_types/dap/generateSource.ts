import fs from 'fs';
import path from 'path';
import {DAPInfoCollector, ParameterType} from "../analyzer";
import _ from "lodash";
import {addIndent} from "../idl/utils";
import {ClassObject, FunctionArgumentType, PropsDeclaration} from "../idl/declaration";

function readConverterTemplate() {
  return fs.readFileSync(path.join(__dirname, '../../../templates/dap_templates/dap_converter.c.tpl'), {encoding: 'utf-8'});
}

function getLists(set: Set<ClassObject>): string[] {
  return Array.from(set).map(s => {
    return s.name;
  });
}

const stringifyTypes = {};
const initializeTypes: {
  [key: string]: {
    normal: boolean;
    array: boolean
  }
} = {};
const freeTypes: {
  [key: string]: {
    normal: boolean;
    array: boolean
  }
} = {};

function generateTypeStringify(object: ClassObject, propName: string, info: DAPInfoCollector, externalInitialize: string[]): void {
  if (stringifyTypes[object.name]) return;

  stringifyTypes[object.name] = true;

  let stringifyCode : string[] = [];
  if (object.props) {
    object.props.forEach(prop => {
      let code = generateMemberStringifyCode(prop, propName, externalInitialize, info);
      if (code) {
        stringifyCode.push(`{\n ${code} \n }`);
      }
    });
  }

  externalInitialize.push(`static JSValue stringify_property_${object.name}(JSContext* ctx, ${object.name}* ${propName}) {
  JSValue object = JS_NewObject(ctx);
  ${stringifyCode.join('\n')}
  return object;
  }`)
}

function generateTypeInitialize(object: ClassObject, propType: ParameterType, info: DAPInfoCollector, externalInitialize: string[], isArray?: boolean): void {
  if (initializeTypes[object.name]) {
    const type = initializeTypes[object.name];
    if (isArray) {
      if (type.array) {
        return;
      }
    } else {
      if (type.normal) return;
    }
  }
  initializeTypes[object.name] = {
    normal: !isArray,
    array: !!isArray
  };
  let parserCode: string[] = [];
  if (object.props) {
    object.props.forEach(prop => {
      let code = generatePropParser(prop, externalInitialize, info);
      if (code) {
        parserCode.push(code);
      }
    });
  }

  let initCode = '';

  if (isArray) {
    initCode = `
  JSValue arr = JS_GetPropertyStr(ctx, this_object, prop);
  int64_t len = get_property_int64(ctx, arr, "length");
  *length = len;
  
  if (len == 0) return NULL;
  
  ${object.name}* return_value = js_malloc(ctx, sizeof(${object.name}) * len);
  for(int i = 0; i < len; i ++) {
    JSValue arguments = JS_GetPropertyUint32(ctx, arr, i);
    ${object.name}* args = &return_value[i];
    ${parserCode.join('\n')}
    JS_FreeValue(ctx, arguments);
  }
  
  JS_FreeValue(ctx, arr);
  return return_value;
`;
  } else {
    initCode = `
  JSValue arguments = JS_GetPropertyStr(ctx, this_object, prop);
  ${object.name}* args = js_malloc(ctx, sizeof(${object.name}));
  ${parserCode.join('\n')}
  JS_FreeValue(ctx, arguments);
  return args;`;
  }

  externalInitialize.push(`static ${object.name}* get_property_${getTypeName(propType)}${isArray ? '_1' : ''}(JSContext* ctx, JSValue this_object, const char* prop${isArray ? ', size_t* length' : ''}) {
${initCode}
}`);
}

enum PropTypeKind {
  normal,
  reference,
  referenceArray,
  normalArray
}

function getTypeKind(type: ParameterType): PropTypeKind {
  if (type.isArray) {
    const value = (type.value as ParameterType).value;
    if (typeof value === 'number') return PropTypeKind.normalArray;
    return PropTypeKind.referenceArray;
  }
  if (typeof type.value === 'string') return PropTypeKind.reference;
  return PropTypeKind.normal
}

function getTypeName(type: ParameterType) {
  if (typeof type.value === 'object') {
    return (type.value as ParameterType).value;
  }
  return type.value;
}

function generatePropParser(prop: PropsDeclaration, externalInitialize: string[], info: DAPInfoCollector): string | null {
  function wrapOptional(code: string) {
    function generateUnInitializeValue(): string {
      if (prop.type.value === FunctionArgumentType.dom_string) {
        callCode = `args->${prop.name} = NULL;`;
      } else if (prop.type.value === FunctionArgumentType.double) {
        callCode = `args->${prop.name} = 0.0;`;
      } else if (prop.type.value === FunctionArgumentType.int64) {
        callCode = `args->${prop.name} = 0;`
      } else if (prop.type.value === FunctionArgumentType.boolean) {
        callCode = `args->${prop.name} = 0;`
      } else {
        callCode = `args->${prop.name} = NULL;`;
      }
      return callCode;
    }

    return addIndent(`if (JS_HasPropertyStr(ctx, arguments, "${prop.name}")) {
  ${code}    
} else {
  ${generateUnInitializeValue()}
}`, 2);
  }

  const typeKind = getTypeKind(prop.type);
  let callCode = '';
  if (typeKind === PropTypeKind.normal || typeKind === PropTypeKind.normalArray) {
    const isArray = prop.type.isArray;

    let value = prop.type.value;
    if (isArray) {
      value = (value as ParameterType).value;
      callCode += 'size_t length;\n'
    }

    if (value === FunctionArgumentType.dom_string) {
      callCode += `args->${prop.name} = get_property_string_copy${isArray ? '_1' : ''}(ctx, arguments, "${prop.name}"${isArray ? ', &length' : ''});\n`;
    } else if (value === FunctionArgumentType.double) {
      callCode += `args->${prop.name} = get_property_float64${isArray ? '_1' : ''}(ctx, arguments, "${prop.name}");\n`;
    } else if (value === FunctionArgumentType.int64) {
      callCode += `args->${prop.name} = get_property_int64${isArray ? '_1' : ''}(ctx, arguments, "${prop.name}");\n`
    } else if (value === FunctionArgumentType.boolean) {
      callCode += `args->${prop.name} = get_property_boolean${isArray ? '_1' : ''}(ctx, arguments, "${prop.name}");\n`
    }
    if (isArray) {
      callCode += `args->${prop.name}Len = length;\n`;
    }
  } else if (typeKind === PropTypeKind.reference || typeKind === PropTypeKind.referenceArray) {
    let targetTypes = Array.from(info.others).find(o => {
      return o.name === getTypeName(prop.type)
    });
    if (targetTypes) {
      const isArray = prop.type.isArray;
      generateTypeInitialize(targetTypes, prop.type, info, externalInitialize, isArray);
      if (isArray) {
        callCode += `size_t length;\n`
      }
      callCode += `args->${prop.name} = get_property_${getTypeName(prop.type)}${isArray ? '_1' : ''}(ctx, arguments, "${prop.name}"${isArray ? ', &length' : ''});\n`;
      if (isArray) {
        callCode += `args->${prop.name}Len = length;\n`;
      }
    }
  }

  return prop.optional ? wrapOptional(callCode) : callCode;
}

function generateMemberInit(prop: PropsDeclaration, externalInitialize: string[], info: DAPInfoCollector): string {
  let initCode = '';
  if (prop.type.value === FunctionArgumentType.boolean) {
    initCode = `body->${prop.name} = 0;`;
  } else if (prop.type.value === FunctionArgumentType.int64 || prop.type.value === FunctionArgumentType.double) {
    initCode = `body->${prop.name} = 0;`;
  } else {
    initCode = `body->${prop.name} = NULL;`;
  }
  if (prop.type.isArray) {
    initCode += `\nbody->${prop.name}Len = 0;`;
  }
  return initCode;
}

function wrapIf(code: string, expression: string, type: ParameterType) {
  if (type.value === FunctionArgumentType.dom_string || typeof type.value === 'string') {
    return `if (${expression} != NULL) {
  ${code}
}`;
  } else if (type.value === FunctionArgumentType.double || type.value === FunctionArgumentType.int64) {
    return `if (!isnan(${expression})) {
  ${code}
}`
  }
  return code;
}

function generateMemberStringifyCode(prop: PropsDeclaration, bodyName: string, externalInitialize: string[], info: DAPInfoCollector): string {

  function generateQuickJSInitFromType(type: ParameterType) {
    if (type.value === FunctionArgumentType.double) {
      return `JS_NewFloat64`;
    } else if (type.value === FunctionArgumentType.dom_string) {
      return `JS_NewString`;
    } else if (type.value === FunctionArgumentType.int64) {
      return `JS_NewInt64`;
    } else if (type.value === FunctionArgumentType.boolean) {
      return `JS_NewBool`;
    } else {
      let targetTypes = Array.from(info.others).find(o => o.name === type.value);
      if (targetTypes) {
        generateTypeStringify(targetTypes, prop.name, info, externalInitialize);
        return `stringify_property_${targetTypes.name}`;
      }
    }
    return '';
  }

  function genCallCode(type: ParameterType, prop: PropsDeclaration) {
    let callCode = '';
    if (type.value === FunctionArgumentType.int64) {
      callCode = `JS_SetPropertyStr(ctx, object, "${prop.name}", ${generateQuickJSInitFromType(type)}(ctx, ${bodyName}->${prop.name}));`;
    } else if (type.value === FunctionArgumentType.boolean) {
      callCode = `JS_SetPropertyStr(ctx, object, "${prop.name}", ${generateQuickJSInitFromType(type)}(ctx, ${bodyName}->${prop.name}));`;
    } else if (type.value === FunctionArgumentType.dom_string) {
      callCode = `JS_SetPropertyStr(ctx, object, "${prop.name}", ${generateQuickJSInitFromType(type)}(ctx, ${bodyName}->${prop.name}));`;
    } else if (type.value === FunctionArgumentType.double) {
      callCode = `JS_SetPropertyStr(ctx, object, "${prop.name}", ${generateQuickJSInitFromType(type)}(ctx, ${bodyName}->${prop.name}));`;
    } else {
      if (type.isArray) {
        let isReference = typeof (prop.type.value as ParameterType).value === 'string';
        let arrCallCode = `JS_SetPropertyUint32(ctx, arr, i, ${generateQuickJSInitFromType(prop.type.value as ParameterType)}(ctx, ${isReference ? '&' : ''}${bodyName}->${prop.name}[i]));`;
        const typeKind = getTypeKind(type);
        if (prop.optional && typeKind === PropTypeKind.normalArray) {
          arrCallCode = `if (${bodyName}->${prop.name} != NULL) {
            ${arrCallCode}
          }`;
        }

        callCode = `JSValue arr = JS_NewArray(ctx);
for(int i = 0; i < ${bodyName}->${prop.name}Len; i ++) {
  ${arrCallCode}
}
JS_SetPropertyStr(ctx, object, "${prop.name}", arr);`
      } else {
        let targetTypes = Array.from(info.others).find(o => o.name === type.value);
        if (targetTypes) {
          generateTypeStringify(targetTypes, prop.name, info, externalInitialize);
          callCode = `JS_SetPropertyStr(ctx, object, "${prop.name}", stringify_property_${type.value}(ctx, ${bodyName}->${prop.name}));`
        }
      }
    }
    return callCode;
  }

  let callCode = genCallCode(prop.type, prop);

  return addIndent(prop.optional ? wrapIf(callCode, `${bodyName}->${prop.name}`, prop.type) : callCode, 2);
}

function generateRequestParser(info: DAPInfoCollector, requests: string[], externalInitialize: string[]) {
  return requests.map(request => {
    let targetArgument = Array.from(info.arguments).find((ag) => {
      const prefix = ag.name.replace('Arguments', '');
      return request.indexOf(prefix) >= 0;
    });

    if (!targetArgument) {
      return '';
    }

    let parserCode: string[] = [];
    if (targetArgument.props) {
      targetArgument.props.forEach(prop => {
        let code = generatePropParser(prop, externalInitialize, info);
        if (code) {
          parserCode.push(code);
        }
      });
    }
    const name = request.replace('Request', '');
    return addIndent(`if (strcmp(command, "${_.camelCase(name)}") == 0) {
    ${targetArgument.props.length > 0 ? `${name}Arguments* args = js_malloc(ctx, sizeof(${name}Arguments));
  ${parserCode.join('\n')}
  return args;` : ''}  
}`, 2);

  }).join('\n');
}


function generateEventInitializer(info: DAPInfoCollector, events: string[], externalInitialize: string[]) {
  return events.map(event => {
    let targetBody = Array.from(info.bodies).find((ag) => {
      const prefix = ag.name.replace('Body', '');
      return event.indexOf(prefix) >= 0;
    });

    if (!targetBody) {
      return '';
    }
    let bodyInitCode: string[] = [];
    if (targetBody.props) {
      targetBody.props.forEach(prop => {
        let code = generateMemberInit(prop, externalInitialize, info);
        if (code) {
          bodyInitCode.push(code);
        }
      });
    }
    return addIndent(`if (strcmp(event, "${_.camelCase(event.replace('Event', ''))}") == 0) {
  ${event}* result = js_malloc(ctx, sizeof(${event}));
  result->event = event;
  result->seq = _seq++;
  ${event}Body* body = js_malloc(ctx, sizeof(${event}Body));
${addIndent(bodyInitCode.join('\n'), 2)}
  result->body = body;
  return result;
}`, 2);

  }).join('\n');
}

function generateResponseInitializer(info: DAPInfoCollector, responses: string[], externalInitialize: string[]) {
  return responses.map(response => {
    let targetBody = Array.from(info.bodies).find((ag) => {
      const prefix = ag.name.replace('Body', '');
      return response.indexOf(prefix) >= 0;
    });

    if (!targetBody) {
      return '';
    }
    let bodyInitCode: string[] = [];
    if (targetBody.props) {
      targetBody.props.forEach(prop => {
        let code = generateMemberInit(prop, externalInitialize, info);
        if (code) {
          bodyInitCode.push(code);
        }
      });
    }
    return addIndent(`if (strcmp(response, "${_.camelCase(response.replace('Response', ''))}") == 0) {
  ${response}* result = js_malloc(ctx, sizeof(${response}));
  result->type = "response";
  result->seq = _seq++;
  result->request_seq = corresponding_request->seq;
  result->command = corresponding_request->command;
  result->success = 1;
  result->message = NULL;
  ${targetBody.props.length > 0 ? `
 ${response}Body* body = js_malloc(ctx, sizeof(${response}Body));
${addIndent(bodyInitCode.join('\n'), 2)}
  result->body = body;` : 'result->body = NULL;'}
  
  return result;
}`, 2);

  }).join('\n');
}

function generateEventBodyStringifyCode(info: DAPInfoCollector, events: string[], externalInitialize: string[]) {
  return events.map(event => {
    let targetBody = Array.from(info.bodies).find((ag) => {
      const prefix = ag.name.replace('Body', '');
      return event.indexOf(prefix) >= 0;
    });

    if (!targetBody) {
      return '';
    }

    let bodyStringifyCode: string[] = [];
    if (targetBody.props) {
      targetBody.props.forEach(prop => {
        let code = generateMemberStringifyCode(prop, `${_.snakeCase(event)}_body`, externalInitialize, info);
        if (code) {
          bodyStringifyCode.push(code);
        }
      });
    }
    return addIndent(`if (strcmp(event, "${_.camelCase(event.replace('Event', ''))}") == 0) {
  ${event}Body* ${_.snakeCase(event)}_body = (${event}Body*) body;
  ${bodyStringifyCode.join('\n')}
}`, 2);
  }).join('\n');
}

function generateResponseBodyStringifyCode(info: DAPInfoCollector, responses: string[], externalInitialize: string[]) {
  return responses.map(response => {
    let targetBody = Array.from(info.bodies).find((ag) => {
      const prefix = ag.name.replace('Body', '');
      return response.indexOf(prefix) >= 0;
    });

    if (!targetBody) {
      return '';
    }

    let bodyStringifyCode: string[] = [];
    if (targetBody.props) {
      targetBody.props.forEach(prop => {
        let code = generateMemberStringifyCode(prop, `${_.snakeCase(response)}_body`, externalInitialize, info);
        if (code) {
          bodyStringifyCode.push(code);
        }
      });
    }
    return addIndent(`if (strcmp(command, "${_.camelCase(response.replace('Response', ''))}") == 0) {
  ${response}Body* ${_.snakeCase(response)}_body = (${response}Body*) body;
  ${bodyStringifyCode.join('\n')}
}`, 2);
  }).join('\n');
}


function generateTypeFree(object: ClassObject, propType: ParameterType, info: DAPInfoCollector, externalInitialize: string[], isArray?: boolean) {
  if (freeTypes[object.name]) {
    const type = freeTypes[object.name];
    if (isArray) {
      if (type.array) {
        return;
      }
    } else {
      if (type.normal) return;
    }
  }
  freeTypes[object.name] = {
    normal: !isArray,
    array: !!isArray
  };
  let freeCode: string[] = [];
  if (object.props) {
    object.props.forEach(prop => {
      let code = generatePropFree(prop, externalInitialize, info);
      if (code) {
        freeCode.push(code);
      }
    });
  }

  let initCode = '';

  if (isArray) {
    initCode = `
  for(int i = 0; i < length; i ++) {   
    ${freeCode.join('\n')}
  }
  js_free(ctx, args);
`;
  } else {
    initCode = `
    ${freeCode.join('\n')}
    js_free(ctx, args);
    `;
  }

  externalInitialize.push(`static void free_property_${getTypeName(propType)}${isArray ? '_1' : ''}(JSContext* ctx, ${object.name}* args${isArray ? ', size_t length' : ''}) {
${initCode}
}`);
}

function generatePropFree(prop: PropsDeclaration, externalInitialize: string[], info: DAPInfoCollector): string | null {
  const typeKind = getTypeKind(prop.type);
  let callCode = '';
  if (typeKind === PropTypeKind.normal || typeKind === PropTypeKind.normalArray) {
    let value = prop.type.value;
    const isArray = prop.type.isArray;

    if (value === FunctionArgumentType.dom_string) {
      callCode += `free_property_string${isArray ? '_1' : ''}(ctx, args->${prop.name}${isArray ? `, args->${prop.name}Len` : ''});`
    }
  } else if (typeKind === PropTypeKind.reference || typeKind === PropTypeKind.referenceArray) {
    let targetTypes = Array.from(info.others).find(o => {
      return o.name === getTypeName(prop.type)
    });
    if (targetTypes) {
      const isArray = prop.type.isArray;
      generateTypeFree(targetTypes, prop.type, info, externalInitialize, isArray);
      callCode += `free_property_${getTypeName(prop.type)}${isArray ? '_1' : ''}(ctx, args->${prop.name}${isArray ? `, args->${prop.name}Len` : ''});\n`;
    }
  }

  return callCode;
}

function generateRequestArgumentFreeCode(info: DAPInfoCollector, requests: string[], externalInitialize: string[]) {
  return requests.map(request => {
    let targetArgument = Array.from(info.arguments).find((ag) => {
      const prefix = ag.name.replace('Arguments', '');
      return request.indexOf(prefix) >= 0;
    });

    if (!targetArgument) {
      return '';
    }

    let freeCode: string[] = [];
    if (targetArgument.props) {
      targetArgument.props.forEach(prop => {
        let code = generatePropFree(prop, externalInitialize, info);
        if (code) {
          freeCode.push(code);
        }
      });
    }
    const name = request.replace('Request', '');
    return addIndent(`if (strcmp(command, "${_.camelCase(name)}") == 0) {
    ${name}Arguments* args = (${name}Arguments*) arguments;
    ${freeCode.join('\n')}  
    js_free(ctx, args);
}`, 2);

  }).join('\n');
}

export function generateDAPSource(info: DAPInfoCollector) {
  const requests: string[] = getLists(info.requests);
  const events: string[] = getLists(info.events);
  const responses: string[] = getLists(info.response);
  const externalInitialize: string[] = [];

  const requestParser = generateRequestParser(info, requests, externalInitialize);
  const eventInit = generateEventInitializer(info, events, externalInitialize);
  const responseInit = generateResponseInitializer(info, responses, externalInitialize);
  const eventBodyStringifyCode = generateEventBodyStringifyCode(info, events, externalInitialize);
  const responseBodyStringifyCode = generateResponseBodyStringifyCode(info, responses, externalInitialize);
  const freeEventArgument = generateRequestArgumentFreeCode(info, requests, externalInitialize);
  return _.template(readConverterTemplate())({
    info,
    requests,
    requestParser,
    eventInit,
    responseInit,
    eventBodyStringifyCode,
    responseBodyStringifyCode,
    externalInitialize,
    freeEventArgument
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}
