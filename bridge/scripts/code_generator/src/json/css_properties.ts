import fs from 'fs';
import path from 'path';
import JSON5 from 'json5';
import {
  enumKeyForCssProperty,
  enumKeyForCssPropertyAlias,
  idForCssProperty,
  idForCssPropertyAlias,
  upperCamelCase
} from "./name_utiltities";
import {NameStyleConverter} from "./name_style_converter";
import {FieldAliasExpander} from "./field_alias_expander";

const PRIMITIVE_TYPES = [
  'short', 'unsigned short', 'int', 'unsigned int', 'unsigned', 'float',
  'LineClampValue'
];

function validateProperty(prop: PropertyBase, props_by_name: { [key: string]: Property }) {
  const name = prop.name;
  const has_method = (x: string) => prop.property_methods && x in prop.property_methods;
  if (!(prop.is_property || prop.is_descriptor)) {
    throw new Error(`Entry must be a property, descriptor, or both [${name}]`);
  }
  if (prop.interpolable && !prop.is_longhand) {
    throw new Error(`Only longhands can be interpolable [${name}]`);
  }
  if (has_method('ParseSingleValue') && !prop.is_longhand) {
    throw new Error(`Only longhands can implement ParseSingleValue [${name}]`);
  }
  if (has_method('ParseShorthand') && !prop.is_shorthand) {
    throw new Error(`Only shorthands can implement ParseShorthand [${name}]`);
  }
  if (prop.field_template && !prop.is_longhand) {
    throw new Error(`Only longhands can have a field_template [${name}]`);
  }
  if (prop.valid_for_first_letter && !prop.is_longhand) {
    throw new Error(`Only longhands can be valid_for_first_letter [${name}]`);
  }
  if (prop.valid_for_first_line && !prop.is_longhand) {
    throw new Error(`Only longhands can be valid_for_first_line [${name}]`);
  }
  if (prop.valid_for_cue && !prop.is_longhand) {
    throw new Error(`Only longhands can be valid_for_cue [${name}]`);
  }
  if (prop.valid_for_marker && !prop.is_longhand) {
    throw new Error(`Only longhands can be valid_for_marker [${name}]`);
  }
  if (prop.valid_for_highlight_legacy && !prop.is_longhand) {
    throw new Error(`Only longhands can be valid_for_highlight_legacy [${name}]`);
  }
  if (prop.valid_for_highlight && !prop.is_longhand) {
    throw new Error(`Only longhands can be valid_for_highlight [${name}]`);
  }
  if (prop.is_internal && prop.computable !== null) {
    throw new Error(`Internal properties are always non-computable [${name}]`);
  }
  if (prop.supports_incremental_style) {
    if (prop.is_animation_property) {
      throw new Error(`Animation properties can not be applied incrementally [${name}]`);
    }
    if (!prop.idempotent) {
      throw new Error(`Incrementally applied properties must be idempotent [${name}]`);
    }
    if (prop.is_shorthand) {
      for (const subprop_name of prop.longhands!) {
        const subprop = props_by_name[subprop_name];
        if (!subprop.supports_incremental_style) {
          throw new Error(`${subprop_name} must be incrementally applicable when its shorthand ${name} is`);
        }
      }
    }
  }
  if (prop.valid_for_formatted_text && !prop.is_longhand) {
    throw new Error(`Only longhands can be valid_for_formatted_text [${name}]`);
  }
  if (prop.valid_for_formatted_text_run && !prop.is_longhand) {
    throw new Error(`Only longhands can be valid_for_formatted_text_run [${name}]`);
  }
  if (prop.alias_for) {
    if (prop.is_internal) {
      throw new Error(`Internal aliases not supported [${name}]`);
    }
  }
  if (prop.mutable && !['derived_flag', 'monotonic_flag'].includes(prop.field_template ?? '')) {
    throw new Error(`mutable requires field_template:derived_flag or monotonic_flag [${name}]`);
  }
  const custom_functions = new Set(prop.computed_style_custom_functions);
  const protected_functions = new Set(prop.computed_style_protected_functions);
  if (new Set([...custom_functions].filter(x => protected_functions.has(x))).size > 0) {
    throw new Error(`Functions must be specified as either protected or custom, not both [${name}]`);
  }
  if (prop.field_template === 'derived_flag') {
    if (!prop.mutable) {
      throw new Error(`Derived flags must be mutable [${name}]`);
    }
    if (prop.field_group) {
      throw new Error(`Derived flags may not have field groups [${name}]`);
    }
    if (!prop.reset_on_new_style) {
      throw new Error(`Derived flags must have reset_on_new_style [${name}]`);
    }
  }
  if (prop.is_logical && prop.field_group) {
    throw new Error(`Logical properties can not have fields [${name}]`);
  }
}

