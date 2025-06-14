import {CSSProperties} from "./css_properties";
import path from 'path';
import fs from 'fs';
import {generateJSONTemplate} from "./generator";
import _ from "lodash";
import {upperCamelCase} from "./name_utiltities";

const sourceTemplate = path.resolve(__dirname, '../../templates/json_templates/property_bitsets.cc.tpl');

function compileSource(properties: CSSProperties) {
  const bodyTemplate = fs.readFileSync(sourceTemplate, {encoding: 'utf-8'});

  const logical_group_properties = properties.properties_including_aliases
    .filter(p => p.logical_property_group && p.logical_property_group.is_logical)
    .map(p => p.enum_key);
  const known_exposed_properties = properties.properties_including_aliases
    .filter(p => p.known_exposed)
    .map(p => p.enum_key);
  const surrogate_properties = properties.properties_including_aliases
    .filter(p => p.surrogate_for || (p.logical_property_group && p.logical_property_group.is_logical))
    .map(p => p.enum_key);

  let compiled = _.template(bodyTemplate);
  return compiled({
    _: _,
    properties,
    logical_group_properties,
    known_exposed_properties,
    surrogate_properties
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makePropertyBitset() {
  const properties = new CSSProperties();

  return {
    source: compileSource(properties)
  }
}