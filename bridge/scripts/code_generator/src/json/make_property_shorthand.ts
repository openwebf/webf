import {CSSProperties} from "./css_properties";
import path from 'path';
import fs from 'fs';
import {generateJSONTemplate} from "./generator";
import _ from "lodash";
import {lowerCamelCase, upperCamelCase} from "./name_utiltities";

const headerTemplate = path.resolve(__dirname, '../../templates/json_templates/style_property_shorthand.h.tpl');
const sourceTemplate = path.resolve(__dirname, '../../templates/json_templates/style_property_shorthand.cc.tpl');

function compileHeader(properties: CSSProperties) {
  const headerTemplateSource = fs.readFileSync(headerTemplate, {encoding: 'utf-8'});

  let compiled = _.template(headerTemplateSource);
  return compiled({
    _: _,
    lowerCamelCase,
    properties
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

function compileSource(properties: CSSProperties) {
  const bodyTemplateSource = fs.readFileSync(sourceTemplate, {encoding: 'utf-8'});

  let compiled = _.template(bodyTemplateSource);
  return compiled({
    _: _,
    lowerCamelCase,
    properties
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makeStylePropertyShorthand() {
  const properties = new CSSProperties();

  return {
    header: compileHeader(properties),
    source: compileSource(properties)
  }
}