function needs_style_builders(property_: any) {
  if (!property_.is_property) {
    return false;
  }
  if (property_.longhands) {
    return false;
  }
  if (property_.surrogate_for) {
    return false;
  }
  if (property_.is_logical) {
    return false;
  }
  return true;
}

export class PropertyBase {
  name: string;
  alias_for?: undefined | string;
  alternative_of?: string | PropertyBase | undefined;
  longhands?: string[] | undefined;
  property_methods?: string[] | undefined;
  is_property?: boolean | undefined;
  is_descriptor?: boolean | undefined;
  surrogate_for?: string | PropertyBase;
  interpolable?: boolean | undefined;
  field_template?: string | undefined;
  valid_for_first_letter?: string | undefined;
  valid_for_first_line?: string | undefined;
  valid_for_cue?: string | undefined;
  valid_for_marker?: string | undefined;
  valid_for_highlight_legacy?: string | undefined;
  valid_for_highlight?: string | undefined;
  computable?: boolean | undefined;
  supports_incremental_style?: boolean | undefined;
  is_animation_property?: boolean | undefined;
  idempotent?: boolean | undefined;
  valid_for_formatted_text?: boolean | undefined;
  valid_for_formatted_text_run?: boolean | undefined;
  mutable?: boolean | undefined;
  runtime_flag?: string;
  keywords?: string[];
  computed_style_custom_functions?: string[] | undefined;
  computed_style_protected_functions?: string[] | undefined;
  field_group?: string | undefined;
  visited_property_for?: string;
  visited?: boolean;
  reset_on_new_style?: boolean | undefined;
  is_logical?: boolean | undefined;
  alternative?: any;
  type_name?: string;
  sorting_key?: [number, string];
  priority: number | 0;
  enum_value?: number;
  visited_property?: PropertyBase;
  unvisited_property?: PropertyBase;
  aliases: string[];

  property_id?: string;
  enum_key?: string;
  inherited?: boolean;
  name_for_methods?: string;
  aliased_enum_value?: number;
  superclass?: string;
  namespace_group?: string;
  is_inherited_setter?: string;
  logical_property_group?: {
    name: NameStyleConverter | string;
    resolver_name: NameStyleConverter | string;
    resolver: string;
    is_logical?: boolean;
  }
  anchor_mode?: string | NameStyleConverter;
  style_builder_declare?: boolean;
  style_builder_custom_functions?: string[];
  default_value?: string;
  unwrapped_type_name?: string;
  wrapper_pointer_name?: string;

  get namespace() {
    if (this.is_shorthand) {
      return 'css_shorthand';
    }
    return 'css_longhand';
  }

  get classname() {
    return upperCamelCase(this.name);
  }

  get is_longhand() {
    return this.is_property && !this.longhands;
  }

  get is_shorthand() {
    return this.is_property && this.longhands;
  }

  get is_internal() {
    return this.name.startsWith('-internal-');
  }

  get known_exposed() {
    return !this.is_internal && !this.runtime_flag && !this.alternative;
  }

