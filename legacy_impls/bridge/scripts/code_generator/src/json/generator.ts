import {JSONBlob} from './JSONBlob';
import {JSONTemplate} from './JSONTemplate';
import _ from 'lodash';

function generateHeader(blob: JSONBlob, template: JSONTemplate, deps?: JSONBlob[], options: GenerateJSONOptions = {}): string {
  let compiled = _.template(template.raw);
  return compiled({
    _: _,
    name: blob.filename,
    template_path: blob.source,
    data: blob.json.data,
    options,
    deps,
    upperCamelCase
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}


function upperCamelCase(name: string) {
  return _.upperFirst(_.camelCase(name));
}

function generateBody(blob: JSONBlob, template: JSONTemplate, deps?: JSONBlob[], options: GenerateJSONOptions = {}): string {
  let compiled = _.template(template.raw);
  return compiled({
    template_path: blob.source,
    name: blob.filename,
    data: blob.json.data,
    deps,
    options,
    upperCamelCase,
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

type GenerateJSONOptions = {
  add_atom_prefix?: boolean;
};

export function generateJSONTemplate(blob: JSONBlob, headerTemplate: JSONTemplate, bodyTemplate?: JSONTemplate, depsBlob?: JSONBlob[], options: GenerateJSONOptions = {}) {
  let header = generateHeader(blob, headerTemplate, depsBlob, options);
  let body = bodyTemplate ? generateBody(blob, bodyTemplate, depsBlob, options) : '';

  return {
    header: header,
    source: body,
  };
}

function generateNames(template: JSONTemplate, names: Set<string>) {
  let compiled = _.template(template.raw);
  return compiled({
    _: _,
    name: 'names_installer',
    names: Array.from(names),
    upperCamelCase
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function generateNamesInstaller(headerTemplate: JSONTemplate, bodyTemplate: JSONTemplate, names: Set<string>) {
  let header = generateNames(headerTemplate, names);
  let body = generateNames(bodyTemplate, names);

  return {
    header: header,
    source: body,
  };
}
