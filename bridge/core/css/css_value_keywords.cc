/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#if !((' ' == 32) && ('!' == 33) && ('"' == 34) && ('#' == 35) \
      && ('%' == 37) && ('&' == 38) && ('\'' == 39) && ('(' == 40) \
      && (')' == 41) && ('*' == 42) && ('+' == 43) && (',' == 44) \
      && ('-' == 45) && ('.' == 46) && ('/' == 47) && ('0' == 48) \
      && ('1' == 49) && ('2' == 50) && ('3' == 51) && ('4' == 52) \
      && ('5' == 53) && ('6' == 54) && ('7' == 55) && ('8' == 56) \
      && ('9' == 57) && (':' == 58) && (';' == 59) && ('<' == 60) \
      && ('=' == 61) && ('>' == 62) && ('?' == 63) && ('A' == 65) \
      && ('B' == 66) && ('C' == 67) && ('D' == 68) && ('E' == 69) \
      && ('F' == 70) && ('G' == 71) && ('H' == 72) && ('I' == 73) \
      && ('J' == 74) && ('K' == 75) && ('L' == 76) && ('M' == 77) \
      && ('N' == 78) && ('O' == 79) && ('P' == 80) && ('Q' == 81) \
      && ('R' == 82) && ('S' == 83) && ('T' == 84) && ('U' == 85) \
      && ('V' == 86) && ('W' == 87) && ('X' == 88) && ('Y' == 89) \
      && ('Z' == 90) && ('[' == 91) && ('\\' == 92) && (']' == 93) \
      && ('^' == 94) && ('_' == 95) && ('a' == 97) && ('b' == 98) \
      && ('c' == 99) && ('d' == 100) && ('e' == 101) && ('f' == 102) \
      && ('g' == 103) && ('h' == 104) && ('i' == 105) && ('j' == 106) \
      && ('k' == 107) && ('l' == 108) && ('m' == 109) && ('n' == 110) \
      && ('o' == 111) && ('p' == 112) && ('q' == 113) && ('r' == 114) \
      && ('s' == 115) && ('t' == 116) && ('u' == 117) && ('v' == 118) \
      && ('w' == 119) && ('x' == 120) && ('y' == 121) && ('z' == 122) \
      && ('{' == 123) && ('|' == 124) && ('}' == 125) && ('~' == 126))
/* The character set is not based on ISO-646.  */
#error "gperf generated tables don't work with this execution character set. Please report a bug to <bug-gperf@gnu.org>."
#endif

#include "css_value_keywords.h"

#include <string.h>
#include <cassert>
#include "core/css/hash_tools.h"

