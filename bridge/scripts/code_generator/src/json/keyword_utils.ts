import {PropertyBase} from "./css_properties";

export function sortKeywordPropertiesByCanonicalOrder(
  css_properties: PropertyBase[],
  css_value_keywords: string[]
): any[] {
  /**
   * Sort all keyword CSS properties by the order of the keyword in
   * css_value_keywords.json5
   *
   * Args:
   *     css_properties: css_properties excluding extra fields.
   *     css_value_keywords_file: file containing all css keywords.
   *     json5_file_parameters: current context json5 parameters.
   *
   * Returns:
   *     New css_properties object with sorted keywords.
   */

  const name_to_position_dictionary: { [key: string]: number } = Object.fromEntries(
    css_value_keywords.map((name, index) => [name, index])
  );

  css_properties.forEach((css_property: PropertyBase) => {
    if (css_property.field_template === 'keyword') {
      css_property['keywords'] = css_property.keywords!.slice().sort(
        (a: string, b: string) => name_to_position_dictionary[a] - name_to_position_dictionary[b]
      );
    }
  });

  return css_properties;
}