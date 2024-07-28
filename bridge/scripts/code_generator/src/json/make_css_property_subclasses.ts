import {CSSProperties} from "./css_properties";
import path from 'path';
import fs from 'fs';
import {generateJSONTemplate} from "./generator";
import _ from "lodash";
import {lowerCamelCase, upperCamelCase} from "./name_utiltities";
import JSON5 from "json5";

const headerTemplate = path.resolve(__dirname, '../../templates/json_templates/css_properties.h.tpl');
const sourceTemplate = path.resolve(__dirname, '../../templates/json_templates/css_properties.cc.tpl');

function compileHeader(properties: CSSProperties, isShortHand: boolean) {
  const headerTemplateSource = fs.readFileSync(headerTemplate, {encoding: 'utf-8'});

  let compiled = _.template(headerTemplateSource);
  return compiled({
    _: _,
    lowerCamelCase,
    upperCamelCase,
    isShortHand,
    properties: isShortHand ? properties.shorthands_including_aliases : properties.longhands_including_aliases
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

function compileSource(properties: CSSProperties, isShortHand: boolean) {
  const bodyTemplateSource = fs.readFileSync(sourceTemplate, {encoding: 'utf-8'});

  let compiled = _.template(bodyTemplateSource);
  return compiled({
    _: _,
    upperCamelCase,
    lowerCamelCase,
    properties: isShortHand ? properties.shorthands_including_aliases : properties.longhands_including_aliases,
    isShortHand
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makeCSSPropertySubClasses(isShortHand: boolean) {
  const properties = new CSSProperties();

  const cssPropertyMethodsPath = path.join(__dirname, '../../../../core/css/properties/css_property_methods.json5');
  const cssPropertyMethods = JSON5.parse(fs.readFileSync(cssPropertyMethodsPath, {encoding: 'utf-8'}));

  let property_methods = {};

  cssPropertyMethods.data.forEach((propertyMethod: any) => {
    property_methods[propertyMethod.name] = propertyMethod;
  });

  const allProperties = properties.properties_including_aliases;

  allProperties.forEach(property => {
    property['property_methods'] = property.property_methods!.map(methodName => property_methods[methodName]);
  });

  return {
    header: compileHeader(properties, isShortHand),
    source: compileSource(properties, isShortHand)
  }
}