import {generateDAPSource} from "./generateSource";
import {generateDAPHeader} from "./generateHeader";
import {DAPBlob} from "./DAPBlob";

export enum TemplateType {
  // Generate C++ Binding codes for JavaScript API
  IDL,
  // Generate C parse and stringify codes based on Microsoft DAP Protocol.
  DAP,
  // Generate Dart bindings codes associate with C++ API.
  Dart,
}

export function generatorDAP(blob: DAPBlob, type: TemplateType) {
  let header = generateDAPHeader(blob);

  return {
    header,
    source: ''
  };
}