  get ultimate_property(): PropertyBase {
    if (this.alternative_of) {
      return (this.alternative_of as PropertyBase).ultimate_property;
    }
    return this;
  }

  get css_sample_id() {
    return this.ultimate_property.enum_key;
  }
}

type PropertyKeys = keyof PropertyBase;

type PropertyParameter = {
  [K in PropertyKeys]: {
    default: any
  }
};

interface Property extends PropertyBase {}

function generatePropertyClass(parameters: PropertyParameter) {
  const fields = Object.entries(parameters).map(([name, spec]) => ({
    name,
    defaultValue: spec.default || null
  }));

  const additional = {
    aliases: [],
    custom_compare: false,
    reset_on_new_style: false,
    mutable: false,
    name: null,
    alternative: null,
    visited_property: null
  };

  fields.push(...Object.entries(additional).map(([name, defaultValue]) => ({
    name,
    defaultValue
  })));

  class _Property extends PropertyBase implements Property {
    constructor(data = {}) {
      super();
      fields.forEach(({name, defaultValue}) => {
        this[name] = data[name] !== undefined ? data[name] : defaultValue;
      });
    }
  }

  return _Property;
}

export class CSSProperties {
  private _alias_offset: number;
  private _first_enum_value: number;
  private _last_used_enum_value: number;
  private _last_high_priority_property: any;
  private _properties_by_id: {[key: string]: PropertyBase};
  private _aliases: PropertyBase[];
  private _longhands: PropertyBase[];
  private _shorthands: PropertyBase[];
  private _properties_including_aliases: PropertyBase[];
  private _default_parameters: PropertyParameter;
  // private _extra_fields: any[];
  private _properties_by_name: { [key: string]: Property };
  private _properties_with_alternatives: any[];
  private _last_unresolved_property_id: number;
  private _field_alias_expander = new FieldAliasExpander();

  constructor() {
    const css_properties_path = path.join(__dirname, '../../../../core/css/css_properties.json5');
    // const computed_style_extra_fields_path = path.join(__dirname, '../../../../core/css/computed_style_extra_fields.json5');

    // _alias_offset is updated in add_properties().
    this._alias_offset = -1;
    this._first_enum_value = 2;
    this._last_used_enum_value = this._first_enum_value;
    this._last_high_priority_property = null;

    this._properties_by_id = {};
    this._aliases = [];
    this._longhands = [];
    this._shorthands = [];
    this._properties_including_aliases = [];

    const css_properties_file = JSON5.parse(fs.readFileSync(css_properties_path, {encoding: 'utf-8'}));
    this._default_parameters = css_properties_file.parameters;

    const Property = generatePropertyClass(this._default_parameters);
    const properties: Property[] = css_properties_file.data.map((x: any) => new Property(x));

    // this._extra_fields = [];
    // if (computed_style_extra_fields_path) {
    //   const fields = Json5File.load_from_files([computed_style_extra_fields_path], this._default_parameters);
    //   this._extra_fields = fields.name_dictionaries.map((x: any) => new Property(x));
    // }

    this._properties_by_name = Object.fromEntries(properties.map((p: Property) => [p.name, p]));

    for (const property_ of properties) {
      this.set_derived_attributes(property_);
      validateProperty(property_, this._properties_by_name);
    }

    this.add_properties(properties);

    this._last_unresolved_property_id = Math.max(...this._aliases.map(property_ => property_.enum_value!));
  }

