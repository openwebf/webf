import {CSSProperties, PropertyBase} from "./css_properties";
import path from 'path';
import fs from 'fs';
import {generateJSONTemplate} from "./generator";
import _, {propertyOf} from "lodash";
import {lowerCamelCase, upperCamelCase} from "./name_utiltities";
import JSON5 from "json5";

const headerTemplate = path.resolve(__dirname, '../../templates/json_templates/css_properties.h.tpl');
const sourceTemplate = path.resolve(__dirname, '../../templates/json_templates/css_properties.cc.tpl');

function applyInitial(property: PropertyBase, fn: (property: PropertyBase) => string) {
  const className = upperCamelCase(property.name);
  if (property.style_builder_declare) {
    if (property['style_builder_generate_initial']) {
      return `void ${className}::ApplyInitial(StyleResolverState& state) const {
      
     }`;
    }
  }
  return '';
}

function applyInherit(property: PropertyBase, fn: (property: PropertyBase) => string) {
  const className = upperCamelCase(property.name);
  if (property.style_builder_declare) {
    if (property['style_builder_generate_inherit']) {
      return `void ${className}::ApplyInherit(StyleResolverState& state) const {
        
      }`
    }
  }
  return '';
}

function applyValue(property: PropertyBase, fn: (property: PropertyBase) => string) {
  const className = upperCamelCase(property.name);
  if (property.style_builder_declare) {
    if (property['style_builder_generate_value']) {
      return `void ${className}::ApplyValue(StyleResolverState& state, const CSSValue& value, ValueMode) const {
        
      }`;
    }
  }
  return '';
}

function styleAccess(property: PropertyBase) {
  return `state.StyleBuilder().`;
}

function setValue(property: PropertyBase) {
  if (property.font) {
    return `state.GetFontBuilder().${property['setter']}`;
  } else {
    return `${styleAccess(property)}${property['setter']}`;
  }
}

function concat(...args: string[]) {
  return args.join('\n');
}

function convertAndSetValue(property: PropertyBase) {
  if (property['converter'] === 'CSSPrimitiveValue') {
    return `${setValue(property)}(To<CSSPrimitiveValue>(value).ConvertTo<${property.type_name}>(state.CssToLengthConversionData()));`;
  } else if (property['converter'] === 'CSSIdentifierValue') {
    return `${setValue(property)}(To<CSSIdentifierValue>(value).ConvertTo<webf::${property.type_name}>());`;
  } else if (property['converter']) {
    return `${setValue(property)}(StyleBuilderConverter::${property['converter']}(state, value));`;
  }
  return '';
}

