import _ from "lodash";

export function idForCssProperty(propertyName: string) {
  return 'CSSProperty' + upperCamelCase(propertyName);
}

export function upperCamelCase(name: string) {
  return _.upperFirst(_.camelCase(name));
}

export function lowerCamelCase(name: string) {
  return _.camelCase(name);
}

export function idForCssPropertyAlias(propertyName: string) {
  return 'CSSPropertyAlias' + upperCamelCase(propertyName);
}

export function enumKeyForCSSKeywords(keyword: any) {
  if (keyword === '-infinity') {
    return 'kNegative' + upperCamelCase(keyword);
  }
  return 'k' + upperCamelCase(keyword);
}

export function enumKeyForCssPropertyAlias(propertyName: string) {
  return 'kAlias' + upperCamelCase(propertyName);
}

export function enumKeyForCssProperty(property_name: string) {
  return 'k' + upperCamelCase(property_name);
}

