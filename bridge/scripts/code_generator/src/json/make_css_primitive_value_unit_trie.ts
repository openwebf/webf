import path from 'path';
import fs from 'fs';
import {generateJSONTemplate} from "./generator";
import _ from "lodash";
import {upperCamelCase} from "./name_utiltities";
import JSON5 from "json5";

const sourceTemplate = path.resolve(__dirname, '../../templates/json_templates/css_primitive_value_unit_trie.cc.tpl');

interface TrieNode {
  [key: string]: TrieNode | string;
}

type StringValuePair = [string, string];

// Function to build a single trie from input string-to-value pairs
function _singleTrie(stringToValuePairs: StringValuePair[], index: number): TrieNode {
  const dictsByIndexedLetter: { [key: string]: StringValuePair[] } = {};

  stringToValuePairs.forEach(([str, value]) => {
    const char = str[index];
    if (!dictsByIndexedLetter[char]) {
      dictsByIndexedLetter[char] = [];
    }
    dictsByIndexedLetter[char].push([str, value]);
  });

  const output: TrieNode = {};
  for (const char in dictsByIndexedLetter) {
    const d = dictsByIndexedLetter[char];
    if (d.length === 1) {
      const string = d[0][0];
      const value = d[0][1];
      output[char] = {[string.slice(index + 1)]: value};
    } else {
      output[char] = _singleTrie(d, index + 1);
    }
  }

  return output;
}

// Function to create a list of tries from a dictionary of input strings and output values
function trieListByStrLength(strToReturnValueDict: { [key: string]: string }): [number, TrieNode][] {
  const dictsByLength: { [key: number]: StringValuePair[] } = {};

  Object.entries(strToReturnValueDict).forEach(([str, value]) => {
    const length = str.length;
    if (!dictsByLength[length]) {
      dictsByLength[length] = [];
    }
    dictsByLength[length].push([str, value]);
  });

  const output: [number, TrieNode][] = [];
  Object.entries(dictsByLength)
    .sort(([a], [b]) => parseInt(a) - parseInt(b))
    .forEach(([length, pairs]) => {
      output.push([parseInt(length), _singleTrie(pairs, 0)]);
    });

  return output;
}

function compileSource() {
  const bodyTemplate = fs.readFileSync(sourceTemplate, {encoding: 'utf-8'});

  const configPath = path.resolve(__dirname, '../../../../core/css/css_primitive_value_units.json5');
  const unitsData = JSON5.parse(fs.readFileSync(configPath, {encoding: 'utf-8'}));
  let compiled = _.template(bodyTemplate);

  let units = unitsData.data.reduce((acc: { [key: string]: string }, entry: any) => {
    acc[entry['name']] = entry['unit_type'];
    return acc;
  }, {});

  return compiled({
    _: _,
    length_tries: trieListByStrLength(units)
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makeCSSPrimitiveValueUnitTrie() {
  return {
    source: compileSource()
  }
}