import {CSSProperties, PropertyBase} from "./css_properties";
import path from 'path';
import fs from 'fs';
import {generateJSONTemplate} from "./generator";
import _ from "lodash";
import {upperCamelCase} from "./name_utiltities";

const cssPropertyInstanceHeaderTemplate = path.resolve(__dirname, '../../templates/json_templates/css_property_instance.h.tpl');
const cssPropertyInstanceSourceTemplate = path.resolve(__dirname, '../../templates/json_templates/css_property_instance.cc.tpl');

function compileHeader(properties: PropertyBase[], alias: PropertyBase[]) {
  const headerTemplate = fs.readFileSync(cssPropertyInstanceHeaderTemplate, {encoding: 'utf-8'});

  let compiled = _.template(headerTemplate);
  return compiled({
    _: _,
    properties,
    alias
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

function compileSource(properties: PropertyBase[], alias: PropertyBase[]) {
  const bodyTemplate = fs.readFileSync(cssPropertyInstanceSourceTemplate, {encoding: 'utf-8'});

  let compiled = _.template(bodyTemplate);
  return compiled({
    _: _,
    properties,
    alias
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makeCSSPropertyInstance() {
  const properties = new CSSProperties();
  const alias = properties.aliases;
  const concatProperties = properties.longhands.concat(properties.shorthands);

  return {
    header: compileHeader(concatProperties, alias),
    source: compileSource(concatProperties, alias)
  }
}