/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import {CSSProperties, PropertyBase} from "./css_properties";
import path from 'path';
import fs from 'fs';
import {upperCamelCase, lowerCamelCase} from "./name_utiltities";
import _ from 'lodash';

const headerTemplate = path.resolve(__dirname, '../../templates/json_templates/computed_style_initial_values.h.tpl');

function isNotTemplateClass(className: string): boolean {
  return !className.includes('<') && !className.includes('>');
}

function compileHeader(properties: CSSProperties): string {
  const allProperties = properties.longhands;
  const forwardDeclarations = new Set<string>();

  for (const property of allProperties) {
    // TODO(meade): CursorList is a typedef, not a class, so it can't be
    // forward declared. Find a better way to specify this.
    // Omitting template classes because they can't be forward-declared
    // when they're instantiated. TODO: parse/treat them correctly so
    // they can be forward-declared.
    // TODO: check that the class that is being forward-declared is not
    // among includes as this could make the compiler throw errors.
    if (property.default_value === 'nullptr' &&
        property.unwrapped_type_name !== 'CursorList' &&
        property.unwrapped_type_name !== 'AppliedTextDecorationVector' &&
        property.unwrapped_type_name &&
        isNotTemplateClass(property.unwrapped_type_name)) {
      forwardDeclarations.add(property.unwrapped_type_name);
    }
  }

  const headerTemplateSource = fs.readFileSync(headerTemplate, {encoding: 'utf-8'});
  const compiled = _.template(headerTemplateSource);
  
  return compiled({
    _: _,
    upperCamelCase,
    lowerCamelCase,
    properties: allProperties,
    forward_declarations: Array.from(forwardDeclarations).sort(),
    includes: ['core/platform/graphics/touch_action.h']
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makeComputedStyleInitialValues() {
  const properties = new CSSProperties();
  
  return {
    header: compileHeader(properties)
  };
}