  add_properties(properties: any[]) {
    this._aliases = properties.filter(property_ => property_.alias_for);
    this._shorthands = properties.filter(property_ => property_.longhands);
    this._longhands = properties.filter(property_ => !property_.alias_for && !property_.longhands);

    for (const property_ of [...this._longhands, ...this._shorthands]) {
      const name_without_leading_dash = property_.name.startsWith('-') ? property_.name.slice(1) : property_.name;
      property_.sorting_key = [-property_.priority, name_without_leading_dash];
    }

    // Sort the properties by priority, then alphabetically. Ensure that
    // the resulting order is deterministic.
    // Sort properties by priority, then alphabetically.
    const sorting_keys = new Map();
    for (const property_ of [...this._longhands, ...this._shorthands]) {
      const key = property_.sorting_key?.toString();
      if (sorting_keys.has(key)) {
        throw new Error(`Collision detected - two properties have the same name and priority, a potentially non-deterministic ordering can occur: ${key}, ${property_.name} and ${sorting_keys.get(key)}`);
      }
      sorting_keys.set(key, property_.name);
    }
    this._longhands.sort((a, b) => {
      if (a.sorting_key![0] === b.sorting_key![0]) {
        return (a.sorting_key![1]).localeCompare(b.sorting_key![1]);
      }
      return a.sorting_key![0] - b.sorting_key![0];
    });
    this._shorthands.sort((a, b) => {
      if (a.sorting_key![0] === b.sorting_key![0]) {
        return a.sorting_key![1].localeCompare(b.sorting_key![1]);
      }
      return a.sorting_key![0] - b.sorting_key![0];
    });

    // The sorted index becomes the CSSPropertyID enum value.
    for (const property_ of [...this._longhands, ...this._shorthands]) {
      property_.enum_value = this._last_used_enum_value++;
      if (this._properties_by_id.hasOwnProperty(property_.property_id!)) {
        throw new Error(`property with ID ${property_.property_id} appears more than once in the properties list`);
      }
      this._properties_by_id[property_.property_id!] = property_;
      if (property_.priority > 0) {
        this._last_high_priority_property = property_;
      }
    }

    this._alias_offset = this._last_used_enum_value;
    this.expand_aliases();
    this._properties_including_aliases = [...this._longhands, ...this._shorthands, ...this._aliases];
    this._properties_with_alternatives = this._properties_including_aliases.filter(p => p.alternative);
  }

  get_property(name: string) {
    if (!(name in this._properties_by_name)) {
      throw new Error(`No property with that name [${name}]`);
    }
    return this._properties_by_name[name];
  }

  set_derived_visited_attributes(property_: PropertyBase) {
    if (!property_.visited_property_for) {
      return;
    }
    const visited_property_for = property_.visited_property_for;
    const unvisited_property = this._properties_by_name[visited_property_for];
    property_.visited = true;
    property_.unvisited_property = unvisited_property;
    if (unvisited_property.visited_property) {
      throw new Error(`A property may not have multiple visited properties`);
    }
    unvisited_property.visited_property = property_;
  }

  set_derived_surrogate_attributes(property_: PropertyBase) {
    if (!property_.surrogate_for) {
      return;
    }
    if (!(property_.surrogate_for as string in this._properties_by_name)) {
      throw new Error(`surrogate_for must name a property`);
    }
    property_.surrogate_for = this._properties_by_name[property_.surrogate_for as string];
  }

  set_derived_alternative_attributes(property_: any) {
    if (!property_.alternative_of) {
      return;
    }
    const main_property = this.get_property(property_.alternative_of);
    property_.alternative_of = main_property;
    if (main_property.alternative) {
      throw new Error(`A property may not have multiple alternatives`);
    }
    main_property.alternative = property_;
  }

  expand_aliases() {
    this._aliases.forEach((alias, i) => {
      const aliased_property = this._properties_by_id[idForCssProperty(alias.alias_for!)];
      aliased_property.aliases.push(alias.name);
      const updated_alias = {...aliased_property, ...alias, aliasFor: alias.alias_for};
      updated_alias.property_id = idForCssPropertyAlias(alias.name);
      updated_alias.enum_key = enumKeyForCssPropertyAlias(alias.name);
      updated_alias.enum_value = this._alias_offset + i;
      updated_alias.aliased_enum_value = aliased_property.enum_value;
      updated_alias.superclass = 'CSSUnresolvedProperty';
      updated_alias.namespace_group = aliased_property.longhands ? 'Shorthand' : 'Longhand';
      this._aliases[i] = Object.setPrototypeOf(updated_alias, PropertyBase.prototype) as PropertyBase;
    });

    const updatedAliasesByName = Object.fromEntries(this._aliases.map(a => [a.name, a]));

    const updateAlternatives = (properties: any[]) => {
      properties.forEach(_property => {
        if (_property.alternativeOf && _property.alternativeOf.aliasFor) {
          _property.alternativeOf = updatedAliasesByName[_property.alternativeOf.name];
        }
        if (_property.alternative && _property.alternative.aliasFor) {
          _property.alternative = updatedAliasesByName[_property.alternative.name];
        }
      });
    };

    updateAlternatives(this._longhands);
    updateAlternatives(this._shorthands);
    updateAlternatives(this._aliases);
  }

