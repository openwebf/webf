import {CSSProperties, PropertyBase} from "./css_properties";
import path from 'path';
import fs from 'fs';
import {generateJSONTemplate} from "./generator";
import _ from "lodash";
import {enumKeyForCssProperty, lowerCamelCase, upperCamelCase} from "./name_utiltities";

const headerTemplate = path.resolve(__dirname, '../../templates/json_templates/style_property_shorthand.h.tpl');
const sourceTemplate = path.resolve(__dirname, '../../templates/json_templates/style_property_shorthand.cc.tpl');

function compileHeader(properties: CSSProperties, longhandDic: Map<string, PropertyBase[]>) {
  const headerTemplateSource = fs.readFileSync(headerTemplate, {encoding: 'utf-8'});

  let compiled = _.template(headerTemplateSource);
  return compiled({
    _: _,
    lowerCamelCase,
    properties: properties.shorthands,
    longhands_dictionary: longhandDic
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

function compileSource(properties: CSSProperties, longHandDic: Map<string, PropertyBase[]>) {
  const bodyTemplateSource = fs.readFileSync(sourceTemplate, {encoding: 'utf-8'});

  let compiled = _.template(bodyTemplateSource);
  return compiled({
    _: _,
    lowerCamelCase,
    properties: properties.shorthands,
    longhands_dictionary: longHandDic
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

function collectRuntimeFlags(properties: PropertyBase[]): string[] {
  // Create a set to store unique runtime flags
  const flags = new Set<string>();

  // Iterate over properties and add runtime_flag to the set if it exists
  properties.forEach(p => {
    if (p.runtime_flag) {
      flags.add(p.runtime_flag);
    }
  });

  // Convert the set to an array and sort it
  return Array.from(flags).sort();
}

class Expansion {
  private _longhands: PropertyBase[];
  private _flags: string[];
  private _enabled_mask: number;

  /**
   * A specific (longhand) expansion of a shorthand.
   *
   * A shorthand may have multiple expansions, because some of the longhands
   * might be behind runtime flags.
   *
   * The enabled_mask represents which flags are enabled/disabled for this
   * specific expansion. For example, if flags contains three elements,
   * and enabled_mask is 0b100, then flags[0] is disabled, flags[1] is disabled,
   * and flags[2] is enabled. This information is used to produce the correct
   * list of longhands corresponding to the runtime flags that are enabled/
   * disabled.
   */
  constructor(longhands: PropertyBase[], flags: string[], enabled_mask: number) {
    this._longhands = longhands;
    this._flags = flags;
    this._enabled_mask = enabled_mask;
  }

  isEnabled(flag: string): boolean {
    return !!((1 << this._flags.indexOf(flag)) & this._enabled_mask);
  }

  get is_empty(): boolean {
    return this.enabled_longhands.length === 0;
  }

  get enabled_longhands(): PropertyBase[] {
    return this._longhands.filter(longhand => !longhand.runtime_flag || this.isEnabled(longhand.runtime_flag));
  }

  get index(): number {
    return this._enabled_mask;
  }

  get flags(): { name: string; enabled: boolean }[] {
    return this._flags.map(flag => ({
      name: flag,
      enabled: this.isEnabled(flag),
    }));
  }
}

function createExpansions(longhands: PropertyBase[]): Expansion[] {
  const flags = collectRuntimeFlags(longhands);
  const expansions = Array.from({length: 1 << flags.length}, (_, mask) => new Expansion(longhands, flags, mask));

  if (expansions.length === 0) {
    throw new Error('No expansions generated');
  }

  // We generate 2^N expansions for N flags, so enforce some limit.
  if (flags.length > 4) {
    throw new Error('Too many runtime flags for a single shorthand');
  }

  return expansions;
}

export function makeStylePropertyShorthand() {
  const properties = new CSSProperties();
  const longhand_dictionary = new Map<string, PropertyBase[]>();
  for (const property_ of properties.shorthands) {
    const longhand_enum_keys = (property_.longhands as any[]).map(enumKeyForCssProperty);
    const longhands = (property_.longhands as any[]).map(name => properties.properties_by_name[name]);
    property_['expansions'] = createExpansions(longhands);

    for (const longhand_enum_key of longhand_enum_keys) {
      if (!longhand_dictionary.has(longhand_enum_key)) {
        longhand_dictionary.set(longhand_enum_key, []);
      }
      longhand_dictionary.get(longhand_enum_key)!.push(property_);
    }
  }

  for (const longhands of longhand_dictionary.values()) {
    // Sort first by number of longhands in decreasing order, then alphabetically
    longhands.sort((a, b) => {
      const lengthDiff = (b.longhands as any[]).length - (a.longhands as any[]).length;
      if (lengthDiff !== 0) {
        return lengthDiff;
      }
      return a.name.localeCompare(b.name);
    });
  }

  return {
    header: compileHeader(properties, longhand_dictionary),
    source: compileSource(properties, longhand_dictionary)
  }
}