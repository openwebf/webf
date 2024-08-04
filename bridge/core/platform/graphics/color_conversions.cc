// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "color_conversions.h"
#include "core/base/numberics/angle_conversion.h"
#include <numeric>
#include "skcms/skcms.h"

namespace webf {

// Namespace containing some of the helper methods for color conversions.
namespace {
// https://en.wikipedia.org/wiki/CIELAB_color_space#Converting_between_CIELAB_and_CIEXYZ_coordinates
constexpr float kD50_x = 0.9642f;
constexpr float kD50_y = 1.0f;
constexpr float kD50_z = 0.8251f;

// NOTE: SkFixedToFloat is exact. SkFloatToFixed seems to lack a rounding step. For all fixed-point
// values, this version is as accurate as possible for (fixed -> float -> fixed). Rounding reduces
// accuracy if the intermediate floats are in the range that only holds integers (adding 0.5f to an
// odd integer then snaps to nearest even). Using double for the rounding math gives maximum
// accuracy for (float -> fixed -> float), but that's usually overkill.
#define SkFixedToFloat(x) ((x) * 1.52587890625e-5f)

/**
 *  Describes a color gamut with primaries and a white point.
 */
struct SkColorSpacePrimaries {
  float fRX;
  float fRY;
  float fGX;
  float fGY;
  float fBX;
  float fBY;
  float fWX;
  float fWY;