  set_derived_attributes(property_: PropertyBase) {
    const set_if_none = (property_: any, key: string, value: any) => {
      if (!property_[key]) {
        property_[key] = value;
      }
    };

    const name = property_.name;
    property_.property_id = idForCssProperty(name);
    property_.enum_key = enumKeyForCssProperty(name);
    let method_name = property_.name_for_methods;
    if (!method_name) {
      method_name = upperCamelCase(name).replace('Webkit', '');
    }
    set_if_none(property_, 'inherited', false);

    set_if_none(property_, 'initial', 'Initial' + method_name);
    const simple_type_name = property_.type_name?.split('::').pop();
    set_if_none(property_, 'name_for_methods', method_name);
    set_if_none(property_, 'type_name', 'E' + method_name);
    set_if_none(property_, 'getter', simple_type_name !== method_name ? method_name : 'Get' + method_name);
    set_if_none(property_, 'setter', 'Set' + method_name);
    if (property_.inherited) {
      property_.is_inherited_setter = 'Set' + method_name + 'IsInherited';
    }

    property_.is_logical = false;

    if (property_.logical_property_group) {
      const group = property_.logical_property_group;
      if (!group.name) {
        throw new Error('name option is required');
      }
      if (!group.resolver) {
        throw new Error('resolver option is required');
      }
      const logicals = new Set(['block', 'inline', 'block-start', 'block-end', 'inline-start', 'inline-end', 'start-start', 'start-end', 'end-start', 'end-end']);
      const physicals = new Set(['vertical', 'horizontal', 'top', 'bottom', 'left', 'right', 'top-left', 'top-right', 'bottom-right', 'bottom-left']);
      if (logicals.has(group.resolver)) {
        group.is_logical = true;
      } else if (physicals.has(group.resolver)) {
        group.is_logical = false;
      } else {
        throw new Error('invalid resolver option');
      }
      group.name = new NameStyleConverter(group.name as string);
      group.resolver_name = new NameStyleConverter(group.resolver);
      property_.is_logical = group.is_logical;
    }

    property_.style_builder_declare = needs_style_builders(property_);

    ['initial', 'inherit', 'value'].forEach(x => {
      const suppressed = property_.style_builder_custom_functions!.includes(x);
      const declared = property_.style_builder_declare;
      property_['style_builder_generate_' + x] = declared && !suppressed;
    });

    if (PRIMITIVE_TYPES.includes(property_.type_name!)) {
      set_if_none(property_, 'converter', 'CSSPrimitiveValue');
    } else {
      set_if_none(property_, 'converter', 'CSSIdentifierValue');
    }

    if (property_.anchor_mode) {
      property_.anchor_mode = new NameStyleConverter(property_.anchor_mode as string);
    }

    if (!property_.longhands) {
      property_.superclass = 'Longhand';
      property_.namespace_group = 'Longhand';
    } else if (property_.longhands) {
      property_.superclass = 'Shorthand';
      property_.namespace_group = 'Shorthand';
    }

    if (property_.field_template) {
      this._field_alias_expander.expandFieldAlias(property_);

      const type_name = property_.type_name;
      let default_value;
      if (['keyword', 'multi_keyword', 'bitset_keyword'].includes(property_.field_template)) {
        default_value = `${type_name}::${new NameStyleConverter(property_.default_value!).toEnumValue()}`;
      } else if (['external', 'primitive', 'pointer'].includes(property_.field_template)) {
        default_value = property_.default_value;
      } else if (property_.field_template === 'derived_flag') {
        property_.type_name = 'unsigned';
        default_value = '0';
      } else if (property_.field_template === 'monotonic_flag') {
        property_.type_name = 'bool';
        default_value = 'false';
      } else {
        throw new Error(`Please put a valid value for field_template; got ${property_.field_template}`);
      }
      property_.default_value = default_value;

      property_.unwrapped_type_name = property_.type_name;
      if (property_.wrapper_pointer_name) {
        if (!['pointer', 'external'].includes(property_.field_template)) {
          throw new Error(`Invalid field_template: ${property_.field_template}`);
        }
        if (property_.field_template === 'external') {
          property_.type_name = `${property_.wrapper_pointer_name}<${type_name}>`;
        }
      }
    }

    set_if_none(property_, 'reset_on_new_style', false);
    set_if_none(property_, 'custom_compare', false);
    set_if_none(property_, 'mutable', false);

    this.set_derived_visited_attributes(property_);
    this.set_derived_surrogate_attributes(property_);
    this.set_derived_alternative_attributes(property_);
  }