namespace webf {

static const char valueListStringPool[] = {
    "inherit\0"
    "initial\0"
    "none\0"
    "hidden\0"
    "inset\0"
    "groove\0"
    "outset\0"
    "ridge\0"
    "dotted\0"
    "dashed\0"
    "solid\0"
    "double\0"
    "caption\0"
    "icon\0"
    "menu\0"
    "message-box\0"
    "small-caption\0"
    "-webkit-mini-control\0"
    "-webkit-small-control\0"
    "-webkit-control\0"
    "status-bar\0"
    "italic\0"
    "oblique\0"
    "all\0"
    "common-ligatures\0"
    "no-common-ligatures\0"
    "discretionary-ligatures\0"
    "no-discretionary-ligatures\0"
    "historical-ligatures\0"
    "no-historical-ligatures\0"
    "contextual\0"
    "no-contextual\0"
    "small-caps\0"
    "all-small-caps\0"
    "petite-caps\0"
    "all-petite-caps\0"
    "unicase\0"
    "titling-caps\0"
    "jis78\0"
    "jis83\0"
    "jis90\0"
    "jis04\0"
    "simplified\0"
    "traditional\0"
    "full-width\0"
    "proportional-width\0"
    "ruby\0"
    "lining-nums\0"
    "oldstyle-nums\0"
    "proportional-nums\0"
    "tabular-nums\0"
    "diagonal-fractions\0"
    "stacked-fractions\0"
    "ordinal\0"
    "slashed-zero\0"
    "stylistic\0"
    "historical-forms\0"
    "styleset\0"
    "character-variant\0"
    "swash\0"
    "ornaments\0"
    "annotation\0"
    "normal\0"
    "bold\0"
    "bolder\0"
    "lighter\0"
    "weight\0"
    "ultra-condensed\0"
    "extra-condensed\0"
    "condensed\0"
    "semi-condensed\0"
    "semi-expanded\0"
    "expanded\0"
    "extra-expanded\0"
    "ultra-expanded\0"
    "xx-small\0"
    "x-small\0"
    "small\0"
    "medium\0"
    "large\0"
    "x-large\0"
    "xx-large\0"
    "xxx-large\0"
    "smaller\0"
    "larger\0"
    "-webkit-xxx-large\0"
    "ex-height\0"
    "cap-height\0"
    "ch-width\0"
    "ic-width\0"
    "ic-height\0"
    "serif\0"
    "sans-serif\0"
    "cursive\0"
    "fantasy\0"
    "monospace\0"
    "system-ui\0"
    "-webkit-body\0"
    "math\0"
    "swap\0"
    "fallback\0"
    "optional\0"
    "font-tech\0"
    "font-format\0"
    "emoji\0"
    "unicode\0"
    "palette-mix\0"
    "aqua\0"
    "black\0"
    "blue\0"
    "fuchsia\0"
    "gray\0"
    "green\0"
    "lime\0"
    "maroon\0"
    "navy\0"
    "olive\0"
    "orange\0"
    "purple\0"
    "red\0"
    "silver\0"
    "teal\0"
    "white\0"
    "yellow\0"
    "transparent\0"
    "-webkit-link\0"
    "-webkit-activelink\0"
    "accentcolor\0"
    "accentcolortext\0"
    "activeborder\0"
    "activecaption\0"
    "activetext\0"
    "appworkspace\0"
    "background\0"
    "buttonborder\0"
    "buttonface\0"
    "buttonhighlight\0"
    "buttonshadow\0"
    "buttontext\0"
    "canvas\0"
    "canvastext\0"
    "captiontext\0"
    "field\0"
    "fieldtext\0"
    "graytext\0"
    "highlight\0"
    "highlighttext\0"
    "inactiveborder\0"
    "inactivecaption\0"
    "inactivecaptiontext\0"
    "infobackground\0"
    "infotext\0"
    "linktext\0"
    "mark\0"
    "marktext\0"
    "menutext\0"
    "selecteditem\0"
    "selecteditemtext\0"
    "scrollbar\0"
    "threeddarkshadow\0"
    "threedface\0"
    "threedhighlight\0"
    "threedlightshadow\0"
    "threedshadow\0"
    "visitedtext\0"
    "window\0"
    "windowframe\0"
    "windowtext\0"
    "-internal-active-list-box-selection\0"
    "-internal-active-list-box-selection-text\0"
    "-internal-inactive-list-box-selection\0"
    "-internal-inactive-list-box-selection-text\0"
    "-webkit-focus-ring-color\0"
    "currentcolor\0"
    "grey\0"
    "-internal-quirk-inherit\0"
    "-internal-spelling-error-color\0"
    "-internal-grammar-error-color\0"
    "-internal-search-color\0"
    "-internal-search-text-color\0"
    "-internal-current-search-color\0"
    "-internal-current-search-text-color\0"
    "aliceblue\0"
    "antiquewhite\0"
    "aquamarine\0"
    "azure\0"
    "beige\0"
    "bisque\0"
    "blanchedalmond\0"
    "blueviolet\0"
    "brown\0"
    "burlywood\0"
    "cadetblue\0"
    "chartreuse\0"
    "chocolate\0"
    "coral\0"
    "cornflowerblue\0"
    "cornsilk\0"
    "crimson\0"
    "cyan\0"
    "darkblue\0"
    "darkcyan\0"
    "darkgoldenrod\0"
    "darkgray\0"
    "darkgreen\0"
    "darkgrey\0"
    "darkkhaki\0"
    "darkmagenta\0"
    "darkolivegreen\0"
    "darkorange\0"
    "darkorchid\0"
    "darkred\0"
    "darksalmon\0"
    "darkseagreen\0"
    "darkslateblue\0"
    "darkslategray\0"
    "darkslategrey\0"
    "darkturquoise\0"
    "darkviolet\0"
    "deeppink\0"
    "deepskyblue\0"
    "dimgray\0"
    "dimgrey\0"
    "dodgerblue\0"
    "firebrick\0"
    "floralwhite\0"
    "forestgreen\0"
    "gainsboro\0"
    "ghostwhite\0"
    "gold\0"
    "goldenrod\0"
    "greenyellow\0"
    "honeydew\0"
    "hotpink\0"
    "indianred\0"
    "indigo\0"
    "ivory\0"
    "khaki\0"
    "lavender\0"
    "lavenderblush\0"
    "lawngreen\0"
    "lemonchiffon\0"
    "lightblue\0"
    "lightcoral\0"
    "lightcyan\0"
    "lightgoldenrodyellow\0"
    "lightgray\0"
    "lightgreen\0"
    "lightgrey\0"
    "lightpink\0"
    "lightsalmon\0"
    "lightseagreen\0"
    "lightskyblue\0"
    "lightslategray\0"
    "lightslategrey\0"
    "lightsteelblue\0"
    "lightyellow\0"
    "limegreen\0"
    "linen\0"
    "magenta\0"
    "mediumaquamarine\0"
    "mediumblue\0"
    "mediumorchid\0"
    "mediumpurple\0"
    "mediumseagreen\0"
    "mediumslateblue\0"
    "mediumspringgreen\0"
    "mediumturquoise\0"
    "mediumvioletred\0"
    "midnightblue\0"
    "mintcream\0"
    "mistyrose\0"
    "moccasin\0"
    "navajowhite\0"
    "oldlace\0"
    "olivedrab\0"
    "orangered\0"
    "orchid\0"
    "palegoldenrod\0"
    "palegreen\0"
    "paleturquoise\0"
    "palevioletred\0"
    "papayawhip\0"
    "peachpuff\0"
    "peru\0"
    "pink\0"
    "plum\0"
    "powderblue\0"
    "rebeccapurple\0"
    "rosybrown\0"
    "royalblue\0"
    "saddlebrown\0"
    "salmon\0"
    "sandybrown\0"
    "seagreen\0"
    "seashell\0"
    "sienna\0"
    "skyblue\0"
    "slateblue\0"
    "slategray\0"
    "slategrey\0"
    "snow\0"
    "springgreen\0"
    "steelblue\0"
    "tan\0"
    "thistle\0"
    "tomato\0"
    "turquoise\0"
    "violet\0"
    "wheat\0"
    "whitesmoke\0"
    "yellowgreen\0"
    "repeat\0"
    "repeat-x\0"
    "repeat-y\0"
    "no-repeat\0"
    "clear\0"
    "copy\0"
    "source-over\0"
    "source-in\0"
    "source-out\0"
    "source-atop\0"
    "destination-over\0"
    "destination-in\0"
    "destination-out\0"
    "destination-atop\0"
    "xor\0"
    "plus-lighter\0"
    "subtract\0"
    "intersect\0"
    "exclude\0"
    "baseline\0"
    "middle\0"
    "sub\0"
    "super\0"
    "text-top\0"
    "text-bottom\0"
    "top\0"
    "bottom\0"
    "-webkit-baseline-middle\0"
    "-webkit-auto\0"
    "left\0"
    "right\0"
    "center\0"
    "justify\0"
    "-webkit-left\0"
    "-webkit-right\0"
    "-webkit-center\0"
    "-webkit-match-parent\0"
    "-internal-center\0"
    "inline-start\0"
    "inline-end\0"
    "outside\0"
    "inside\0"
    "disc\0"
    "circle\0"
    "square\0"
    "disclosure-open\0"
    "disclosure-closed\0"
    "decimal\0"
    "inline\0"
    "block\0"
    "flow-root\0"
    "flow\0"
    "table\0"
    "flex\0"
    "grid\0"
    "contents\0"
    "table-row-group\0"
    "table-header-group\0"
    "table-footer-group\0"
    "table-row\0"
    "table-column-group\0"
    "table-column\0"
    "table-cell\0"
    "table-caption\0"
    "ruby-text\0"
    "inline-block\0"
    "inline-table\0"
    "inline-flex\0"
    "inline-grid\0"
    "-webkit-box\0"
    "-webkit-inline-box\0"
    "-webkit-flex\0"
    "-webkit-inline-flex\0"
    "layout\0"
    "inline-layout\0"
    "list-item\0"
    "auto\0"
    "crosshair\0"
    "default\0"
    "pointer\0"
    "move\0"
    "vertical-text\0"
    "cell\0"
    "context-menu\0"
    "alias\0"
    "progress\0"
    "no-drop\0"
    "not-allowed\0"
    "zoom-in\0"
    "zoom-out\0"
    "e-resize\0"
    "ne-resize\0"
    "nw-resize\0"
    "n-resize\0"
    "se-resize\0"
    "sw-resize\0"
    "s-resize\0"
    "w-resize\0"
    "ew-resize\0"
    "ns-resize\0"
    "nesw-resize\0"
    "nwse-resize\0"
    "col-resize\0"
    "row-resize\0"
    "text\0"
    "wait\0"
    "help\0"
    "all-scroll\0"
    "grab\0"
    "grabbing\0"
    "-webkit-grab\0"
    "-webkit-grabbing\0"
    "-webkit-zoom-in\0"
    "-webkit-zoom-out\0"
    "ltr\0"
    "rtl\0"
    "capitalize\0"
    "uppercase\0"
    "lowercase\0"
    "math-auto\0"
    "visible\0"
    "collapse\0"
    "preserve\0"
    "preserve-breaks\0"
    "pretty\0"
    "a3\0"
    "a4\0"
    "a5\0"
    "above\0"
    "absolute\0"
    "always\0"
    "avoid\0"
    "b4\0"
    "b5\0"
    "below\0"
    "bidi-override\0"
    "blink\0"
    "both\0"
    "break-spaces\0"
    "close-quote\0"
    "embed\0"
    "fixed\0"
    "hand\0"
    "hide\0"
    "isolate\0"
    "isolate-override\0"
    "plaintext\0"
    "-webkit-isolate\0"
    "-webkit-isolate-override\0"
    "-webkit-plaintext\0"
    "jis-b5\0"
    "jis-b4\0"
    "landscape\0"
    "ledger\0"
    "legal\0"
    "letter\0"
    "line-through\0"
    "local\0"
    "no-close-quote\0"
    "no-open-quote\0"
    "nowrap\0"
    "open-quote\0"
    "overlay\0"
    "overline\0"
    "portrait\0"
    "pre\0"
    "pre-line\0"
    "pre-wrap\0"
    "relative\0"
    "scroll\0"
    "separate\0"
    "show\0"
    "static\0"
    "thick\0"
    "thin\0"
    "underline\0"
    "view\0"
    "wavy\0"
    "compact\0"
    "stretch\0"
    "start\0"
    "end\0"
    "clone\0"
    "slice\0"
    "reverse\0"
    "horizontal\0"
    "vertical\0"
    "inline-axis\0"
    "block-axis\0"
    "flex-start\0"
    "flex-end\0"
    "space-between\0"
    "space-around\0"
    "space-evenly\0"
    "unsafe\0"
    "safe\0"
    "anchor-center\0"
    "row\0"
    "row-reverse\0"
    "column\0"
    "column-reverse\0"
    "wrap\0"
    "wrap-reverse\0"
    "auto-flow\0"
    "dense\0"
    "read-only\0"
    "read-write\0"
    "read-write-plaintext-only\0"
    "element\0"
    "-webkit-min-content\0"
    "-webkit-max-content\0"
    "-webkit-fill-available\0"
    "-webkit-fit-content\0"
    "min-content\0"
    "max-content\0"
    "fit-content\0"
    "no-autospace\0"
    "cap\0"
    "ex\0"
    "leading\0"
    "clip\0"
    "ellipsis\0"
    "spelling-error\0"
    "grammar-error\0"
    "from-font\0"
    "space-all\0"
    "space-first\0"
    "trim-start\0"
    "break-all\0"
    "keep-all\0"
    "auto-phrase\0"
    "break-word\0"
    "space\0"
    "loose\0"
    "strict\0"
    "after-white-space\0"
    "anywhere\0"
    "manual\0"
    "checkbox\0"
    "radio\0"
    "button\0"
    "listbox\0"
    "-internal-media-control\0"
    "menulist\0"
    "menulist-button\0"
    "meter\0"
    "progress-bar\0"
    "searchfield\0"
    "textfield\0"
    "textarea\0"
    "inner-spin-button\0"
    "push-button\0"
    "square-button\0"
    "slider-horizontal\0"
    "searchfield-cancel-button\0"
    "slider-vertical\0"
    "round\0"
    "base-select\0"
    "-internal-appearance-auto-base-select\0"
    "border\0"
    "border-box\0"
    "content\0"
    "content-box\0"
    "padding\0"
    "padding-box\0"
    "margin-box\0"
    "no-clip\0"
    "contain\0"
    "cover\0"
    "logical\0"
    "visual\0"
    "replace\0"
    "accumulate\0"
    "alternate\0"
    "alternate-reverse\0"
    "forwards\0"
    "backwards\0"
    "infinite\0"
    "running\0"
    "paused\0"
    "flat\0"
    "preserve-3d\0"
    "fill-box\0"
    "view-box\0"
    "ease\0"
    "linear\0"
    "ease-in\0"
    "ease-out\0"
    "ease-in-out\0"
    "jump-both\0"
    "jump-end\0"
    "jump-none\0"
    "jump-start\0"
    "step-start\0"
    "step-end\0"
    "steps\0"
    "frames\0"
    "cubic-bezier\0"
    "document\0"
    "reset\0"
    "zoom\0"
    "visiblepainted\0"
    "visiblefill\0"
    "visiblestroke\0"
    "painted\0"
    "fill\0"
    "stroke\0"
    "bounding-box\0"
    "spell-out\0"
    "digits\0"
    "literal-punctuation\0"
    "no-punctuation\0"
    "antialiased\0"
    "subpixel-antialiased\0"
    "optimizespeed\0"
    "optimizelegibility\0"
    "geometricprecision\0"
    "crispedges\0"
    "economy\0"
    "exact\0"
    "lr\0"
    "rl\0"
    "tb\0"
    "lr-tb\0"
    "rl-tb\0"
    "tb-rl\0"
    "horizontal-tb\0"
    "vertical-rl\0"
    "vertical-lr\0"
    "after\0"
    "before\0"
    "inter-character\0"
    "over\0"
    "under\0"
    "filled\0"
    "open\0"
    "dot\0"
    "double-circle\0"
    "triangle\0"
    "sesame\0"
    "ellipse\0"
    "closest-side\0"
    "closest-corner\0"
    "farthest-side\0"
    "farthest-corner\0"
    "mixed\0"
    "sideways\0"
    "sideways-right\0"
    "upright\0"
    "vertical-right\0"
    "on\0"
    "off\0"
    "optimizequality\0"
    "pixelated\0"
    "-webkit-optimize-contrast\0"
    "from-image\0"
    "rotate-left\0"
    "rotate-right\0"
    "nonzero\0"
    "evenodd\0"
    "at\0"
    "alphabetic\0"
    "borderless\0"
    "fullscreen\0"
    "standalone\0"
    "minimal-ui\0"
    "browser\0"
    "window-controls-overlay\0"
    "tabbed\0"
    "picture-in-picture\0"
    "minimized\0"
    "maximized\0"
    "paged\0"
    "slow\0"
    "fast\0"
    "sticky\0"
    "coarse\0"
    "fine\0"
    "on-demand\0"
    "hover\0"
    "multiply\0"
    "screen\0"
    "darken\0"
    "lighten\0"
    "color-dodge\0"
    "color-burn\0"
    "hard-light\0"
    "soft-light\0"
    "difference\0"
    "exclusion\0"
    "hue\0"
    "saturation\0"
    "color\0"
    "luminosity\0"
    "scale-down\0"
    "balance\0"
    "drag\0"
    "no-drag\0"
    "span\0"
    "minmax\0"
    "subgrid\0"
    "progressive\0"
    "interlace\0"
    "markers\0"
    "alpha\0"
    "luminance\0"
    "match-source\0"
    "srgb\0"
    "linearrgb\0"
    "butt\0"
    "miter\0"
    "bevel\0"
    "before-edge\0"
    "after-edge\0"
    "central\0"
    "text-before-edge\0"
    "text-after-edge\0"
    "ideographic\0"
    "hanging\0"
    "mathematical\0"
    "use-script\0"
    "no-change\0"
    "reset-size\0"
    "dynamic\0"
    "non-scaling-stroke\0"
    "-internal-extend-to-zoom\0"
    "pan-x\0"
    "pan-y\0"
    "pan-left\0"
    "pan-right\0"
    "pan-up\0"
    "pan-down\0"
    "manipulation\0"
    "pinch-zoom\0"
    "last-baseline\0"
    "first-baseline\0"
    "first\0"
    "last\0"
    "self-start\0"
    "self-end\0"
    "legacy\0"
    "smooth\0"
    "scroll-position\0"
    "revert\0"
    "revert-layer\0"
    "unset\0"
    "linear-gradient\0"
    "radial-gradient\0"
    "conic-gradient\0"
    "repeating-linear-gradient\0"
    "repeating-radial-gradient\0"
    "repeating-conic-gradient\0"
    "paint\0"
    "cross-fade\0"
    "-webkit-cross-fade\0"
    "-webkit-gradient\0"
    "-webkit-linear-gradient\0"
    "-webkit-radial-gradient\0"
    "-webkit-repeating-linear-gradient\0"
    "-webkit-repeating-radial-gradient\0"
    "-webkit-image-set\0"
    "image-set\0"
    "type\0"
    "to\0"
    "color-stop\0"
    "radial\0"
    "attr\0"
    "counter\0"
    "counters\0"
    "rect\0"
    "polygon\0"
    "format\0"
    "collection\0"
    "embedded-opentype\0"
    "opentype\0"
    "svg\0"
    "truetype\0"
    "woff\0"
    "woff2\0"
    "tech\0"
    "features-opentype\0"
    "features-aat\0"
    "features-graphite\0"
    "color-COLRv0\0"
    "color-COLRv1\0"
    "color-SVG\0"
    "color-sbix\0"
    "color-CBDT\0"
    "variations\0"
    "palettes\0"
    "incremental\0"
    "invert\0"
    "grayscale\0"
    "sepia\0"
    "saturate\0"
    "hue-rotate\0"
    "opacity\0"
    "brightness\0"
    "contrast\0"
    "blur\0"
    "drop-shadow\0"
    "url\0"
    "rgb\0"
    "rgba\0"
    "hsl\0"
    "hsla\0"
    "hwb\0"
    "lab\0"
    "oklab\0"
    "lch\0"
    "oklch\0"
    "light-dark\0"
    "srgb-linear\0"
    "display-p3\0"
    "a98-rgb\0"
    "prophoto-rgb\0"
    "xyz\0"
    "xyz-d50\0"
    "xyz-d65\0"
    "shorter\0"
    "longer\0"
    "decreasing\0"
    "increasing\0"
    "in\0"
    "color-mix\0"
    "from\0"
    "r\0"
    "g\0"
    "b\0"
    "h\0"
    "s\0"
    "l\0"
    "w\0"
    "a\0"
    "c\0"
    "matrix\0"
    "matrix3d\0"
    "perspective\0"
    "rotate\0"
    "rotateX\0"
    "rotateY\0"
    "rotateZ\0"
    "rotate3d\0"
    "scale\0"
    "scaleX\0"
    "scaleY\0"
    "scaleZ\0"
    "scale3d\0"
    "skew\0"
    "skewX\0"
    "skewY\0"
    "translate\0"
    "translateX\0"
    "translateY\0"
    "translateZ\0"
    "translate3d\0"
    "x\0"
    "y\0"
    "z\0"
    "path\0"
    "ray\0"
    "sides\0"
    "stroke-box\0"
    "calc\0"
    "-webkit-calc\0"
    "min\0"
    "max\0"
    "clamp\0"
    "calc-size\0"
    "any\0"
    "sin\0"
    "cos\0"
    "asin\0"
    "atan\0"
    "atan2\0"
    "acos\0"
    "mod\0"
    "rem\0"
    "up\0"
    "down\0"
    "to-zero\0"
    "sign\0"
    "abs\0"
    "pow\0"
    "sqrt\0"
    "hypot\0"
    "log\0"
    "exp\0"
    "infinity\0"
    "-infinity\0"
    "nan\0"
    "pi\0"
    "e\0"
    "mandatory\0"
    "proximity\0"
    "style\0"
    "size\0"
    "block-size\0"
    "inline-size\0"
    "scroll-state\0"
    "inset-block-start\0"
    "inset-block-end\0"
    "inset-inline-start\0"
    "inset-inline-end\0"
    "auto-fill\0"
    "auto-fit\0"
    "var\0"
    "-internal-variable-value\0"
    "env\0"
    "arg\0"
    "avoid-page\0"
    "page\0"
    "recto\0"
    "verso\0"
    "avoid-column\0"
    "p3\0"
    "rec2020\0"
    "add\0"
    "auto-add\0"
    "true\0"
    "false\0"
    "no-preference\0"
    "dark\0"
    "light\0"
    "only\0"
    "reduce\0"
    "active\0"
    "preserve-parent-color\0"
    "back-button\0"
    "fabricated\0"
    "selector\0"
    "continuous\0"
    "folded\0"
    "stable\0"
    "both-edges\0"
    "more\0"
    "less\0"
    "custom\0"
    "cyclic\0"
    "symbolic\0"
    "numeric\0"
    "additive\0"
    "extends\0"
    "-internal-simp-chinese-informal\0"
    "-internal-simp-chinese-formal\0"
    "-internal-trad-chinese-informal\0"
    "-internal-trad-chinese-formal\0"
    "-internal-korean-hangul-formal\0"
    "-internal-korean-hanja-informal\0"
    "-internal-korean-hanja-formal\0"
    "-internal-hebrew\0"
    "-internal-lower-armenian\0"
    "-internal-upper-armenian\0"
    "-internal-ethiopic-numeric\0"
    "bullets\0"
    "numbers\0"
    "words\0"
    "standard\0"
    "high\0"
    "constrained-high\0"
    "dynamic-range-limit-mix\0"
    "layer\0"
    "supports\0"
    "color-contrast\0"
    "vs\0"
    "AA\0"
    "AA-large\0"
    "AAA\0"
    "AAA-large\0"
    "drop\0"
    "raise\0"
    "xywh\0"
    "anchor\0"
    "anchor-size\0"
    "width\0"
    "height\0"
    "self-block\0"
    "self-inline\0"
    "entry\0"
    "exit\0"
    "entry-crossing\0"
    "exit-crossing\0"
    "root\0"
    "nearest\0"
    "self\0"
    "allow-discrete\0"
    "inverted\0"
    "enabled\0"
    "initial-only\0"
    "span-left\0"
    "span-right\0"
    "x-start\0"
    "x-end\0"
    "span-x-start\0"
    "span-x-end\0"
    "x-self-start\0"
    "x-self-end\0"
    "span-x-self-start\0"
    "span-x-self-end\0"
    "span-all\0"
    "span-top\0"
    "span-bottom\0"
    "y-start\0"
    "y-end\0"
    "span-y-start\0"
    "span-y-end\0"
    "y-self-start\0"
    "y-self-end\0"
    "span-y-self-start\0"
    "span-y-self-end\0"
    "block-start\0"
    "block-end\0"
    "span-block-start\0"
    "span-block-end\0"
    "self-block-start\0"
    "self-block-end\0"
    "span-self-block-start\0"
    "span-self-block-end\0"
    "span-inline-start\0"
    "span-inline-end\0"
    "self-inline-start\0"
    "self-inline-end\0"
    "span-self-inline-start\0"
    "span-self-inline-end\0"
    "span-start\0"
    "span-end\0"
    "span-self-start\0"
    "span-self-end\0"
    "inset-area\0"
    "-internal-textarea-auto\0"
    "most-width\0"
    "most-height\0"
    "most-block-size\0"
    "most-inline-size\0"
    "flip-block\0"
    "flip-inline\0"
    "flip-start\0"
    "anchors-visible\0"
    "no-overflow\0"
    "flex-visual\0"
    "flex-flow\0"
    "grid-rows\0"
    "grid-columns\0"
    "grid-order\0"
    "context-fill\0"
    "context-stroke\0"
    "media-progress\0"
    "container-progress\0"
    "of\0"
    "blink-feature\0"
};

static const uint16_t valueListStringOffsets[] = {
    0,
    8,
    16,
    21,
    28,
    34,
    41,
    48,
    54,
    61,
    68,
    74,
    81,
    89,
    94,
    99,
    111,
    125,
    146,
    168,
    184,
    195,
    202,
    210,
    214,
    231,
    251,
    275,
    302,
    323,
    347,
    358,
    372,
    383,
    398,
    410,
    426,
    434,
    447,
    453,
    459,
    465,
    471,
    482,
    494,
    505,
    524,
    529,
    541,
    555,
    573,
    586,
    605,
    623,
    631,
    644,
    654,
    671,
    680,
    698,
    704,
    714,
    725,
    732,
    737,
    744,
    752,
    759,
    775,
    791,
    801,
    816,
    830,
    839,
    854,
    869,
    878,
    886,
    892,
    899,
    905,
    913,
    922,
    932,
    940,
    947,
    965,
    975,
    986,
    995,
    1004,
    1014,
    1020,
    1031,
    1039,
    1047,
    1057,
    1067,
    1080,
    1085,
    1090,
    1099,
    1108,
    1118,
    1130,
    1136,
    1144,
    1156,
    1161,
    1167,
    1172,
    1180,
    1185,
    1191,
    1196,
    1203,
    1208,
    1214,
    1221,
    1228,
    1232,
    1239,
    1244,
    1250,
    1257,
    1269,
    1282,
    1301,
    1313,
    1329,
    1342,
    1356,
    1367,
    1380,
    1391,
    1404,
    1415,
    1431,
    1444,
    1455,
    1462,
    1473,
    1485,
    1491,
    1501,
    1510,
    1520,
    1534,
    1549,
    1565,
    1585,
    1600,
    1609,
    1618,
    1623,
    1632,
    1641,
    1654,
    1671,
    1681,
    1698,
    1709,
    1725,
    1743,
    1756,
    1768,
    1775,
    1787,
    1798,
    1834,
    1875,
    1913,
    1956,
    1981,
    1994,
    1999,
    2023,
    2054,
    2084,
    2107,
    2135,
    2166,
    2202,
    2212,
    2225,
    2236,
    2242,
    2248,
    2255,
    2270,
    2281,
    2287,
    2297,
    2307,
    2318,
    2328,
    2334,
    2349,
    2358,
    2366,
    2371,
    2380,
    2389,
    2403,
    2412,
    2422,
    2431,
    2441,
    2453,
    2468,
    2479,
    2490,
    2498,
    2509,
    2522,
    2536,
    2550,
    2564,
    2578,
    2589,
    2598,
    2610,
    2618,
    2626,
    2637,
    2647,
    2659,
    2671,
    2681,
    2692,
    2697,
    2707,
    2719,
    2728,
    2736,
    2746,
    2753,
    2759,
    2765,
    2774,
    2788,
    2798,
    2811,
    2821,
    2832,
    2842,
    2863,
    2873,
    2884,
    2894,
    2904,
    2916,
    2930,
    2943,
    2958,
    2973,
    2988,
    3000,
    3010,
    3016,
    3024,
    3041,
    3052,
    3065,
    3078,
    3093,
    3109,
    3127,
    3143,
    3159,
    3172,
    3182,
    3192,
    3201,
    3213,
    3221,
    3231,
    3241,
    3248,
    3262,
    3272,
    3286,
    3300,
    3311,
    3321,
    3326,
    3331,
    3336,
    3347,
    3361,
    3371,
    3381,
    3393,
    3400,
    3411,
    3420,
    3429,
    3436,
    3444,
    3454,
    3464,
    3474,
    3479,
    3491,
    3501,
    3505,
    3513,
    3520,
    3530,
    3537,
    3543,
    3554,
    3566,
    3573,
    3582,
    3591,
    3601,
    3607,
    3612,
    3624,
    3634,
    3645,
    3657,
    3674,
    3689,
    3705,
    3722,
    3726,
    3739,
    3748,
    3758,
    3766,
    3775,
    3782,
    3786,
    3792,
    3801,
    3813,
    3817,
    3824,
    3848,
    3861,
    3866,
    3872,
    3879,
    3887,
    3900,
    3914,
    3929,
    3950,
    3967,
    3980,
    3991,
    3999,
    4006,
    4011,
    4018,
    4025,
    4041,
    4059,
    4067,
    4074,
    4080,
    4090,
    4095,
    4101,
    4106,
    4111,
    4120,
    4136,
    4155,
    4174,
    4184,
    4203,
    4216,
    4227,
    4241,
    4251,
    4264,
    4277,
    4289,
    4301,
    4313,
    4332,
    4345,
    4365,
    4372,
    4386,
    4396,
    4401,
    4411,
    4419,
    4427,
    4432,
    4446,
    4451,
    4464,
    4470,
    4479,
    4487,
    4499,
    4507,
    4516,
    4525,
    4535,
    4545,
    4554,
    4564,
    4574,
    4583,
    4592,
    4602,
    4612,
    4624,
    4636,
    4647,
    4658,
    4663,
    4668,
    4673,
    4684,
    4689,
    4698,
    4711,
    4728,
    4744,
    4761,
    4765,
    4769,
    4780,
    4790,
    4800,
    4810,
    4818,
    4827,
    4836,
    4852,
    4859,
    4862,
    4865,
    4868,
    4874,
    4883,
    4890,
    4896,
    4899,
    4902,
    4908,
    4922,
    4928,
    4933,
    4946,
    4958,
    4964,
    4970,
    4975,
    4980,
    4988,
    5005,
    5015,
    5031,
    5056,
    5074,
    5081,
    5088,
    5098,
    5105,
    5111,
    5118,
    5131,
    5137,
    5152,
    5166,
    5173,
    5184,
    5192,
    5201,
    5210,
    5214,
    5223,
    5232,
    5241,
    5248,
    5257,
    5262,
    5269,
    5275,
    5280,
    5290,
    5295,
    5300,
    5308,
    5316,
    5322,
    5326,
    5332,
    5338,
    5346,
    5357,
    5366,
    5378,
    5389,
    5400,
    5409,
    5423,
    5436,
    5449,
    5456,
    5461,
    5475,
    5479,
    5491,
    5498,
    5513,
    5518,
    5531,
    5541,
    5547,
    5557,
    5568,
    5594,
    5602,
    5622,
    5642,
    5665,
    5685,
    5697,
    5709,
    5721,
    5734,
    5738,
    5741,
    5749,
    5754,
    5763,
    5778,
    5792,
    5802,
    5812,
    5824,
    5835,
    5845,
    5854,
    5866,
    5877,
    5883,
    5889,
    5896,
    5914,
    5923,
    5930,
    5939,
    5945,
    5952,
    5960,
    5984,
    5993,
    6009,
    6015,
    6028,
    6040,
    6050,
    6059,
    6077,
    6089,
    6103,
    6121,
    6147,
    6163,
    6169,
    6181,
    6219,
    6226,
    6237,
    6245,
    6257,
    6265,
    6277,
    6288,
    6296,
    6304,
    6310,
    6318,
    6325,
    6333,
    6344,
    6354,
    6372,
    6381,
    6391,
    6400,
    6408,
    6415,
    6420,
    6432,
    6441,
    6450,
    6455,
    6462,
    6470,
    6479,
    6491,
    6501,
    6510,
    6520,
    6531,
    6542,
    6551,
    6557,
    6564,
    6577,
    6586,
    6592,
    6597,
    6612,
    6624,
    6638,
    6646,
    6651,
    6658,
    6671,
    6681,
    6688,
    6708,
    6723,
    6735,
    6756,
    6770,
    6789,
    6808,
    6819,
    6827,
    6833,
    6836,
    6839,
    6842,
    6848,
    6854,
    6860,
    6874,
    6886,
    6898,
    6904,
    6911,
    6927,
    6932,
    6938,
    6945,
    6950,
    6954,
    6968,
    6977,
    6984,
    6992,
    7005,
    7020,
    7034,
    7050,
    7056,
    7065,
    7080,
    7088,
    7103,
    7106,
    7110,
    7126,
    7136,
    7162,
    7173,
    7185,
    7198,
    7206,
    7214,
    7217,
    7228,
    7239,
    7250,
    7261,
    7272,
    7280,
    7304,
    7311,
    7330,
    7340,
    7350,
    7356,
    7361,
    7366,
    7373,
    7380,
    7385,
    7395,
    7401,
    7410,
    7417,
    7424,
    7432,
    7444,
    7455,
    7466,
    7477,
    7488,
    7498,
    7502,
    7513,
    7519,
    7530,
    7541,
    7549,
    7554,
    7562,
    7567,
    7574,
    7582,
    7594,
    7604,
    7612,
    7618,
    7628,
    7641,
    7646,
    7656,
    7661,
    7667,
    7673,
    7685,
    7696,
    7704,
    7721,
    7737,
    7749,
    7757,
    7770,
    7781,
    7791,
    7802,
    7810,
    7829,
    7854,
    7860,
    7866,
    7875,
    7885,
    7892,
    7901,
    7914,
    7925,
    7939,
    7954,
    7960,
    7965,
    7976,
    7985,
    7992,
    7999,
    8015,
    8022,
    8035,
    8041,
    8057,
    8073,
    8088,
    8114,
    8140,
    8165,
    8171,
    8182,
    8201,
    8218,
    8242,
    8266,
    8300,
    8334,
    8352,
    8362,
    8367,
    8370,
    8381,
    8388,
    8393,
    8401,
    8410,
    8415,
    8423,
    8430,
    8441,
    8459,
    8468,
    8472,
    8481,
    8486,
    8492,
    8497,
    8515,
    8528,
    8546,
    8559,
    8572,
    8582,
    8593,
    8604,
    8615,
    8624,
    8636,
    8643,
    8653,
    8659,
    8668,
    8679,
    8687,
    8698,
    8707,
    8712,
    8724,
    8728,
    8732,
    8737,
    8741,
    8746,
    8750,
    8754,
    8760,
    8764,
    8770,
    8781,
    8793,
    8804,
    8812,
    8825,
    8829,
    8837,
    8845,
    8853,
    8860,
    8871,
    8882,
    8885,
    8895,
    8900,
    8902,
    8904,
    8906,
    8908,
    8910,
    8912,
    8914,
    8916,
    8918,
    8925,
    8934,
    8946,
    8953,
    8961,
    8969,
    8977,
    8986,
    8992,
    8999,
    9006,
    9013,
    9021,
    9026,
    9032,
    9038,
    9048,
    9059,
    9070,
    9081,
    9093,
    9095,
    9097,
    9099,
    9104,
    9108,
    9114,
    9125,
    9130,
    9143,
    9147,
    9151,
    9157,
    9167,
    9171,
    9175,
    9179,
    9184,
    9189,
    9195,
    9200,
    9204,
    9208,
    9211,
    9216,
    9224,
    9229,
    9233,
    9237,
    9242,
    9248,
    9252,
    9256,
    9265,
    9275,
    9279,
    9282,
    9284,
    9294,
    9304,
    9310,
    9315,
    9326,
    9338,
    9351,
    9369,
    9385,
    9404,
    9421,
    9431,
    9440,
    9444,
    9469,
    9473,
    9477,
    9488,
    9493,
    9499,
    9505,
    9518,
    9521,
    9529,
    9533,
    9542,
    9547,
    9553,
    9567,
    9572,
    9578,
    9583,
    9590,
    9597,
    9619,
    9631,
    9642,
    9651,
    9662,
    9669,
    9676,
    9687,
    9692,
    9697,
    9704,
    9711,
    9720,
    9728,
    9737,
    9745,
    9777,
    9807,
    9839,
    9869,
    9900,
    9932,
    9962,
    9979,
    10004,
    10029,
    10056,
    10064,
    10072,
    10078,
    10087,
    10092,
    10109,
    10133,
    10139,
    10148,
    10163,
    10166,
    10169,
    10178,
    10182,
    10192,
    10197,
    10203,
    10208,
    10215,
    10227,
    10233,
    10240,
    10251,
    10263,
    10269,
    10274,
    10289,
    10303,
    10308,
    10316,
    10321,
    10336,
    10345,
    10353,
    10366,
    10376,
    10387,
    10395,
    10401,
    10414,
    10425,
    10438,
    10449,
    10467,
    10483,
    10492,
    10501,
    10513,
    10521,
    10527,
    10540,
    10551,
    10564,
    10575,
    10593,
    10609,
    10621,
    10631,
    10648,
    10663,
    10680,
    10695,
    10717,
    10737,
    10755,
    10771,
    10789,
    10805,
    10828,
    10849,
    10860,
    10869,
    10885,
    10899,
    10910,
    10934,
    10945,
    10957,
    10973,
    10990,
    11001,
    11013,
    11024,
    11040,
    11052,
    11064,
    11074,
    11084,
    11097,
    11108,
    11121,
    11136,
    11151,
    11170,
    11173,
};

/* maximum key range = 8846, duplicates = 0 */

class CSSValueKeywordsHash
{
 private:
  static inline unsigned int value_hash_function (const char *str, size_t len);
 public:
  static const struct Value *findValueImpl (const char *str, size_t len);
};

inline unsigned int
CSSValueKeywordsHash::value_hash_function (const char *str, size_t len)
{
  static const unsigned short asso_values[] =
      {
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853,  297,   38,  189,    7,    8,
          9,    9,   10,   11,    8, 8853,    7,    7,    7,    8,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853,    8,  792,  217,
          93,    7,  526,   13, 1620,    8, 1133, 1111,  111,   12,
          9,   48,  314, 1519,   11,   52,    7,  253,  172, 2289,
          1880,  795, 2356,   32,    8, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853,
          8853, 8853, 8853, 8853, 8853, 8853, 8853, 8853
      };
  unsigned int hval = 0;

  switch (len)
  {
    default:
      hval += asso_values[static_cast<unsigned char>(str[41])];
      [[fallthrough]];
    case 41:
      hval += asso_values[static_cast<unsigned char>(str[40])];
      [[fallthrough]];
    case 40:
      hval += asso_values[static_cast<unsigned char>(str[39])];
      [[fallthrough]];
    case 39:
      hval += asso_values[static_cast<unsigned char>(str[38])];
      [[fallthrough]];
    case 38:
      hval += asso_values[static_cast<unsigned char>(str[37])];
      [[fallthrough]];
    case 37:
      hval += asso_values[static_cast<unsigned char>(str[36])];
      [[fallthrough]];
    case 36:
      hval += asso_values[static_cast<unsigned char>(str[35])];
      [[fallthrough]];
    case 35:
      hval += asso_values[static_cast<unsigned char>(str[34])];
      [[fallthrough]];
    case 34:
      hval += asso_values[static_cast<unsigned char>(str[33])];
      [[fallthrough]];
    case 33:
      hval += asso_values[static_cast<unsigned char>(str[32])];
      [[fallthrough]];
    case 32:
      hval += asso_values[static_cast<unsigned char>(str[31])];
      [[fallthrough]];
    case 31:
      hval += asso_values[static_cast<unsigned char>(str[30])];
      [[fallthrough]];
    case 30:
      hval += asso_values[static_cast<unsigned char>(str[29])];
      [[fallthrough]];
    case 29:
      hval += asso_values[static_cast<unsigned char>(str[28])];
      [[fallthrough]];
    case 28:
      hval += asso_values[static_cast<unsigned char>(str[27])];
      [[fallthrough]];
    case 27:
      hval += asso_values[static_cast<unsigned char>(str[26])];
      [[fallthrough]];
    case 26:
      hval += asso_values[static_cast<unsigned char>(str[25])];
      [[fallthrough]];
    case 25:
      hval += asso_values[static_cast<unsigned char>(str[24])];
      [[fallthrough]];
    case 24:
      hval += asso_values[static_cast<unsigned char>(str[23])];
      [[fallthrough]];
    case 23:
      hval += asso_values[static_cast<unsigned char>(str[22])];
      [[fallthrough]];
    case 22:
      hval += asso_values[static_cast<unsigned char>(str[21])];
      [[fallthrough]];
    case 21:
      hval += asso_values[static_cast<unsigned char>(str[20])];
      [[fallthrough]];
    case 20:
      hval += asso_values[static_cast<unsigned char>(str[19])];
      [[fallthrough]];
    case 19:
      hval += asso_values[static_cast<unsigned char>(str[18])];
      [[fallthrough]];
    case 18:
      hval += asso_values[static_cast<unsigned char>(str[17])];
      [[fallthrough]];
    case 17:
      hval += asso_values[static_cast<unsigned char>(str[16])];
      [[fallthrough]];
    case 16:
      hval += asso_values[static_cast<unsigned char>(str[15])];
      [[fallthrough]];
    case 15:
      hval += asso_values[static_cast<unsigned char>(str[14])];
      [[fallthrough]];
    case 14:
      hval += asso_values[static_cast<unsigned char>(str[13])];
      [[fallthrough]];
    case 13:
      hval += asso_values[static_cast<unsigned char>(str[12])];
      [[fallthrough]];
    case 12:
      hval += asso_values[static_cast<unsigned char>(str[11])];
      [[fallthrough]];
    case 11:
      hval += asso_values[static_cast<unsigned char>(str[10]+1)];
      [[fallthrough]];
    case 10:
      hval += asso_values[static_cast<unsigned char>(str[9])];
      [[fallthrough]];
    case 9:
      hval += asso_values[static_cast<unsigned char>(str[8])];
      [[fallthrough]];
    case 8:
      hval += asso_values[static_cast<unsigned char>(str[7])];
      [[fallthrough]];
    case 7:
      hval += asso_values[static_cast<unsigned char>(str[6])];
      [[fallthrough]];
    case 6:
      hval += asso_values[static_cast<unsigned char>(str[5])];
      [[fallthrough]];
    case 5:
      hval += asso_values[static_cast<unsigned char>(str[4])];
      [[fallthrough]];
    case 4:
      hval += asso_values[static_cast<unsigned char>(str[3]+2)];
      [[fallthrough]];
    case 3:
      hval += asso_values[static_cast<unsigned char>(str[2])];
      [[fallthrough]];
    case 2:
      hval += asso_values[static_cast<unsigned char>(str[1])];
      [[fallthrough]];
    case 1:
      hval += asso_values[static_cast<unsigned char>(str[0]+1)];
      break;
  }
  return hval;
}

struct CSSValueStringPool_t
{
  char CSSValueStringPool_str0[sizeof("s")];
  char CSSValueStringPool_str1[sizeof("h")];
  char CSSValueStringPool_str2[sizeof("l")];
  char CSSValueStringPool_str3[sizeof("lr")];
  char CSSValueStringPool_str4[sizeof("sin")];
  char CSSValueStringPool_str5[sizeof("min")];
  char CSSValueStringPool_str6[sizeof("ltr")];
  char CSSValueStringPool_str7[sizeof("z")];
  char CSSValueStringPool_str8[sizeof("drag")];
  char CSSValueStringPool_str9[sizeof("start")];
  char CSSValueStringPool_str10[sizeof("dark")];
  char CSSValueStringPool_str11[sizeof("mark")];
  char CSSValueStringPool_str12[sizeof("fine")];
  char CSSValueStringPool_str13[sizeof("lime")];
  char CSSValueStringPool_str14[sizeof("large")];
  char CSSValueStringPool_str15[sizeof("meter")];
  char CSSValueStringPool_str16[sizeof("miter")];
  char CSSValueStringPool_str17[sizeof("linen")];
  char CSSValueStringPool_str18[sizeof("r")];
  char CSSValueStringPool_str19[sizeof("darken")];
  char CSSValueStringPool_str20[sizeof("larger")];
  char CSSValueStringPool_str21[sizeof("linear")];
  char CSSValueStringPool_str22[sizeof("dot")];
  char CSSValueStringPool_str23[sizeof("hanging")];
  char CSSValueStringPool_str24[sizeof("seagreen")];
  char CSSValueStringPool_str25[sizeof("nan")];
  char CSSValueStringPool_str26[sizeof("magenta")];
  char CSSValueStringPool_str27[sizeof("rem")];
  char CSSValueStringPool_str28[sizeof("log")];
  char CSSValueStringPool_str29[sizeof("disc")];
  char CSSValueStringPool_str30[sizeof("drop")];
  char CSSValueStringPool_str31[sizeof("more")];
  char CSSValueStringPool_str32[sizeof("steps")];
  char CSSValueStringPool_str33[sizeof("darkgreen")];
  char CSSValueStringPool_str34[sizeof("limegreen")];
  char CSSValueStringPool_str35[sizeof("c")];
  char CSSValueStringPool_str36[sizeof("longer")];
  char CSSValueStringPool_str37[sizeof("markers")];
  char CSSValueStringPool_str38[sizeof("none")];
  char CSSValueStringPool_str39[sizeof("from")];
  char CSSValueStringPool_str40[sizeof("hide")];
  char CSSValueStringPool_str41[sizeof("srgb")];
  char CSSValueStringPool_str42[sizeof("field")];
  char CSSValueStringPool_str43[sizeof("reset")];
  char CSSValueStringPool_str44[sizeof("darkorange")];
  char CSSValueStringPool_str45[sizeof("format")];
  char CSSValueStringPool_str46[sizeof("nearest")];
  char CSSValueStringPool_str47[sizeof("help")];
  char CSSValueStringPool_str48[sizeof("ledger")];
  char CSSValueStringPool_str49[sizeof("frames")];
  char CSSValueStringPool_str50[sizeof("slice")];
  char CSSValueStringPool_str51[sizeof("fill")];
  char CSSValueStringPool_str52[sizeof("small")];
  char CSSValueStringPool_str53[sizeof("darkred")];
  char CSSValueStringPool_str54[sizeof("mod")];
  char CSSValueStringPool_str55[sizeof("red")];
  char CSSValueStringPool_str56[sizeof("rl")];
  char CSSValueStringPool_str57[sizeof("smaller")];
  char CSSValueStringPool_str58[sizeof("ridge")];
  char CSSValueStringPool_str59[sizeof("rtl")];
  char CSSValueStringPool_str60[sizeof("hsl")];
  char CSSValueStringPool_str61[sizeof("sides")];
  char CSSValueStringPool_str62[sizeof("zoom")];
  char CSSValueStringPool_str63[sizeof("nonzero")];
  char CSSValueStringPool_str64[sizeof("svg")];
  char CSSValueStringPool_str65[sizeof("cos")];
  char CSSValueStringPool_str66[sizeof("coarse")];
  char CSSValueStringPool_str67[sizeof("letter")];
  char CSSValueStringPool_str68[sizeof("b")];
  char CSSValueStringPool_str69[sizeof("calc")];
  char CSSValueStringPool_str70[sizeof("cell")];
  char CSSValueStringPool_str71[sizeof("clip")];
  char CSSValueStringPool_str72[sizeof("b4")];
  char CSSValueStringPool_str73[sizeof("b5")];
  char CSSValueStringPool_str74[sizeof("forestgreen")];
  char CSSValueStringPool_str75[sizeof("salmon")];
  char CSSValueStringPool_str76[sizeof("stable")];
  char CSSValueStringPool_str77[sizeof("circle")];
  char CSSValueStringPool_str78[sizeof("filled")];
  char CSSValueStringPool_str79[sizeof("move")];
  char CSSValueStringPool_str80[sizeof("last")];
  char CSSValueStringPool_str81[sizeof("fast")];
  char CSSValueStringPool_str82[sizeof("beige")];
  char CSSValueStringPool_str83[sizeof("scale")];
  char CSSValueStringPool_str84[sizeof("hover")];
  char CSSValueStringPool_str85[sizeof("unset")];
  char CSSValueStringPool_str86[sizeof("navy")];
  char CSSValueStringPool_str87[sizeof("revert")];
  char CSSValueStringPool_str88[sizeof("unicase")];
  char CSSValueStringPool_str89[sizeof("screen")];
  char CSSValueStringPool_str90[sizeof("hue")];
  char CSSValueStringPool_str91[sizeof("crimson")];
  char CSSValueStringPool_str92[sizeof("tan")];
  char CSSValueStringPool_str93[sizeof("normal")];
  char CSSValueStringPool_str94[sizeof("teal")];
  char CSSValueStringPool_str95[sizeof("darksalmon")];
  char CSSValueStringPool_str96[sizeof("dense")];
  char CSSValueStringPool_str97[sizeof("first")];
  char CSSValueStringPool_str98[sizeof("url")];
  char CSSValueStringPool_str99[sizeof("under")];
  char CSSValueStringPool_str100[sizeof("center")];
  char CSSValueStringPool_str101[sizeof("to")];
  char CSSValueStringPool_str102[sizeof("sesame")];
  char CSSValueStringPool_str103[sizeof("flat")];
  char CSSValueStringPool_str104[sizeof("rec2020")];
  char CSSValueStringPool_str105[sizeof("reverse")];
  char CSSValueStringPool_str106[sizeof("root")];
  char CSSValueStringPool_str107[sizeof("on")];
  char CSSValueStringPool_str108[sizeof("less")];
  char CSSValueStringPool_str109[sizeof("lavender")];
  char CSSValueStringPool_str110[sizeof("raise")];
  char CSSValueStringPool_str111[sizeof("dotted")];
  char CSSValueStringPool_str112[sizeof("decreasing")];
  char CSSValueStringPool_str113[sizeof("cover")];
  char CSSValueStringPool_str114[sizeof("rotate")];
  char CSSValueStringPool_str115[sizeof("sign")];
  char CSSValueStringPool_str116[sizeof("space")];
  char CSSValueStringPool_str117[sizeof("unicode")];
  char CSSValueStringPool_str118[sizeof("content")];
  char CSSValueStringPool_str119[sizeof("contain")];
  char CSSValueStringPool_str120[sizeof("scale3d")];
  char CSSValueStringPool_str121[sizeof("sienna")];
  char CSSValueStringPool_str122[sizeof("moccasin")];
  char CSSValueStringPool_str123[sizeof("legal")];
  char CSSValueStringPool_str124[sizeof("loose")];
  char CSSValueStringPool_str125[sizeof("hsla")];
  char CSSValueStringPool_str126[sizeof("darkviolet")];
  char CSSValueStringPool_str127[sizeof("false")];
  char CSSValueStringPool_str128[sizeof("compact")];
  char CSSValueStringPool_str129[sizeof("contents")];
  char CSSValueStringPool_str130[sizeof("contrast")];
  char CSSValueStringPool_str131[sizeof("repeat")];
  char CSSValueStringPool_str132[sizeof("central")];
  char CSSValueStringPool_str133[sizeof("step-start")];
  char CSSValueStringPool_str134[sizeof("cap")];
  char CSSValueStringPool_str135[sizeof("static")];
  char CSSValueStringPool_str136[sizeof("selector")];
  char CSSValueStringPool_str137[sizeof("baseline")];
  char CSSValueStringPool_str138[sizeof("linear-gradient")];
  char CSSValueStringPool_str139[sizeof("underline")];
  char CSSValueStringPool_str140[sizeof("step-end")];
  char CSSValueStringPool_str141[sizeof("clear")];
  char CSSValueStringPool_str142[sizeof("rotate3d")];
  char CSSValueStringPool_str143[sizeof("rect")];
  char CSSValueStringPool_str144[sizeof("mintcream")];
  char CSSValueStringPool_str145[sizeof("from-image")];
  char CSSValueStringPool_str146[sizeof("only")];
  char CSSValueStringPool_str147[sizeof("darkolivegreen")];
  char CSSValueStringPool_str148[sizeof("numbers")];
  char CSSValueStringPool_str149[sizeof("coral")];
  char CSSValueStringPool_str150[sizeof("up")];
  char CSSValueStringPool_str151[sizeof("copy")];
  char CSSValueStringPool_str152[sizeof("zoom-in")];
  char CSSValueStringPool_str153[sizeof("recto")];
  char CSSValueStringPool_str154[sizeof("over")];
  char CSSValueStringPool_str155[sizeof("bottom")];
  char CSSValueStringPool_str156[sizeof("darkgoldenrod")];
  char CSSValueStringPool_str157[sizeof("double")];
  char CSSValueStringPool_str158[sizeof("bevel")];
  char CSSValueStringPool_str159[sizeof("flip-start")];
  char CSSValueStringPool_str160[sizeof("e")];
  char CSSValueStringPool_str161[sizeof("true")];
  char CSSValueStringPool_str162[sizeof("standard")];
  char CSSValueStringPool_str163[sizeof("hue-rotate")];
  char CSSValueStringPool_str164[sizeof("hand")];
  char CSSValueStringPool_str165[sizeof("safe")];
  char CSSValueStringPool_str166[sizeof("collection")];
  char CSSValueStringPool_str167[sizeof("numeric")];
  char CSSValueStringPool_str168[sizeof("clone")];
  char CSSValueStringPool_str169[sizeof("clamp")];
  char CSSValueStringPool_str170[sizeof("list-item")];
  char CSSValueStringPool_str171[sizeof("separate")];
  char CSSValueStringPool_str172[sizeof("relative")];
  char CSSValueStringPool_str173[sizeof("leading")];
  char CSSValueStringPool_str174[sizeof("tomato")];
  char CSSValueStringPool_str175[sizeof("blur")];
  char CSSValueStringPool_str176[sizeof("bisque")];
  char CSSValueStringPool_str177[sizeof("blue")];
  char CSSValueStringPool_str178[sizeof("super")];
  char CSSValueStringPool_str179[sizeof("ease")];
  char CSSValueStringPool_str180[sizeof("local")];
  char CSSValueStringPool_str181[sizeof("standalone")];
  char CSSValueStringPool_str182[sizeof("replace")];
  char CSSValueStringPool_str183[sizeof("top")];
  char CSSValueStringPool_str184[sizeof("srgb-linear")];
  char CSSValueStringPool_str185[sizeof("end")];
  char CSSValueStringPool_str186[sizeof("triangle")];
  char CSSValueStringPool_str187[sizeof("custom")];
  char CSSValueStringPool_str188[sizeof("overline")];
  char CSSValueStringPool_str189[sizeof("ornaments")];
  char CSSValueStringPool_str190[sizeof("collapse")];
  char CSSValueStringPool_str191[sizeof("span")];
  char CSSValueStringPool_str192[sizeof("butt")];
  char CSSValueStringPool_str193[sizeof("hidden")];
  char CSSValueStringPool_str194[sizeof("caption")];
  char CSSValueStringPool_str195[sizeof("bullets")];
  char CSSValueStringPool_str196[sizeof("running")];
  char CSSValueStringPool_str197[sizeof("keep-all")];
  char CSSValueStringPool_str198[sizeof("orange")];
  char CSSValueStringPool_str199[sizeof("darkseagreen")];
  char CSSValueStringPool_str200[sizeof("to-zero")];
  char CSSValueStringPool_str201[sizeof("rotate-right")];
  char CSSValueStringPool_str202[sizeof("destination-in")];
  char CSSValueStringPool_str203[sizeof("fullscreen")];
  char CSSValueStringPool_str204[sizeof("trim-start")];
  char CSSValueStringPool_str205[sizeof("supports")];
  char CSSValueStringPool_str206[sizeof("emoji")];
  char CSSValueStringPool_str207[sizeof("button")];
  char CSSValueStringPool_str208[sizeof("env")];
  char CSSValueStringPool_str209[sizeof("element")];
  char CSSValueStringPool_str210[sizeof("left")];
  char CSSValueStringPool_str211[sizeof("counter")];
  char CSSValueStringPool_str212[sizeof("no-repeat")];
  char CSSValueStringPool_str213[sizeof("middle")];
  char CSSValueStringPool_str214[sizeof("oldlace")];
  char CSSValueStringPool_str215[sizeof("round")];
  char CSSValueStringPool_str216[sizeof("min-content")];
  char CSSValueStringPool_str217[sizeof("fit-content")];
  char CSSValueStringPool_str218[sizeof("translate")];
  char CSSValueStringPool_str219[sizeof("orangered")];
  char CSSValueStringPool_str220[sizeof("zoom-out")];
  char CSSValueStringPool_str221[sizeof("counters")];
  char CSSValueStringPool_str222[sizeof("balance")];
  char CSSValueStringPool_str223[sizeof("translate3d")];
  char CSSValueStringPool_str224[sizeof("simplified")];
  char CSSValueStringPool_str225[sizeof("a")];
  char CSSValueStringPool_str226[sizeof("x")];
  char CSSValueStringPool_str227[sizeof("cursive")];
  char CSSValueStringPool_str228[sizeof("folded")];
  char CSSValueStringPool_str229[sizeof("at")];
  char CSSValueStringPool_str230[sizeof("aa")];
  char CSSValueStringPool_str231[sizeof("a3")];
  char CSSValueStringPool_str232[sizeof("a4")];
  char CSSValueStringPool_str233[sizeof("a5")];
  char CSSValueStringPool_str234[sizeof("-internal-center")];
  char CSSValueStringPool_str235[sizeof("aaa")];
  char CSSValueStringPool_str236[sizeof("lab")];
  char CSSValueStringPool_str237[sizeof("attr")];
  char CSSValueStringPool_str238[sizeof("arg")];
  char CSSValueStringPool_str239[sizeof("border")];
  char CSSValueStringPool_str240[sizeof("style")];
  char CSSValueStringPool_str241[sizeof("no-clip")];
  char CSSValueStringPool_str242[sizeof("layer")];
  char CSSValueStringPool_str243[sizeof("of")];
  char CSSValueStringPool_str244[sizeof("outset")];
  char CSSValueStringPool_str245[sizeof("condensed")];
  char CSSValueStringPool_str246[sizeof("enabled")];
  char CSSValueStringPool_str247[sizeof("dimgrey")];
  char CSSValueStringPool_str248[sizeof("dimgray")];
  char CSSValueStringPool_str249[sizeof("crispedges")];
  char CSSValueStringPool_str250[sizeof("source-in")];
  char CSSValueStringPool_str251[sizeof("xor")];
  char CSSValueStringPool_str252[sizeof("ray")];
  char CSSValueStringPool_str253[sizeof("rgb")];
  char CSSValueStringPool_str254[sizeof("snow")];
  char CSSValueStringPool_str255[sizeof("darkgrey")];
  char CSSValueStringPool_str256[sizeof("darkgray")];
  char CSSValueStringPool_str257[sizeof("space-all")];
  char CSSValueStringPool_str258[sizeof("linearrgb")];
  char CSSValueStringPool_str259[sizeof("background")];
  char CSSValueStringPool_str260[sizeof("darkmagenta")];
  char CSSValueStringPool_str261[sizeof("styleset")];
  char CSSValueStringPool_str262[sizeof("traditional")];
  char CSSValueStringPool_str263[sizeof("bold")];
  char CSSValueStringPool_str264[sizeof("spelling-error")];
  char CSSValueStringPool_str265[sizeof("destination-over")];
  char CSSValueStringPool_str266[sizeof("ease-in")];
  char CSSValueStringPool_str267[sizeof("bolder")];
  char CSSValueStringPool_str268[sizeof("outside")];
  char CSSValueStringPool_str269[sizeof("turquoise")];
  char CSSValueStringPool_str270[sizeof("closest-side")];
  char CSSValueStringPool_str271[sizeof("continuous")];
  char CSSValueStringPool_str272[sizeof("blueviolet")];
  char CSSValueStringPool_str273[sizeof("open")];
  char CSSValueStringPool_str274[sizeof("no-drag")];
  char CSSValueStringPool_str275[sizeof("slow")];
  char CSSValueStringPool_str276[sizeof("alternate")];
  char CSSValueStringPool_str277[sizeof("flow")];
  char CSSValueStringPool_str278[sizeof("disclosure-open")];
  char CSSValueStringPool_str279[sizeof("add")];
  char CSSValueStringPool_str280[sizeof("destination-out")];
  char CSSValueStringPool_str281[sizeof("unsafe")];
  char CSSValueStringPool_str282[sizeof("from-font")];
  char CSSValueStringPool_str283[sizeof("all")];
  char CSSValueStringPool_str284[sizeof("selecteditem")];
  char CSSValueStringPool_str285[sizeof("span-start")];
  char CSSValueStringPool_str286[sizeof("use-script")];
  char CSSValueStringPool_str287[sizeof("forwards")];
  char CSSValueStringPool_str288[sizeof("small-caps")];
  char CSSValueStringPool_str289[sizeof("borderless")];
  char CSSValueStringPool_str290[sizeof("scaley")];
  char CSSValueStringPool_str291[sizeof("tb")];
  char CSSValueStringPool_str292[sizeof("destination-atop")];
  char CSSValueStringPool_str293[sizeof("span-end")];
  char CSSValueStringPool_str294[sizeof("sub")];
  char CSSValueStringPool_str295[sizeof("spell-out")];
  char CSSValueStringPool_str296[sizeof("fantasy")];
  char CSSValueStringPool_str297[sizeof("darkcyan")];
  char CSSValueStringPool_str298[sizeof("table")];
  char CSSValueStringPool_str299[sizeof("rgba")];
  char CSSValueStringPool_str300[sizeof("brown")];
  char CSSValueStringPool_str301[sizeof("currentcolor")];
  char CSSValueStringPool_str302[sizeof("darkslategrey")];
  char CSSValueStringPool_str303[sizeof("darkslategray")];
  char CSSValueStringPool_str304[sizeof("space-around")];
  char CSSValueStringPool_str305[sizeof("uppercase")];
  char CSSValueStringPool_str306[sizeof("stylistic")];
  char CSSValueStringPool_str307[sizeof("flip-inline")];
  char CSSValueStringPool_str308[sizeof("source-over")];
  char CSSValueStringPool_str309[sizeof("atan")];
  char CSSValueStringPool_str310[sizeof("disclosure-closed")];
  char CSSValueStringPool_str311[sizeof("default")];
  char CSSValueStringPool_str312[sizeof("ruby")];
  char CSSValueStringPool_str313[sizeof("atan2")];
  char CSSValueStringPool_str314[sizeof("slategrey")];
  char CSSValueStringPool_str315[sizeof("slategray")];
  char CSSValueStringPool_str316[sizeof("rotatey")];
  char CSSValueStringPool_str317[sizeof("browser")];
  char CSSValueStringPool_str318[sizeof("in")];
  char CSSValueStringPool_str319[sizeof("source-out")];
  char CSSValueStringPool_str320[sizeof("aa-large")];
  char CSSValueStringPool_str321[sizeof("aaa-large")];
  char CSSValueStringPool_str322[sizeof("historical-ligatures")];
  char CSSValueStringPool_str323[sizeof("landscape")];
  char CSSValueStringPool_str324[sizeof("mistyrose")];
  char CSSValueStringPool_str325[sizeof("math")];
  char CSSValueStringPool_str326[sizeof("fabricated")];
  char CSSValueStringPool_str327[sizeof("high")];
  char CSSValueStringPool_str328[sizeof("asin")];
  char CSSValueStringPool_str329[sizeof("span-all")];
  char CSSValueStringPool_str330[sizeof("subgrid")];
  char CSSValueStringPool_str331[sizeof("light")];
  char CSSValueStringPool_str332[sizeof("sans-serif")];
  char CSSValueStringPool_str333[sizeof("alias")];
  char CSSValueStringPool_str334[sizeof("jis78")];
  char CSSValueStringPool_str335[sizeof("jis90")];
  char CSSValueStringPool_str336[sizeof("jis83")];
  char CSSValueStringPool_str337[sizeof("lighten")];
  char CSSValueStringPool_str338[sizeof("jis04")];
  char CSSValueStringPool_str339[sizeof("lighter")];
  char CSSValueStringPool_str340[sizeof("no-common-ligatures")];
  char CSSValueStringPool_str341[sizeof("digits")];
  char CSSValueStringPool_str342[sizeof("darkblue")];
  char CSSValueStringPool_str343[sizeof("hotpink")];
  char CSSValueStringPool_str344[sizeof("ease-out")];
  char CSSValueStringPool_str345[sizeof("cyan")];
  char CSSValueStringPool_str346[sizeof("closest-corner")];
  char CSSValueStringPool_str347[sizeof("right")];
  char CSSValueStringPool_str348[sizeof("inset")];
  char CSSValueStringPool_str349[sizeof("lightgreen")];
  char CSSValueStringPool_str350[sizeof("base-select")];
  char CSSValueStringPool_str351[sizeof("repeating-linear-gradient")];
  char CSSValueStringPool_str352[sizeof("transparent")];
  char CSSValueStringPool_str353[sizeof("no-preference")];
  char CSSValueStringPool_str354[sizeof("tabbed")];
  char CSSValueStringPool_str355[sizeof("evenodd")];
  char CSSValueStringPool_str356[sizeof("legacy")];
  char CSSValueStringPool_str357[sizeof("double-circle")];
  char CSSValueStringPool_str358[sizeof("isolate")];
  char CSSValueStringPool_str359[sizeof("dynamic")];
  char CSSValueStringPool_str360[sizeof("on-demand")];
  char CSSValueStringPool_str361[sizeof("lr-tb")];
  char CSSValueStringPool_str362[sizeof("darkslateblue")];
  char CSSValueStringPool_str363[sizeof("symbolic")];
  char CSSValueStringPool_str364[sizeof("no-drop")];
  char CSSValueStringPool_str365[sizeof("dashed")];
  char CSSValueStringPool_str366[sizeof("steelblue")];
  char CSSValueStringPool_str367[sizeof("span-top")];
  char CSSValueStringPool_str368[sizeof("acos")];
  char CSSValueStringPool_str369[sizeof("radio")];
  char CSSValueStringPool_str370[sizeof("historical-forms")];
  char CSSValueStringPool_str371[sizeof("dodgerblue")];
  char CSSValueStringPool_str372[sizeof("cyclic")];
  char CSSValueStringPool_str373[sizeof("x-start")];
  char CSSValueStringPool_str374[sizeof("entry")];
  char CSSValueStringPool_str375[sizeof("invert")];
  char CSSValueStringPool_str376[sizeof("after")];
  char CSSValueStringPool_str377[sizeof("strict")];
  char CSSValueStringPool_str378[sizeof("off")];
  char CSSValueStringPool_str379[sizeof("solid")];
  char CSSValueStringPool_str380[sizeof("type")];
  char CSSValueStringPool_str381[sizeof("cadetblue")];
  char CSSValueStringPool_str382[sizeof("flow-root")];
  char CSSValueStringPool_str383[sizeof("italic")];
  char CSSValueStringPool_str384[sizeof("radial")];
  char CSSValueStringPool_str385[sizeof("cross-fade")];
  char CSSValueStringPool_str386[sizeof("no-autospace")];
  char CSSValueStringPool_str387[sizeof("font-format")];
  char CSSValueStringPool_str388[sizeof("both")];
  char CSSValueStringPool_str389[sizeof("overlay")];
  char CSSValueStringPool_str390[sizeof("mandatory")];
  char CSSValueStringPool_str391[sizeof("x-small")];
  char CSSValueStringPool_str392[sizeof("rl-tb")];
  char CSSValueStringPool_str393[sizeof("incremental")];
  char CSSValueStringPool_str394[sizeof("diagonal-fractions")];
  char CSSValueStringPool_str395[sizeof("embed")];
  char CSSValueStringPool_str396[sizeof("inverted")];
  char CSSValueStringPool_str397[sizeof("sepia")];
  char CSSValueStringPool_str398[sizeof("initial")];
  char CSSValueStringPool_str399[sizeof("x-large")];
  char CSSValueStringPool_str400[sizeof("lightsalmon")];
  char CSSValueStringPool_str401[sizeof("opacity")];
  char CSSValueStringPool_str402[sizeof("black")];
  char CSSValueStringPool_str403[sizeof("intersect")];
  char CSSValueStringPool_str404[sizeof("tb-rl")];
  char CSSValueStringPool_str405[sizeof("repeating-radial-gradient")];
  char CSSValueStringPool_str406[sizeof("increasing")];
  char CSSValueStringPool_str407[sizeof("buttonface")];
  char CSSValueStringPool_str408[sizeof("subtract")];
  char CSSValueStringPool_str409[sizeof("slateblue")];
  char CSSValueStringPool_str410[sizeof("no-punctuation")];
  char CSSValueStringPool_str411[sizeof("decimal")];
  char CSSValueStringPool_str412[sizeof("deeppink")];
  char CSSValueStringPool_str413[sizeof("first-baseline")];
  char CSSValueStringPool_str414[sizeof("medium")];
  char CSSValueStringPool_str415[sizeof("space-first")];
  char CSSValueStringPool_str416[sizeof("repeat-y")];
  char CSSValueStringPool_str417[sizeof("block")];
  char CSSValueStringPool_str418[sizeof("x-end")];
  char CSSValueStringPool_str419[sizeof("interlace")];
  char CSSValueStringPool_str420[sizeof("logical")];
  char CSSValueStringPool_str421[sizeof("pi")];
  char CSSValueStringPool_str422[sizeof("p3")];
  char CSSValueStringPool_str423[sizeof("image-set")];
  char CSSValueStringPool_str424[sizeof("rotate-left")];
  char CSSValueStringPool_str425[sizeof("pre")];
  char CSSValueStringPool_str426[sizeof("-internal-media-control")];
  char CSSValueStringPool_str427[sizeof("inset-area")];
  char CSSValueStringPool_str428[sizeof("pink")];
  char CSSValueStringPool_str429[sizeof("springgreen")];
  char CSSValueStringPool_str430[sizeof("page")];
  char CSSValueStringPool_str431[sizeof("repeating-conic-gradient")];
  char CSSValueStringPool_str432[sizeof("translatey")];
  char CSSValueStringPool_str433[sizeof("lightcoral")];
  char CSSValueStringPool_str434[sizeof("alternate-reverse")];
  char CSSValueStringPool_str435[sizeof("span-left")];
  char CSSValueStringPool_str436[sizeof("any")];
  char CSSValueStringPool_str437[sizeof("system-ui")];
  char CSSValueStringPool_str438[sizeof("maroon")];
  char CSSValueStringPool_str439[sizeof("status-bar")];
  char CSSValueStringPool_str440[sizeof("tech")];
  char CSSValueStringPool_str441[sizeof("display-p3")];
  char CSSValueStringPool_str442[sizeof("g")];
  char CSSValueStringPool_str443[sizeof("features-aat")];
  char CSSValueStringPool_str444[sizeof("abs")];
  char CSSValueStringPool_str445[sizeof("luminance")];
  char CSSValueStringPool_str446[sizeof("literal-punctuation")];
  char CSSValueStringPool_str447[sizeof("mediumseagreen")];
  char CSSValueStringPool_str448[sizeof("space-evenly")];
  char CSSValueStringPool_str449[sizeof("paged")];
  char CSSValueStringPool_str450[sizeof("truetype")];
  char CSSValueStringPool_str451[sizeof("ultra-condensed")];
  char CSSValueStringPool_str452[sizeof("ordinal")];
  char CSSValueStringPool_str453[sizeof("height")];
  char CSSValueStringPool_str454[sizeof("green")];
  char CSSValueStringPool_str455[sizeof("serif")];
  char CSSValueStringPool_str456[sizeof("grey")];
  char CSSValueStringPool_str457[sizeof("gray")];
  char CSSValueStringPool_str458[sizeof("fuchsia")];
  char CSSValueStringPool_str459[sizeof("palegreen")];
  char CSSValueStringPool_str460[sizeof("shorter")];
  char CSSValueStringPool_str461[sizeof("progress")];
  char CSSValueStringPool_str462[sizeof("sqrt")];
  char CSSValueStringPool_str463[sizeof("icon")];
  char CSSValueStringPool_str464[sizeof("palettes")];
  char CSSValueStringPool_str465[sizeof("accentcolor")];
  char CSSValueStringPool_str466[sizeof("grab")];
  char CSSValueStringPool_str467[sizeof("lining-nums")];
  char CSSValueStringPool_str468[sizeof("self")];
  char CSSValueStringPool_str469[sizeof("cornsilk")];
  char CSSValueStringPool_str470[sizeof("radial-gradient")];
  char CSSValueStringPool_str471[sizeof("all-scroll")];
  char CSSValueStringPool_str472[sizeof("slider-vertical")];
  char CSSValueStringPool_str473[sizeof("jump-none")];
  char CSSValueStringPool_str474[sizeof("khaki")];
  char CSSValueStringPool_str475[sizeof("blink")];
  char CSSValueStringPool_str476[sizeof("ease-in-out")];
  char CSSValueStringPool_str477[sizeof("after-edge")];
  char CSSValueStringPool_str478[sizeof("jump-start")];
  char CSSValueStringPool_str479[sizeof("math-auto")];
  char CSSValueStringPool_str480[sizeof("multiply")];
  char CSSValueStringPool_str481[sizeof("orchid")];
  char CSSValueStringPool_str482[sizeof("polygon")];
  char CSSValueStringPool_str483[sizeof("color")];
  char CSSValueStringPool_str484[sizeof("portrait")];
  char CSSValueStringPool_str485[sizeof("jump-end")];
  char CSSValueStringPool_str486[sizeof("lightseagreen")];
  char CSSValueStringPool_str487[sizeof("common-ligatures")];
  char CSSValueStringPool_str488[sizeof("a98-rgb")];
  char CSSValueStringPool_str489[sizeof("table-cell")];
  char CSSValueStringPool_str490[sizeof("minimal-ui")];
  char CSSValueStringPool_str491[sizeof("lch")];
  char CSSValueStringPool_str492[sizeof("span-bottom")];
  char CSSValueStringPool_str493[sizeof("read-only")];
  char CSSValueStringPool_str494[sizeof("paint")];
  char CSSValueStringPool_str495[sizeof("-internal-upper-armenian")];
  char CSSValueStringPool_str496[sizeof("pre-line")];
  char CSSValueStringPool_str497[sizeof("both-edges")];
  char CSSValueStringPool_str498[sizeof("w")];
  char CSSValueStringPool_str499[sizeof("stretch")];
  char CSSValueStringPool_str500[sizeof("max")];
  char CSSValueStringPool_str501[sizeof("block-end")];
  char CSSValueStringPool_str502[sizeof("back-button")];
  char CSSValueStringPool_str503[sizeof("wrap")];
  char CSSValueStringPool_str504[sizeof("purple")];
  char CSSValueStringPool_str505[sizeof("pointer")];
  char CSSValueStringPool_str506[sizeof("matrix")];
  char CSSValueStringPool_str507[sizeof("skew")];
  char CSSValueStringPool_str508[sizeof("optional")];
  char CSSValueStringPool_str509[sizeof("plum")];
  char CSSValueStringPool_str510[sizeof("sticky")];
  char CSSValueStringPool_str511[sizeof("marktext")];
  char CSSValueStringPool_str512[sizeof("linktext")];
  char CSSValueStringPool_str513[sizeof("lightsteelblue")];
  char CSSValueStringPool_str514[sizeof("chocolate")];
  char CSSValueStringPool_str515[sizeof("painted")];
  char CSSValueStringPool_str516[sizeof("economy")];
  char CSSValueStringPool_str517[sizeof("minmax")];
  char CSSValueStringPool_str518[sizeof("span-self-start")];
  char CSSValueStringPool_str519[sizeof("scroll")];
  char CSSValueStringPool_str520[sizeof("mediumspringgreen")];
  char CSSValueStringPool_str521[sizeof("preserve")];
  char CSSValueStringPool_str522[sizeof("brightness")];
  char CSSValueStringPool_str523[sizeof("span-inline-start")];
  char CSSValueStringPool_str524[sizeof("lightgrey")];
  char CSSValueStringPool_str525[sizeof("lightgray")];
  char CSSValueStringPool_str526[sizeof("mixed")];
  char CSSValueStringPool_str527[sizeof("entry-crossing")];
  char CSSValueStringPool_str528[sizeof("fixed")];
  char CSSValueStringPool_str529[sizeof("semi-condensed")];
  char CSSValueStringPool_str530[sizeof("revert-layer")];
  char CSSValueStringPool_str531[sizeof("table-column")];
  char CSSValueStringPool_str532[sizeof("square")];
  char CSSValueStringPool_str533[sizeof("span-inline-end")];
  char CSSValueStringPool_str534[sizeof("matrix3d")];
  char CSSValueStringPool_str535[sizeof("silver")];
  char CSSValueStringPool_str536[sizeof("fieldtext")];
  char CSSValueStringPool_str537[sizeof("darkorchid")];
  char CSSValueStringPool_str538[sizeof("canvas")];
  char CSSValueStringPool_str539[sizeof("no-change")];
  char CSSValueStringPool_str540[sizeof("chartreuse")];
  char CSSValueStringPool_str541[sizeof("grayscale")];
  char CSSValueStringPool_str542[sizeof("wait")];
  char CSSValueStringPool_str543[sizeof("opentype")];
  char CSSValueStringPool_str544[sizeof("media-progress")];
  char CSSValueStringPool_str545[sizeof("inset-inline-start")];
  char CSSValueStringPool_str546[sizeof("aliceblue")];
  char CSSValueStringPool_str547[sizeof("break-all")];
  char CSSValueStringPool_str548[sizeof("wavy")];
  char CSSValueStringPool_str549[sizeof("crosshair")];
  char CSSValueStringPool_str550[sizeof("inset-inline-end")];
  char CSSValueStringPool_str551[sizeof("antialiased")];
  char CSSValueStringPool_str552[sizeof("block-start")];
  char CSSValueStringPool_str553[sizeof("seashell")];
  char CSSValueStringPool_str554[sizeof("palegoldenrod")];
  char CSSValueStringPool_str555[sizeof("self-start")];
  char CSSValueStringPool_str556[sizeof("scalex")];
  char CSSValueStringPool_str557[sizeof("paused")];
  char CSSValueStringPool_str558[sizeof("span-y-end")];
  char CSSValueStringPool_str559[sizeof("grammar-error")];
  char CSSValueStringPool_str560[sizeof("self-end")];
  char CSSValueStringPool_str561[sizeof("ivory")];
  char CSSValueStringPool_str562[sizeof("palevioletred")];
  char CSSValueStringPool_str563[sizeof("span-y-start")];
  char CSSValueStringPool_str564[sizeof("manipulation")];
  char CSSValueStringPool_str565[sizeof("jis-b4")];
  char CSSValueStringPool_str566[sizeof("jis-b5")];
  char CSSValueStringPool_str567[sizeof("grid")];
  char CSSValueStringPool_str568[sizeof("padding")];
  char CSSValueStringPool_str569[sizeof("small-caption")];
  char CSSValueStringPool_str570[sizeof("all-petite-caps")];
  char CSSValueStringPool_str571[sizeof("monospace")];
  char CSSValueStringPool_str572[sizeof("firebrick")];
  char CSSValueStringPool_str573[sizeof("buttonborder")];
  char CSSValueStringPool_str574[sizeof("thin")];
  char CSSValueStringPool_str575[sizeof("x-self-end")];
  char CSSValueStringPool_str576[sizeof("lightcyan")];
  char CSSValueStringPool_str577[sizeof("anchor")];
  char CSSValueStringPool_str578[sizeof("avoid")];
  char CSSValueStringPool_str579[sizeof("x-self-start")];
  char CSSValueStringPool_str580[sizeof("rotatex")];
  char CSSValueStringPool_str581[sizeof("ellipse")];
  char CSSValueStringPool_str582[sizeof("oldstyle-nums")];
  char CSSValueStringPool_str583[sizeof("thistle")];
  char CSSValueStringPool_str584[sizeof("all-small-caps")];
  char CSSValueStringPool_str585[sizeof("fallback")];
  char CSSValueStringPool_str586[sizeof("content-box")];
  char CSSValueStringPool_str587[sizeof("message-box")];
  char CSSValueStringPool_str588[sizeof("additive")];
  char CSSValueStringPool_str589[sizeof("ellipsis")];
  char CSSValueStringPool_str590[sizeof("before")];
  char CSSValueStringPool_str591[sizeof("pan-up")];
  char CSSValueStringPool_str592[sizeof("preserve-3d")];
  char CSSValueStringPool_str593[sizeof("gold")];
  char CSSValueStringPool_str594[sizeof("active")];
  char CSSValueStringPool_str595[sizeof("luminosity")];
  char CSSValueStringPool_str596[sizeof("var")];
  char CSSValueStringPool_str597[sizeof("text")];
  char CSSValueStringPool_str598[sizeof("menu")];
  char CSSValueStringPool_str599[sizeof("swap")];
  char CSSValueStringPool_str600[sizeof("color-svg")];
  char CSSValueStringPool_str601[sizeof("mathematical")];
  char CSSValueStringPool_str602[sizeof("olive")];
  char CSSValueStringPool_str603[sizeof("lightblue")];
  char CSSValueStringPool_str604[sizeof("vs")];
  char CSSValueStringPool_str605[sizeof("saturate")];
  char CSSValueStringPool_str606[sizeof("textarea")];
  char CSSValueStringPool_str607[sizeof("inactiveborder")];
  char CSSValueStringPool_str608[sizeof("y")];
  char CSSValueStringPool_str609[sizeof("alpha")];
  char CSSValueStringPool_str610[sizeof("-internal-spelling-error-color")];
  char CSSValueStringPool_str611[sizeof("violet")];
  char CSSValueStringPool_str612[sizeof("container-progress")];
  char CSSValueStringPool_str613[sizeof("pan-left")];
  char CSSValueStringPool_str614[sizeof("skyblue")];
  char CSSValueStringPool_str615[sizeof("inline")];
  char CSSValueStringPool_str616[sizeof("size")];
  char CSSValueStringPool_str617[sizeof("royalblue")];
  char CSSValueStringPool_str618[sizeof("row")];
  char CSSValueStringPool_str619[sizeof("font-tech")];
  char CSSValueStringPool_str620[sizeof("mediumpurple")];
  char CSSValueStringPool_str621[sizeof("titling-caps")];
  char CSSValueStringPool_str622[sizeof("saturation")];
  char CSSValueStringPool_str623[sizeof("inside")];
  char CSSValueStringPool_str624[sizeof("ex")];
  char CSSValueStringPool_str625[sizeof("indigo")];
  char CSSValueStringPool_str626[sizeof("match-source")];
  char CSSValueStringPool_str627[sizeof("progressive")];
  char CSSValueStringPool_str628[sizeof("annotation")];
  char CSSValueStringPool_str629[sizeof("source-atop")];
  char CSSValueStringPool_str630[sizeof("difference")];
  char CSSValueStringPool_str631[sizeof("exact")];
  char CSSValueStringPool_str632[sizeof("wrap-reverse")];
  char CSSValueStringPool_str633[sizeof("manual")];
  char CSSValueStringPool_str634[sizeof("isolate-override")];
  char CSSValueStringPool_str635[sizeof("mediumvioletred")];
  char CSSValueStringPool_str636[sizeof("show")];
  char CSSValueStringPool_str637[sizeof("goldenrod")];
  char CSSValueStringPool_str638[sizeof("indianred")];
  char CSSValueStringPool_str639[sizeof("color-contrast")];
  char CSSValueStringPool_str640[sizeof("flex")];
  char CSSValueStringPool_str641[sizeof("menulist")];
  char CSSValueStringPool_str642[sizeof("color-stop")];
  char CSSValueStringPool_str643[sizeof("-infinity")];
  char CSSValueStringPool_str644[sizeof("pretty")];
  char CSSValueStringPool_str645[sizeof("words")];
  char CSSValueStringPool_str646[sizeof("pan-y")];
  char CSSValueStringPool_str647[sizeof("searchfield")];
  char CSSValueStringPool_str648[sizeof("discretionary-ligatures")];
  char CSSValueStringPool_str649[sizeof("oklab")];
  char CSSValueStringPool_str650[sizeof("grabbing")];
  char CSSValueStringPool_str651[sizeof("span-self-end")];
  char CSSValueStringPool_str652[sizeof("column")];
  char CSSValueStringPool_str653[sizeof("auto")];
  char CSSValueStringPool_str654[sizeof("repeat-x")];
  char CSSValueStringPool_str655[sizeof("extends")];
  char CSSValueStringPool_str656[sizeof("exit")];
  char CSSValueStringPool_str657[sizeof("contextual")];
  char CSSValueStringPool_str658[sizeof("layout")];
  char CSSValueStringPool_str659[sizeof("document")];
  char CSSValueStringPool_str660[sizeof("span-y-self-start")];
  char CSSValueStringPool_str661[sizeof("span-right")];
  char CSSValueStringPool_str662[sizeof("scroll-state")];
  char CSSValueStringPool_str663[sizeof("scalez")];
  char CSSValueStringPool_str664[sizeof("buttontext")];
  char CSSValueStringPool_str665[sizeof("verso")];
  char CSSValueStringPool_str666[sizeof("hard-light")];
  char CSSValueStringPool_str667[sizeof("initial-only")];
  char CSSValueStringPool_str668[sizeof("lightpink")];
  char CSSValueStringPool_str669[sizeof("span-y-self-end")];
  char CSSValueStringPool_str670[sizeof("grid-order")];
  char CSSValueStringPool_str671[sizeof("max-content")];
  char CSSValueStringPool_str672[sizeof("no-historical-ligatures")];
  char CSSValueStringPool_str673[sizeof("hypot")];
  char CSSValueStringPool_str674[sizeof("mediumblue")];
  char CSSValueStringPool_str675[sizeof("no-contextual")];
  char CSSValueStringPool_str676[sizeof("translatex")];
  char CSSValueStringPool_str677[sizeof("lowercase")];
  char CSSValueStringPool_str678[sizeof("down")];
  char CSSValueStringPool_str679[sizeof("last-baseline")];
  char CSSValueStringPool_str680[sizeof("stroke")];
  char CSSValueStringPool_str681[sizeof("reduce")];
  char CSSValueStringPool_str682[sizeof("path")];
  char CSSValueStringPool_str683[sizeof("no-close-quote")];
  char CSSValueStringPool_str684[sizeof("lawngreen")];
  char CSSValueStringPool_str685[sizeof("geometricprecision")];
  char CSSValueStringPool_str686[sizeof("light-dark")];
  char CSSValueStringPool_str687[sizeof("rotatez")];
  char CSSValueStringPool_str688[sizeof("self-inline")];
  char CSSValueStringPool_str689[sizeof("nowrap")];
  char CSSValueStringPool_str690[sizeof("skewy")];
  char CSSValueStringPool_str691[sizeof("inline-grid")];
  char CSSValueStringPool_str692[sizeof("flip-block")];
  char CSSValueStringPool_str693[sizeof("exp")];
  char CSSValueStringPool_str694[sizeof("se-resize")];
  char CSSValueStringPool_str695[sizeof("s-resize")];
  char CSSValueStringPool_str696[sizeof("threedface")];
  char CSSValueStringPool_str697[sizeof("farthest-corner")];
  char CSSValueStringPool_str698[sizeof("aqua")];
  char CSSValueStringPool_str699[sizeof("palette-mix")];
  char CSSValueStringPool_str700[sizeof("inline-end")];
  char CSSValueStringPool_str701[sizeof("scrollbar")];
  char CSSValueStringPool_str702[sizeof("ne-resize")];
  char CSSValueStringPool_str703[sizeof("n-resize")];
  char CSSValueStringPool_str704[sizeof("blink-feature")];
  char CSSValueStringPool_str705[sizeof("captiontext")];
  char CSSValueStringPool_str706[sizeof("inherit")];
  char CSSValueStringPool_str707[sizeof("inline-start")];
  char CSSValueStringPool_str708[sizeof("soft-light")];
  char CSSValueStringPool_str709[sizeof("infinite")];
  char CSSValueStringPool_str710[sizeof("vertical")];
  char CSSValueStringPool_str711[sizeof("context-menu")];
  char CSSValueStringPool_str712[sizeof("ns-resize")];
  char CSSValueStringPool_str713[sizeof("aquamarine")];
  char CSSValueStringPool_str714[sizeof("features-graphite")];
  char CSSValueStringPool_str715[sizeof("reset-size")];
  char CSSValueStringPool_str716[sizeof("color-dodge")];
  char CSSValueStringPool_str717[sizeof("avoid-page")];
  char CSSValueStringPool_str718[sizeof("blanchedalmond")];
  char CSSValueStringPool_str719[sizeof("flex-start")];
  char CSSValueStringPool_str720[sizeof("not-allowed")];
  char CSSValueStringPool_str721[sizeof("col-resize")];
  char CSSValueStringPool_str722[sizeof("flex-end")];
  char CSSValueStringPool_str723[sizeof("gainsboro")];
  char CSSValueStringPool_str724[sizeof("y-start")];
  char CSSValueStringPool_str725[sizeof("backwards")];
  char CSSValueStringPool_str726[sizeof("selecteditemtext")];
  char CSSValueStringPool_str727[sizeof("justify")];
  char CSSValueStringPool_str728[sizeof("highlight")];
  char CSSValueStringPool_str729[sizeof("calc-size")];
  char CSSValueStringPool_str730[sizeof("table-column-group")];
  char CSSValueStringPool_str731[sizeof("listbox")];
  char CSSValueStringPool_str732[sizeof("text-top")];
  char CSSValueStringPool_str733[sizeof("scale-down")];
  char CSSValueStringPool_str734[sizeof("exclude")];
  char CSSValueStringPool_str735[sizeof("thick")];
  char CSSValueStringPool_str736[sizeof("exclusion")];
  char CSSValueStringPool_str737[sizeof("inner-spin-button")];
  char CSSValueStringPool_str738[sizeof("anchor-center")];
  char CSSValueStringPool_str739[sizeof("xx-large")];
  char CSSValueStringPool_str740[sizeof("break-spaces")];
  char CSSValueStringPool_str741[sizeof("perspective")];
  char CSSValueStringPool_str742[sizeof("ultra-expanded")];
  char CSSValueStringPool_str743[sizeof("conic-gradient")];
  char CSSValueStringPool_str744[sizeof("textfield")];
  char CSSValueStringPool_str745[sizeof("auto-add")];
  char CSSValueStringPool_str746[sizeof("y-end")];
  char CSSValueStringPool_str747[sizeof("margin-box")];
  char CSSValueStringPool_str748[sizeof("lavenderblush")];
  char CSSValueStringPool_str749[sizeof("open-quote")];
  char CSSValueStringPool_str750[sizeof("hwb")];
  char CSSValueStringPool_str751[sizeof("self-inline-start")];
  char CSSValueStringPool_str752[sizeof("view")];
  char CSSValueStringPool_str753[sizeof("table-caption")];
  char CSSValueStringPool_str754[sizeof("self-inline-end")];
  char CSSValueStringPool_str755[sizeof("translatez")];
  char CSSValueStringPool_str756[sizeof("expanded")];
  char CSSValueStringPool_str757[sizeof("vertical-rl")];
  char CSSValueStringPool_str758[sizeof("color-burn")];
  char CSSValueStringPool_str759[sizeof("midnightblue")];
  char CSSValueStringPool_str760[sizeof("fill-box")];
  char CSSValueStringPool_str761[sizeof("avoid-column")];
  char CSSValueStringPool_str762[sizeof("close-quote")];
  char CSSValueStringPool_str763[sizeof("oklch")];
  char CSSValueStringPool_str764[sizeof("inactivecaption")];
  char CSSValueStringPool_str765[sizeof("context-fill")];
  char CSSValueStringPool_str766[sizeof("inset-block-start")];
  char CSSValueStringPool_str767[sizeof("color-cbdt")];
  char CSSValueStringPool_str768[sizeof("inset-block-end")];
  char CSSValueStringPool_str769[sizeof("grid-columns")];
  char CSSValueStringPool_str770[sizeof("stacked-fractions")];
  char CSSValueStringPool_str771[sizeof("bidi-override")];
  char CSSValueStringPool_str772[sizeof("read-write")];
  char CSSValueStringPool_str773[sizeof("smooth")];
  char CSSValueStringPool_str774[sizeof("before-edge")];
  char CSSValueStringPool_str775[sizeof("olivedrab")];
  char CSSValueStringPool_str776[sizeof("span-x-end")];
  char CSSValueStringPool_str777[sizeof("span-x-start")];
  char CSSValueStringPool_str778[sizeof("proportional-nums")];
  char CSSValueStringPool_str779[sizeof("upright")];
  char CSSValueStringPool_str780[sizeof("honeydew")];
  char CSSValueStringPool_str781[sizeof("sideways")];
  char CSSValueStringPool_str782[sizeof("e-resize")];
  char CSSValueStringPool_str783[sizeof("-internal-search-color")];
  char CSSValueStringPool_str784[sizeof("vertical-lr")];
  char CSSValueStringPool_str785[sizeof("flex-visual")];
  char CSSValueStringPool_str786[sizeof("darkturquoise")];
  char CSSValueStringPool_str787[sizeof("mediumaquamarine")];
  char CSSValueStringPool_str788[sizeof("text-after-edge")];
  char CSSValueStringPool_str789[sizeof("ruby-text")];
  char CSSValueStringPool_str790[sizeof("rosybrown")];
  char CSSValueStringPool_str791[sizeof("span-block-start")];
  char CSSValueStringPool_str792[sizeof("mediumslateblue")];
  char CSSValueStringPool_str793[sizeof("picture-in-picture")];
  char CSSValueStringPool_str794[sizeof("row-reverse")];
  char CSSValueStringPool_str795[sizeof("span-block-end")];
  char CSSValueStringPool_str796[sizeof("groove")];
  char CSSValueStringPool_str797[sizeof("pan-right")];
  char CSSValueStringPool_str798[sizeof("alphabetic")];
  char CSSValueStringPool_str799[sizeof("-internal-lower-armenian")];
  char CSSValueStringPool_str800[sizeof("auto-fit")];
  char CSSValueStringPool_str801[sizeof("azure")];
  char CSSValueStringPool_str802[sizeof("-internal-textarea-auto")];
  char CSSValueStringPool_str803[sizeof("xx-small")];
  char CSSValueStringPool_str804[sizeof("table-footer-group")];
  char CSSValueStringPool_str805[sizeof("-internal-grammar-error-color")];
  char CSSValueStringPool_str806[sizeof("farthest-side")];
  char CSSValueStringPool_str807[sizeof("petite-caps")];
  char CSSValueStringPool_str808[sizeof("inline-table")];
  char CSSValueStringPool_str809[sizeof("above")];
  char CSSValueStringPool_str810[sizeof("text-bottom")];
  char CSSValueStringPool_str811[sizeof("rebeccapurple")];
  char CSSValueStringPool_str812[sizeof("features-opentype")];
  char CSSValueStringPool_str813[sizeof("weight")];
  char CSSValueStringPool_str814[sizeof("absolute")];
  char CSSValueStringPool_str815[sizeof("variations")];
  char CSSValueStringPool_str816[sizeof("mediumturquoise")];
  char CSSValueStringPool_str817[sizeof("graytext")];
  char CSSValueStringPool_str818[sizeof("span-self-inline-start")];
  char CSSValueStringPool_str819[sizeof("infinity")];
  char CSSValueStringPool_str820[sizeof("progress-bar")];
  char CSSValueStringPool_str821[sizeof("pan-x")];
  char CSSValueStringPool_str822[sizeof("minimized")];
  char CSSValueStringPool_str823[sizeof("span-self-inline-end")];
  char CSSValueStringPool_str824[sizeof("auto-fill")];
  char CSSValueStringPool_str825[sizeof("accentcolortext")];
  char CSSValueStringPool_str826[sizeof("column-reverse")];
  char CSSValueStringPool_str827[sizeof("pixelated")];
  char CSSValueStringPool_str828[sizeof("anchors-visible")];
  char CSSValueStringPool_str829[sizeof("deepskyblue")];
  char CSSValueStringPool_str830[sizeof("square-button")];
  char CSSValueStringPool_str831[sizeof("span-x-self-start")];
  char CSSValueStringPool_str832[sizeof("white")];
  char CSSValueStringPool_str833[sizeof("span-x-self-end")];
  char CSSValueStringPool_str834[sizeof("table-row")];
  char CSSValueStringPool_str835[sizeof("horizontal")];
  char CSSValueStringPool_str836[sizeof("subpixel-antialiased")];
  char CSSValueStringPool_str837[sizeof("wheat")];
  char CSSValueStringPool_str838[sizeof("block-axis")];
  char CSSValueStringPool_str839[sizeof("semi-expanded")];
  char CSSValueStringPool_str840[sizeof("y-self-end")];
  char CSSValueStringPool_str841[sizeof("burlywood")];
  char CSSValueStringPool_str842[sizeof("width")];
  char CSSValueStringPool_str843[sizeof("y-self-start")];
  char CSSValueStringPool_str844[sizeof("extra-condensed")];
  char CSSValueStringPool_str845[sizeof("-internal-hebrew")];
  char CSSValueStringPool_str846[sizeof("activeborder")];
  char CSSValueStringPool_str847[sizeof("context-stroke")];
  char CSSValueStringPool_str848[sizeof("lightslategrey")];
  char CSSValueStringPool_str849[sizeof("lightslategray")];
  char CSSValueStringPool_str850[sizeof("skewx")];
  char CSSValueStringPool_str851[sizeof("menulist-button")];
  char CSSValueStringPool_str852[sizeof("peru")];
  char CSSValueStringPool_str853[sizeof("border-box")];
  char CSSValueStringPool_str854[sizeof("non-scaling-stroke")];
  char CSSValueStringPool_str855[sizeof("pow")];
  char CSSValueStringPool_str856[sizeof("appworkspace")];
  char CSSValueStringPool_str857[sizeof("cap-height")];
  char CSSValueStringPool_str858[sizeof("scroll-position")];
  char CSSValueStringPool_str859[sizeof("darkkhaki")];
  char CSSValueStringPool_str860[sizeof("accumulate")];
  char CSSValueStringPool_str861[sizeof("saddlebrown")];
  char CSSValueStringPool_str862[sizeof("xyz")];
  char CSSValueStringPool_str863[sizeof("canvastext")];
  char CSSValueStringPool_str864[sizeof("most-inline-size")];
  char CSSValueStringPool_str865[sizeof("color-mix")];
  char CSSValueStringPool_str866[sizeof("-webkit-left")];
  char CSSValueStringPool_str867[sizeof("no-discretionary-ligatures")];
  char CSSValueStringPool_str868[sizeof("-internal-current-search-color")];
  char CSSValueStringPool_str869[sizeof("constrained-high")];
  char CSSValueStringPool_str870[sizeof("span-self-block-start")];
  char CSSValueStringPool_str871[sizeof("capitalize")];
  char CSSValueStringPool_str872[sizeof("-internal-quirk-inherit")];
  char CSSValueStringPool_str873[sizeof("anywhere")];
  char CSSValueStringPool_str874[sizeof("activecaption")];
  char CSSValueStringPool_str875[sizeof("span-self-block-end")];
  char CSSValueStringPool_str876[sizeof("cornflowerblue")];
  char CSSValueStringPool_str877[sizeof("woff")];
  char CSSValueStringPool_str878[sizeof("drop-shadow")];
  char CSSValueStringPool_str879[sizeof("woff2")];
  char CSSValueStringPool_str880[sizeof("tabular-nums")];
  char CSSValueStringPool_str881[sizeof("most-height")];
  char CSSValueStringPool_str882[sizeof("oblique")];
  char CSSValueStringPool_str883[sizeof("padding-box")];
  char CSSValueStringPool_str884[sizeof("inline-flex")];
  char CSSValueStringPool_str885[sizeof("lightyellow")];
  char CSSValueStringPool_str886[sizeof("below")];
  char CSSValueStringPool_str887[sizeof("-webkit-center")];
  char CSSValueStringPool_str888[sizeof("jump-both")];
  char CSSValueStringPool_str889[sizeof("preserve-parent-color")];
  char CSSValueStringPool_str890[sizeof("nesw-resize")];
  char CSSValueStringPool_str891[sizeof("pan-down")];
  char CSSValueStringPool_str892[sizeof("inline-layout")];
  char CSSValueStringPool_str893[sizeof("ic-width")];
  char CSSValueStringPool_str894[sizeof("swash")];
  char CSSValueStringPool_str895[sizeof("-internal-korean-hangul-formal")];
  char CSSValueStringPool_str896[sizeof("activetext")];
  char CSSValueStringPool_str897[sizeof("lightskyblue")];
  char CSSValueStringPool_str898[sizeof("block-size")];
  char CSSValueStringPool_str899[sizeof("menutext")];
  char CSSValueStringPool_str900[sizeof("-internal-ethiopic-numeric")];
  char CSSValueStringPool_str901[sizeof("bounding-box")];
  char CSSValueStringPool_str902[sizeof("-internal-simp-chinese-formal")];
  char CSSValueStringPool_str903[sizeof("xyz-d50")];
  char CSSValueStringPool_str904[sizeof("xyz-d65")];
  char CSSValueStringPool_str905[sizeof("always")];
  char CSSValueStringPool_str906[sizeof("-internal-simp-chinese-informal")];
  char CSSValueStringPool_str907[sizeof("-internal-trad-chinese-formal")];
  char CSSValueStringPool_str908[sizeof("space-between")];
  char CSSValueStringPool_str909[sizeof("-internal-trad-chinese-informal")];
  char CSSValueStringPool_str910[sizeof("dynamic-range-limit-mix")];
  char CSSValueStringPool_str911[sizeof("break-word")];
  char CSSValueStringPool_str912[sizeof("-webkit-calc")];
  char CSSValueStringPool_str913[sizeof("preserve-breaks")];
  char CSSValueStringPool_str914[sizeof("self-block")];
  char CSSValueStringPool_str915[sizeof("-webkit-control")];
  char CSSValueStringPool_str916[sizeof("pre-wrap")];
  char CSSValueStringPool_str917[sizeof("-webkit-isolate")];
  char CSSValueStringPool_str918[sizeof("inter-character")];
  char CSSValueStringPool_str919[sizeof("visible")];
  char CSSValueStringPool_str920[sizeof("push-button")];
  char CSSValueStringPool_str921[sizeof("-webkit-auto")];
  char CSSValueStringPool_str922[sizeof("exit-crossing")];
  char CSSValueStringPool_str923[sizeof("ic-height")];
  char CSSValueStringPool_str924[sizeof("self-block-start")];
  char CSSValueStringPool_str925[sizeof("-webkit-radial-gradient")];
  char CSSValueStringPool_str926[sizeof("self-block-end")];
  char CSSValueStringPool_str927[sizeof("sandybrown")];
  char CSSValueStringPool_str928[sizeof("-webkit-linear-gradient")];
  char CSSValueStringPool_str929[sizeof("-webkit-min-content")];
  char CSSValueStringPool_str930[sizeof("ch-width")];
  char CSSValueStringPool_str931[sizeof("horizontal-tb")];
  char CSSValueStringPool_str932[sizeof("table-header-group")];
  char CSSValueStringPool_str933[sizeof("inline-axis")];
  char CSSValueStringPool_str934[sizeof("most-width")];
  char CSSValueStringPool_str935[sizeof("mediumorchid")];
  char CSSValueStringPool_str936[sizeof("greenyellow")];
  char CSSValueStringPool_str937[sizeof("character-variant")];
  char CSSValueStringPool_str938[sizeof("w-resize")];
  char CSSValueStringPool_str939[sizeof("embedded-opentype")];
  char CSSValueStringPool_str940[sizeof("no-open-quote")];
  char CSSValueStringPool_str941[sizeof("plaintext")];
  char CSSValueStringPool_str942[sizeof("no-overflow")];
  char CSSValueStringPool_str943[sizeof("-webkit-mini-control")];
  char CSSValueStringPool_str944[sizeof("full-width")];
  char CSSValueStringPool_str945[sizeof("plus-lighter")];
  char CSSValueStringPool_str946[sizeof("floralwhite")];
  char CSSValueStringPool_str947[sizeof("-internal-variable-value")];
  char CSSValueStringPool_str948[sizeof("visual")];
  char CSSValueStringPool_str949[sizeof("window")];
  char CSSValueStringPool_str950[sizeof("color-colrv0")];
  char CSSValueStringPool_str951[sizeof("color-colrv1")];
  char CSSValueStringPool_str952[sizeof("proximity")];
  char CSSValueStringPool_str953[sizeof("lemonchiffon")];
  char CSSValueStringPool_str954[sizeof("peachpuff")];
  char CSSValueStringPool_str955[sizeof("-webkit-gradient")];
  char CSSValueStringPool_str956[sizeof("searchfield-cancel-button")];
  char CSSValueStringPool_str957[sizeof("color-sbix")];
  char CSSValueStringPool_str958[sizeof("ideographic")];
  char CSSValueStringPool_str959[sizeof("yellow")];
  char CSSValueStringPool_str960[sizeof("-internal-appearance-auto-base-select")];
  char CSSValueStringPool_str961[sizeof("inline-block")];
  char CSSValueStringPool_str962[sizeof("visiblepainted")];
  char CSSValueStringPool_str963[sizeof("slashed-zero")];
  char CSSValueStringPool_str964[sizeof("grid-rows")];
  char CSSValueStringPool_str965[sizeof("xxx-large")];
  char CSSValueStringPool_str966[sizeof("yellowgreen")];
  char CSSValueStringPool_str967[sizeof("whitesmoke")];
  char CSSValueStringPool_str968[sizeof("paleturquoise")];
  char CSSValueStringPool_str969[sizeof("text-before-edge")];
  char CSSValueStringPool_str970[sizeof("-internal-korean-hanja-formal")];
  char CSSValueStringPool_str971[sizeof("-internal-korean-hanja-informal")];
  char CSSValueStringPool_str972[sizeof("lightgoldenrodyellow")];
  char CSSValueStringPool_str973[sizeof("-webkit-isolate-override")];
  char CSSValueStringPool_str974[sizeof("xywh")];
  char CSSValueStringPool_str975[sizeof("row-resize")];
  char CSSValueStringPool_str976[sizeof("visiblefill")];
  char CSSValueStringPool_str977[sizeof("sw-resize")];
  char CSSValueStringPool_str978[sizeof("-webkit-image-set")];
  char CSSValueStringPool_str979[sizeof("inactivecaptiontext")];
  char CSSValueStringPool_str980[sizeof("nw-resize")];
  char CSSValueStringPool_str981[sizeof("buttonshadow")];
  char CSSValueStringPool_str982[sizeof("infotext")];
  char CSSValueStringPool_str983[sizeof("optimizespeed")];
  char CSSValueStringPool_str984[sizeof("-webkit-link")];
  char CSSValueStringPool_str985[sizeof("extra-expanded")];
  char CSSValueStringPool_str986[sizeof("-webkit-fit-content")];
  char CSSValueStringPool_str987[sizeof("-webkit-max-content")];
  char CSSValueStringPool_str988[sizeof("most-block-size")];
  char CSSValueStringPool_str989[sizeof("highlighttext")];
  char CSSValueStringPool_str990[sizeof("auto-phrase")];
  char CSSValueStringPool_str991[sizeof("-webkit-baseline-middle")];
  char CSSValueStringPool_str992[sizeof("-webkit-cross-fade")];
  char CSSValueStringPool_str993[sizeof("anchor-size")];
  char CSSValueStringPool_str994[sizeof("-webkit-grab")];
  char CSSValueStringPool_str995[sizeof("-internal-search-text-color")];
  char CSSValueStringPool_str996[sizeof("maximized")];
  char CSSValueStringPool_str997[sizeof("-webkit-box")];
  char CSSValueStringPool_str998[sizeof("ex-height")];
  char CSSValueStringPool_str999[sizeof("-webkit-body")];
  char CSSValueStringPool_str1000[sizeof("line-through")];
  char CSSValueStringPool_str1001[sizeof("vertical-text")];
  char CSSValueStringPool_str1002[sizeof("ew-resize")];
  char CSSValueStringPool_str1003[sizeof("checkbox")];
  char CSSValueStringPool_str1004[sizeof("allow-discrete")];
  char CSSValueStringPool_str1005[sizeof("powderblue")];
  char CSSValueStringPool_str1006[sizeof("inline-size")];
  char CSSValueStringPool_str1007[sizeof("buttonhighlight")];
  char CSSValueStringPool_str1008[sizeof("nwse-resize")];
  char CSSValueStringPool_str1009[sizeof("-webkit-small-control")];
  char CSSValueStringPool_str1010[sizeof("stroke-box")];
  char CSSValueStringPool_str1011[sizeof("visitedtext")];
  char CSSValueStringPool_str1012[sizeof("-webkit-activelink")];
  char CSSValueStringPool_str1013[sizeof("flex-flow")];
  char CSSValueStringPool_str1014[sizeof("auto-flow")];
  char CSSValueStringPool_str1015[sizeof("windowframe")];
  char CSSValueStringPool_str1016[sizeof("visiblestroke")];
  char CSSValueStringPool_str1017[sizeof("-webkit-focus-ring-color")];
  char CSSValueStringPool_str1018[sizeof("vertical-right")];
  char CSSValueStringPool_str1019[sizeof("pinch-zoom")];
  char CSSValueStringPool_str1020[sizeof("infobackground")];
  char CSSValueStringPool_str1021[sizeof("-webkit-fill-available")];
  char CSSValueStringPool_str1022[sizeof("prophoto-rgb")];
  char CSSValueStringPool_str1023[sizeof("navajowhite")];
  char CSSValueStringPool_str1024[sizeof("view-box")];
  char CSSValueStringPool_str1025[sizeof("-internal-active-list-box-selection")];
  char CSSValueStringPool_str1026[sizeof("-internal-current-search-text-color")];
  char CSSValueStringPool_str1027[sizeof("table-row-group")];
  char CSSValueStringPool_str1028[sizeof("-webkit-grabbing")];
  char CSSValueStringPool_str1029[sizeof("-internal-extend-to-zoom")];
  char CSSValueStringPool_str1030[sizeof("slider-horizontal")];
  char CSSValueStringPool_str1031[sizeof("-webkit-repeating-linear-gradient")];
  char CSSValueStringPool_str1032[sizeof("sideways-right")];
  char CSSValueStringPool_str1033[sizeof("threedshadow")];
  char CSSValueStringPool_str1034[sizeof("-webkit-repeating-radial-gradient")];
  char CSSValueStringPool_str1035[sizeof("cubic-bezier")];
  char CSSValueStringPool_str1036[sizeof("-internal-inactive-list-box-selection")];
  char CSSValueStringPool_str1037[sizeof("-webkit-match-parent")];
  char CSSValueStringPool_str1038[sizeof("windowtext")];
  char CSSValueStringPool_str1039[sizeof("-webkit-inline-flex")];
  char CSSValueStringPool_str1040[sizeof("read-write-plaintext-only")];
  char CSSValueStringPool_str1041[sizeof("-webkit-flex")];
  char CSSValueStringPool_str1042[sizeof("-webkit-zoom-in")];
  char CSSValueStringPool_str1043[sizeof("threedhighlight")];
  char CSSValueStringPool_str1044[sizeof("-webkit-inline-box")];
  char CSSValueStringPool_str1045[sizeof("proportional-width")];
  char CSSValueStringPool_str1046[sizeof("-webkit-plaintext")];
  char CSSValueStringPool_str1047[sizeof("after-white-space")];
  char CSSValueStringPool_str1048[sizeof("papayawhip")];
  char CSSValueStringPool_str1049[sizeof("-webkit-right")];
  char CSSValueStringPool_str1050[sizeof("-webkit-zoom-out")];
  char CSSValueStringPool_str1051[sizeof("window-controls-overlay")];
  char CSSValueStringPool_str1052[sizeof("threeddarkshadow")];
  char CSSValueStringPool_str1053[sizeof("ghostwhite")];
  char CSSValueStringPool_str1054[sizeof("-webkit-optimize-contrast")];
  char CSSValueStringPool_str1055[sizeof("optimizelegibility")];
  char CSSValueStringPool_str1056[sizeof("optimizequality")];
  char CSSValueStringPool_str1057[sizeof("antiquewhite")];
  char CSSValueStringPool_str1058[sizeof("threedlightshadow")];
  char CSSValueStringPool_str1059[sizeof("-internal-active-list-box-selection-text")];
  char CSSValueStringPool_str1060[sizeof("-internal-inactive-list-box-selection-text")];
  char CSSValueStringPool_str1061[sizeof("-webkit-xxx-large")];
};
static const struct CSSValueStringPool_t CSSValueStringPool_contents =
    {
        "s",
        "h",
        "l",
        "lr",
        "sin",
        "min",
        "ltr",
        "z",
        "drag",
        "start",
        "dark",
        "mark",
        "fine",
        "lime",
        "large",
        "meter",
        "miter",
        "linen",
        "r",
        "darken",
        "larger",
        "linear",
        "dot",
        "hanging",
        "seagreen",
        "nan",
        "magenta",
        "rem",
        "log",
        "disc",
        "drop",
        "more",
        "steps",
        "darkgreen",
        "limegreen",
        "c",
        "longer",
        "markers",
        "none",
        "from",
        "hide",
        "srgb",
        "field",
        "reset",
        "darkorange",
        "format",
        "nearest",
        "help",
        "ledger",
        "frames",
        "slice",
        "fill",
        "small",
        "darkred",
        "mod",
        "red",
        "rl",
        "smaller",
        "ridge",
        "rtl",
        "hsl",
        "sides",
        "zoom",
        "nonzero",
        "svg",
        "cos",
        "coarse",
        "letter",
        "b",
        "calc",
        "cell",
        "clip",
        "b4",
        "b5",
        "forestgreen",
        "salmon",
        "stable",
        "circle",
        "filled",
        "move",
        "last",
        "fast",
        "beige",
        "scale",
        "hover",
        "unset",
        "navy",
        "revert",
        "unicase",
        "screen",
        "hue",
        "crimson",
        "tan",
        "normal",
        "teal",
        "darksalmon",
        "dense",
        "first",
        "url",
        "under",
        "center",
        "to",
        "sesame",
        "flat",
        "rec2020",
        "reverse",
        "root",
        "on",
        "less",
        "lavender",
        "raise",
        "dotted",
        "decreasing",
        "cover",
        "rotate",
        "sign",
        "space",
        "unicode",
        "content",
        "contain",
        "scale3d",
        "sienna",
        "moccasin",
        "legal",
        "loose",
        "hsla",
        "darkviolet",
        "false",
        "compact",
        "contents",
        "contrast",
        "repeat",
        "central",
        "step-start",
        "cap",
        "static",
        "selector",
        "baseline",
        "linear-gradient",
        "underline",
        "step-end",
        "clear",
        "rotate3d",
        "rect",
        "mintcream",
        "from-image",
        "only",
        "darkolivegreen",
        "numbers",
        "coral",
        "up",
        "copy",
        "zoom-in",
        "recto",
        "over",
        "bottom",
        "darkgoldenrod",
        "double",
        "bevel",
        "flip-start",
        "e",
        "true",
        "standard",
        "hue-rotate",
        "hand",
        "safe",
        "collection",
        "numeric",
        "clone",
        "clamp",
        "list-item",
        "separate",
        "relative",
        "leading",
        "tomato",
        "blur",
        "bisque",
        "blue",
        "super",
        "ease",
        "local",
        "standalone",
        "replace",
        "top",
        "srgb-linear",
        "end",
        "triangle",
        "custom",
        "overline",
        "ornaments",
        "collapse",
        "span",
        "butt",
        "hidden",
        "caption",
        "bullets",
        "running",
        "keep-all",
        "orange",
        "darkseagreen",
        "to-zero",
        "rotate-right",
        "destination-in",
        "fullscreen",
        "trim-start",
        "supports",
        "emoji",
        "button",
        "env",
        "element",
        "left",
        "counter",
        "no-repeat",
        "middle",
        "oldlace",
        "round",
        "min-content",
        "fit-content",
        "translate",
        "orangered",
        "zoom-out",
        "counters",
        "balance",
        "translate3d",
        "simplified",
        "a",
        "x",
        "cursive",
        "folded",
        "at",
        "aa",
        "a3",
        "a4",
        "a5",
        "-internal-center",
        "aaa",
        "lab",
        "attr",
        "arg",
        "border",
        "style",
        "no-clip",
        "layer",
        "of",
        "outset",
        "condensed",
        "enabled",
        "dimgrey",
        "dimgray",
        "crispedges",
        "source-in",
        "xor",
        "ray",
        "rgb",
        "snow",
        "darkgrey",
        "darkgray",
        "space-all",
        "linearrgb",
        "background",
        "darkmagenta",
        "styleset",
        "traditional",
        "bold",
        "spelling-error",
        "destination-over",
        "ease-in",
        "bolder",
        "outside",
        "turquoise",
        "closest-side",
        "continuous",
        "blueviolet",
        "open",
        "no-drag",
        "slow",
        "alternate",
        "flow",
        "disclosure-open",
        "add",
        "destination-out",
        "unsafe",
        "from-font",
        "all",
        "selecteditem",
        "span-start",
        "use-script",
        "forwards",
        "small-caps",
        "borderless",
        "scaley",
        "tb",
        "destination-atop",
        "span-end",
        "sub",
        "spell-out",
        "fantasy",
        "darkcyan",
        "table",
        "rgba",
        "brown",
        "currentcolor",
        "darkslategrey",
        "darkslategray",
        "space-around",
        "uppercase",
        "stylistic",
        "flip-inline",
        "source-over",
        "atan",
        "disclosure-closed",
        "default",
        "ruby",
        "atan2",
        "slategrey",
        "slategray",
        "rotatey",
        "browser",
        "in",
        "source-out",
        "aa-large",
        "aaa-large",
        "historical-ligatures",
        "landscape",
        "mistyrose",
        "math",
        "fabricated",
        "high",
        "asin",
        "span-all",
        "subgrid",
        "light",
        "sans-serif",
        "alias",
        "jis78",
        "jis90",
        "jis83",
        "lighten",
        "jis04",
        "lighter",
        "no-common-ligatures",
        "digits",
        "darkblue",
        "hotpink",
        "ease-out",
        "cyan",
        "closest-corner",
        "right",
        "inset",
        "lightgreen",
        "base-select",
        "repeating-linear-gradient",
        "transparent",
        "no-preference",
        "tabbed",
        "evenodd",
        "legacy",
        "double-circle",
        "isolate",
        "dynamic",
        "on-demand",
        "lr-tb",
        "darkslateblue",
        "symbolic",
        "no-drop",
        "dashed",
        "steelblue",
        "span-top",
        "acos",
        "radio",
        "historical-forms",
        "dodgerblue",
        "cyclic",
        "x-start",
        "entry",
        "invert",
        "after",
        "strict",
        "off",
        "solid",
        "type",
        "cadetblue",
        "flow-root",
        "italic",
        "radial",
        "cross-fade",
        "no-autospace",
        "font-format",
        "both",
        "overlay",
        "mandatory",
        "x-small",
        "rl-tb",
        "incremental",
        "diagonal-fractions",
        "embed",
        "inverted",
        "sepia",
        "initial",
        "x-large",
        "lightsalmon",
        "opacity",
        "black",
        "intersect",
        "tb-rl",
        "repeating-radial-gradient",
        "increasing",
        "buttonface",
        "subtract",
        "slateblue",
        "no-punctuation",
        "decimal",
        "deeppink",
        "first-baseline",
        "medium",
        "space-first",
        "repeat-y",
        "block",
        "x-end",
        "interlace",
        "logical",
        "pi",
        "p3",
        "image-set",
        "rotate-left",
        "pre",
        "-internal-media-control",
        "inset-area",
        "pink",
        "springgreen",
        "page",
        "repeating-conic-gradient",
        "translatey",
        "lightcoral",
        "alternate-reverse",
        "span-left",
        "any",
        "system-ui",
        "maroon",
        "status-bar",
        "tech",
        "display-p3",
        "g",
        "features-aat",
        "abs",
        "luminance",
        "literal-punctuation",
        "mediumseagreen",
        "space-evenly",
        "paged",
        "truetype",
        "ultra-condensed",
        "ordinal",
        "height",
        "green",
        "serif",
        "grey",
        "gray",
        "fuchsia",
        "palegreen",
        "shorter",
        "progress",
        "sqrt",
        "icon",
        "palettes",
        "accentcolor",
        "grab",
        "lining-nums",
        "self",
        "cornsilk",
        "radial-gradient",
        "all-scroll",
        "slider-vertical",
        "jump-none",
        "khaki",
        "blink",
        "ease-in-out",
        "after-edge",
        "jump-start",
        "math-auto",
        "multiply",
        "orchid",
        "polygon",
        "color",
        "portrait",
        "jump-end",
        "lightseagreen",
        "common-ligatures",
        "a98-rgb",
        "table-cell",
        "minimal-ui",
        "lch",
        "span-bottom",
        "read-only",
        "paint",
        "-internal-upper-armenian",
        "pre-line",
        "both-edges",
        "w",
        "stretch",
        "max",
        "block-end",
        "back-button",
        "wrap",
        "purple",
        "pointer",
        "matrix",
        "skew",
        "optional",
        "plum",
        "sticky",
        "marktext",
        "linktext",
        "lightsteelblue",
        "chocolate",
        "painted",
        "economy",
        "minmax",
        "span-self-start",
        "scroll",
        "mediumspringgreen",
        "preserve",
        "brightness",
        "span-inline-start",
        "lightgrey",
        "lightgray",
        "mixed",
        "entry-crossing",
        "fixed",
        "semi-condensed",
        "revert-layer",
        "table-column",
        "square",
        "span-inline-end",
        "matrix3d",
        "silver",
        "fieldtext",
        "darkorchid",
        "canvas",
        "no-change",
        "chartreuse",
        "grayscale",
        "wait",
        "opentype",
        "media-progress",
        "inset-inline-start",
        "aliceblue",
        "break-all",
        "wavy",
        "crosshair",
        "inset-inline-end",
        "antialiased",
        "block-start",
        "seashell",
        "palegoldenrod",
        "self-start",
        "scalex",
        "paused",
        "span-y-end",
        "grammar-error",
        "self-end",
        "ivory",
        "palevioletred",
        "span-y-start",
        "manipulation",
        "jis-b4",
        "jis-b5",
        "grid",
        "padding",
        "small-caption",
        "all-petite-caps",
        "monospace",
        "firebrick",
        "buttonborder",
        "thin",
        "x-self-end",
        "lightcyan",
        "anchor",
        "avoid",
        "x-self-start",
        "rotatex",
        "ellipse",
        "oldstyle-nums",
        "thistle",
        "all-small-caps",
        "fallback",
        "content-box",
        "message-box",
        "additive",
        "ellipsis",
        "before",
        "pan-up",
        "preserve-3d",
        "gold",
        "active",
        "luminosity",
        "var",
        "text",
        "menu",
        "swap",
        "color-svg",
        "mathematical",
        "olive",
        "lightblue",
        "vs",
        "saturate",
        "textarea",
        "inactiveborder",
        "y",
        "alpha",
        "-internal-spelling-error-color",
        "violet",
        "container-progress",
        "pan-left",
        "skyblue",
        "inline",
        "size",
        "royalblue",
        "row",
        "font-tech",
        "mediumpurple",
        "titling-caps",
        "saturation",
        "inside",
        "ex",
        "indigo",
        "match-source",
        "progressive",
        "annotation",
        "source-atop",
        "difference",
        "exact",
        "wrap-reverse",
        "manual",
        "isolate-override",
        "mediumvioletred",
        "show",
        "goldenrod",
        "indianred",
        "color-contrast",
        "flex",
        "menulist",
        "color-stop",
        "-infinity",
        "pretty",
        "words",
        "pan-y",
        "searchfield",
        "discretionary-ligatures",
        "oklab",
        "grabbing",
        "span-self-end",
        "column",
        "auto",
        "repeat-x",
        "extends",
        "exit",
        "contextual",
        "layout",
        "document",
        "span-y-self-start",
        "span-right",
        "scroll-state",
        "scalez",
        "buttontext",
        "verso",
        "hard-light",
        "initial-only",
        "lightpink",
        "span-y-self-end",
        "grid-order",
        "max-content",
        "no-historical-ligatures",
        "hypot",
        "mediumblue",
        "no-contextual",
        "translatex",
        "lowercase",
        "down",
        "last-baseline",
        "stroke",
        "reduce",
        "path",
        "no-close-quote",
        "lawngreen",
        "geometricprecision",
        "light-dark",
        "rotatez",
        "self-inline",
        "nowrap",
        "skewy",
        "inline-grid",
        "flip-block",
        "exp",
        "se-resize",
        "s-resize",
        "threedface",
        "farthest-corner",
        "aqua",
        "palette-mix",
        "inline-end",
        "scrollbar",
        "ne-resize",
        "n-resize",
        "blink-feature",
        "captiontext",
        "inherit",
        "inline-start",
        "soft-light",
        "infinite",
        "vertical",
        "context-menu",
        "ns-resize",
        "aquamarine",
        "features-graphite",
        "reset-size",
        "color-dodge",
        "avoid-page",
        "blanchedalmond",
        "flex-start",
        "not-allowed",
        "col-resize",
        "flex-end",
        "gainsboro",
        "y-start",
        "backwards",
        "selecteditemtext",
        "justify",
        "highlight",
        "calc-size",
        "table-column-group",
        "listbox",
        "text-top",
        "scale-down",
        "exclude",
        "thick",
        "exclusion",
        "inner-spin-button",
        "anchor-center",
        "xx-large",
        "break-spaces",
        "perspective",
        "ultra-expanded",
        "conic-gradient",
        "textfield",
        "auto-add",
        "y-end",
        "margin-box",
        "lavenderblush",
        "open-quote",
        "hwb",
        "self-inline-start",
        "view",
        "table-caption",
        "self-inline-end",
        "translatez",
        "expanded",
        "vertical-rl",
        "color-burn",
        "midnightblue",
        "fill-box",
        "avoid-column",
        "close-quote",
        "oklch",
        "inactivecaption",
        "context-fill",
        "inset-block-start",
        "color-cbdt",
        "inset-block-end",
        "grid-columns",
        "stacked-fractions",
        "bidi-override",
        "read-write",
        "smooth",
        "before-edge",
        "olivedrab",
        "span-x-end",
        "span-x-start",
        "proportional-nums",
        "upright",
        "honeydew",
        "sideways",
        "e-resize",
        "-internal-search-color",
        "vertical-lr",
        "flex-visual",
        "darkturquoise",
        "mediumaquamarine",
        "text-after-edge",
        "ruby-text",
        "rosybrown",
        "span-block-start",
        "mediumslateblue",
        "picture-in-picture",
        "row-reverse",
        "span-block-end",
        "groove",
        "pan-right",
        "alphabetic",
        "-internal-lower-armenian",
        "auto-fit",
        "azure",
        "-internal-textarea-auto",
        "xx-small",
        "table-footer-group",
        "-internal-grammar-error-color",
        "farthest-side",
        "petite-caps",
        "inline-table",
        "above",
        "text-bottom",
        "rebeccapurple",
        "features-opentype",
        "weight",
        "absolute",
        "variations",
        "mediumturquoise",
        "graytext",
        "span-self-inline-start",
        "infinity",
        "progress-bar",
        "pan-x",
        "minimized",
        "span-self-inline-end",
        "auto-fill",
        "accentcolortext",
        "column-reverse",
        "pixelated",
        "anchors-visible",
        "deepskyblue",
        "square-button",
        "span-x-self-start",
        "white",
        "span-x-self-end",
        "table-row",
        "horizontal",
        "subpixel-antialiased",
        "wheat",
        "block-axis",
        "semi-expanded",
        "y-self-end",
        "burlywood",
        "width",
        "y-self-start",
        "extra-condensed",
        "-internal-hebrew",
        "activeborder",
        "context-stroke",
        "lightslategrey",
        "lightslategray",
        "skewx",
        "menulist-button",
        "peru",
        "border-box",
        "non-scaling-stroke",
        "pow",
        "appworkspace",
        "cap-height",
        "scroll-position",
        "darkkhaki",
        "accumulate",
        "saddlebrown",
        "xyz",
        "canvastext",
        "most-inline-size",
        "color-mix",
        "-webkit-left",
        "no-discretionary-ligatures",
        "-internal-current-search-color",
        "constrained-high",
        "span-self-block-start",
        "capitalize",
        "-internal-quirk-inherit",
        "anywhere",
        "activecaption",
        "span-self-block-end",
        "cornflowerblue",
        "woff",
        "drop-shadow",
        "woff2",
        "tabular-nums",
        "most-height",
        "oblique",
        "padding-box",
        "inline-flex",
        "lightyellow",
        "below",
        "-webkit-center",
        "jump-both",
        "preserve-parent-color",
        "nesw-resize",
        "pan-down",
        "inline-layout",
        "ic-width",
        "swash",
        "-internal-korean-hangul-formal",
        "activetext",
        "lightskyblue",
        "block-size",
        "menutext",
        "-internal-ethiopic-numeric",
        "bounding-box",
        "-internal-simp-chinese-formal",
        "xyz-d50",
        "xyz-d65",
        "always",
        "-internal-simp-chinese-informal",
        "-internal-trad-chinese-formal",
        "space-between",
        "-internal-trad-chinese-informal",
        "dynamic-range-limit-mix",
        "break-word",
        "-webkit-calc",
        "preserve-breaks",
        "self-block",
        "-webkit-control",
        "pre-wrap",
        "-webkit-isolate",
        "inter-character",
        "visible",
        "push-button",
        "-webkit-auto",
        "exit-crossing",
        "ic-height",
        "self-block-start",
        "-webkit-radial-gradient",
        "self-block-end",
        "sandybrown",
        "-webkit-linear-gradient",
        "-webkit-min-content",
        "ch-width",
        "horizontal-tb",
        "table-header-group",
        "inline-axis",
        "most-width",
        "mediumorchid",
        "greenyellow",
        "character-variant",
        "w-resize",
        "embedded-opentype",
        "no-open-quote",
        "plaintext",
        "no-overflow",
        "-webkit-mini-control",
        "full-width",
        "plus-lighter",
        "floralwhite",
        "-internal-variable-value",
        "visual",
        "window",
        "color-colrv0",
        "color-colrv1",
        "proximity",
        "lemonchiffon",
        "peachpuff",
        "-webkit-gradient",
        "searchfield-cancel-button",
        "color-sbix",
        "ideographic",
        "yellow",
        "-internal-appearance-auto-base-select",
        "inline-block",
        "visiblepainted",
        "slashed-zero",
        "grid-rows",
        "xxx-large",
        "yellowgreen",
        "whitesmoke",
        "paleturquoise",
        "text-before-edge",
        "-internal-korean-hanja-formal",
        "-internal-korean-hanja-informal",
        "lightgoldenrodyellow",
        "-webkit-isolate-override",
        "xywh",
        "row-resize",
        "visiblefill",
        "sw-resize",
        "-webkit-image-set",
        "inactivecaptiontext",
        "nw-resize",
        "buttonshadow",
        "infotext",
        "optimizespeed",
        "-webkit-link",
        "extra-expanded",
        "-webkit-fit-content",
        "-webkit-max-content",
        "most-block-size",
        "highlighttext",
        "auto-phrase",
        "-webkit-baseline-middle",
        "-webkit-cross-fade",
        "anchor-size",
        "-webkit-grab",
        "-internal-search-text-color",
        "maximized",
        "-webkit-box",
        "ex-height",
        "-webkit-body",
        "line-through",
        "vertical-text",
        "ew-resize",
        "checkbox",
        "allow-discrete",
        "powderblue",
        "inline-size",
        "buttonhighlight",
        "nwse-resize",
        "-webkit-small-control",
        "stroke-box",
        "visitedtext",
        "-webkit-activelink",
        "flex-flow",
        "auto-flow",
        "windowframe",
        "visiblestroke",
        "-webkit-focus-ring-color",
        "vertical-right",
        "pinch-zoom",
        "infobackground",
        "-webkit-fill-available",
        "prophoto-rgb",
        "navajowhite",
        "view-box",
        "-internal-active-list-box-selection",
        "-internal-current-search-text-color",
        "table-row-group",
        "-webkit-grabbing",
        "-internal-extend-to-zoom",
        "slider-horizontal",
        "-webkit-repeating-linear-gradient",
        "sideways-right",
        "threedshadow",
        "-webkit-repeating-radial-gradient",
        "cubic-bezier",
        "-internal-inactive-list-box-selection",
        "-webkit-match-parent",
        "windowtext",
        "-webkit-inline-flex",
        "read-write-plaintext-only",
        "-webkit-flex",
        "-webkit-zoom-in",
        "threedhighlight",
        "-webkit-inline-box",
        "proportional-width",
        "-webkit-plaintext",
        "after-white-space",
        "papayawhip",
        "-webkit-right",
        "-webkit-zoom-out",
        "window-controls-overlay",
        "threeddarkshadow",
        "ghostwhite",
        "-webkit-optimize-contrast",
        "optimizelegibility",
        "optimizequality",
        "antiquewhite",
        "threedlightshadow",
        "-internal-active-list-box-selection-text",
        "-internal-inactive-list-box-selection-text",
        "-webkit-xxx-large"
};
#define CSSValueStringPool ((const char *) &CSSValueStringPool_contents)
const struct Value *
CSSValueKeywordsHash::findValueImpl (const char *str, size_t len)
{
  enum
  {
    TOTAL_KEYWORDS = 1062,
    MIN_WORD_LENGTH = 1,
    MAX_WORD_LENGTH = 42,
    MIN_HASH_VALUE = 7,
    MAX_HASH_VALUE = 8852
  };

  static const struct Value value_word_list[] =
      {
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str0, static_cast<int>(CSSValueID::kS)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1, static_cast<int>(CSSValueID::kH)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str2, static_cast<int>(CSSValueID::kL)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str3, static_cast<int>(CSSValueID::kLr)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str4, static_cast<int>(CSSValueID::kSin)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str5, static_cast<int>(CSSValueID::kMin)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str6, static_cast<int>(CSSValueID::kLtr)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str7, static_cast<int>(CSSValueID::kZ)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str8, static_cast<int>(CSSValueID::kDrag)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str9, static_cast<int>(CSSValueID::kStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str10, static_cast<int>(CSSValueID::kDark)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str11, static_cast<int>(CSSValueID::kMark)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str12, static_cast<int>(CSSValueID::kFine)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str13, static_cast<int>(CSSValueID::kLime)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str14, static_cast<int>(CSSValueID::kLarge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str15, static_cast<int>(CSSValueID::kMeter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str16, static_cast<int>(CSSValueID::kMiter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str17, static_cast<int>(CSSValueID::kLinen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str18, static_cast<int>(CSSValueID::kR)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str19, static_cast<int>(CSSValueID::kDarken)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str20, static_cast<int>(CSSValueID::kLarger)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str21, static_cast<int>(CSSValueID::kLinear)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str22, static_cast<int>(CSSValueID::kDot)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str23, static_cast<int>(CSSValueID::kHanging)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str24, static_cast<int>(CSSValueID::kSeagreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str25, static_cast<int>(CSSValueID::kNan)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str26, static_cast<int>(CSSValueID::kMagenta)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str27, static_cast<int>(CSSValueID::kRem)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str28, static_cast<int>(CSSValueID::kLog)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str29, static_cast<int>(CSSValueID::kDisc)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str30, static_cast<int>(CSSValueID::kDrop)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str31, static_cast<int>(CSSValueID::kMore)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str32, static_cast<int>(CSSValueID::kSteps)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str33, static_cast<int>(CSSValueID::kDarkgreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str34, static_cast<int>(CSSValueID::kLimegreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str35, static_cast<int>(CSSValueID::kC)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str36, static_cast<int>(CSSValueID::kLonger)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str37, static_cast<int>(CSSValueID::kMarkers)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str38, static_cast<int>(CSSValueID::kNone)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str39, static_cast<int>(CSSValueID::kFrom)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str40, static_cast<int>(CSSValueID::kHide)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str41, static_cast<int>(CSSValueID::kSRGB)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str42, static_cast<int>(CSSValueID::kField)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str43, static_cast<int>(CSSValueID::kReset)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str44, static_cast<int>(CSSValueID::kDarkorange)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str45, static_cast<int>(CSSValueID::kFormat)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str46, static_cast<int>(CSSValueID::kNearest)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str47, static_cast<int>(CSSValueID::kHelp)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str48, static_cast<int>(CSSValueID::kLedger)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str49, static_cast<int>(CSSValueID::kFrames)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str50, static_cast<int>(CSSValueID::kSlice)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str51, static_cast<int>(CSSValueID::kFill)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str52, static_cast<int>(CSSValueID::kSmall)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str53, static_cast<int>(CSSValueID::kDarkred)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str54, static_cast<int>(CSSValueID::kMod)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str55, static_cast<int>(CSSValueID::kRed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str56, static_cast<int>(CSSValueID::kRl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str57, static_cast<int>(CSSValueID::kSmaller)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str58, static_cast<int>(CSSValueID::kRidge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str59, static_cast<int>(CSSValueID::kRtl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str60, static_cast<int>(CSSValueID::kHsl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str61, static_cast<int>(CSSValueID::kSides)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str62, static_cast<int>(CSSValueID::kZoom)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str63, static_cast<int>(CSSValueID::kNonzero)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str64, static_cast<int>(CSSValueID::kSVG)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str65, static_cast<int>(CSSValueID::kCos)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str66, static_cast<int>(CSSValueID::kCoarse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str67, static_cast<int>(CSSValueID::kLetter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str68, static_cast<int>(CSSValueID::kB)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str69, static_cast<int>(CSSValueID::kCalc)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str70, static_cast<int>(CSSValueID::kCell)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str71, static_cast<int>(CSSValueID::kClip)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str72, static_cast<int>(CSSValueID::kB4)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str73, static_cast<int>(CSSValueID::kB5)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str74, static_cast<int>(CSSValueID::kForestgreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str75, static_cast<int>(CSSValueID::kSalmon)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str76, static_cast<int>(CSSValueID::kStable)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str77, static_cast<int>(CSSValueID::kCircle)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str78, static_cast<int>(CSSValueID::kFilled)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str79, static_cast<int>(CSSValueID::kMove)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str80, static_cast<int>(CSSValueID::kLast)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str81, static_cast<int>(CSSValueID::kFast)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str82, static_cast<int>(CSSValueID::kBeige)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str83, static_cast<int>(CSSValueID::kScale)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str84, static_cast<int>(CSSValueID::kHover)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str85, static_cast<int>(CSSValueID::kUnset)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str86, static_cast<int>(CSSValueID::kNavy)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str87, static_cast<int>(CSSValueID::kRevert)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str88, static_cast<int>(CSSValueID::kUnicase)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str89, static_cast<int>(CSSValueID::kScreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str90, static_cast<int>(CSSValueID::kHue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str91, static_cast<int>(CSSValueID::kCrimson)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str92, static_cast<int>(CSSValueID::kTan)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str93, static_cast<int>(CSSValueID::kNormal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str94, static_cast<int>(CSSValueID::kTeal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str95, static_cast<int>(CSSValueID::kDarksalmon)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str96, static_cast<int>(CSSValueID::kDense)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str97, static_cast<int>(CSSValueID::kFirst)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str98, static_cast<int>(CSSValueID::kUrl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str99, static_cast<int>(CSSValueID::kUnder)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str100, static_cast<int>(CSSValueID::kCenter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str101, static_cast<int>(CSSValueID::kTo)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str102, static_cast<int>(CSSValueID::kSesame)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str103, static_cast<int>(CSSValueID::kFlat)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str104, static_cast<int>(CSSValueID::kRec2020)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str105, static_cast<int>(CSSValueID::kReverse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str106, static_cast<int>(CSSValueID::kRoot)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str107, static_cast<int>(CSSValueID::kOn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str108, static_cast<int>(CSSValueID::kLess)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str109, static_cast<int>(CSSValueID::kLavender)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str110, static_cast<int>(CSSValueID::kRaise)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str111, static_cast<int>(CSSValueID::kDotted)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str112, static_cast<int>(CSSValueID::kDecreasing)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str113, static_cast<int>(CSSValueID::kCover)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str114, static_cast<int>(CSSValueID::kRotate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str115, static_cast<int>(CSSValueID::kSign)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str116, static_cast<int>(CSSValueID::kSpace)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str117, static_cast<int>(CSSValueID::kUnicode)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str118, static_cast<int>(CSSValueID::kContent)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str119, static_cast<int>(CSSValueID::kContain)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str120, static_cast<int>(CSSValueID::kScale3d)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str121, static_cast<int>(CSSValueID::kSienna)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str122, static_cast<int>(CSSValueID::kMoccasin)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str123, static_cast<int>(CSSValueID::kLegal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str124, static_cast<int>(CSSValueID::kLoose)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str125, static_cast<int>(CSSValueID::kHsla)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str126, static_cast<int>(CSSValueID::kDarkviolet)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str127, static_cast<int>(CSSValueID::kFalse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str128, static_cast<int>(CSSValueID::kCompact)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str129, static_cast<int>(CSSValueID::kContents)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str130, static_cast<int>(CSSValueID::kContrast)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str131, static_cast<int>(CSSValueID::kRepeat)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str132, static_cast<int>(CSSValueID::kCentral)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str133, static_cast<int>(CSSValueID::kStepStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str134, static_cast<int>(CSSValueID::kCap)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str135, static_cast<int>(CSSValueID::kStatic)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str136, static_cast<int>(CSSValueID::kSelector)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str137, static_cast<int>(CSSValueID::kBaseline)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str138, static_cast<int>(CSSValueID::kLinearGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str139, static_cast<int>(CSSValueID::kUnderline)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str140, static_cast<int>(CSSValueID::kStepEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str141, static_cast<int>(CSSValueID::kClear)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str142, static_cast<int>(CSSValueID::kRotate3d)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str143, static_cast<int>(CSSValueID::kRect)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str144, static_cast<int>(CSSValueID::kMintcream)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str145, static_cast<int>(CSSValueID::kFromImage)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str146, static_cast<int>(CSSValueID::kOnly)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str147, static_cast<int>(CSSValueID::kDarkolivegreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str148, static_cast<int>(CSSValueID::kNumbers)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str149, static_cast<int>(CSSValueID::kCoral)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str150, static_cast<int>(CSSValueID::kUp)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str151, static_cast<int>(CSSValueID::kCopy)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str152, static_cast<int>(CSSValueID::kZoomIn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str153, static_cast<int>(CSSValueID::kRecto)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str154, static_cast<int>(CSSValueID::kOver)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str155, static_cast<int>(CSSValueID::kBottom)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str156, static_cast<int>(CSSValueID::kDarkgoldenrod)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str157, static_cast<int>(CSSValueID::kDouble)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str158, static_cast<int>(CSSValueID::kBevel)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str159, static_cast<int>(CSSValueID::kFlipStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str160, static_cast<int>(CSSValueID::kE)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str161, static_cast<int>(CSSValueID::kTrue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str162, static_cast<int>(CSSValueID::kStandard)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str163, static_cast<int>(CSSValueID::kHueRotate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str164, static_cast<int>(CSSValueID::kHand)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str165, static_cast<int>(CSSValueID::kSafe)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str166, static_cast<int>(CSSValueID::kCollection)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str167, static_cast<int>(CSSValueID::kNumeric)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str168, static_cast<int>(CSSValueID::kClone)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str169, static_cast<int>(CSSValueID::kClamp)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str170, static_cast<int>(CSSValueID::kListItem)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str171, static_cast<int>(CSSValueID::kSeparate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str172, static_cast<int>(CSSValueID::kRelative)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str173, static_cast<int>(CSSValueID::kLeading)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str174, static_cast<int>(CSSValueID::kTomato)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str175, static_cast<int>(CSSValueID::kBlur)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str176, static_cast<int>(CSSValueID::kBisque)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str177, static_cast<int>(CSSValueID::kBlue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str178, static_cast<int>(CSSValueID::kSuper)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str179, static_cast<int>(CSSValueID::kEase)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str180, static_cast<int>(CSSValueID::kLocal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str181, static_cast<int>(CSSValueID::kStandalone)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str182, static_cast<int>(CSSValueID::kReplace)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str183, static_cast<int>(CSSValueID::kTop)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str184, static_cast<int>(CSSValueID::kSRGBLinear)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str185, static_cast<int>(CSSValueID::kEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str186, static_cast<int>(CSSValueID::kTriangle)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str187, static_cast<int>(CSSValueID::kCustom)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str188, static_cast<int>(CSSValueID::kOverline)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str189, static_cast<int>(CSSValueID::kOrnaments)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str190, static_cast<int>(CSSValueID::kCollapse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str191, static_cast<int>(CSSValueID::kSpan)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str192, static_cast<int>(CSSValueID::kButt)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str193, static_cast<int>(CSSValueID::kHidden)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str194, static_cast<int>(CSSValueID::kCaption)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str195, static_cast<int>(CSSValueID::kBullets)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str196, static_cast<int>(CSSValueID::kRunning)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str197, static_cast<int>(CSSValueID::kKeepAll)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str198, static_cast<int>(CSSValueID::kOrange)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str199, static_cast<int>(CSSValueID::kDarkseagreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str200, static_cast<int>(CSSValueID::kToZero)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str201, static_cast<int>(CSSValueID::kRotateRight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str202, static_cast<int>(CSSValueID::kDestinationIn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str203, static_cast<int>(CSSValueID::kFullscreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str204, static_cast<int>(CSSValueID::kTrimStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str205, static_cast<int>(CSSValueID::kSupports)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str206, static_cast<int>(CSSValueID::kEmoji)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str207, static_cast<int>(CSSValueID::kButton)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str208, static_cast<int>(CSSValueID::kEnv)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str209, static_cast<int>(CSSValueID::kElement)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str210, static_cast<int>(CSSValueID::kLeft)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str211, static_cast<int>(CSSValueID::kCounter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str212, static_cast<int>(CSSValueID::kNoRepeat)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str213, static_cast<int>(CSSValueID::kMiddle)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str214, static_cast<int>(CSSValueID::kOldlace)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str215, static_cast<int>(CSSValueID::kRound)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str216, static_cast<int>(CSSValueID::kMinContent)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str217, static_cast<int>(CSSValueID::kFitContent)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str218, static_cast<int>(CSSValueID::kTranslate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str219, static_cast<int>(CSSValueID::kOrangered)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str220, static_cast<int>(CSSValueID::kZoomOut)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str221, static_cast<int>(CSSValueID::kCounters)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str222, static_cast<int>(CSSValueID::kBalance)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str223, static_cast<int>(CSSValueID::kTranslate3d)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str224, static_cast<int>(CSSValueID::kSimplified)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str225, static_cast<int>(CSSValueID::kA)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str226, static_cast<int>(CSSValueID::kX)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str227, static_cast<int>(CSSValueID::kCursive)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str228, static_cast<int>(CSSValueID::kFolded)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str229, static_cast<int>(CSSValueID::kAt)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str230, static_cast<int>(CSSValueID::kAA)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str231, static_cast<int>(CSSValueID::kA3)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str232, static_cast<int>(CSSValueID::kA4)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str233, static_cast<int>(CSSValueID::kA5)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str234, static_cast<int>(CSSValueID::kInternalCenter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str235, static_cast<int>(CSSValueID::kAAA)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str236, static_cast<int>(CSSValueID::kLab)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str237, static_cast<int>(CSSValueID::kAttr)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str238, static_cast<int>(CSSValueID::kArg)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str239, static_cast<int>(CSSValueID::kBorder)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str240, static_cast<int>(CSSValueID::kStyle)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str241, static_cast<int>(CSSValueID::kNoClip)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str242, static_cast<int>(CSSValueID::kLayer)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str243, static_cast<int>(CSSValueID::kOf)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str244, static_cast<int>(CSSValueID::kOutset)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str245, static_cast<int>(CSSValueID::kCondensed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str246, static_cast<int>(CSSValueID::kEnabled)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str247, static_cast<int>(CSSValueID::kDimgrey)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str248, static_cast<int>(CSSValueID::kDimgray)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str249, static_cast<int>(CSSValueID::kCrispedges)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str250, static_cast<int>(CSSValueID::kSourceIn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str251, static_cast<int>(CSSValueID::kXor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str252, static_cast<int>(CSSValueID::kRay)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str253, static_cast<int>(CSSValueID::kRgb)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str254, static_cast<int>(CSSValueID::kSnow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str255, static_cast<int>(CSSValueID::kDarkgrey)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str256, static_cast<int>(CSSValueID::kDarkgray)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str257, static_cast<int>(CSSValueID::kSpaceAll)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str258, static_cast<int>(CSSValueID::kLinearrgb)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str259, static_cast<int>(CSSValueID::kBackground)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str260, static_cast<int>(CSSValueID::kDarkmagenta)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str261, static_cast<int>(CSSValueID::kStyleset)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str262, static_cast<int>(CSSValueID::kTraditional)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str263, static_cast<int>(CSSValueID::kBold)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str264, static_cast<int>(CSSValueID::kSpellingError)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str265, static_cast<int>(CSSValueID::kDestinationOver)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str266, static_cast<int>(CSSValueID::kEaseIn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str267, static_cast<int>(CSSValueID::kBolder)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str268, static_cast<int>(CSSValueID::kOutside)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str269, static_cast<int>(CSSValueID::kTurquoise)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str270, static_cast<int>(CSSValueID::kClosestSide)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str271, static_cast<int>(CSSValueID::kContinuous)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str272, static_cast<int>(CSSValueID::kBlueviolet)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str273, static_cast<int>(CSSValueID::kOpen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str274, static_cast<int>(CSSValueID::kNoDrag)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str275, static_cast<int>(CSSValueID::kSlow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str276, static_cast<int>(CSSValueID::kAlternate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str277, static_cast<int>(CSSValueID::kFlow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str278, static_cast<int>(CSSValueID::kDisclosureOpen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str279, static_cast<int>(CSSValueID::kAdd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str280, static_cast<int>(CSSValueID::kDestinationOut)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str281, static_cast<int>(CSSValueID::kUnsafe)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str282, static_cast<int>(CSSValueID::kFromFont)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str283, static_cast<int>(CSSValueID::kAll)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str284, static_cast<int>(CSSValueID::kSelecteditem)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str285, static_cast<int>(CSSValueID::kSpanStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str286, static_cast<int>(CSSValueID::kUseScript)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str287, static_cast<int>(CSSValueID::kForwards)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str288, static_cast<int>(CSSValueID::kSmallCaps)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str289, static_cast<int>(CSSValueID::kBorderless)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str290, static_cast<int>(CSSValueID::kScaleY)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str291, static_cast<int>(CSSValueID::kTb)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str292, static_cast<int>(CSSValueID::kDestinationAtop)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str293, static_cast<int>(CSSValueID::kSpanEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str294, static_cast<int>(CSSValueID::kSub)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str295, static_cast<int>(CSSValueID::kSpellOut)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str296, static_cast<int>(CSSValueID::kFantasy)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str297, static_cast<int>(CSSValueID::kDarkcyan)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str298, static_cast<int>(CSSValueID::kTable)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str299, static_cast<int>(CSSValueID::kRgba)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str300, static_cast<int>(CSSValueID::kBrown)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str301, static_cast<int>(CSSValueID::kCurrentcolor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str302, static_cast<int>(CSSValueID::kDarkslategrey)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str303, static_cast<int>(CSSValueID::kDarkslategray)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str304, static_cast<int>(CSSValueID::kSpaceAround)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str305, static_cast<int>(CSSValueID::kUppercase)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str306, static_cast<int>(CSSValueID::kStylistic)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str307, static_cast<int>(CSSValueID::kFlipInline)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str308, static_cast<int>(CSSValueID::kSourceOver)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str309, static_cast<int>(CSSValueID::kAtan)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str310, static_cast<int>(CSSValueID::kDisclosureClosed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str311, static_cast<int>(CSSValueID::kDefault)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str312, static_cast<int>(CSSValueID::kRuby)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str313, static_cast<int>(CSSValueID::kAtan2)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str314, static_cast<int>(CSSValueID::kSlategrey)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str315, static_cast<int>(CSSValueID::kSlategray)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str316, static_cast<int>(CSSValueID::kRotateY)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str317, static_cast<int>(CSSValueID::kBrowser)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str318, static_cast<int>(CSSValueID::kIn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str319, static_cast<int>(CSSValueID::kSourceOut)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str320, static_cast<int>(CSSValueID::kAALarge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str321, static_cast<int>(CSSValueID::kAAALarge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str322, static_cast<int>(CSSValueID::kHistoricalLigatures)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str323, static_cast<int>(CSSValueID::kLandscape)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str324, static_cast<int>(CSSValueID::kMistyrose)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str325, static_cast<int>(CSSValueID::kMath)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str326, static_cast<int>(CSSValueID::kFabricated)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str327, static_cast<int>(CSSValueID::kHigh)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str328, static_cast<int>(CSSValueID::kAsin)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str329, static_cast<int>(CSSValueID::kSpanAll)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str330, static_cast<int>(CSSValueID::kSubgrid)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str331, static_cast<int>(CSSValueID::kLight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str332, static_cast<int>(CSSValueID::kSansSerif)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str333, static_cast<int>(CSSValueID::kAlias)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str334, static_cast<int>(CSSValueID::kJis78)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str335, static_cast<int>(CSSValueID::kJis90)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str336, static_cast<int>(CSSValueID::kJis83)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str337, static_cast<int>(CSSValueID::kLighten)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str338, static_cast<int>(CSSValueID::kJis04)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str339, static_cast<int>(CSSValueID::kLighter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str340, static_cast<int>(CSSValueID::kNoCommonLigatures)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str341, static_cast<int>(CSSValueID::kDigits)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str342, static_cast<int>(CSSValueID::kDarkblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str343, static_cast<int>(CSSValueID::kHotpink)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str344, static_cast<int>(CSSValueID::kEaseOut)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str345, static_cast<int>(CSSValueID::kCyan)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str346, static_cast<int>(CSSValueID::kClosestCorner)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str347, static_cast<int>(CSSValueID::kRight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str348, static_cast<int>(CSSValueID::kInset)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str349, static_cast<int>(CSSValueID::kLightgreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str350, static_cast<int>(CSSValueID::kBaseSelect)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str351, static_cast<int>(CSSValueID::kRepeatingLinearGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str352, static_cast<int>(CSSValueID::kTransparent)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str353, static_cast<int>(CSSValueID::kNoPreference)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str354, static_cast<int>(CSSValueID::kTabbed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str355, static_cast<int>(CSSValueID::kEvenodd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str356, static_cast<int>(CSSValueID::kLegacy)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str357, static_cast<int>(CSSValueID::kDoubleCircle)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str358, static_cast<int>(CSSValueID::kIsolate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str359, static_cast<int>(CSSValueID::kDynamic)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str360, static_cast<int>(CSSValueID::kOnDemand)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str361, static_cast<int>(CSSValueID::kLrTb)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str362, static_cast<int>(CSSValueID::kDarkslateblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str363, static_cast<int>(CSSValueID::kSymbolic)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str364, static_cast<int>(CSSValueID::kNoDrop)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str365, static_cast<int>(CSSValueID::kDashed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str366, static_cast<int>(CSSValueID::kSteelblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str367, static_cast<int>(CSSValueID::kSpanTop)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str368, static_cast<int>(CSSValueID::kAcos)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str369, static_cast<int>(CSSValueID::kRadio)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str370, static_cast<int>(CSSValueID::kHistoricalForms)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str371, static_cast<int>(CSSValueID::kDodgerblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str372, static_cast<int>(CSSValueID::kCyclic)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str373, static_cast<int>(CSSValueID::kXStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str374, static_cast<int>(CSSValueID::kEntry)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str375, static_cast<int>(CSSValueID::kInvert)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str376, static_cast<int>(CSSValueID::kAfter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str377, static_cast<int>(CSSValueID::kStrict)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str378, static_cast<int>(CSSValueID::kOff)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str379, static_cast<int>(CSSValueID::kSolid)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str380, static_cast<int>(CSSValueID::kType)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str381, static_cast<int>(CSSValueID::kCadetblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str382, static_cast<int>(CSSValueID::kFlowRoot)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str383, static_cast<int>(CSSValueID::kItalic)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str384, static_cast<int>(CSSValueID::kRadial)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str385, static_cast<int>(CSSValueID::kCrossFade)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str386, static_cast<int>(CSSValueID::kNoAutospace)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str387, static_cast<int>(CSSValueID::kFontFormat)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str388, static_cast<int>(CSSValueID::kBoth)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str389, static_cast<int>(CSSValueID::kOverlay)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str390, static_cast<int>(CSSValueID::kMandatory)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str391, static_cast<int>(CSSValueID::kXSmall)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str392, static_cast<int>(CSSValueID::kRlTb)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str393, static_cast<int>(CSSValueID::kIncremental)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str394, static_cast<int>(CSSValueID::kDiagonalFractions)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str395, static_cast<int>(CSSValueID::kEmbed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str396, static_cast<int>(CSSValueID::kInverted)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str397, static_cast<int>(CSSValueID::kSepia)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str398, static_cast<int>(CSSValueID::kInitial)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str399, static_cast<int>(CSSValueID::kXLarge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str400, static_cast<int>(CSSValueID::kLightsalmon)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str401, static_cast<int>(CSSValueID::kOpacity)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str402, static_cast<int>(CSSValueID::kBlack)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str403, static_cast<int>(CSSValueID::kIntersect)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str404, static_cast<int>(CSSValueID::kTbRl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str405, static_cast<int>(CSSValueID::kRepeatingRadialGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str406, static_cast<int>(CSSValueID::kIncreasing)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str407, static_cast<int>(CSSValueID::kButtonface)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str408, static_cast<int>(CSSValueID::kSubtract)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str409, static_cast<int>(CSSValueID::kSlateblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str410, static_cast<int>(CSSValueID::kNoPunctuation)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str411, static_cast<int>(CSSValueID::kDecimal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str412, static_cast<int>(CSSValueID::kDeeppink)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str413, static_cast<int>(CSSValueID::kFirstBaseline)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str414, static_cast<int>(CSSValueID::kMedium)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str415, static_cast<int>(CSSValueID::kSpaceFirst)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str416, static_cast<int>(CSSValueID::kRepeatY)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str417, static_cast<int>(CSSValueID::kBlock)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str418, static_cast<int>(CSSValueID::kXEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str419, static_cast<int>(CSSValueID::kInterlace)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str420, static_cast<int>(CSSValueID::kLogical)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str421, static_cast<int>(CSSValueID::kPi)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str422, static_cast<int>(CSSValueID::kP3)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str423, static_cast<int>(CSSValueID::kImageSet)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str424, static_cast<int>(CSSValueID::kRotateLeft)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str425, static_cast<int>(CSSValueID::kPre)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str426, static_cast<int>(CSSValueID::kInternalMediaControl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str427, static_cast<int>(CSSValueID::kInsetArea)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str428, static_cast<int>(CSSValueID::kPink)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str429, static_cast<int>(CSSValueID::kSpringgreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str430, static_cast<int>(CSSValueID::kPage)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str431, static_cast<int>(CSSValueID::kRepeatingConicGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str432, static_cast<int>(CSSValueID::kTranslateY)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str433, static_cast<int>(CSSValueID::kLightcoral)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str434, static_cast<int>(CSSValueID::kAlternateReverse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str435, static_cast<int>(CSSValueID::kSpanLeft)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str436, static_cast<int>(CSSValueID::kAny)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str437, static_cast<int>(CSSValueID::kSystemUi)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str438, static_cast<int>(CSSValueID::kMaroon)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str439, static_cast<int>(CSSValueID::kStatusBar)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str440, static_cast<int>(CSSValueID::kTech)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str441, static_cast<int>(CSSValueID::kDisplayP3)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str442, static_cast<int>(CSSValueID::kG)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str443, static_cast<int>(CSSValueID::kFeaturesAat)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str444, static_cast<int>(CSSValueID::kAbs)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str445, static_cast<int>(CSSValueID::kLuminance)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str446, static_cast<int>(CSSValueID::kLiteralPunctuation)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str447, static_cast<int>(CSSValueID::kMediumseagreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str448, static_cast<int>(CSSValueID::kSpaceEvenly)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str449, static_cast<int>(CSSValueID::kPaged)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str450, static_cast<int>(CSSValueID::kTruetype)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str451, static_cast<int>(CSSValueID::kUltraCondensed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str452, static_cast<int>(CSSValueID::kOrdinal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str453, static_cast<int>(CSSValueID::kHeight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str454, static_cast<int>(CSSValueID::kGreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str455, static_cast<int>(CSSValueID::kSerif)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str456, static_cast<int>(CSSValueID::kGrey)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str457, static_cast<int>(CSSValueID::kGray)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str458, static_cast<int>(CSSValueID::kFuchsia)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str459, static_cast<int>(CSSValueID::kPalegreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str460, static_cast<int>(CSSValueID::kShorter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str461, static_cast<int>(CSSValueID::kProgress)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str462, static_cast<int>(CSSValueID::kSqrt)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str463, static_cast<int>(CSSValueID::kIcon)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str464, static_cast<int>(CSSValueID::kPalettes)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str465, static_cast<int>(CSSValueID::kAccentcolor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str466, static_cast<int>(CSSValueID::kGrab)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str467, static_cast<int>(CSSValueID::kLiningNums)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str468, static_cast<int>(CSSValueID::kSelf)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str469, static_cast<int>(CSSValueID::kCornsilk)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str470, static_cast<int>(CSSValueID::kRadialGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str471, static_cast<int>(CSSValueID::kAllScroll)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str472, static_cast<int>(CSSValueID::kSliderVertical)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str473, static_cast<int>(CSSValueID::kJumpNone)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str474, static_cast<int>(CSSValueID::kKhaki)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str475, static_cast<int>(CSSValueID::kBlink)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str476, static_cast<int>(CSSValueID::kEaseInOut)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str477, static_cast<int>(CSSValueID::kAfterEdge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str478, static_cast<int>(CSSValueID::kJumpStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str479, static_cast<int>(CSSValueID::kMathAuto)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str480, static_cast<int>(CSSValueID::kMultiply)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str481, static_cast<int>(CSSValueID::kOrchid)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str482, static_cast<int>(CSSValueID::kPolygon)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str483, static_cast<int>(CSSValueID::kColor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str484, static_cast<int>(CSSValueID::kPortrait)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str485, static_cast<int>(CSSValueID::kJumpEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str486, static_cast<int>(CSSValueID::kLightseagreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str487, static_cast<int>(CSSValueID::kCommonLigatures)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str488, static_cast<int>(CSSValueID::kA98Rgb)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str489, static_cast<int>(CSSValueID::kTableCell)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str490, static_cast<int>(CSSValueID::kMinimalUi)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str491, static_cast<int>(CSSValueID::kLch)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str492, static_cast<int>(CSSValueID::kSpanBottom)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str493, static_cast<int>(CSSValueID::kReadOnly)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str494, static_cast<int>(CSSValueID::kPaint)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str495, static_cast<int>(CSSValueID::kInternalUpperArmenian)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str496, static_cast<int>(CSSValueID::kPreLine)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str497, static_cast<int>(CSSValueID::kBothEdges)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str498, static_cast<int>(CSSValueID::kW)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str499, static_cast<int>(CSSValueID::kStretch)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str500, static_cast<int>(CSSValueID::kMax)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str501, static_cast<int>(CSSValueID::kBlockEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str502, static_cast<int>(CSSValueID::kBackButton)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str503, static_cast<int>(CSSValueID::kWrap)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str504, static_cast<int>(CSSValueID::kPurple)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str505, static_cast<int>(CSSValueID::kPointer)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str506, static_cast<int>(CSSValueID::kMatrix)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str507, static_cast<int>(CSSValueID::kSkew)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str508, static_cast<int>(CSSValueID::kOptional)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str509, static_cast<int>(CSSValueID::kPlum)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str510, static_cast<int>(CSSValueID::kSticky)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str511, static_cast<int>(CSSValueID::kMarktext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str512, static_cast<int>(CSSValueID::kLinktext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str513, static_cast<int>(CSSValueID::kLightsteelblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str514, static_cast<int>(CSSValueID::kChocolate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str515, static_cast<int>(CSSValueID::kPainted)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str516, static_cast<int>(CSSValueID::kEconomy)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str517, static_cast<int>(CSSValueID::kMinmax)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str518, static_cast<int>(CSSValueID::kSpanSelfStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str519, static_cast<int>(CSSValueID::kScroll)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str520, static_cast<int>(CSSValueID::kMediumspringgreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str521, static_cast<int>(CSSValueID::kPreserve)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str522, static_cast<int>(CSSValueID::kBrightness)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str523, static_cast<int>(CSSValueID::kSpanInlineStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str524, static_cast<int>(CSSValueID::kLightgrey)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str525, static_cast<int>(CSSValueID::kLightgray)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str526, static_cast<int>(CSSValueID::kMixed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str527, static_cast<int>(CSSValueID::kEntryCrossing)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str528, static_cast<int>(CSSValueID::kFixed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str529, static_cast<int>(CSSValueID::kSemiCondensed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str530, static_cast<int>(CSSValueID::kRevertLayer)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str531, static_cast<int>(CSSValueID::kTableColumn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str532, static_cast<int>(CSSValueID::kSquare)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str533, static_cast<int>(CSSValueID::kSpanInlineEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str534, static_cast<int>(CSSValueID::kMatrix3d)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str535, static_cast<int>(CSSValueID::kSilver)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str536, static_cast<int>(CSSValueID::kFieldtext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str537, static_cast<int>(CSSValueID::kDarkorchid)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str538, static_cast<int>(CSSValueID::kCanvas)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str539, static_cast<int>(CSSValueID::kNoChange)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str540, static_cast<int>(CSSValueID::kChartreuse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str541, static_cast<int>(CSSValueID::kGrayscale)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str542, static_cast<int>(CSSValueID::kWait)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str543, static_cast<int>(CSSValueID::kOpentype)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str544, static_cast<int>(CSSValueID::kMediaProgress)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str545, static_cast<int>(CSSValueID::kInsetInlineStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str546, static_cast<int>(CSSValueID::kAliceblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str547, static_cast<int>(CSSValueID::kBreakAll)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str548, static_cast<int>(CSSValueID::kWavy)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str549, static_cast<int>(CSSValueID::kCrosshair)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str550, static_cast<int>(CSSValueID::kInsetInlineEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str551, static_cast<int>(CSSValueID::kAntialiased)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str552, static_cast<int>(CSSValueID::kBlockStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str553, static_cast<int>(CSSValueID::kSeashell)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str554, static_cast<int>(CSSValueID::kPalegoldenrod)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str555, static_cast<int>(CSSValueID::kSelfStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str556, static_cast<int>(CSSValueID::kScaleX)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str557, static_cast<int>(CSSValueID::kPaused)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str558, static_cast<int>(CSSValueID::kSpanYEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str559, static_cast<int>(CSSValueID::kGrammarError)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str560, static_cast<int>(CSSValueID::kSelfEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str561, static_cast<int>(CSSValueID::kIvory)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str562, static_cast<int>(CSSValueID::kPalevioletred)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str563, static_cast<int>(CSSValueID::kSpanYStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str564, static_cast<int>(CSSValueID::kManipulation)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str565, static_cast<int>(CSSValueID::kJisB4)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str566, static_cast<int>(CSSValueID::kJisB5)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str567, static_cast<int>(CSSValueID::kGrid)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str568, static_cast<int>(CSSValueID::kPadding)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str569, static_cast<int>(CSSValueID::kSmallCaption)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str570, static_cast<int>(CSSValueID::kAllPetiteCaps)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str571, static_cast<int>(CSSValueID::kMonospace)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str572, static_cast<int>(CSSValueID::kFirebrick)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str573, static_cast<int>(CSSValueID::kButtonborder)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str574, static_cast<int>(CSSValueID::kThin)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str575, static_cast<int>(CSSValueID::kXSelfEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str576, static_cast<int>(CSSValueID::kLightcyan)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str577, static_cast<int>(CSSValueID::kAnchor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str578, static_cast<int>(CSSValueID::kAvoid)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str579, static_cast<int>(CSSValueID::kXSelfStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str580, static_cast<int>(CSSValueID::kRotateX)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str581, static_cast<int>(CSSValueID::kEllipse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str582, static_cast<int>(CSSValueID::kOldstyleNums)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str583, static_cast<int>(CSSValueID::kThistle)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str584, static_cast<int>(CSSValueID::kAllSmallCaps)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str585, static_cast<int>(CSSValueID::kFallback)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str586, static_cast<int>(CSSValueID::kContentBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str587, static_cast<int>(CSSValueID::kMessageBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str588, static_cast<int>(CSSValueID::kAdditive)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str589, static_cast<int>(CSSValueID::kEllipsis)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str590, static_cast<int>(CSSValueID::kBefore)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str591, static_cast<int>(CSSValueID::kPanUp)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str592, static_cast<int>(CSSValueID::kPreserve3d)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str593, static_cast<int>(CSSValueID::kGold)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str594, static_cast<int>(CSSValueID::kActive)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str595, static_cast<int>(CSSValueID::kLuminosity)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str596, static_cast<int>(CSSValueID::kVar)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str597, static_cast<int>(CSSValueID::kText)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str598, static_cast<int>(CSSValueID::kMenu)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str599, static_cast<int>(CSSValueID::kSwap)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str600, static_cast<int>(CSSValueID::kColorSVG)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str601, static_cast<int>(CSSValueID::kMathematical)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str602, static_cast<int>(CSSValueID::kOlive)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str603, static_cast<int>(CSSValueID::kLightblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str604, static_cast<int>(CSSValueID::kVs)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str605, static_cast<int>(CSSValueID::kSaturate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str606, static_cast<int>(CSSValueID::kTextarea)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str607, static_cast<int>(CSSValueID::kInactiveborder)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str608, static_cast<int>(CSSValueID::kY)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str609, static_cast<int>(CSSValueID::kAlpha)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str610, static_cast<int>(CSSValueID::kInternalSpellingErrorColor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str611, static_cast<int>(CSSValueID::kViolet)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str612, static_cast<int>(CSSValueID::kContainerProgress)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str613, static_cast<int>(CSSValueID::kPanLeft)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str614, static_cast<int>(CSSValueID::kSkyblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str615, static_cast<int>(CSSValueID::kInline)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str616, static_cast<int>(CSSValueID::kSize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str617, static_cast<int>(CSSValueID::kRoyalblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str618, static_cast<int>(CSSValueID::kRow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str619, static_cast<int>(CSSValueID::kFontTech)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str620, static_cast<int>(CSSValueID::kMediumpurple)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str621, static_cast<int>(CSSValueID::kTitlingCaps)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str622, static_cast<int>(CSSValueID::kSaturation)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str623, static_cast<int>(CSSValueID::kInside)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str624, static_cast<int>(CSSValueID::kEx)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str625, static_cast<int>(CSSValueID::kIndigo)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str626, static_cast<int>(CSSValueID::kMatchSource)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str627, static_cast<int>(CSSValueID::kProgressive)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str628, static_cast<int>(CSSValueID::kAnnotation)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str629, static_cast<int>(CSSValueID::kSourceAtop)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str630, static_cast<int>(CSSValueID::kDifference)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str631, static_cast<int>(CSSValueID::kExact)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str632, static_cast<int>(CSSValueID::kWrapReverse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str633, static_cast<int>(CSSValueID::kManual)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str634, static_cast<int>(CSSValueID::kIsolateOverride)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str635, static_cast<int>(CSSValueID::kMediumvioletred)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str636, static_cast<int>(CSSValueID::kShow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str637, static_cast<int>(CSSValueID::kGoldenrod)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str638, static_cast<int>(CSSValueID::kIndianred)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str639, static_cast<int>(CSSValueID::kColorContrast)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str640, static_cast<int>(CSSValueID::kFlex)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str641, static_cast<int>(CSSValueID::kMenulist)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str642, static_cast<int>(CSSValueID::kColorStop)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str643, static_cast<int>(CSSValueID::kNegativeInfinity)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str644, static_cast<int>(CSSValueID::kPretty)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str645, static_cast<int>(CSSValueID::kWords)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str646, static_cast<int>(CSSValueID::kPanY)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str647, static_cast<int>(CSSValueID::kSearchfield)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str648, static_cast<int>(CSSValueID::kDiscretionaryLigatures)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str649, static_cast<int>(CSSValueID::kOklab)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str650, static_cast<int>(CSSValueID::kGrabbing)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str651, static_cast<int>(CSSValueID::kSpanSelfEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str652, static_cast<int>(CSSValueID::kColumn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str653, static_cast<int>(CSSValueID::kAuto)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str654, static_cast<int>(CSSValueID::kRepeatX)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str655, static_cast<int>(CSSValueID::kExtends)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str656, static_cast<int>(CSSValueID::kExit)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str657, static_cast<int>(CSSValueID::kContextual)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str658, static_cast<int>(CSSValueID::kLayout)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str659, static_cast<int>(CSSValueID::kDocument)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str660, static_cast<int>(CSSValueID::kSpanYSelfStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str661, static_cast<int>(CSSValueID::kSpanRight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str662, static_cast<int>(CSSValueID::kScrollState)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str663, static_cast<int>(CSSValueID::kScaleZ)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str664, static_cast<int>(CSSValueID::kButtontext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str665, static_cast<int>(CSSValueID::kVerso)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str666, static_cast<int>(CSSValueID::kHardLight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str667, static_cast<int>(CSSValueID::kInitialOnly)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str668, static_cast<int>(CSSValueID::kLightpink)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str669, static_cast<int>(CSSValueID::kSpanYSelfEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str670, static_cast<int>(CSSValueID::kGridOrder)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str671, static_cast<int>(CSSValueID::kMaxContent)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str672, static_cast<int>(CSSValueID::kNoHistoricalLigatures)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str673, static_cast<int>(CSSValueID::kHypot)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str674, static_cast<int>(CSSValueID::kMediumblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str675, static_cast<int>(CSSValueID::kNoContextual)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str676, static_cast<int>(CSSValueID::kTranslateX)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str677, static_cast<int>(CSSValueID::kLowercase)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str678, static_cast<int>(CSSValueID::kDown)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str679, static_cast<int>(CSSValueID::kLastBaseline)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str680, static_cast<int>(CSSValueID::kStroke)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str681, static_cast<int>(CSSValueID::kReduce)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str682, static_cast<int>(CSSValueID::kPath)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str683, static_cast<int>(CSSValueID::kNoCloseQuote)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str684, static_cast<int>(CSSValueID::kLawngreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str685, static_cast<int>(CSSValueID::kGeometricprecision)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str686, static_cast<int>(CSSValueID::kLightDark)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str687, static_cast<int>(CSSValueID::kRotateZ)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str688, static_cast<int>(CSSValueID::kSelfInline)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str689, static_cast<int>(CSSValueID::kNowrap)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str690, static_cast<int>(CSSValueID::kSkewY)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str691, static_cast<int>(CSSValueID::kInlineGrid)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str692, static_cast<int>(CSSValueID::kFlipBlock)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str693, static_cast<int>(CSSValueID::kExp)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str694, static_cast<int>(CSSValueID::kSeResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str695, static_cast<int>(CSSValueID::kSResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str696, static_cast<int>(CSSValueID::kThreedface)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str697, static_cast<int>(CSSValueID::kFarthestCorner)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str698, static_cast<int>(CSSValueID::kAqua)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str699, static_cast<int>(CSSValueID::kPaletteMix)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str700, static_cast<int>(CSSValueID::kInlineEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str701, static_cast<int>(CSSValueID::kScrollbar)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str702, static_cast<int>(CSSValueID::kNeResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str703, static_cast<int>(CSSValueID::kNResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str704, static_cast<int>(CSSValueID::kBlinkFeature)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str705, static_cast<int>(CSSValueID::kCaptiontext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str706, static_cast<int>(CSSValueID::kInherit)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str707, static_cast<int>(CSSValueID::kInlineStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str708, static_cast<int>(CSSValueID::kSoftLight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str709, static_cast<int>(CSSValueID::kInfinite)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str710, static_cast<int>(CSSValueID::kVertical)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str711, static_cast<int>(CSSValueID::kContextMenu)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str712, static_cast<int>(CSSValueID::kNsResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str713, static_cast<int>(CSSValueID::kAquamarine)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str714, static_cast<int>(CSSValueID::kFeaturesGraphite)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str715, static_cast<int>(CSSValueID::kResetSize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str716, static_cast<int>(CSSValueID::kColorDodge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str717, static_cast<int>(CSSValueID::kAvoidPage)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str718, static_cast<int>(CSSValueID::kBlanchedalmond)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str719, static_cast<int>(CSSValueID::kFlexStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str720, static_cast<int>(CSSValueID::kNotAllowed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str721, static_cast<int>(CSSValueID::kColResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str722, static_cast<int>(CSSValueID::kFlexEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str723, static_cast<int>(CSSValueID::kGainsboro)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str724, static_cast<int>(CSSValueID::kYStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str725, static_cast<int>(CSSValueID::kBackwards)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str726, static_cast<int>(CSSValueID::kSelecteditemtext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str727, static_cast<int>(CSSValueID::kJustify)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str728, static_cast<int>(CSSValueID::kHighlight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str729, static_cast<int>(CSSValueID::kCalcSize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str730, static_cast<int>(CSSValueID::kTableColumnGroup)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str731, static_cast<int>(CSSValueID::kListbox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str732, static_cast<int>(CSSValueID::kTextTop)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str733, static_cast<int>(CSSValueID::kScaleDown)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str734, static_cast<int>(CSSValueID::kExclude)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str735, static_cast<int>(CSSValueID::kThick)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str736, static_cast<int>(CSSValueID::kExclusion)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str737, static_cast<int>(CSSValueID::kInnerSpinButton)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str738, static_cast<int>(CSSValueID::kAnchorCenter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str739, static_cast<int>(CSSValueID::kXxLarge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str740, static_cast<int>(CSSValueID::kBreakSpaces)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str741, static_cast<int>(CSSValueID::kPerspective)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str742, static_cast<int>(CSSValueID::kUltraExpanded)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str743, static_cast<int>(CSSValueID::kConicGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str744, static_cast<int>(CSSValueID::kTextfield)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str745, static_cast<int>(CSSValueID::kAutoAdd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str746, static_cast<int>(CSSValueID::kYEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str747, static_cast<int>(CSSValueID::kMarginBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str748, static_cast<int>(CSSValueID::kLavenderblush)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str749, static_cast<int>(CSSValueID::kOpenQuote)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str750, static_cast<int>(CSSValueID::kHwb)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str751, static_cast<int>(CSSValueID::kSelfInlineStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str752, static_cast<int>(CSSValueID::kView)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str753, static_cast<int>(CSSValueID::kTableCaption)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str754, static_cast<int>(CSSValueID::kSelfInlineEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str755, static_cast<int>(CSSValueID::kTranslateZ)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str756, static_cast<int>(CSSValueID::kExpanded)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str757, static_cast<int>(CSSValueID::kVerticalRl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str758, static_cast<int>(CSSValueID::kColorBurn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str759, static_cast<int>(CSSValueID::kMidnightblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str760, static_cast<int>(CSSValueID::kFillBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str761, static_cast<int>(CSSValueID::kAvoidColumn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str762, static_cast<int>(CSSValueID::kCloseQuote)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str763, static_cast<int>(CSSValueID::kOklch)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str764, static_cast<int>(CSSValueID::kInactivecaption)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str765, static_cast<int>(CSSValueID::kContextFill)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str766, static_cast<int>(CSSValueID::kInsetBlockStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str767, static_cast<int>(CSSValueID::kColorCBDT)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str768, static_cast<int>(CSSValueID::kInsetBlockEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str769, static_cast<int>(CSSValueID::kGridColumns)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str770, static_cast<int>(CSSValueID::kStackedFractions)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str771, static_cast<int>(CSSValueID::kBidiOverride)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str772, static_cast<int>(CSSValueID::kReadWrite)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str773, static_cast<int>(CSSValueID::kSmooth)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str774, static_cast<int>(CSSValueID::kBeforeEdge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str775, static_cast<int>(CSSValueID::kOlivedrab)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str776, static_cast<int>(CSSValueID::kSpanXEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str777, static_cast<int>(CSSValueID::kSpanXStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str778, static_cast<int>(CSSValueID::kProportionalNums)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str779, static_cast<int>(CSSValueID::kUpright)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str780, static_cast<int>(CSSValueID::kHoneydew)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str781, static_cast<int>(CSSValueID::kSideways)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str782, static_cast<int>(CSSValueID::kEResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str783, static_cast<int>(CSSValueID::kInternalSearchColor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str784, static_cast<int>(CSSValueID::kVerticalLr)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str785, static_cast<int>(CSSValueID::kFlexVisual)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str786, static_cast<int>(CSSValueID::kDarkturquoise)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str787, static_cast<int>(CSSValueID::kMediumaquamarine)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str788, static_cast<int>(CSSValueID::kTextAfterEdge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str789, static_cast<int>(CSSValueID::kRubyText)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str790, static_cast<int>(CSSValueID::kRosybrown)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str791, static_cast<int>(CSSValueID::kSpanBlockStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str792, static_cast<int>(CSSValueID::kMediumslateblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str793, static_cast<int>(CSSValueID::kPictureInPicture)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str794, static_cast<int>(CSSValueID::kRowReverse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str795, static_cast<int>(CSSValueID::kSpanBlockEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str796, static_cast<int>(CSSValueID::kGroove)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str797, static_cast<int>(CSSValueID::kPanRight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str798, static_cast<int>(CSSValueID::kAlphabetic)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str799, static_cast<int>(CSSValueID::kInternalLowerArmenian)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str800, static_cast<int>(CSSValueID::kAutoFit)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str801, static_cast<int>(CSSValueID::kAzure)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str802, static_cast<int>(CSSValueID::kInternalTextareaAuto)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str803, static_cast<int>(CSSValueID::kXxSmall)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str804, static_cast<int>(CSSValueID::kTableFooterGroup)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str805, static_cast<int>(CSSValueID::kInternalGrammarErrorColor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str806, static_cast<int>(CSSValueID::kFarthestSide)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str807, static_cast<int>(CSSValueID::kPetiteCaps)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str808, static_cast<int>(CSSValueID::kInlineTable)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str809, static_cast<int>(CSSValueID::kAbove)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str810, static_cast<int>(CSSValueID::kTextBottom)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str811, static_cast<int>(CSSValueID::kRebeccapurple)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str812, static_cast<int>(CSSValueID::kFeaturesOpentype)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str813, static_cast<int>(CSSValueID::kWeight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str814, static_cast<int>(CSSValueID::kAbsolute)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str815, static_cast<int>(CSSValueID::kVariations)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str816, static_cast<int>(CSSValueID::kMediumturquoise)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str817, static_cast<int>(CSSValueID::kGraytext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str818, static_cast<int>(CSSValueID::kSpanSelfInlineStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str819, static_cast<int>(CSSValueID::kInfinity)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str820, static_cast<int>(CSSValueID::kProgressBar)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str821, static_cast<int>(CSSValueID::kPanX)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str822, static_cast<int>(CSSValueID::kMinimized)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str823, static_cast<int>(CSSValueID::kSpanSelfInlineEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str824, static_cast<int>(CSSValueID::kAutoFill)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str825, static_cast<int>(CSSValueID::kAccentcolortext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str826, static_cast<int>(CSSValueID::kColumnReverse)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str827, static_cast<int>(CSSValueID::kPixelated)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str828, static_cast<int>(CSSValueID::kAnchorsVisible)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str829, static_cast<int>(CSSValueID::kDeepskyblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str830, static_cast<int>(CSSValueID::kSquareButton)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str831, static_cast<int>(CSSValueID::kSpanXSelfStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str832, static_cast<int>(CSSValueID::kWhite)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str833, static_cast<int>(CSSValueID::kSpanXSelfEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str834, static_cast<int>(CSSValueID::kTableRow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str835, static_cast<int>(CSSValueID::kHorizontal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str836, static_cast<int>(CSSValueID::kSubpixelAntialiased)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str837, static_cast<int>(CSSValueID::kWheat)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str838, static_cast<int>(CSSValueID::kBlockAxis)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str839, static_cast<int>(CSSValueID::kSemiExpanded)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str840, static_cast<int>(CSSValueID::kYSelfEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str841, static_cast<int>(CSSValueID::kBurlywood)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str842, static_cast<int>(CSSValueID::kWidth)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str843, static_cast<int>(CSSValueID::kYSelfStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str844, static_cast<int>(CSSValueID::kExtraCondensed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str845, static_cast<int>(CSSValueID::kInternalHebrew)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str846, static_cast<int>(CSSValueID::kActiveborder)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str847, static_cast<int>(CSSValueID::kContextStroke)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str848, static_cast<int>(CSSValueID::kLightslategrey)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str849, static_cast<int>(CSSValueID::kLightslategray)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str850, static_cast<int>(CSSValueID::kSkewX)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str851, static_cast<int>(CSSValueID::kMenulistButton)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str852, static_cast<int>(CSSValueID::kPeru)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str853, static_cast<int>(CSSValueID::kBorderBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str854, static_cast<int>(CSSValueID::kNonScalingStroke)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str855, static_cast<int>(CSSValueID::kPow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str856, static_cast<int>(CSSValueID::kAppworkspace)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str857, static_cast<int>(CSSValueID::kCapHeight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str858, static_cast<int>(CSSValueID::kScrollPosition)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str859, static_cast<int>(CSSValueID::kDarkkhaki)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str860, static_cast<int>(CSSValueID::kAccumulate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str861, static_cast<int>(CSSValueID::kSaddlebrown)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str862, static_cast<int>(CSSValueID::kXyz)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str863, static_cast<int>(CSSValueID::kCanvastext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str864, static_cast<int>(CSSValueID::kMostInlineSize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str865, static_cast<int>(CSSValueID::kColorMix)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str866, static_cast<int>(CSSValueID::kWebkitLeft)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str867, static_cast<int>(CSSValueID::kNoDiscretionaryLigatures)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str868, static_cast<int>(CSSValueID::kInternalCurrentSearchColor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str869, static_cast<int>(CSSValueID::kConstrainedHigh)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str870, static_cast<int>(CSSValueID::kSpanSelfBlockStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str871, static_cast<int>(CSSValueID::kCapitalize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str872, static_cast<int>(CSSValueID::kInternalQuirkInherit)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str873, static_cast<int>(CSSValueID::kAnywhere)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str874, static_cast<int>(CSSValueID::kActivecaption)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str875, static_cast<int>(CSSValueID::kSpanSelfBlockEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str876, static_cast<int>(CSSValueID::kCornflowerblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str877, static_cast<int>(CSSValueID::kWoff)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str878, static_cast<int>(CSSValueID::kDropShadow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str879, static_cast<int>(CSSValueID::kWoff2)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str880, static_cast<int>(CSSValueID::kTabularNums)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str881, static_cast<int>(CSSValueID::kMostHeight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str882, static_cast<int>(CSSValueID::kOblique)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str883, static_cast<int>(CSSValueID::kPaddingBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str884, static_cast<int>(CSSValueID::kInlineFlex)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str885, static_cast<int>(CSSValueID::kLightyellow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str886, static_cast<int>(CSSValueID::kBelow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str887, static_cast<int>(CSSValueID::kWebkitCenter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str888, static_cast<int>(CSSValueID::kJumpBoth)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str889, static_cast<int>(CSSValueID::kPreserveParentColor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str890, static_cast<int>(CSSValueID::kNeswResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str891, static_cast<int>(CSSValueID::kPanDown)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str892, static_cast<int>(CSSValueID::kInlineLayout)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str893, static_cast<int>(CSSValueID::kIcWidth)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str894, static_cast<int>(CSSValueID::kSwash)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str895, static_cast<int>(CSSValueID::kInternalKoreanHangulFormal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str896, static_cast<int>(CSSValueID::kActivetext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str897, static_cast<int>(CSSValueID::kLightskyblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str898, static_cast<int>(CSSValueID::kBlockSize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str899, static_cast<int>(CSSValueID::kMenutext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str900, static_cast<int>(CSSValueID::kInternalEthiopicNumeric)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str901, static_cast<int>(CSSValueID::kBoundingBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str902, static_cast<int>(CSSValueID::kInternalSimpChineseFormal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str903, static_cast<int>(CSSValueID::kXyzD50)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str904, static_cast<int>(CSSValueID::kXyzD65)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str905, static_cast<int>(CSSValueID::kAlways)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str906, static_cast<int>(CSSValueID::kInternalSimpChineseInformal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str907, static_cast<int>(CSSValueID::kInternalTradChineseFormal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str908, static_cast<int>(CSSValueID::kSpaceBetween)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str909, static_cast<int>(CSSValueID::kInternalTradChineseInformal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str910, static_cast<int>(CSSValueID::kDynamicRangeLimitMix)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str911, static_cast<int>(CSSValueID::kBreakWord)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str912, static_cast<int>(CSSValueID::kWebkitCalc)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str913, static_cast<int>(CSSValueID::kPreserveBreaks)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str914, static_cast<int>(CSSValueID::kSelfBlock)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str915, static_cast<int>(CSSValueID::kWebkitControl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str916, static_cast<int>(CSSValueID::kPreWrap)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str917, static_cast<int>(CSSValueID::kWebkitIsolate)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str918, static_cast<int>(CSSValueID::kInterCharacter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str919, static_cast<int>(CSSValueID::kVisible)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str920, static_cast<int>(CSSValueID::kPushButton)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str921, static_cast<int>(CSSValueID::kWebkitAuto)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str922, static_cast<int>(CSSValueID::kExitCrossing)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str923, static_cast<int>(CSSValueID::kIcHeight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str924, static_cast<int>(CSSValueID::kSelfBlockStart)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str925, static_cast<int>(CSSValueID::kWebkitRadialGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str926, static_cast<int>(CSSValueID::kSelfBlockEnd)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str927, static_cast<int>(CSSValueID::kSandybrown)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str928, static_cast<int>(CSSValueID::kWebkitLinearGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str929, static_cast<int>(CSSValueID::kWebkitMinContent)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str930, static_cast<int>(CSSValueID::kChWidth)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str931, static_cast<int>(CSSValueID::kHorizontalTb)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str932, static_cast<int>(CSSValueID::kTableHeaderGroup)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str933, static_cast<int>(CSSValueID::kInlineAxis)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str934, static_cast<int>(CSSValueID::kMostWidth)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str935, static_cast<int>(CSSValueID::kMediumorchid)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str936, static_cast<int>(CSSValueID::kGreenyellow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str937, static_cast<int>(CSSValueID::kCharacterVariant)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str938, static_cast<int>(CSSValueID::kWResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str939, static_cast<int>(CSSValueID::kEmbeddedOpentype)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str940, static_cast<int>(CSSValueID::kNoOpenQuote)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str941, static_cast<int>(CSSValueID::kPlaintext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str942, static_cast<int>(CSSValueID::kNoOverflow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str943, static_cast<int>(CSSValueID::kWebkitMiniControl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str944, static_cast<int>(CSSValueID::kFullWidth)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str945, static_cast<int>(CSSValueID::kPlusLighter)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str946, static_cast<int>(CSSValueID::kFloralwhite)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str947, static_cast<int>(CSSValueID::kInternalVariableValue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str948, static_cast<int>(CSSValueID::kVisual)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str949, static_cast<int>(CSSValueID::kWindow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str950, static_cast<int>(CSSValueID::kColorCOLRv0)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str951, static_cast<int>(CSSValueID::kColorCOLRv1)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str952, static_cast<int>(CSSValueID::kProximity)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str953, static_cast<int>(CSSValueID::kLemonchiffon)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str954, static_cast<int>(CSSValueID::kPeachpuff)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str955, static_cast<int>(CSSValueID::kWebkitGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str956, static_cast<int>(CSSValueID::kSearchfieldCancelButton)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str957, static_cast<int>(CSSValueID::kColorSbix)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str958, static_cast<int>(CSSValueID::kIdeographic)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str959, static_cast<int>(CSSValueID::kYellow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str960, static_cast<int>(CSSValueID::kInternalAppearanceAutoBaseSelect)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str961, static_cast<int>(CSSValueID::kInlineBlock)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str962, static_cast<int>(CSSValueID::kVisiblepainted)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str963, static_cast<int>(CSSValueID::kSlashedZero)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str964, static_cast<int>(CSSValueID::kGridRows)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str965, static_cast<int>(CSSValueID::kXxxLarge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str966, static_cast<int>(CSSValueID::kYellowgreen)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str967, static_cast<int>(CSSValueID::kWhitesmoke)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str968, static_cast<int>(CSSValueID::kPaleturquoise)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str969, static_cast<int>(CSSValueID::kTextBeforeEdge)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str970, static_cast<int>(CSSValueID::kInternalKoreanHanjaFormal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str971, static_cast<int>(CSSValueID::kInternalKoreanHanjaInformal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str972, static_cast<int>(CSSValueID::kLightgoldenrodyellow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str973, static_cast<int>(CSSValueID::kWebkitIsolateOverride)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str974, static_cast<int>(CSSValueID::kXywh)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str975, static_cast<int>(CSSValueID::kRowResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str976, static_cast<int>(CSSValueID::kVisiblefill)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str977, static_cast<int>(CSSValueID::kSwResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str978, static_cast<int>(CSSValueID::kWebkitImageSet)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str979, static_cast<int>(CSSValueID::kInactivecaptiontext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str980, static_cast<int>(CSSValueID::kNwResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str981, static_cast<int>(CSSValueID::kButtonshadow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str982, static_cast<int>(CSSValueID::kInfotext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str983, static_cast<int>(CSSValueID::kOptimizespeed)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str984, static_cast<int>(CSSValueID::kWebkitLink)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str985, static_cast<int>(CSSValueID::kExtraExpanded)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str986, static_cast<int>(CSSValueID::kWebkitFitContent)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str987, static_cast<int>(CSSValueID::kWebkitMaxContent)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str988, static_cast<int>(CSSValueID::kMostBlockSize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str989, static_cast<int>(CSSValueID::kHighlighttext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str990, static_cast<int>(CSSValueID::kAutoPhrase)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str991, static_cast<int>(CSSValueID::kWebkitBaselineMiddle)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str992, static_cast<int>(CSSValueID::kWebkitCrossFade)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str993, static_cast<int>(CSSValueID::kAnchorSize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str994, static_cast<int>(CSSValueID::kWebkitGrab)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str995, static_cast<int>(CSSValueID::kInternalSearchTextColor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str996, static_cast<int>(CSSValueID::kMaximized)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str997, static_cast<int>(CSSValueID::kWebkitBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str998, static_cast<int>(CSSValueID::kExHeight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str999, static_cast<int>(CSSValueID::kWebkitBody)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1000, static_cast<int>(CSSValueID::kLineThrough)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1001, static_cast<int>(CSSValueID::kVerticalText)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1002, static_cast<int>(CSSValueID::kEwResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1003, static_cast<int>(CSSValueID::kCheckbox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1004, static_cast<int>(CSSValueID::kAllowDiscrete)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1005, static_cast<int>(CSSValueID::kPowderblue)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1006, static_cast<int>(CSSValueID::kInlineSize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1007, static_cast<int>(CSSValueID::kButtonhighlight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1008, static_cast<int>(CSSValueID::kNwseResize)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1009, static_cast<int>(CSSValueID::kWebkitSmallControl)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1010, static_cast<int>(CSSValueID::kStrokeBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1011, static_cast<int>(CSSValueID::kVisitedtext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1012, static_cast<int>(CSSValueID::kWebkitActivelink)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1013, static_cast<int>(CSSValueID::kFlexFlow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1014, static_cast<int>(CSSValueID::kAutoFlow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1015, static_cast<int>(CSSValueID::kWindowframe)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1016, static_cast<int>(CSSValueID::kVisiblestroke)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1017, static_cast<int>(CSSValueID::kWebkitFocusRingColor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1018, static_cast<int>(CSSValueID::kVerticalRight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1019, static_cast<int>(CSSValueID::kPinchZoom)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1020, static_cast<int>(CSSValueID::kInfobackground)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1021, static_cast<int>(CSSValueID::kWebkitFillAvailable)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1022, static_cast<int>(CSSValueID::kProphotoRgb)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1023, static_cast<int>(CSSValueID::kNavajowhite)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1024, static_cast<int>(CSSValueID::kViewBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1025, static_cast<int>(CSSValueID::kInternalActiveListBoxSelection)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1026, static_cast<int>(CSSValueID::kInternalCurrentSearchTextColor)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1027, static_cast<int>(CSSValueID::kTableRowGroup)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1028, static_cast<int>(CSSValueID::kWebkitGrabbing)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1029, static_cast<int>(CSSValueID::kInternalExtendToZoom)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1030, static_cast<int>(CSSValueID::kSliderHorizontal)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1031, static_cast<int>(CSSValueID::kWebkitRepeatingLinearGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1032, static_cast<int>(CSSValueID::kSidewaysRight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1033, static_cast<int>(CSSValueID::kThreedshadow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1034, static_cast<int>(CSSValueID::kWebkitRepeatingRadialGradient)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1035, static_cast<int>(CSSValueID::kCubicBezier)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1036, static_cast<int>(CSSValueID::kInternalInactiveListBoxSelection)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1037, static_cast<int>(CSSValueID::kWebkitMatchParent)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1038, static_cast<int>(CSSValueID::kWindowtext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1039, static_cast<int>(CSSValueID::kWebkitInlineFlex)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1040, static_cast<int>(CSSValueID::kReadWritePlaintextOnly)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1041, static_cast<int>(CSSValueID::kWebkitFlex)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1042, static_cast<int>(CSSValueID::kWebkitZoomIn)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1043, static_cast<int>(CSSValueID::kThreedhighlight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1044, static_cast<int>(CSSValueID::kWebkitInlineBox)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1045, static_cast<int>(CSSValueID::kProportionalWidth)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1046, static_cast<int>(CSSValueID::kWebkitPlaintext)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1047, static_cast<int>(CSSValueID::kAfterWhiteSpace)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1048, static_cast<int>(CSSValueID::kPapayawhip)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1049, static_cast<int>(CSSValueID::kWebkitRight)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1050, static_cast<int>(CSSValueID::kWebkitZoomOut)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1051, static_cast<int>(CSSValueID::kWindowControlsOverlay)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1052, static_cast<int>(CSSValueID::kThreeddarkshadow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1053, static_cast<int>(CSSValueID::kGhostwhite)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1054, static_cast<int>(CSSValueID::kWebkitOptimizeContrast)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1055, static_cast<int>(CSSValueID::kOptimizelegibility)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1056, static_cast<int>(CSSValueID::kOptimizequality)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1057, static_cast<int>(CSSValueID::kAntiquewhite)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1058, static_cast<int>(CSSValueID::kThreedlightshadow)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1059, static_cast<int>(CSSValueID::kInternalActiveListBoxSelectionText)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1060, static_cast<int>(CSSValueID::kInternalInactiveListBoxSelectionText)},
          {(int)(size_t)&((struct CSSValueStringPool_t *)0)->CSSValueStringPool_str1061, static_cast<int>(CSSValueID::kWebkitXxxLarge)}
      };

  static const short lookup[] =
      {
          -1,   -1,   -1,   -1,   -1,   -1,   -1,    0,
          1,   -1,   -1,   -1,    2,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,    3,
          4,   -1,    5,   -1,   -1,   -1,    6,   -1,
          7,   -1,    8,   -1,    9,   -1,   10,   -1,
          11,   -1,   -1,   12,   -1,   13,   14,   15,
          16,   -1,   -1,   17,   18,   -1,   19,   -1,
          -1,   20,   -1,   -1,   -1,   21,   22,   23,
          24,   25,   -1,   26,   -1,   -1,   -1,   27,
          -1,   28,   29,   -1,   -1,   30,   -1,   -1,
          -1,   31,   -1,   -1,   32,   33,   -1,   -1,
          -1,   -1,   -1,   -1,   34,   35,   -1,   36,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   37,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   38,   -1,
          39,   -1,   40,   -1,   41,   -1,   -1,   -1,
          -1,   -1,   42,   43,   -1,   -1,   44,   45,
          46,   47,   48,   49,   50,   51,   -1,   -1,
          -1,   -1,   -1,   52,   -1,   53,   54,   -1,
          55,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   56,   -1,   57,   -1,   -1,
          58,   -1,   59,   60,   -1,   61,   -1,   -1,
          62,   -1,   -1,   63,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          64,   65,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   66,
          67,   68,   -1,   69,   70,   -1,   -1,   71,
          -1,   -1,   -1,   72,   73,   -1,   74,   75,
          -1,   76,   -1,   -1,   -1,   77,   -1,   -1,
          -1,   78,   79,   -1,   80,   81,   -1,   82,
          83,   -1,   -1,   -1,   84,   85,   -1,   -1,
          -1,   -1,   -1,   -1,   86,   -1,   87,   88,
          89,   -1,   -1,   -1,   90,   91,   92,   -1,
          -1,   -1,   93,   -1,   -1,   94,   95,   -1,
          -1,   -1,   -1,   96,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   97,   -1,   98,   -1,
          -1,   -1,   99,  100,   -1,  101,  102,   -1,
          103,   -1,   -1,   -1,   -1,  104,   -1,   -1,
          -1,   -1,  105,   -1,   -1,   -1,   -1,   -1,
          106,   -1,   -1,  107,  108,  109,   -1,   -1,
          110,   -1,   -1,   -1,   -1,   -1,  111,  112,
          -1,  113,  114,   -1,   -1,   -1,  115,  116,
          117,  118,   -1,  119,   -1,   -1,  120,   -1,
          -1,  121,   -1,   -1,   -1,   -1,  122,   -1,
          123,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          124,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  125,   -1,   -1,  126,
          127,   -1,   -1,   -1,  128,  129,   -1,   -1,
          130,  131,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  132,   -1,   -1,  133,  134,
          -1,   -1,   -1,  135,   -1,  136,   -1,   -1,
          -1,  137,   -1,   -1,  138,   -1,   -1,   -1,
          -1,  139,   -1,   -1,   -1,   -1,  140,  141,
          142,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          143,   -1,   -1,   -1,   -1,  144,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  145,  146,   -1,   -1,   -1,   -1,   -1,
          147,   -1,   -1,   -1,  148,   -1,   -1,   -1,
          149,   -1,   -1,   -1,   -1,   -1,  150,  151,
          -1,   -1,  152,   -1,   -1,   -1,   -1,   -1,
          153,   -1,   -1,   -1,  154,   -1,   -1,   -1,
          155,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          156,   -1,   -1,   -1,   -1,   -1,   -1,  157,
          158,   -1,   -1,   -1,   -1,  159,  160,   -1,
          -1,   -1,  161,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  162,   -1,   -1,
          -1,  163,   -1,   -1,   -1,   -1,   -1,  164,
          -1,   -1,  165,   -1,   -1,  166,   -1,   -1,
          -1,   -1,  167,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  168,  169,  170,
          -1,   -1,  171,   -1,   -1,  172,   -1,  173,
          -1,  174,   -1,   -1,  175,  176,   -1,   -1,
          -1,   -1,  177,   -1,   -1,   -1,  178,  179,
          -1,   -1,   -1,   -1,   -1,  180,   -1,   -1,
          -1,   -1,   -1,   -1,  181,   -1,  182,  183,
          184,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  185,  186,  187,   -1,
          -1,   -1,   -1,  188,   -1,   -1,  189,   -1,
          -1,   -1,  190,  191,   -1,   -1,   -1,   -1,
          -1,  192,   -1,  193,  194,   -1,   -1,   -1,
          195,   -1,  196,   -1,   -1,   -1,   -1,  197,
          -1,   -1,   -1,  198,   -1,   -1,   -1,  199,
          200,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  201,   -1,   -1,   -1,   -1,   -1,
          202,  203,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  204,  205,
          -1,  206,  207,  208,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  209,   -1,  210,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  211,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  212,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  213,   -1,   -1,   -1,   -1,  214,
          215,   -1,   -1,   -1,   -1,  216,   -1,  217,
          -1,   -1,   -1,  218,   -1,   -1,   -1,   -1,
          -1,   -1,  219,   -1,   -1,  220,   -1,   -1,
          -1,  221,  222,  223,   -1,   -1,   -1,  224,
          225,   -1,   -1,  226,   -1,  227,  228,  229,
          230,  231,  232,  233,  234,   -1,   -1,   -1,
          235,   -1,   -1,   -1,  236,  237,   -1,   -1,
          238,   -1,   -1,   -1,  239,   -1,   -1,   -1,
          -1,  240,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  241,   -1,   -1,   -1,   -1,   -1,  242,
          243,  244,   -1,   -1,  245,   -1,   -1,  246,
          247,  248,   -1,  249,   -1,  250,  251,  252,
          -1,  253,   -1,  254,   -1,   -1,   -1,   -1,
          255,  256,   -1,   -1,   -1,   -1,  257,   -1,
          -1,   -1,   -1,   -1,   -1,  258,   -1,   -1,
          -1,  259,   -1,   -1,   -1,   -1,  260,   -1,
          -1,   -1,   -1,  261,   -1,   -1,   -1,   -1,
          -1,   -1,  262,   -1,   -1,   -1,  263,   -1,
          264,   -1,   -1,   -1,   -1,  265,   -1,   -1,
          -1,  266,   -1,   -1,   -1,   -1,   -1,   -1,
          267,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  268,
          -1,  269,   -1,   -1,   -1,   -1,  270,   -1,
          -1,  271,   -1,  272,   -1,  273,   -1,  274,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  275,   -1,   -1,   -1,  276,   -1,  277,
          -1,   -1,   -1,   -1,  278,   -1,   -1,   -1,
          -1,   -1,  279,  280,   -1,   -1,   -1,  281,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  282,
          -1,   -1,   -1,   -1,   -1,   -1,  283,  284,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  285,   -1,   -1,   -1,  286,   -1,  287,
          -1,   -1,   -1,  288,   -1,   -1,   -1,   -1,
          -1,   -1,  289,  290,   -1,  291,   -1,   -1,
          292,  293,   -1,   -1,  294,  295,   -1,   -1,
          -1,  296,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  297,   -1,  298,   -1,   -1,
          -1,   -1,  299,   -1,   -1,   -1,   -1,   -1,
          300,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          301,   -1,  302,  303,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  304,   -1,   -1,
          -1,   -1,   -1,   -1,  305,   -1,  306,  307,
          -1,   -1,   -1,  308,   -1,   -1,   -1,   -1,
          -1,  309,  310,   -1,   -1,   -1,   -1,   -1,
          311,  312,  313,  314,  315,  316,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  317,  318,   -1,
          319,  320,   -1,  321,   -1,   -1,   -1,  322,
          -1,  323,  324,   -1,   -1,  325,   -1,   -1,
          326,   -1,  327,   -1,   -1,   -1,  328,   -1,
          -1,   -1,  329,   -1,  330,  331,   -1,   -1,
          -1,   -1,  332,   -1,  333,   -1,   -1,   -1,
          -1,  334,  335,  336,   -1,  337,  338,  339,
          -1,   -1,   -1,   -1,   -1,  340,  341,   -1,
          -1,  342,  343,   -1,  344,   -1,   -1,   -1,
          -1,   -1,  345,   -1,  346,  347,  348,   -1,
          -1,   -1,   -1,   -1,  349,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  350,   -1,  351,   -1,   -1,   -1,
          352,   -1,   -1,   -1,   -1,  353,  354,   -1,
          -1,   -1,   -1,   -1,   -1,  355,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  356,   -1,  357,
          358,  359,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  360,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  361,   -1,   -1,  362,
          -1,   -1,   -1,  363,  364,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  365,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  366,  367,  368,   -1,
          369,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  370,   -1,   -1,   -1,   -1,   -1,
          -1,  371,   -1,  372,   -1,   -1,  373,   -1,
          374,  375,   -1,   -1,   -1,  376,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          377,   -1,   -1,   -1,   -1,   -1,  378,   -1,
          -1,   -1,  379,   -1,   -1,   -1,   -1,  380,
          -1,  381,  382,   -1,   -1,   -1,  383,  384,
          -1,   -1,   -1,   -1,  385,   -1,   -1,   -1,
          386,   -1,   -1,   -1,   -1,  387,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  388,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  389,   -1,
          -1,   -1,   -1,   -1,   -1,  390,  391,   -1,
          392,   -1,   -1,   -1,  393,   -1,   -1,  394,
          -1,   -1,   -1,   -1,  395,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  396,   -1,  397,
          -1,  398,   -1,  399,  400,  401,  402,   -1,
          403,   -1,   -1,   -1,  404,  405,   -1,  406,
          407,   -1,   -1,  408,  409,  410,   -1,   -1,
          -1,  411,  412,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  413,  414,   -1,   -1,
          -1,   -1,  415,   -1,   -1,  416,  417,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  418,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  419,   -1,   -1,   -1,
          420,   -1,   -1,   -1,   -1,   -1,   -1,  421,
          422,   -1,   -1,  423,  424,   -1,   -1,   -1,
          -1,  425,   -1,   -1,   -1,   -1,   -1,  426,
          -1,  427,   -1,   -1,  428,   -1,   -1,  429,
          -1,  430,   -1,   -1,  431,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  432,   -1,
          433,   -1,  434,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  435,
          -1,   -1,   -1,   -1,  436,   -1,   -1,   -1,
          -1,   -1,   -1,  437,  438,   -1,   -1,  439,
          -1,   -1,  440,   -1,  441,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  442,   -1,   -1,   -1,
          -1,   -1,   -1,  443,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  444,   -1,  445,  446,
          447,   -1,  448,   -1,   -1,   -1,  449,   -1,
          -1,   -1,   -1,   -1,   -1,  450,   -1,   -1,
          451,  452,  453,   -1,  454,   -1,  455,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  456,  457,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  458,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  459,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  460,  461,  462,   -1,   -1,
          463,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  464,   -1,   -1,   -1,
          -1,   -1,   -1,  465,  466,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  467,   -1,   -1,   -1,
          -1,  468,   -1,   -1,  469,   -1,  470,   -1,
          -1,  471,  472,   -1,   -1,  473,   -1,  474,
          -1,  475,   -1,   -1,  476,   -1,  477,   -1,
          -1,  478,  479,   -1,   -1,  480,   -1,   -1,
          481,   -1,   -1,   -1,  482,   -1,  483,   -1,
          484,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  485,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  486,   -1,
          -1,  487,   -1,  488,  489,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  490,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  491,   -1,  492,   -1,  493,   -1,   -1,
          494,  495,   -1,   -1,   -1,  496,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  497,   -1,   -1,   -1,   -1,   -1,
          498,   -1,  499,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  500,   -1,   -1,  501,   -1,   -1,   -1,
          -1,   -1,  502,   -1,   -1,   -1,  503,   -1,
          504,   -1,  505,   -1,   -1,   -1,   -1,  506,
          507,   -1,  508,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  509,   -1,   -1,   -1,  510,
          -1,   -1,   -1,   -1,   -1,  511,  512,   -1,
          -1,  513,   -1,   -1,   -1,  514,   -1,   -1,
          -1,   -1,   -1,   -1,  515,   -1,   -1,   -1,
          516,   -1,  517,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  518,   -1,   -1,
          519,   -1,  520,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  521,   -1,   -1,   -1,  522,
          -1,  523,   -1,   -1,   -1,   -1,   -1,  524,
          525,   -1,   -1,  526,   -1,   -1,  527,  528,
          529,   -1,  530,   -1,   -1,  531,  532,   -1,
          -1,  533,   -1,   -1,   -1,  534,   -1,   -1,
          535,   -1,   -1,   -1,   -1,   -1,   -1,  536,
          -1,   -1,   -1,  537,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  538,   -1,   -1,   -1,   -1,   -1,
          -1,  539,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  540,  541,   -1,  542,   -1,   -1,   -1,
          543,   -1,  544,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  545,   -1,   -1,   -1,
          546,   -1,  547,   -1,  548,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          549,   -1,   -1,   -1,  550,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          551,   -1,  552,   -1,  553,  554,   -1,  555,
          556,   -1,   -1,   -1,   -1,  557,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  558,   -1,   -1,
          559,   -1,   -1,   -1,   -1,   -1,   -1,  560,
          -1,   -1,   -1,  561,  562,   -1,  563,   -1,
          -1,  564,  565,  566,   -1,  567,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          568,   -1,   -1,   -1,  569,   -1,  570,  571,
          572,   -1,   -1,  573,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  574,   -1,   -1,   -1,   -1,
          575,   -1,  576,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  577,   -1,   -1,   -1,   -1,   -1,
          578,  579,  580,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          581,  582,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  583,   -1,  584,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  585,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  586,   -1,   -1,
          -1,  587,   -1,  588,   -1,  589,   -1,  590,
          -1,   -1,   -1,   -1,  591,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  592,   -1,   -1,   -1,
          -1,  593,  594,  595,  596,   -1,   -1,   -1,
          597,   -1,  598,  599,  600,   -1,   -1,  601,
          602,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          603,   -1,   -1,   -1,   -1,  604,   -1,   -1,
          605,   -1,  606,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  607,   -1,  608,   -1,  609,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  610,
          611,   -1,   -1,   -1,   -1,   -1,   -1,  612,
          613,  614,   -1,   -1,  615,   -1,   -1,   -1,
          616,   -1,  617,   -1,   -1,  618,  619,   -1,
          -1,   -1,   -1,   -1,  620,   -1,   -1,   -1,
          621,   -1,  622,   -1,   -1,  623,  624,  625,
          -1,   -1,   -1,   -1,  626,   -1,  627,   -1,
          628,   -1,  629,  630,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  631,  632,   -1,   -1,
          -1,   -1,  633,   -1,   -1,  634,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  635,   -1,  636,   -1,
          -1,  637,  638,   -1,   -1,   -1,   -1,  639,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  640,
          -1,   -1,   -1,   -1,  641,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  642,   -1,  643,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  644,
          -1,   -1,   -1,   -1,   -1,  645,   -1,   -1,
          646,   -1,   -1,   -1,   -1,  647,   -1,   -1,
          -1,  648,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  649,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  650,   -1,   -1,   -1,   -1,   -1,
          -1,  651,  652,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  653,   -1,   -1,   -1,   -1,
          -1,   -1,  654,   -1,  655,   -1,   -1,   -1,
          -1,   -1,  656,   -1,  657,   -1,   -1,   -1,
          -1,   -1,  658,   -1,  659,  660,   -1,  661,
          662,   -1,   -1,   -1,  663,   -1,   -1,  664,
          665,  666,  667,   -1,   -1,   -1,   -1,  668,
          -1,   -1,   -1,   -1,   -1,  669,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          670,   -1,   -1,   -1,  671,   -1,   -1,  672,
          -1,   -1,   -1,  673,   -1,   -1,   -1,   -1,
          674,  675,   -1,  676,   -1,   -1,   -1,   -1,
          -1,  677,  678,   -1,  679,   -1,  680,   -1,
          -1,  681,   -1,  682,  683,   -1,  684,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          685,   -1,   -1,   -1,   -1,  686,  687,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  688,  689,  690,  691,   -1,   -1,  692,
          693,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  694,   -1,   -1,  695,
          -1,   -1,   -1,  696,  697,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  698,   -1,   -1,
          699,   -1,  700,  701,   -1,  702,   -1,   -1,
          703,   -1,   -1,   -1,  704,   -1,   -1,  705,
          -1,  706,   -1,  707,   -1,   -1,   -1,   -1,
          -1,  708,  709,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  710,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  711,  712,   -1,  713,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  714,   -1,  715,  716,   -1,   -1,  717,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  718,   -1,   -1,   -1,  719,   -1,   -1,
          -1,  720,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  721,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  722,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  723,   -1,  724,
          -1,   -1,   -1,  725,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  726,  727,   -1,   -1,
          -1,  728,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  729,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  730,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  731,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  732,   -1,   -1,   -1,   -1,   -1,
          733,  734,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  735,
          -1,   -1,  736,   -1,   -1,   -1,   -1,   -1,
          -1,  737,   -1,  738,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  739,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  740,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  741,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  742,   -1,   -1,   -1,
          743,  744,   -1,   -1,   -1,   -1,  745,   -1,
          -1,   -1,   -1,  746,   -1,   -1,  747,   -1,
          748,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          749,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  750,   -1,   -1,   -1,   -1,   -1,  751,
          -1,   -1,   -1,  752,   -1,   -1,  753,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  754,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  755,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  756,   -1,   -1,   -1,  757,
          758,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  759,   -1,   -1,   -1,  760,   -1,
          761,   -1,  762,  763,   -1,   -1,   -1,  764,
          -1,   -1,  765,   -1,  766,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  767,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  768,   -1,   -1,   -1,
          -1,   -1,   -1,  769,   -1,   -1,   -1,  770,
          771,   -1,   -1,   -1,  772,  773,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  774,
          775,   -1,  776,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  777,   -1,   -1,  778,   -1,
          779,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  780,   -1,
          -1,  781,   -1,   -1,   -1,   -1,  782,   -1,
          783,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  784,   -1,   -1,   -1,   -1,
          -1,  785,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  786,   -1,   -1,   -1,  787,  788,  789,
          -1,   -1,   -1,   -1,   -1,  790,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  791,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          792,   -1,   -1,   -1,  793,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  794,   -1,  795,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  796,   -1,   -1,   -1,   -1,   -1,   -1,
          797,   -1,   -1,   -1,   -1,  798,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  799,   -1,
          -1,  800,   -1,   -1,   -1,   -1,   -1,  801,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          802,   -1,   -1,  803,  804,  805,   -1,   -1,
          806,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  807,   -1,  808,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  809,
          810,  811,   -1,   -1,   -1,   -1,  812,   -1,
          -1,   -1,  813,   -1,   -1,  814,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  815,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  816,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  817,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          818,   -1,   -1,   -1,   -1,   -1,  819,   -1,
          820,   -1,   -1,   -1,   -1,  821,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  822,   -1,   -1,
          823,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          824,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          825,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  826,  827,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          828,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          829,  830,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  831,   -1,   -1,   -1,   -1,  832,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  833,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  834,   -1,   -1,  835,   -1,   -1,
          -1,   -1,   -1,   -1,  836,   -1,   -1,   -1,
          -1,   -1,   -1,  837,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  838,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  839,
          -1,  840,   -1,  841,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  842,   -1,   -1,
          -1,   -1,  843,  844,   -1,   -1,   -1,   -1,
          845,   -1,   -1,  846,   -1,   -1,  847,  848,
          849,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          850,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          851,   -1,  852,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  853,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  854,   -1,   -1,   -1,
          855,   -1,   -1,  856,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  857,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  858,   -1,   -1,   -1,
          859,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  860,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  861,   -1,   -1,   -1,
          -1,   -1,  862,   -1,   -1,   -1,   -1,  863,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  864,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  865,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  866,   -1,   -1,   -1,
          867,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  868,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  869,  870,   -1,   -1,   -1,  871,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  872,
          -1,   -1,   -1,   -1,  873,   -1,   -1,   -1,
          -1,   -1,  874,  875,   -1,   -1,  876,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  877,  878,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  879,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  880,   -1,   -1,   -1,
          -1,   -1,   -1,  881,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  882,  883,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  884,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  885,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  886,
          -1,   -1,   -1,  887,   -1,   -1,   -1,  888,
          -1,   -1,   -1,   -1,  889,   -1,   -1,  890,
          -1,   -1,   -1,   -1,  891,  892,   -1,   -1,
          -1,   -1,  893,   -1,   -1,   -1,   -1,   -1,
          -1,  894,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  895,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  896,
          -1,   -1,   -1,   -1,   -1,  897,  898,  899,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          900,   -1,   -1,   -1,   -1,   -1,  901,   -1,
          -1,  902,   -1,   -1,   -1,   -1,  903,  904,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          905,   -1,  906,   -1,   -1,   -1,   -1,   -1,
          -1,  907,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  908,   -1,   -1,
          -1,   -1,  909,   -1,   -1,   -1,   -1,   -1,
          -1,  910,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  911,   -1,   -1,
          912,   -1,  913,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  914,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  915,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  916,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  917,   -1,   -1,
          918,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  919,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  920,   -1,   -1,  921,   -1,   -1,   -1,
          -1,   -1,  922,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  923,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  924,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          925,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  926,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  927,   -1,
          928,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  929,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  930,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  931,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  932,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  933,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  934,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  935,
          -1,   -1,   -1,   -1,  936,   -1,   -1,  937,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          938,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          939,   -1,   -1,   -1,   -1,   -1,   -1,  940,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  941,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  942,   -1,   -1,   -1,   -1,
          -1,   -1,  943,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  944,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  945,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  946,   -1,   -1,   -1,
          947,   -1,   -1,   -1,   -1,  948,   -1,   -1,
          949,   -1,  950,  951,  952,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  953,  954,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  955,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  956,   -1,   -1,   -1,
          -1,   -1,   -1,  957,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  958,  959,   -1,   -1,   -1,
          960,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          961,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  962,
          -1,   -1,   -1,  963,   -1,   -1,  964,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  965,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  966,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  967,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  968,   -1,
          969,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          970,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  971,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  972,   -1,
          -1,   -1,   -1,  973,  974,   -1,   -1,   -1,
          -1,   -1,   -1,  975,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,  976,   -1,   -1,  977,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  978,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  979,   -1,   -1,  980,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  981,   -1,   -1,   -1,   -1,   -1,
          982,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  983,   -1,   -1,   -1,   -1,   -1,   -1,
          984,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  985,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  986,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  987,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  988,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,  989,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,  990,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  991,   -1,   -1,   -1,
          -1,   -1,   -1,  992,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,  993,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,  994,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,  995,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,  996,  997,   -1,   -1,
          -1,   -1,   -1,  998,  999,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1, 1000,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1001,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1, 1002,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1, 1003,   -1,
          -1,   -1, 1004, 1005,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1, 1006,   -1,   -1,   -1,   -1,
          -1,   -1,   -1, 1007,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1, 1008,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1009,   -1,   -1, 1010,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1, 1011,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1, 1012,   -1,   -1,   -1, 1013,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1, 1014, 1015,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          1016,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1017,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          1018,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1019,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          1020,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1, 1021,   -1,   -1,
          1022,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1023,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1024,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          1025,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1, 1026,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1, 1027,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          1028,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1, 1029,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1, 1030,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1, 1031,
          -1,   -1, 1032,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1, 1033,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1034,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1, 1035,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1, 1036,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1, 1037,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1, 1038,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1039,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1, 1040,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1, 1041, 1042,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1, 1043,   -1,
          1044,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1, 1045,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1, 1046,   -1,   -1,   -1,   -1,   -1, 1047,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1048,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1049,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1, 1050,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1, 1051,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1, 1052,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1, 1053,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          1054,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1055,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1, 1056,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1, 1057,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          1058,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1, 1059,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1060,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
          -1,   -1,   -1,   -1, 1061
      };

  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
  {
    unsigned int key = value_hash_function (str, len);

    if (key <= MAX_HASH_VALUE)
    {
      int index = lookup[key];

      if (index >= 0)
      {
        const char *s = value_word_list[index].name_offset + CSSValueStringPool;

        if (*str == *s && !strncmp (str + 1, s + 1, len - 1) && s[len] == '\0')
          return &value_word_list[index];
      }
    }
  }
  return 0;
}


const Value* FindValue(const char* str, unsigned int len) {
  return CSSValueKeywordsHash::findValueImpl(str, len);
}

const char* getValueName(CSSValueID id) {
  assert(id > CSSValueID::kInvalid);
  assert(static_cast<int>(id) < numCSSValueKeywords);
  return valueListStringPool + valueListStringOffsets[static_cast<int>(id) - 1];
}

bool isValueAllowedInMode(CSSValueID id, CSSParserMode mode) {
  switch (id) {
    case CSSValueID::kInternalActiveListBoxSelection:
    case CSSValueID::kInternalActiveListBoxSelectionText:
    case CSSValueID::kInternalInactiveListBoxSelection:
    case CSSValueID::kInternalInactiveListBoxSelectionText:
    case CSSValueID::kInternalQuirkInherit:
    case CSSValueID::kInternalSpellingErrorColor:
    case CSSValueID::kInternalGrammarErrorColor:
    case CSSValueID::kInternalSearchColor:
    case CSSValueID::kInternalSearchTextColor:
    case CSSValueID::kInternalCurrentSearchColor:
    case CSSValueID::kInternalCurrentSearchTextColor:
    case CSSValueID::kInternalCenter:
    case CSSValueID::kInternalMediaControl:
    case CSSValueID::kInternalAppearanceAutoBaseSelect:
    case CSSValueID::kInternalExtendToZoom:
    case CSSValueID::kInternalVariableValue:
    case CSSValueID::kInternalSimpChineseInformal:
    case CSSValueID::kInternalSimpChineseFormal:
    case CSSValueID::kInternalTradChineseInformal:
    case CSSValueID::kInternalTradChineseFormal:
    case CSSValueID::kInternalKoreanHangulFormal:
    case CSSValueID::kInternalKoreanHanjaInformal:
    case CSSValueID::kInternalKoreanHanjaFormal:
    case CSSValueID::kInternalHebrew:
    case CSSValueID::kInternalLowerArmenian:
    case CSSValueID::kInternalUpperArmenian:
    case CSSValueID::kInternalEthiopicNumeric:
    case CSSValueID::kInternalTextareaAuto:
      return IsUASheetBehavior(mode);
    case CSSValueID::kWebkitFocusRingColor:
      return IsUASheetBehavior(mode) || IsQuirksModeBehavior(mode);
    default:
      return true;
  }
};

}  // namespace webf