  /**
   *  Convert primaries and a white point to a toXYZD50 matrix, the preferred color gamut
   *  representation of SkColorSpace.
   */
  bool toXYZD50(skcms_Matrix3x3* toXYZ_D50) const {
    return skcms_PrimariesToXYZD50(fRX, fRY, fGX, fGY, fBX, fBY, fWX, fWY, toXYZ_D50);
  }
};

namespace SkNamedGamut {

static constexpr skcms_Matrix3x3 kSRGB = {{
    // ICC fixed-point (16.16) representation, taken from skcms. Please keep them exactly in sync.
    // 0.436065674f, 0.385147095f, 0.143066406f,
    // 0.222488403f, 0.716873169f, 0.060607910f,
    // 0.013916016f, 0.097076416f, 0.714096069f,
    {SkFixedToFloat(0x6FA2), SkFixedToFloat(0x6299), SkFixedToFloat(0x24A0)},
    {SkFixedToFloat(0x38F5), SkFixedToFloat(0xB785), SkFixedToFloat(0x0F84)},
    {SkFixedToFloat(0x0390), SkFixedToFloat(0x18DA), SkFixedToFloat(0xB6CF)},
}};

static constexpr skcms_Matrix3x3 kAdobeRGB = {{
    // ICC fixed-point (16.16) repesentation of:
    // 0.60974, 0.20528, 0.14919,
    // 0.31111, 0.62567, 0.06322,
    // 0.01947, 0.06087, 0.74457,
    {SkFixedToFloat(0x9c18), SkFixedToFloat(0x348d), SkFixedToFloat(0x2631)},
    {SkFixedToFloat(0x4fa5), SkFixedToFloat(0xa02c), SkFixedToFloat(0x102f)},
    {SkFixedToFloat(0x04fc), SkFixedToFloat(0x0f95), SkFixedToFloat(0xbe9c)},
}};

static constexpr skcms_Matrix3x3 kDisplayP3 = {{
    {0.515102f, 0.291965f, 0.157153f},
    {0.241182f, 0.692236f, 0.0665819f},
    {-0.00104941f, 0.0418818f, 0.784378f},
}};

static constexpr skcms_Matrix3x3 kRec2020 = {{
    {0.673459f, 0.165661f, 0.125100f},
    {0.279033f, 0.675338f, 0.0456288f},
    {-0.00193139f, 0.0299794f, 0.797162f},
}};

static constexpr skcms_Matrix3x3 kXYZ = {{
    {1.0f, 0.0f, 0.0f},
    {0.0f, 1.0f, 0.0f},
    {0.0f, 0.0f, 1.0f},
}};

}  // namespace SkNamedGamut

namespace SkNamedPrimariesExt {

////////////////////////////////////////////////////////////////////////////////
// Color primaries defined by ITU-T H.273, table 2. Names are given by the first
// specification referenced in the value's row.

// Rec. ITU-R BT.709-6, value 1.
static constexpr SkColorSpacePrimaries kRec709 = {0.64f, 0.33f, 0.3f, 0.6f, 0.15f, 0.06f, 0.3127f, 0.329f};

// Rec. ITU-R BT.470-6 System M (historical), value 4.
static constexpr SkColorSpacePrimaries kRec470SystemM = {0.67f, 0.33f, 0.21f, 0.71f, 0.14f, 0.08f, 0.31f, 0.316f};

// Rec. ITU-R BT.470-6 System B, G (historical), value 5.
static constexpr SkColorSpacePrimaries kRec470SystemBG = {0.64f, 0.33f, 0.29f, 0.60f, 0.15f, 0.06f, 0.3127f, 0.3290f};

// Rec. ITU-R BT.601-7 525, value 6.
static constexpr SkColorSpacePrimaries kRec601 = {0.630f, 0.340f, 0.310f, 0.595f, 0.155f, 0.070f, 0.3127f, 0.3290f};

// SMPTE ST 240, value 7 (functionally the same as value 6).
static constexpr SkColorSpacePrimaries kSMPTE_ST_240 = kRec601;

// Generic film (colour filters using Illuminant C), value 8.
static constexpr SkColorSpacePrimaries kGenericFilm = {0.681f, 0.319f, 0.243f, 0.692f, 0.145f, 0.049f, 0.310f, 0.316f};

// Rec. ITU-R BT.2020-2, value 9.
static constexpr SkColorSpacePrimaries kRec2020{0.708f, 0.292f, 0.170f, 0.797f, 0.131f, 0.046f, 0.3127f, 0.3290f};

// SMPTE ST 428-1, value 10.
static constexpr SkColorSpacePrimaries kSMPTE_ST_428_1 = {1.f, 0.f, 0.f, 1.f, 0.f, 0.f, 1.f / 3.f, 1.f / 3.f};

// SMPTE RP 431-2, value 11.
static constexpr SkColorSpacePrimaries kSMPTE_RP_431_2 = {0.680f, 0.320f, 0.265f, 0.690f,
                                                          0.150f, 0.060f, 0.314f, 0.351f};

// SMPTE EG 432-1, value 12.
static constexpr SkColorSpacePrimaries kSMPTE_EG_432_1 = {0.680f, 0.320f, 0.265f,  0.690f,
                                                          0.150f, 0.060f, 0.3127f, 0.3290f};

// No corresponding industry specification identified, value 22.
// This is sometimes referred to as EBU 3213-E, but that document doesn't
// specify these values.
static constexpr SkColorSpacePrimaries kITU_T_H273_Value22 = {0.630f, 0.340f, 0.295f,  0.605f,
                                                              0.155f, 0.077f, 0.3127f, 0.3290f};

////////////////////////////////////////////////////////////////////////////////
// CSS Color Level 4 predefined and xyz color spaces.

// 'srgb'
static constexpr SkColorSpacePrimaries kSRGB = kRec709;

// 'display-p3' (and also 'p3' as a color gamut).
static constexpr SkColorSpacePrimaries kP3 = kSMPTE_EG_432_1;

// 'a98-rgb'
static constexpr SkColorSpacePrimaries kA98RGB = {0.64f, 0.33f, 0.21f, 0.71f, 0.15f, 0.06f, 0.3127f, 0.3290f};

// 'prophoto-rgb'
static constexpr SkColorSpacePrimaries kProPhotoRGB = {0.7347f, 0.2653f, 0.1596f,  0.8404f,
                                                       0.0366f, 0.0001f, 0.34567f, 0.35850f};

// 'rec2020' (as both a predefined color space and color gamut).
// The value kRec2020 is already defined above.

// 'xyzd50'
static constexpr SkColorSpacePrimaries kXYZD50 = {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.34567f, 0.35850f};

// 'xyz' and 'xyzd65'
static constexpr SkColorSpacePrimaries kXYZD65 = {1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.3127f, 0.3290f};

////////////////////////////////////////////////////////////////////////////////
// Additional helper color primaries.

// Invalid primaries, initialized to zero.
static constexpr SkColorSpacePrimaries kInvalid = {0};

// The GenericRGB space on macOS.
static constexpr SkColorSpacePrimaries kAppleGenericRGB = {0.63002f, 0.34000f, 0.29505f, 0.60498f,
                                                           0.15501f, 0.07701f, 0.3127f,  0.3290f};

// Primaries where the colors are rotated and the gamut is huge. Good for
// testing.
static constexpr SkColorSpacePrimaries kWideGamutColorSpin = {0.01f, 0.98f, 0.01f,   0.01f,
                                                              0.98f, 0.01f, 0.3127f, 0.3290f};

}  // namespace SkNamedPrimariesExt

namespace SkNamedTransferFn {

// Like SkNamedGamut::kSRGB, keeping this bitwise exactly the same as skcms makes things fastest.
static constexpr skcms_TransferFunction kSRGB = {
    2.4f, (float)(1 / 1.055), (float)(0.055 / 1.055), (float)(1 / 12.92), 0.04045f, 0.0f, 0.0f};

static constexpr skcms_TransferFunction k2Dot2 = {2.2f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};

static constexpr skcms_TransferFunction kLinear = {1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f};

static constexpr skcms_TransferFunction kRec2020 = {2.22222f, 0.909672f, 0.0903276f, 0.222222f, 0.0812429f, 0, 0};

static constexpr skcms_TransferFunction kPQ = {-2.0f,         -107 / 128.0f,  1.0f,          32 / 2523.0f,
                                               2413 / 128.0f, -2392 / 128.0f, 8192 / 1305.0f};

static constexpr skcms_TransferFunction kHLG = {-3.0f, 2.0f, 2.0f, 1 / 0.17883277f, 0.28466892f, 0.55991073f, 0.0f};

}  // namespace SkNamedTransferFn

namespace SkNamedTransferFnExt {

////////////////////////////////////////////////////////////////////////////////
// Color primaries defined by ITU-T H.273, table 3. Names are given by the first
// specification referenced in the value's row.

// Rec. ITU-R BT.709-6, value 1.
static constexpr skcms_TransferFunction kRec709 = {
    2.222222222222f, 0.909672415686f, 0.090327584314f, 0.222222222222f, 0.081242858299f, 0.f, 0.f};

// Rec. ITU-R BT.470-6 System M (historical) assumed display gamma 2.2, value 4.
static constexpr skcms_TransferFunction kRec470SystemM = {2.2f, 1.f};

// Rec. ITU-R BT.470-6 System B, G (historical) assumed display gamma 2.8,
// value 5.
static constexpr skcms_TransferFunction kRec470SystemBG = {2.8f, 1.f};

// Rec. ITU-R BT.601-7, same as kRec709, value 6.
static constexpr skcms_TransferFunction kRec601 = kRec709;

// SMPTE ST 240, value 7.
static constexpr skcms_TransferFunction kSMPTE_ST_240 = {
    2.222222222222f, 0.899626676224f, 0.100373323776f, 0.25f, 0.091286342118f, 0.f, 0.f};

// IEC 61966-2-4, value 11, same as kRec709 (but is explicitly extended).
static constexpr skcms_TransferFunction kIEC61966_2_4 = kRec709;

// IEC 61966-2-1 sRGB, value 13. This is almost equal to
// SkNamedTransferFnExt::kSRGB. The differences are rounding errors that
// cause test failures (and should be unified).
static constexpr skcms_TransferFunction kIEC61966_2_1 = {2.4f, 0.947867345704f, 0.052132654296f, 0.077399380805f,
                                                         0.040449937172f};

// Rec. ITU-R BT.2020-2 (10-bit system), value 14.
static constexpr skcms_TransferFunction kRec2020_10bit = kRec709;

// Rec. ITU-R BT.2020-2 (12-bit system), value 15.
static constexpr skcms_TransferFunction kRec2020_12bit = kRec709;

// SMPTE ST 428-1, value 17.
static constexpr skcms_TransferFunction kSMPTE_ST_428_1 = {2.6f, 1.034080527699f};

////////////////////////////////////////////////////////////////////////////////
// CSS Color Level 4 predefined color spaces.

// 'srgb', 'display-p3'
static constexpr skcms_TransferFunction kSRGB = kIEC61966_2_1;

// 'a98-rgb'
static constexpr skcms_TransferFunction kA98RGB = {2.2f, 1.};

// 'prophoto-rgb'
static constexpr skcms_TransferFunction kProPhotoRGB = {1.8f, 1.};

// 'rec2020' uses the same transfer function as kRec709.
static constexpr skcms_TransferFunction kRec2020 = kRec709;

////////////////////////////////////////////////////////////////////////////////
// Additional helper transfer functions.

// Invalid primaries, initialized to zero.
static constexpr skcms_TransferFunction kInvalid = {0};

// The interpretation of kRec709 that is produced by accelerated video decode
// on macOS.
static constexpr skcms_TransferFunction kRec709Apple = {1.961f, 1.};

// If the sRGB transfer function is f(x), then this transfer function is
// f(x * 1023 / 510). This function gives 510 values to SDR content, and can
// reach a maximum brightnes of 4.99x SDR brightness.
static constexpr skcms_TransferFunction kSRGBExtended1023Over510 = {SkNamedTransferFnExt::kSRGB.g,
                                                                    SkNamedTransferFnExt::kSRGB.a * 1023 / 510,
                                                                    SkNamedTransferFnExt::kSRGB.b,
                                                                    SkNamedTransferFnExt::kSRGB.c * 1023 / 510,
                                                                    SkNamedTransferFnExt::kSRGB.d * 1023 / 510,
                                                                    SkNamedTransferFnExt::kSRGB.e,
                                                                    SkNamedTransferFnExt::kSRGB.f};

}  // namespace SkNamedTransferFnExt

// Evaluate the specified transfer function. This can be replaced by
// skcms_TransferFunction_eval when b/331320414 is fixed.
float skcmsTrFnEvalExt(const skcms_TransferFunction* fn, float x) {
  float sign = x < 0 ? -1 : 1;
  x *= sign;
  // TODO(b/331320414): Make skcms_TransferFunction_eval not assert on when
  // this is the case.
  if (x >= fn->d && fn->a * x + fn->b < 0) {
    return sign * fn->e;
  }
  return sign * skcms_TransferFunction_eval(fn, x);
}

// Power function extended to all real numbers by point symmetry.
float powExt(float x, float p) {
  if (x < 0) {
    return -powf(-x, p);
  } else {
    return powf(x, p);
  }
}

const skcms_Matrix3x3* getXYDZ65toXYZD50matrix() {
  constexpr float kD65_x = 0.3127f;
  constexpr float kD65_y = 0.3290f;
  static skcms_Matrix3x3 adapt_d65_to_d50;
  skcms_AdaptToXYZD50(kD65_x, kD65_y, &adapt_d65_to_d50);
  return &adapt_d65_to_d50;
}

const skcms_Matrix3x3* getXYDZ50toXYZD65matrix() {
  static skcms_Matrix3x3 adapt_d50_to_d65;
  skcms_Matrix3x3_invert(getXYDZ65toXYZD50matrix(), &adapt_d50_to_d65);
  return &adapt_d50_to_d65;
}

const skcms_Matrix3x3* getXYZD50TosRGBLinearMatrix() {
  static skcms_Matrix3x3 xyzd50_to_srgb_linear;
  skcms_Matrix3x3_invert(&SkNamedGamut::kSRGB, &xyzd50_to_srgb_linear);
  return &xyzd50_to_srgb_linear;
}

const skcms_Matrix3x3* getXYZD65tosRGBLinearMatrix() {
  static skcms_Matrix3x3 adapt_XYZD65_to_srgb =
      skcms_Matrix3x3_concat(getXYZD50TosRGBLinearMatrix(), getXYDZ65toXYZD50matrix());
  return &adapt_XYZD65_to_srgb;
}

const skcms_Matrix3x3* getProPhotoRGBtoXYZD50Matrix() {
  static skcms_Matrix3x3 lin_proPhoto_to_XYZ_D50;
  SkNamedPrimariesExt::kProPhotoRGB.toXYZD50(&lin_proPhoto_to_XYZ_D50);
  return &lin_proPhoto_to_XYZ_D50;
}

const skcms_Matrix3x3* getXYZD50toProPhotoRGBMatrix() {
  static skcms_Matrix3x3 xyzd50_to_ProPhotoRGB;
  skcms_Matrix3x3_invert(getProPhotoRGBtoXYZD50Matrix(), &xyzd50_to_ProPhotoRGB);
  return &xyzd50_to_ProPhotoRGB;
}

const skcms_Matrix3x3* getXYZD50toDisplayP3Matrix() {
  static skcms_Matrix3x3 xyzd50_to_DisplayP3;
  skcms_Matrix3x3_invert(&SkNamedGamut::kDisplayP3, &xyzd50_to_DisplayP3);
  return &xyzd50_to_DisplayP3;
}

const skcms_Matrix3x3* getXYZD50toAdobeRGBMatrix() {
  static skcms_Matrix3x3 xyzd50_to_kAdobeRGB;
  skcms_Matrix3x3_invert(&SkNamedGamut::kAdobeRGB, &xyzd50_to_kAdobeRGB);
  return &xyzd50_to_kAdobeRGB;
}

const skcms_Matrix3x3* getXYZD50toRec2020Matrix() {
  static skcms_Matrix3x3 xyzd50_to_Rec2020;
  skcms_Matrix3x3_invert(&SkNamedGamut::kRec2020, &xyzd50_to_Rec2020);
  return &xyzd50_to_Rec2020;
}

const skcms_Matrix3x3* getXYZToLMSMatrix() {
  static const skcms_Matrix3x3 kXYZ_to_LMS = {{{0.8190224432164319f, 0.3619062562801221f, -0.12887378261216414f},
                                               {0.0329836671980271f, 0.9292868468965546f, 0.03614466816999844f},
                                               {0.048177199566046255f, 0.26423952494422764f, 0.6335478258136937f}}};
  return &kXYZ_to_LMS;
}

const skcms_Matrix3x3* getLMSToXYZMatrix() {
  static skcms_Matrix3x3 LMS_to_XYZ;
  skcms_Matrix3x3_invert(getXYZToLMSMatrix(), &LMS_to_XYZ);
  return &LMS_to_XYZ;
}

const skcms_Matrix3x3* getOklabToLMSMatrix() {
  static const skcms_Matrix3x3 kOklab_to_LMS = {
      {{0.99999999845051981432f, 0.39633779217376785678f, 0.21580375806075880339f},
       {1.0000000088817607767f, -0.1055613423236563494f, -0.063854174771705903402f},
       {1.0000000546724109177f, -0.089484182094965759684f, -1.2914855378640917399f}}};
  return &kOklab_to_LMS;
}

const skcms_Matrix3x3* getLMSToOklabMatrix() {
  static skcms_Matrix3x3 LMS_to_Oklab;
  skcms_Matrix3x3_invert(getOklabToLMSMatrix(), &LMS_to_Oklab);
  return &LMS_to_Oklab;
}

typedef struct {
  float vals[3];
} skcms_Vector3;

typedef struct {
  float vals[2];
} skcms_Vector2;

float dot(const skcms_Vector2& a, const skcms_Vector2& b) {
  return a.vals[0] * b.vals[0] + a.vals[1] * b.vals[1];
}

static skcms_Vector3 skcms_Matrix3x3_apply(const skcms_Matrix3x3* m, const skcms_Vector3* v) {
  skcms_Vector3 dst = {{0, 0, 0}};
  for (int row = 0; row < 3; ++row) {
    dst.vals[row] = m->vals[row][0] * v->vals[0] + m->vals[row][1] * v->vals[1] + m->vals[row][2] * v->vals[2];
  }
  return dst;
}

skcms_TransferFunction* getSRGBInverseTransferFunction() {
  static skcms_TransferFunction srgb_inverse;
  skcms_TransferFunction_invert(&SkNamedTransferFn::kSRGB, &srgb_inverse);
  return &srgb_inverse;
}

std::tuple<float, float, float> ApplyInverseTransferFnsRGB(float r, float g, float b) {
  return std::make_tuple(skcmsTrFnEvalExt(getSRGBInverseTransferFunction(), r),
                         skcmsTrFnEvalExt(getSRGBInverseTransferFunction(), g),
                         skcmsTrFnEvalExt(getSRGBInverseTransferFunction(), b));
}

std::tuple<float, float, float> ApplyTransferFnsRGB(float r, float g, float b) {
  return std::make_tuple(skcmsTrFnEvalExt(&SkNamedTransferFn::kSRGB, r), skcmsTrFnEvalExt(&SkNamedTransferFn::kSRGB, g),
                         skcmsTrFnEvalExt(&SkNamedTransferFn::kSRGB, b));
}

std::tuple<float, float, float> ApplyTransferFnProPhoto(float r, float g, float b) {
  return std::make_tuple(skcmsTrFnEvalExt(&SkNamedTransferFnExt::kProPhotoRGB, r),
                         skcmsTrFnEvalExt(&SkNamedTransferFnExt::kProPhotoRGB, g),
                         skcmsTrFnEvalExt(&SkNamedTransferFnExt::kProPhotoRGB, b));
}

std::tuple<float, float, float> ApplyTransferFnAdobeRGB(float r, float g, float b) {
  return std::make_tuple(skcmsTrFnEvalExt(&SkNamedTransferFn::k2Dot2, r),
                         skcmsTrFnEvalExt(&SkNamedTransferFn::k2Dot2, g),
                         skcmsTrFnEvalExt(&SkNamedTransferFn::k2Dot2, b));
}

skcms_TransferFunction* getProPhotoInverseTransferFunction() {
  static skcms_TransferFunction ProPhoto_inverse;
  skcms_TransferFunction_invert(&SkNamedTransferFnExt::kProPhotoRGB, &ProPhoto_inverse);
  return &ProPhoto_inverse;
}

std::tuple<float, float, float> ApplyInverseTransferFnProPhoto(float r, float g, float b) {
  return std::make_tuple(skcmsTrFnEvalExt(getProPhotoInverseTransferFunction(), r),
                         skcmsTrFnEvalExt(getProPhotoInverseTransferFunction(), g),
                         skcmsTrFnEvalExt(getProPhotoInverseTransferFunction(), b));
}

skcms_TransferFunction* getAdobeRGBInverseTransferFunction() {
  static skcms_TransferFunction AdobeRGB_inverse;
  skcms_TransferFunction_invert(&SkNamedTransferFn::k2Dot2, &AdobeRGB_inverse);
  return &AdobeRGB_inverse;
}

std::tuple<float, float, float> ApplyInverseTransferFnAdobeRGB(float r, float g, float b) {
  return std::make_tuple(skcmsTrFnEvalExt(getAdobeRGBInverseTransferFunction(), r),
                         skcmsTrFnEvalExt(getAdobeRGBInverseTransferFunction(), g),
                         skcmsTrFnEvalExt(getAdobeRGBInverseTransferFunction(), b));
}

std::tuple<float, float, float> ApplyTransferFnRec2020(float r, float g, float b) {
  return std::make_tuple(skcmsTrFnEvalExt(&SkNamedTransferFn::kRec2020, r),
                         skcmsTrFnEvalExt(&SkNamedTransferFn::kRec2020, g),
                         skcmsTrFnEvalExt(&SkNamedTransferFn::kRec2020, b));
}

skcms_TransferFunction* getRec2020nverseTransferFunction() {
  static skcms_TransferFunction Rec2020_inverse;
  skcms_TransferFunction_invert(&SkNamedTransferFn::kRec2020, &Rec2020_inverse);
  return &Rec2020_inverse;
}

std::tuple<float, float, float> ApplyInverseTransferFnRec2020(float r, float g, float b) {
  return std::make_tuple(skcmsTrFnEvalExt(getRec2020nverseTransferFunction(), r),
                         skcmsTrFnEvalExt(getRec2020nverseTransferFunction(), g),
                         skcmsTrFnEvalExt(getRec2020nverseTransferFunction(), b));
}
}  // namespace

std::tuple<float, float, float> LabToXYZD50(float l, float a, float b) {
  float y = (l + 16.0f) / 116.0f;
  float x = y + a / 500.0f;
  float z = y - b / 200.0f;

  auto LabInverseTransferFunction = [](float t) {
    constexpr float delta = (24.0f / 116.0f);

    if (t <= delta) {
      return (108.0f / 841.0f) * (t - (16.0f / 116.0f));
    }

    return t * t * t;
  };

  x = LabInverseTransferFunction(x) * kD50_x;
  y = LabInverseTransferFunction(y) * kD50_y;
  z = LabInverseTransferFunction(z) * kD50_z;

  return std::make_tuple(x, y, z);
}

std::tuple<float, float, float> XYZD50ToLab(float x, float y, float z) {
  auto LabTransferFunction = [](float t) {
    constexpr float delta_limit = (24.0f / 116.0f) * (24.0f / 116.0f) * (24.0f / 116.0f);

    if (t <= delta_limit)
      return (841.0f / 108.0f) * t + (16.0f / 116.0f);
    else
      return std::pow(t, 1.0f / 3.0f);
  };

  x = LabTransferFunction(x / kD50_x);
  y = LabTransferFunction(y / kD50_y);
  z = LabTransferFunction(z / kD50_z);

  float l = 116.0f * y - 16.0f;
  float a = 500.0f * (x - y);
  float b = 200.0f * (y - z);

  return std::make_tuple(l, a, b);
}

// Projects the color (l,a,b) to be within a polyhedral approximation of the
// Rec2020 gamut. This is done by finding the maximum value of alpha such that
// (l, alpha*a, alpha*b) is within that polyhedral approximation.
std::tuple<float, float, float> OklabGamutMap(float l, float a, float b) {
  // Constants for the normal vector of the plane formed by white, black, and
  // the specified vertex of the gamut.
  const skcms_Vector2 normal_R{{0.409702, -0.912219}};
  const skcms_Vector2 normal_M{{-0.397919, -0.917421}};
  const skcms_Vector2 normal_B{{-0.906800, 0.421562}};
  const skcms_Vector2 normal_C{{-0.171122, 0.985250}};
  const skcms_Vector2 normal_G{{0.460276, 0.887776}};
  const skcms_Vector2 normal_Y{{0.947925, 0.318495}};

  // For the triangles formed by white (W) or black (K) with the vertices
  // of Yellow and Red (YR), Red and Magenta (RM), etc, the constants to be
  // used to compute the intersection of a line of constant hue and luminance
  // with that plane.
  const float c0_YR = 0.091132;
  const skcms_Vector2 cW_YR{{0.070370, 0.034139}};
  const skcms_Vector2 cK_YR{{0.018170, 0.378550}};
  const float c0_RM = 0.113902;
  const skcms_Vector2 cW_RM{{0.090836, 0.036251}};
  const skcms_Vector2 cK_RM{{0.226781, 0.018764}};
  const float c0_MB = 0.161739;
  const skcms_Vector2 cW_MB{{-0.008202, -0.264819}};
  const skcms_Vector2 cK_MB{{0.187156, -0.284304}};
  const float c0_BC = 0.102047;
  const skcms_Vector2 cW_BC{{-0.014804, -0.162608}};
  const skcms_Vector2 cK_BC{{-0.276786, 0.004193}};
  const float c0_CG = 0.092029;
  const skcms_Vector2 cW_CG{{-0.038533, -0.001650}};
  const skcms_Vector2 cK_CG{{-0.232572, -0.094331}};
  const float c0_GY = 0.081709;
  const skcms_Vector2 cW_GY{{-0.034601, -0.002215}};
  const skcms_Vector2 cK_GY{{0.012185, 0.338031}};

  const float L = l;
  const float one_minus_L = 1.0 - L;
  const skcms_Vector2 ab{{a, b}};

  // Find the planes to intersect with and set the constants based on those
  // planes.
  float c0 = 0.f;
  skcms_Vector2 cW{{0.f, 0.f}};
  skcms_Vector2 cK{{0.f, 0.f}};
  if (dot(ab, normal_R) < 0.0) {
    if (dot(ab, normal_G) < 0.0) {
      if (dot(ab, normal_C) < 0.0) {
        c0 = c0_BC;
        cW = cW_BC;
        cK = cK_BC;
      } else {
        c0 = c0_CG;
        cW = cW_CG;
        cK = cK_CG;
      }
    } else {
      if (dot(ab, normal_Y) < 0.0) {
        c0 = c0_GY;
        cW = cW_GY;
        cK = cK_GY;
      } else {
        c0 = c0_YR;
        cW = cW_YR;
        cK = cK_YR;
      }
    }
  } else {
    if (dot(ab, normal_B) < 0.0) {
      if (dot(ab, normal_M) < 0.0) {
        c0 = c0_RM;
        cW = cW_RM;
        cK = cK_RM;
      } else {
        c0 = c0_MB;
        cW = cW_MB;
        cK = cK_MB;
      }
    } else {
      c0 = c0_BC;
      cW = cW_BC;
      cK = cK_BC;
    }
  }

  // Perform the intersection.
  float alpha = 1.f;

  // Intersect with the plane with white.
  const float w_denom = dot(cW, ab);
  if (w_denom > 0.f) {
    const float w_num = c0 * one_minus_L;
    if (w_num < w_denom) {
      alpha = std::min(alpha, w_num / w_denom);
    }
  }

  // Intersect with the plane with black.
  const float k_denom = dot(cK, ab);
  if (k_denom > 0.f) {
    const float k_num = c0 * L;
    if (k_num < k_denom) {
      alpha = std::min(alpha, k_num / k_denom);
    }
  }

  // Attenuate the ab coordinate by alpha.
  return std::make_tuple(L, alpha * a, alpha * b);
}

std::tuple<float, float, float> OklabToXYZD65(float l, float a, float b) {
  skcms_Vector3 lab_input{{l, a, b}};
  skcms_Vector3 lms_intermediate = skcms_Matrix3x3_apply(getOklabToLMSMatrix(), &lab_input);
  lms_intermediate.vals[0] = lms_intermediate.vals[0] * lms_intermediate.vals[0] * lms_intermediate.vals[0];
  lms_intermediate.vals[1] = lms_intermediate.vals[1] * lms_intermediate.vals[1] * lms_intermediate.vals[1];
  lms_intermediate.vals[2] = lms_intermediate.vals[2] * lms_intermediate.vals[2] * lms_intermediate.vals[2];
  skcms_Vector3 xyz_output = skcms_Matrix3x3_apply(getLMSToXYZMatrix(), &lms_intermediate);
  return std::make_tuple(xyz_output.vals[0], xyz_output.vals[1], xyz_output.vals[2]);
}

std::tuple<float, float, float> XYZD65ToOklab(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 lms_intermediate = skcms_Matrix3x3_apply(getXYZToLMSMatrix(), &xyz_input);

  lms_intermediate.vals[0] = powExt(lms_intermediate.vals[0], 1.0f / 3.0f);
  lms_intermediate.vals[1] = powExt(lms_intermediate.vals[1], 1.0f / 3.0f);
  lms_intermediate.vals[2] = powExt(lms_intermediate.vals[2], 1.0f / 3.0f);

  skcms_Vector3 lab_output = skcms_Matrix3x3_apply(getLMSToOklabMatrix(), &lms_intermediate);
  return std::make_tuple(lab_output.vals[0], lab_output.vals[1], lab_output.vals[2]);
}

std::tuple<float, float, float> LchToLab(float l, float c, float h) {
  return std::make_tuple(l, c * std::cos(base::DegToRad(h)), c * std::sin(base::DegToRad(h)));
}
std::tuple<float, float, float> LabToLch(float l, float a, float b) {
  return std::make_tuple(l, std::sqrt(a * a + b * b), base::RadToDeg(atan2f(b, a)));
}

std::tuple<float, float, float> DisplayP3ToXYZD50(float r, float g, float b) {
  auto [r_, g_, b_] = ApplyTransferFnsRGB(r, g, b);
  skcms_Vector3 rgb_input{{r_, g_, b_}};
  skcms_Vector3 xyz_output = skcms_Matrix3x3_apply(&SkNamedGamut::kDisplayP3, &rgb_input);
  return std::make_tuple(xyz_output.vals[0], xyz_output.vals[1], xyz_output.vals[2]);
}

std::tuple<float, float, float> XYZD50ToDisplayP3(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 rgb_output = skcms_Matrix3x3_apply(getXYZD50toDisplayP3Matrix(), &xyz_input);
  return ApplyInverseTransferFnsRGB(rgb_output.vals[0], rgb_output.vals[1], rgb_output.vals[2]);
}

std::tuple<float, float, float> ProPhotoToXYZD50(float r, float g, float b) {
  auto [r_, g_, b_] = ApplyTransferFnProPhoto(r, g, b);
  skcms_Vector3 rgb_input{{r_, g_, b_}};
  skcms_Vector3 xyz_output = skcms_Matrix3x3_apply(getProPhotoRGBtoXYZD50Matrix(), &rgb_input);
  return std::make_tuple(xyz_output.vals[0], xyz_output.vals[1], xyz_output.vals[2]);
}

std::tuple<float, float, float> XYZD50ToProPhoto(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 rgb_output = skcms_Matrix3x3_apply(getXYZD50toProPhotoRGBMatrix(), &xyz_input);
  return ApplyInverseTransferFnProPhoto(rgb_output.vals[0], rgb_output.vals[1], rgb_output.vals[2]);
}

std::tuple<float, float, float> AdobeRGBToXYZD50(float r, float g, float b) {
  auto [r_, g_, b_] = ApplyTransferFnAdobeRGB(r, g, b);
  skcms_Vector3 rgb_input{{r_, g_, b_}};
  skcms_Vector3 xyz_output = skcms_Matrix3x3_apply(&SkNamedGamut::kAdobeRGB, &rgb_input);
  return std::make_tuple(xyz_output.vals[0], xyz_output.vals[1], xyz_output.vals[2]);
}

std::tuple<float, float, float> XYZD50ToAdobeRGB(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 rgb_output = skcms_Matrix3x3_apply(getXYZD50toAdobeRGBMatrix(), &xyz_input);
  return ApplyInverseTransferFnAdobeRGB(rgb_output.vals[0], rgb_output.vals[1], rgb_output.vals[2]);
}

std::tuple<float, float, float> Rec2020ToXYZD50(float r, float g, float b) {
  auto [r_, g_, b_] = ApplyTransferFnRec2020(r, g, b);
  skcms_Vector3 rgb_input{{r_, g_, b_}};
  skcms_Vector3 xyz_output = skcms_Matrix3x3_apply(&SkNamedGamut::kRec2020, &rgb_input);
  return std::make_tuple(xyz_output.vals[0], xyz_output.vals[1], xyz_output.vals[2]);
}

std::tuple<float, float, float> XYZD50ToRec2020(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 rgb_output = skcms_Matrix3x3_apply(getXYZD50toRec2020Matrix(), &xyz_input);
  return ApplyInverseTransferFnRec2020(rgb_output.vals[0], rgb_output.vals[1], rgb_output.vals[2]);
}

std::tuple<float, float, float> XYZD50ToD65(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 xyz_output = skcms_Matrix3x3_apply(getXYDZ50toXYZD65matrix(), &xyz_input);
  return std::make_tuple(xyz_output.vals[0], xyz_output.vals[1], xyz_output.vals[2]);
}

std::tuple<float, float, float> XYZD65ToD50(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 xyz_output = skcms_Matrix3x3_apply(getXYDZ65toXYZD50matrix(), &xyz_input);
  return std::make_tuple(xyz_output.vals[0], xyz_output.vals[1], xyz_output.vals[2]);
}

std::tuple<float, float, float> SRGBToSRGBLegacy(float r, float g, float b) {
  return std::make_tuple(r * 255.0, g * 255.0, b * 255.0);
}

std::tuple<float, float, float> SRGBLegacyToSRGB(float r, float g, float b) {
  return std::make_tuple(r / 255.0, g / 255.0, b / 255.0);
}

std::tuple<float, float, float> XYZD50TosRGB(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 rgb_result = skcms_Matrix3x3_apply(getXYZD50TosRGBLinearMatrix(), &xyz_input);
  return ApplyInverseTransferFnsRGB(rgb_result.vals[0], rgb_result.vals[1], rgb_result.vals[2]);
}

std::tuple<float, float, float> XYZD65TosRGBLinear(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 rgb_result = skcms_Matrix3x3_apply(getXYZD65tosRGBLinearMatrix(), &xyz_input);
  return std::make_tuple(rgb_result.vals[0], rgb_result.vals[1], rgb_result.vals[2]);
}

std::tuple<float, float, float> XYZD50TosRGBLinear(float x, float y, float z) {
  skcms_Vector3 xyz_input{{x, y, z}};
  skcms_Vector3 rgb_result = skcms_Matrix3x3_apply(getXYZD50TosRGBLinearMatrix(), &xyz_input);
  return std::make_tuple(rgb_result.vals[0], rgb_result.vals[1], rgb_result.vals[2]);
}

std::tuple<float, float, float> SRGBLinearToXYZD50(float r, float g, float b) {
  skcms_Vector3 rgb_input{{r, g, b}};
  skcms_Vector3 xyz_output = skcms_Matrix3x3_apply(&SkNamedGamut::kSRGB, &rgb_input);
  return std::make_tuple(xyz_output.vals[0], xyz_output.vals[1], xyz_output.vals[2]);
}

std::tuple<float, float, float> SRGBToXYZD50(float r, float g, float b) {
  auto [r_, g_, b_] = ApplyTransferFnsRGB(r, g, b);
  skcms_Vector3 rgb_input{{r_, g_, b_}};
  skcms_Vector3 xyz_output = skcms_Matrix3x3_apply(&SkNamedGamut::kSRGB, &rgb_input);
  return std::make_tuple(xyz_output.vals[0], xyz_output.vals[1], xyz_output.vals[2]);
}

std::tuple<float, float, float> HSLToSRGB(float h, float s, float l) {
  // See https://www.w3.org/TR/css-color-4/#hsl-to-rgb
  if (!s) {
    return std::make_tuple(l, l, l);
  }

  auto f = [&h, &l, &s](float n) {
    float k = fmod(n + h / 30.0f, 12.0);
    float a = s * std::min(l, 1.0f - l);
    return l - a * std::max(-1.0f, std::min({k - 3.0f, 9.0f - k, 1.0f}));
  };

  return std::make_tuple(f(0), f(8), f(4));
}

std::tuple<float, float, float> SRGBToHSL(float r, float g, float b) {
  // See https://www.w3.org/TR/css-color-4/#rgb-to-hsl
  auto [min, max] = std::minmax({r, g, b});
  float hue = 0.0f, saturation = 0.0f, lightness = std::midpoint(min, max);
  float d = max - min;

  if (d != 0.0f) {
    saturation =
        (lightness == 0.0f || lightness == 1.0f) ? 0.0f : (max - lightness) / std::min(lightness, 1 - lightness);
    if (max == r) {
      hue = (g - b) / d + (g < b ? 6.0f : 0.0f);
    } else if (max == g) {
      hue = (b - r) / d + 2.0f;
    } else {  // if(max == b)
      hue = (r - g) / d + 4.0f;
    }
    hue *= 60.0f;
  }

  return std::make_tuple(hue, saturation, lightness);
}

std::tuple<float, float, float> HWBToSRGB(float h, float w, float b) {
  if (w + b >= 1.0f) {
    float gray = (w / (w + b));
    return std::make_tuple(gray, gray, gray);
  }

  // Leverage HSL to RGB conversion to find HWB to RGB, see
  // https://drafts.csswg.org/css-color-4/#hwb-to-rgb
  auto [red, green, blue] = HSLToSRGB(h, 1.0f, 0.5f);

  red += w - (w + b) * red;
  green += w - (w + b) * green;
  blue += w - (w + b) * blue;

  return std::make_tuple(red, green, blue);
}

std::tuple<float, float, float> SRGBToHWB(float r, float g, float b) {
  // Leverage RGB to HSL conversion to find RGB to HWB, see
  // https://www.w3.org/TR/css-color-4/#rgb-to-hwb
  auto [hue, saturation, light] = SRGBToHSL(r, g, b);
  float white = std::min({r, g, b});
  float black = 1.0f - std::max({r, g, b});

  return std::make_tuple(hue, white, black);
}

SkColor4f SRGBLinearToSkColor4f(float r, float g, float b, float alpha) {
  auto [srgb_r, srgb_g, srgb_b] = ApplyInverseTransferFnsRGB(r, g, b);
  return SkColor4f{srgb_r, srgb_g, srgb_b, alpha};
}

SkColor4f XYZD50ToSkColor4f(float x, float y, float z, float alpha) {
  auto [r, g, b] = XYZD50TosRGBLinear(x, y, z);
  return SRGBLinearToSkColor4f(r, g, b, alpha);
}

SkColor4f XYZD65ToSkColor4f(float x, float y, float z, float alpha) {
  auto [r, g, b] = XYZD65TosRGBLinear(x, y, z);
  return SRGBLinearToSkColor4f(r, g, b, alpha);
}

SkColor4f LabToSkColor4f(float l, float a, float b, float alpha) {
  auto [x, y, z] = LabToXYZD50(l, a, b);
  return XYZD50ToSkColor4f(x, y, z, alpha);
}

SkColor4f ProPhotoToSkColor4f(float r, float g, float b, float alpha) {
  auto [x, y, z] = ProPhotoToXYZD50(r, g, b);
  return XYZD50ToSkColor4f(x, y, z, alpha);
}

SkColor4f OklabToSkColor4f(float l, float a, float b, float alpha) {
  auto [x, y, z] = OklabToXYZD65(l, a, b);
  return XYZD65ToSkColor4f(x, y, z, alpha);
}

SkColor4f OklabGamutMapToSkColor4f(float l, float a, float b, float alpha) {
  auto [l_gm, a_gm, b_gm] = OklabGamutMap(l, a, b);
  auto [x, y, z] = OklabToXYZD65(l_gm, a_gm, b_gm);
  return XYZD65ToSkColor4f(x, y, z, alpha);
}

SkColor4f DisplayP3ToSkColor4f(float r, float g, float b, float alpha) {
  auto [x, y, z] = DisplayP3ToXYZD50(r, g, b);
  return XYZD50ToSkColor4f(x, y, z, alpha);
}

SkColor4f LchToSkColor4f(float l_input, float c, float h, float alpha) {
  auto [l, a, b] = LchToLab(l_input, c, h);
  auto [x, y, z] = LabToXYZD50(l, a, b);
  return XYZD50ToSkColor4f(x, y, z, alpha);
}
SkColor4f AdobeRGBToSkColor4f(float r, float g, float b, float alpha) {
  auto [x, y, z] = AdobeRGBToXYZD50(r, g, b);
  return XYZD50ToSkColor4f(x, y, z, alpha);
}

SkColor4f Rec2020ToSkColor4f(float r, float g, float b, float alpha) {
  auto [x, y, z] = Rec2020ToXYZD50(r, g, b);
  return XYZD50ToSkColor4f(x, y, z, alpha);
}

SkColor4f OklchToSkColor4f(float l_input, float c, float h, float alpha) {
  auto [l, a, b] = LchToLab(l_input, c, h);
  auto [x, y, z] = OklabToXYZD65(l, a, b);
  return XYZD65ToSkColor4f(x, y, z, alpha);
}

SkColor4f OklchGamutMapToSkColor4f(float l_input, float c, float h, float alpha) {
  auto [l, a, b] = LchToLab(l_input, c, h);
  auto [l_gm, a_gm, b_gm] = OklabGamutMap(l, a, b);
  auto [x, y, z] = OklabToXYZD65(l_gm, a_gm, b_gm);
  return XYZD65ToSkColor4f(x, y, z, alpha);
}

SkColor4f HSLToSkColor4f(float h, float s, float l, float alpha) {
  auto [r, g, b] = HSLToSRGB(h, s, l);
  return SkColor4f{r, g, b, alpha};
}

SkColor4f HWBToSkColor4f(float h, float w, float b, float alpha) {
  auto [red, green, blue] = HWBToSRGB(h, w, b);
  return SkColor4f{red, green, blue, alpha};
}

}  // namespace webf