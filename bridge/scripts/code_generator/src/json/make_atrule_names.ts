import path from 'path';
import fs from 'fs';
import _ from "lodash";
import JSON5 from 'json5';
import {upperCamelCase} from "./name_utiltities";

const headerTemplatePath = path.resolve(__dirname, '../../templates/json_templates/at_rule_descriptors.h.tpl');
const bodyTemplatePath = path.resolve(__dirname, '../../templates/json_templates/at_rule_descriptors.cc.tpl');

class AtRuleNamesWriter {
  public _outputs: { [key: string]: () => void };
  public _descriptors: any[];
  public _characterOffsets: number[];
  public _descriptorsCount: number;
  public _longestNameLength: number;

  constructor() {
    const sourcePath = path.resolve(__dirname, '../../../../core/css/parser/at_rule_names.json5');
    const data = JSON5.parse(fs.readFileSync(sourcePath, {encoding: 'utf-8'}));

    this._descriptors = data['data'];
    this._characterOffsets = [];

    // AtRuleDescriptorID::Invalid is 0.
    const firstDescriptorId = 1;
    // Aliases are resolved immediately at parse time, and thus don't appear
    // in the enum.
    this._descriptorsCount = this._descriptors.length + firstDescriptorId;
    let charsUsed = 0;
    this._longestNameLength = 0;

    this._descriptors.forEach((descriptor, offset) => {
      descriptor['enum_value'] = firstDescriptorId + offset;
      this._characterOffsets.push(charsUsed);
      charsUsed += descriptor['name'].length;
      this._longestNameLength = Math.max(
        descriptor['name'].length,
        descriptor['alias'] ? descriptor['alias'].length : 0,
        this._longestNameLength
      );
    });
  }
}

function compileHeader() {
  const headerTemplate = fs.readFileSync(headerTemplatePath, {encoding: 'utf-8'});
  const writer = new AtRuleNamesWriter();

  let compiled = _.template(headerTemplate);
  return compiled({
    _: _,
    upperCamelCase: upperCamelCase,
    descriptors: writer._descriptors,
    descriptors_count: writer._descriptorsCount
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

function compileSource() {
  const bodyTemplate = fs.readFileSync(bodyTemplatePath, {encoding: 'utf-8'});
  const writer = new AtRuleNamesWriter();

  let compiled = _.template(bodyTemplate);
  return compiled({
    _: _,
    upperCamelCase: upperCamelCase,
    descriptors: writer._descriptors,
    descriptors_count: writer._descriptorsCount,
    descriptor_offsets: writer._characterOffsets,
    longest_name_length: writer._longestNameLength,
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makeAtRuleNames() {
  return {
    header: compileHeader(),
    source: compileSource()
  }
}