  get default_parameters() {
    return this._default_parameters;
  }

  get aliases() {
    return this._aliases;
  }

  get computable() {
    const sorting_name = (p: any) => p.ultimate_property.name;
    const is_prefixed = (p: any) => sorting_name(p).startsWith('-');
    const is_not_prefixed = (p: any) => !is_prefixed(p);

    const prefixed = [...this._properties_including_aliases].filter(is_prefixed);
    const unprefixed = [...this._properties_including_aliases].filter(is_not_prefixed);

    const is_computable = (p: any) => {
      if (p.is_internal) return false;
      if (p.computable !== null) return p.computable;
      if (p.alias_for) return false;
      if (!p.is_property) return false;
      if (!p.is_longhand) return false;
      return true;
    };

    const prefixed_computable = prefixed.filter(is_computable);
    const unprefixed_computable = unprefixed.filter(is_computable);

    return [...unprefixed_computable.sort((a, b) => sorting_name(a) < sorting_name(b) ? -1 : 1), ...prefixed_computable.sort((a, b) => sorting_name(a) < sorting_name(b) ? -1 : 1)];
  }

  get shorthands() {
    return this._shorthands;
  }

  get shorthands_including_aliases() {
    return [...this._shorthands, ...this._aliases.filter(x => x.longhands)];
  }

  get longhands() {
    return this._longhands;
  }

  get longhands_including_aliases() {
    return [...this._longhands, ...this._aliases.filter(x => !x.longhands)];
  }

  get properties_by_name() {
    return this._properties_by_name;
  }

  get properties_by_id() {
    return this._properties_by_id;
  }

  get properties_including_aliases() {
    return this._properties_including_aliases;
  }

  get properties_with_alternatives() {
    return this._properties_with_alternatives;
  }

  get gperf_properties() {
    const non_alternative = (p: any) => !p.alternative_of;
    return this._properties_including_aliases.filter(non_alternative);
  }

  get first_property_id() {
    return this._first_enum_value;
  }

  get last_property_id() {
    return this._first_enum_value + Object.keys(this._properties_by_id).length - 1;
  }

  get last_unresolved_property_id() {
    return this._last_unresolved_property_id;
  }

  get last_high_priority_property_id() {
    return this._last_high_priority_property.enum_key;
  }

  get property_id_bit_length() {
    return Math.ceil(Math.log2(this._last_unresolved_property_id + 1));
  }

  get alias_offset() {
    return this._alias_offset;
  }

  get max_shorthand_expansion() {
    return Math.max(...this._shorthands.map(s => s.longhands!.length));
  }
}