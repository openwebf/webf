import {generateDAPSource} from "./generateSource";
import {generateDAPHeader} from "./generateHeader";
import {DAPBlob} from "./DAPBlob";
import {DAPInfoCollector} from "../analyzer";

export enum TemplateType {
  // Generate C++ Binding codes for JavaScript API
  IDL,
  // Generate C parse and stringify codes based on Microsoft DAP Protocol.
  DAP,
  // Generate Dart bindings codes associate with C++ API.
  Dart,
}

export function generatorDAP(blob: DAPBlob, dapInfoCollector: DAPInfoCollector) {
  let header = generateDAPHeader(blob, dapInfoCollector);

  return {
    header,
    source: ''
  };
}
