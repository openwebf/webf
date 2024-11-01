import {CSSProperties} from "./css_properties";
import path from 'path';
import fs from 'fs';
import {generateJSONTemplate} from "./generator";
import _ from "lodash";
import {upperCamelCase} from "./name_utiltities";

const cssPropertyNameHeaderTemplate = path.resolve(__dirname, '../../templates/json_templates/css_property_names.h.tpl');
const cssPropertyNameSourceTemplate = path.resolve(__dirname, '../../templates/json_templates/css_property_names.cc.tpl');

function compileHeader(properties: CSSProperties) {
  const headerTemplate = fs.readFileSync(cssPropertyNameHeaderTemplate, {encoding: 'utf-8'});

  let compiled = _.template(headerTemplate);
  return compiled({
    _: _,
    properties
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

function compileSource(properties: CSSProperties) {
  const bodyTemplate = fs.readFileSync(cssPropertyNameSourceTemplate, {encoding: 'utf-8'});

  let compiled = _.template(bodyTemplate);
  return compiled({
    _: _,
    properties
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makeCSSPropertyNames() {
  const properties = new CSSProperties();

  return {
    header: compileHeader(properties),
    source: compileSource(properties)
  }
}