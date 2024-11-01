import {CSSProperties, PropertyBase} from "./css_properties";
import _ from "lodash";
import path from 'path';
import fs from 'fs';
import {enumKeyForCSSKeywords, upperCamelCase} from "./name_utiltities";
import {NameStyleConverter} from "./name_style_converter";
import JSON5 from "json5";

const header_template = path.resolve(__dirname, '../../templates/json_templates/css_value_id_mappings.h.tpl');
const includeFiles: string[] = [
  '#include "foundation/macros.h"',
  '#include "foundation/macros.h"',
  '#include "core/style/computed_style_base_constants.h"',
  '#include "core/platform/text/text_direction.h"',
  '#include "core/platform/text/writing_mode.h"',
  '#include "core/platform/graphics/graphic_types.h"'
];

function findContinuousSegment(numbers: [number, number][]): [number[], [number, number][]] {
  const segments = [0];
  const numberListSorted = numbers.slice().sort((a, b) => a[0] - b[0]);
  for (let i = 0; i < numberListSorted.length - 1; i++) {
    if (
      numberListSorted[i + 1][0] - numberListSorted[i][0] !== 1 ||
      numberListSorted[i + 1][1] - numberListSorted[i][1] !== 1
    ) {
      segments.push(i + 1);
    }
  }
  segments.push(numberListSorted.length);
  return [segments, numberListSorted];
}

function findLargestSegment(segments: number[]): [number, number] {
  const segmentList = segments.slice(0, -1).map((start, i) => [start, segments[i + 1]]);
  return segmentList.reduce((max, segment) => (segment[1] - segment[0] > max[1] - max[0] ? segment : max)) as [number, number];
}


function findEnumLongestContinuousSegment(
  property: PropertyBase,
  nameToPositionDictionary: { [key: string]: number }
): [any[], number[], [number, number]] {
  const propertyEnumOrder = Array.from({length: property.keywords!.length}, (_, i) => i);
  const cssEnumOrder = property.keywords!.map((keyword: string) => nameToPositionDictionary[keyword]);
  const enumPairList = propertyEnumOrder.map((order, i) => [cssEnumOrder[i], order] as [number, number]);

  const [enumSegment, enumPairListSorted] = findContinuousSegment(enumPairList);
  const longestSegment = findLargestSegment(enumSegment);

  const enumTupleList = enumPairListSorted.map(([cssOrder, propOrder]) => ([
    enumKeyForCSSKeywords(new NameStyleConverter(property.keywords![propOrder]).toUpperCamelCase()),
    propOrder,
    cssOrder
  ]));

  return [enumTupleList, enumSegment, longestSegment];
}

function compileHeader(properties: CSSProperties) {

  const sourcePath = path.resolve(__dirname, '../../../../core/css/css_value_keywords.json5');
  const cssValueKeyWords = JSON5.parse(fs.readFileSync(sourcePath, {encoding: 'utf-8'}));

  const nameToPositionDictionary = Object.fromEntries(
    cssValueKeyWords.data.map((x: any, i: number) => [x, i])
  );

  let mappings = {};

  for (const property of properties.properties_including_aliases) {
    if (property.field_template === 'multi_keyword' || property.field_template === 'bitset_keyword') {
      mappings[property.type_name!] = {
        default_value: property.default_value,
        mapping: property.keywords!.map((k: string) => enumKeyForCSSKeywords(k)),
      };
    } else if (property.field_template === 'keyword') {
      const [enumPairList, enumSegment, pSegment] = findEnumLongestContinuousSegment(
        property,
        nameToPositionDictionary
      );
      mappings[property.type_name!] = {
        default_value: property.default_value,
        mapping: enumPairList,
        segment: enumSegment,
        longest_segment_length: pSegment[1] - pSegment[0],
        start_segment: enumPairList[pSegment[0]],
        end_segment: enumPairList[pSegment[1] - 1],
      };
    }
  }

  const headerTemplate = fs.readFileSync(header_template, {encoding: 'utf-8'});

  let compiled = _.template(headerTemplate);
  return compiled({
    _: _,
    mappings: mappings,
    include_files: includeFiles,
    properties
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makeCSSValueIdMapping() {
  const properties = new CSSProperties();

  return {
    header: compileHeader(properties),
  }
}