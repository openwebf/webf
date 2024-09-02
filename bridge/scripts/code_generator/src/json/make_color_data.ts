import path from 'path';
import fs from 'fs';
import _ from "lodash";

const colorDataTemplate = path.resolve(__dirname, '../../templates/json_templates/color_data.cc.tpl');

function compileSource() {
  const bodyTemplate = fs.readFileSync(colorDataTemplate, {encoding: 'utf-8'});

  let compiled = _.template(bodyTemplate);
  return compiled({
    _: _
  }).split('\n').filter(str => {
    return str.trim().length > 0;
  }).join('\n');
}

export function makeColorData() {
  return {
    source: compileSource()
  }
}