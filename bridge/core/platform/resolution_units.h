//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_RESOLUTION_UNITS_H
#define WEBF_RESOLUTION_UNITS_H

namespace webf {

const double kMillimetersPerCentimeter = 10;
const double kQuarterMillimetersPerCentimeter = 40;
const double kCentimetersPerInch = 2.54;
const double kMillimetersPerInch = 25.4;
const double kQuarterMillimetersPerInch = 101.6;
const double kPointsPerInch = 72;
const double kPicasPerInch = 6;

// The constant CSS pixels per inch value is needed in platform/ for font size
// calculations.
const double kCssPixelsPerInch = 96;
const double kCssPixelsPerPoint = kCssPixelsPerInch / kPointsPerInch;

}  // namespace webf

#endif  // WEBF_RESOLUTION_UNITS_H