function styleBuilderFunction(property: PropertyBase) {
  if (!property.style_builder_template) {
    return concat(
      applyInitial(property, (property) => {
        let str1: string = '';
        if (property.font) {
          str1 = `${setValue(property)}(FontBuilder::${property.initial}());`;
        } else {
          str1 = `${setValue(property)}(ComputedStyleInitialValues::${property.initial}());`;
        }

        let str2: string = '';
        if (property.independent) {
          str2 = `state.StyleBuilder().${property.is_inherited_setter}(false);`;
        }

        return str1 + '\n' + str2;
      }),
      applyInherit(property, (property) => {
        let str1: string = '';
        if (property.font) {
          str1 = `${setValue(property)}(state.ParentFontDescription().${property['getter']}());`;
        } else {
          str1 = `${setValue(property)}(state.ParentStyle()->${property['getter']}());`;
        }
        let str2 = '';
        if (property.independent) {
          str2 = `state.StyleBuilder().${property.is_inherited_setter}(true);`;
        }

        return str1 + '\n' + str2;
      }),
      applyValue(property, (property) => {
        const str1 = convertAndSetValue(property);
        let str2 = '';
        if (property.independent) {
          str2 = `state.StyleBuilder().${property.is_inherited_setter}(false);`;
        }
        return str1 + '\n' + str2;
      })
    );
  } else if (property.style_builder_template == 'empty') {
    return concat(
      applyInitial(property, () => ''),
      applyInherit(property, () => ''),
      applyValue(property, () => '')
    );
  } else if (property.style_builder_template == 'auto') {
    const autoGetter = property.style_builder_template_args!['auto_getter'] || 'HasAuto' + property.name_for_methods;
    const autoSetter = property.style_builder_template_args!['auto_setter'] || 'SetHasAuto' + property.name_for_methods;
    return concat(
      applyInitial(property, (property) => {
        return `${styleAccess(property)}${autoSetter}();`;
      }),
      applyInherit(property, (property) => {
        return `if (state.ParentStyle()->${autoGetter}())
    ${styleAccess(property)}${autoSetter}();
  else
    ${setValue(property)}(state.ParentStyle()->${property['getter']}());
 `;
      }),
      applyValue(property, (property) => {
        return `auto* identifier_value = DynamicTo<CSSIdentifierValue>(value);
  if (identifier_value && identifier_value->GetValueID() == CSSValueID::kAuto)
    ${styleAccess(property)}${autoSetter}();
  else
    ${convertAndSetValue(property)}
`;
      })
    );
  } else if (['border_image', 'mask_box'].includes(property.style_builder_template)) {
    const isMaskBox = property.style_builder_template == 'mask_box';
    const modifierType = property.style_builder_template_args!['modifier_type'];
    const getter = isMaskBox ? 'MaskBoxImage' : 'BorderImage';
    const setter = 'Set' + getter;
    return applyInitial(property, (property) => {
      let str1 = `const NinePieceImage& current_image = state.StyleBuilder().${getter}();`;
      let str2 = '';
      //  Check for equality in case we can bail out before creating a new NinePieceImage.

      if (modifierType == 'Outset') {
        str2 = `
  if (style_building_utils::BorderImageLengthMatchesAllSides(current_image.Outset(),
    BorderImageLength(0)))
    return;
          `;
      } else if (modifierType == 'Repeat') {
        str2 = `  
  if (current_image.HorizontalRule() == kStretchImageRule &&
    current_image.VerticalRule() == kStretchImageRule)
    return;`;
      } else if (modifierType == 'Slice' && isMaskBox) {
        str2 = `     
  // Masks have a different initial value for slices. Preserve the value of 0
  // for backwards compatibility.
  if (current_image.Fill() == true &&
    style_building_utils::LengthMatchesAllSides(current_image.ImageSlices(), Length::Fixed(0)))
    return;`;
      } else if (modifierType == 'Slice' && !isMaskBox) {
        str2 = `
  if (current_image.Fill() == false &&
    style_building_utils::LengthMatchesAllSides(current_image.ImageSlices(), Length::Percent(100)))
  return;`;
      } else if (modifierType == 'Width' && isMaskBox) {
        str2 = `    
  // Masks have a different initial value for widths. Preserve the value of
  // 'auto' for backwards compatibility.
  if (style_building_utils::BorderImageLengthMatchesAllSides(current_image.BorderSlices(),
    BorderImageLength(Length::Auto())))
    return;`;
      } else if (modifierType == 'Width' && !isMaskBox) {
        str2 = `     
  if (style_building_utils::BorderImageLengthMatchesAllSides(current_image.BorderSlices(),
    BorderImageLength(1.0)))
    return;`;
      }
      let str3 = 'NinePieceImage image(current_image)';
      let str4 = '';

      if (modifierType == 'Outset') {
        str4 = 'image.SetOutset(0);';
      } else if (modifierType == 'Repeat') {
        str4 = `
  image.SetHorizontalRule(kStretchImageRule);
  image.SetVerticalRule(kStretchImageRule)  
`
      } else if (modifierType == 'Slice' && isMaskBox) {
        str4 = `
  image.SetImageSlices(LengthBox({{ (['Length::Fixed(0)']*4) | join(', ') }}));
  image.SetFill(true);
`;
      } else if (modifierType == 'Slice' && !isMaskBox) {
        str4 = `
  image.SetImageSlices(LengthBox({{ (['Length::Percent(100)']*4) | join(', ') }}));
  image.SetFill(false);
`;
      } else if (modifierType == 'Outset') {
        str4 = `
  image.SetOutset(0);
`;
      } else if (modifierType == 'Repeat') {
        str4 = `
  image.SetHorizontalRule(kStretchImageRule);
  image.SetVerticalRule(kStretchImageRule)
`
      } else if (modifierType == 'Slice' && isMaskBox) {
        str4 = `
  image.SetImageSlices(LengthBox({{ (['Length::Fixed(0)']*4) | join(', ') }}));
  image.SetFill(true);
        `
      } else if (modifierType == 'Slice' && !isMaskBox) {
        str4 = `
  image.SetImageSlices(LengthBox({{ (['Length::Percent(100)']*4) | join(', ') }}));
  image.SetFill(false);
`;
      } else if (modifierType == 'Width') {
        str4 = `
  image.SetBorderSlices({{ 'Length::Auto()' if is_mask_box else '1.0' }});
`;
      }
      let str5: string = `state.StyleBuilder().${setter}(image);`;

      return concat(str1, str2, str3, str4, str5);
    });
  } else if (['animation', 'transition'].includes(property.style_builder_template)) {
    const attribute = property.style_builder_template_args!['attribute'];
    const animation = property.style_builder_template == 'animation' ? 'Animation' : 'Transition';
    const vector = attribute + 'List()';
    return concat(
      applyInitial(property, (property) => {
        return `if (!state.StyleBuilder().${animation}s())
    return;
  CSS${animation}Data& data = state.StyleBuilder().Access${animation}s();
  data.${vector}.clear();
  data.${vector}.push_back(CSS${animation}Data::Initial${attribute}());`
      }),
      applyInherit(property, () => {
        return `const CSS${animation}Data* parent_data = state.ParentStyle()->${animation}s();
  if (!parent_data)
    ApplyInitial{{property_id}}(state);
  else
    state.StyleBuilder().Access${animation}s().${vector} = parent_data->${vector};`;
      }),
      applyValue(property, (property) => {
        return `const CSSValueList& list = To<CSSValueList>(value);
  CSS${animation}Data& data = state.StyleBuilder().Access${animation}s();
  data.${vector}.clear();
  data.${vector}.reserve(list.length());
  for (const CSSValue* list_value : list) {
    const auto& item = *list_value;
    data.${vector}.push_back(CSSToStyleMap::MapAnimation${attribute}(state, item));
  }`;
      })
    );
  } else if (['color', 'visited_color'].includes(property.style_builder_template)) {
    const initialColor = property.style_builder_template_args!['initial_color'];
    const isVisited = property.style_builder_template == 'visited_color';
    const mainGetter = isVisited && property.unvisited_property!['getter'] || property['getter'];
    return concat(
      applyInitial(property, () => {
        return `${setValue(property)}(${initialColor}());`;
      }),
      applyInherit(property, () => {
        return `${setValue(property)}(state.ParentStyle()->${mainGetter}());`;
      }),
      applyValue(property, () => {
        const visited_link = isVisited ? 'true' : 'false';
        return `${setValue(property)}(StyleBuilderConverter::${property['converter']}(state, value, ${visited_link}));`;
      })
    );
  } else if (property.style_builder_template == 'counter') {
    const action = property.style_builder_template_args!['action'];
    return concat(
      applyInitial(property, () => {
        return `state.StyleBuilder().Clear${action}Directives();`;
      }),
      applyInherit(property, () => {
        return `state.StyleBuilder().Clear${action}Directives();
  const CounterDirectiveMap* parent_map = state.ParentStyle()->GetCounterDirectives();
  if (!parent_map)
    return;

  CounterDirectiveMap& map = state.StyleBuilder().AccessCounterDirectives();
  DCHECK(!parent_map->empty());

  typedef CounterDirectiveMap::const_iterator Iterator;
  Iterator end = parent_map->end();
  for (Iterator it = parent_map->begin(); it != end; ++it) {
    CounterDirectives& directives = map.insert(it->key, CounterDirectives()).stored_value->value;
    directives.Inherit${action}(it->value);
  }`;
      }),
      applyValue(property, () => {
        let str1 = ``;

        if (action == 'Reset') {
          str1 = 'directives.SetResetValue(counter_value);';
        } else if (action == 'Increment') {
          str1 = 'directives.AddIncrementValue(counter_value);';
        } else {
          str1 = 'directives.SetSetValue(counter_value);';
        }

        return `state.StyleBuilder().Clear${action}Directives();

  const auto* list = DynamicTo<CSSValueList>(value);
  if (!list) {
    DCHECK_EQ(To<CSSIdentifierValue>(value).GetValueID(), CSSValueID::kNone);
    return;
  }

  CounterDirectiveMap& map = state.StyleBuilder().AccessCounterDirectives();

  for (const CSSValue* item : *list) {
    const auto& pair = To<CSSValuePair>(*item);
    AtomicString identifier(To<CSSCustomIdentValue>(pair.First()).Value());
    int counter_value = To<CSSPrimitiveValue>(pair.Second()).ComputeInteger(state.CssToLengthConversionData());
    CounterDirectives& directives =
    map.insert(identifier, CounterDirectives()).stored_value->value;
    ${str1}
  }
  DCHECK(!map.empty());`;
      })
    );
  } else if (property.style_builder_template == 'grid') {
    const type = property.style_builder_template_args!['type'];
    return concat(
      applyInitial(property, () => {
        return `${styleAccess(property)}SetGridTemplate${type}s(ComputedStyleInitialValues::InitialGridTemplate${type}s());`;
      }),
      applyInherit(property, () => {
        return `${styleAccess(property)}SetGridTemplate${type}s(state.ParentStyle()->GridTemplate${type}s());`;
      }),
      applyValue(property, () => {
        return `ComputedGridTrackList computed_grid_track_list;
  StyleBuilderConverter::ConvertGridTrackList(value, computed_grid_track_list, state);
  ${styleAccess(property)}SetGridTemplate${type}s(computed_grid_track_list);`;
      })
    );
  }

  return '';
}

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
    styleBuilderFunction,
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