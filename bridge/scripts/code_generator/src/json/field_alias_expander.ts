import JSON5 from 'json5';
import path from 'path';
import fs from 'fs';
import {PropertyBase} from "./css_properties";

interface Alias {
  name: string;
  [key: string]: any;
}

export class FieldAliasExpander {
  private _field_aliases: { [key: string]: Alias };

  /**
   * A helper for expanding the "field_template" parameter in css_properties.json5
   *
   * It takes the list of aliases and expansions from the given file_path, (it
   * should point to core/css/computed_style_field_aliases.json5) and uses that to
   * inform which fields in a given property should be set.
   */
  constructor() {
    const sourcePath = path.resolve(__dirname, '../../../../core/css/computed_style_field_aliases.json5');
    const config = JSON5.parse(fs.readFileSync(sourcePath, {encoding: 'utf-8'}));
    this._field_aliases = config.data.reduce(
      (acc: { [key: string]: Alias }, alias: Alias) => {
        acc[alias.name] = alias;
        return acc;
      },
      {}
    );
  }

  expandFieldAlias(property_: PropertyBase): void {
    /**
     * Does expansion base on the value of field_template of a given property.
     */
    const alias_template = property_.field_template;
    if (this._field_aliases.hasOwnProperty(alias_template ?? '')) {
      const alias = this._field_aliases[alias_template!];
      for (const field in alias) {
        if (field === 'name') continue;
        if (property_.hasOwnProperty(field)) {
          property_[field] = alias[field];
        } else {
          throw new Error(`Property does not have field: ${field}`);
        }
      }
    }
  }
}