import 'dart:ffi';

import 'package:ffi/ffi.dart';

class GumboNodeType {
  static const GUMBO_NODE_DOCUMENT = 0;
  static const GUMBO_NODE_ELEMENT = 1;
  static const GUMBO_NODE_TEXT = 2;
  static const GUMBO_NODE_CDATA = 3;
  static const GUMBO_NODE_COMMENT = 4;
  static const GUMBO_NODE_WHITESPACE = 5;
  static const GUMBO_NODE_TEMPLATE = 6;
}

class GumboNamespaceEnum {
  static const int GUMBO_NAMESPACE_HTML = 0;
  static const int GUMBO_NAMESPACE_SVG = 1;
  static const int GUMBO_NAMESPACE_MATHML = 2;
}

class GumboTag {
  static const HTML = 0;
  static const HEAD = 1;
  static const TITLE = 2;
  static const BASE = 3;
  static const LINK = 4;
  static const META = 5;
  static const STYLE = 6;
  static const SCRIPT = 7;
  static const NOSCRIPT = 8;
  static const TEMPLATE = 9;
  static const BODY = 10;
  static const ARTICLE = 11;
  static const SECTION = 12;
  static const NAV = 13;
  static const ASIDE = 14;
  static const H1 = 15;
  static const H2 = 16;
  static const H3 = 17;
  static const H4 = 18;
  static const H5 = 19;
  static const H6 = 20;
  static const HGROUP = 21;
  static const HEADER = 22;
  static const FOOTER = 23;
  static const ADDRESS = 24;
  static const P = 25;
  static const HR = 26;
  static const PRE = 27;
  static const BLOCKQUOTE = 28;
  static const OL = 29;
  static const UL = 30;
  static const LI = 31;
  static const DL = 32;
  static const DT = 33;
  static const DD = 34;
  static const FIGURE = 35;
  static const FIGCAPTION = 36;
  static const MAIN = 37;
  static const DIV = 38;
  static const A = 39;
  static const EM = 40;
  static const STRONG = 41;
  static const SMALL = 42;
  static const S = 43;
  static const CITE = 44;
  static const Q = 45;
  static const DFN = 46;
  static const ABBR = 47;
  static const DATA = 48;
  static const TIME = 49;
  static const CODE = 50;
  static const VAR = 51;
  static const SAMP = 52;
  static const KBD = 53;
  static const SUB = 54;
  static const SUP = 55;
  static const I = 56;
  static const B = 57;
  static const U = 58;
  static const MARK = 59;
  static const RUBY = 60;
  static const RT = 61;
  static const RP = 62;
  static const BDI = 63;
  static const BDO = 64;
  static const SPAN = 65;
  static const BR = 66;
  static const WBR = 67;
  static const INS = 68;
  static const DEL = 69;
  static const IMAGE = 70;
  static const IMG = 71;
  static const IFRAME = 72;
  static const EMBED = 73;
  static const OBJECT = 74;
  static const PARAM = 75;
  static const VIDEO = 76;
  static const AUDIO = 77;
  static const SOURCE = 78;
  static const TRACK = 79;
  static const CANVAS = 80;
  static const MAP = 81;
  static const AREA = 82;
  static const MATH = 83;
  static const MI = 84;
  static const MO = 85;
  static const MN = 86;
  static const MS = 87;
  static const MTEXT = 88;
  static const MGLYPH = 89;
  static const MALIGNMARK = 90;
  static const ANNOTATION_XML = 91;
  static const SVG = 92;
  static const FOREIGNOBJECT = 93;
  static const DESC = 94;
  static const TABLE = 95;
  static const CAPTION = 96;
  static const COLGROUP = 97;
  static const COL = 98;
  static const TBODY = 99;
  static const THEAD = 100;
  static const TFOOT = 101;
  static const TR = 102;
  static const TD = 103;
  static const TH = 104;
  static const FORM = 105;
  static const FIELDSET = 106;
  static const LEGEND = 107;
  static const LABEL = 108;
  static const INPUT = 109;
  static const BUTTON = 110;
  static const SELECT = 111;
  static const DATALIST = 112;
  static const OPTGROUP = 113;
  static const OPTION = 114;
  static const TEXTAREA = 115;
  static const KEYGEN = 116;
  static const OUTPUT = 117;
  static const PROGRESS = 118;
  static const METER = 119;
  static const DETAILS = 120;
  static const SUMMARY = 121;
  static const MENU = 122;
  static const MENUITEM = 123;
  static const APPLET = 124;
  static const ACRONYM = 125;
  static const BGSOUND = 126;
  static const DIR = 127;
  static const FRAME = 128;
  static const FRAMESET = 129;
  static const NOFRAMES = 130;
  static const ISINDEX = 131;
  static const LISTING = 132;
  static const XMP = 133;
  static const NEXTID = 134;
  static const NOEMBED = 135;
  static const PLAINTEXT = 136;
  static const RB = 137;
  static const STRIKE = 138;
  static const BASEFONT = 139;
  static const BIG = 140;
  static const BLINK = 141;
  static const CENTER = 142;
  static const FONT = 143;
  static const MARQUEE = 144;
  static const MULTICOL = 145;
  static const NOBR = 146;
  static const SPACER = 147;
  static const TT = 148;
  static const RTC = 149;
  static const UNKNOWN = 150;
  static const LAST = 151;
}

class NativeGumboOutput extends Struct {
  external Pointer<NativeGumboNode> document;
  external Pointer<NativeGumboNode> root;
  external NativeGumboVector errors;
}

class NativeGumboStringPiece extends Struct {
  external Pointer<Utf8> data;

  @Size()
  external int length;
}

class NativeGumboVector extends Struct {
  external Pointer<Pointer<Void>> data;

  @Uint32()
  external int length;

  @Uint32()
  external int capacity;
}

class NativeGumboSourcePosition extends Struct {
  @Uint32()
  external int line;
  @Uint32()
  external int column;
  @Uint32()
  external int offset;
}

class NativeGumboNode extends Struct {
  @Int32()
  external int type;

  external Pointer<NativeGumboNode> parent;

  @Size()
  external int index_within_parent;

  @Int32()
  external int parse_flags;

  external NativeGumboNodeUnionValue v;
}

class NativeGumboNodeUnionValue extends Union {
  external NativeGumboDocument document;

  external NativeGumboElement element;

  external NativeGumboText text;
}

class NativeGumboDocument extends Struct {
  external NativeGumboVector children;

  @Bool()
  external bool has_doctype;

  external Pointer<Uint8> name;

  external Pointer<Uint8> public_identifier;

  external Pointer<Uint8> system_identifier;

  @Int32()
  external int doc_type_quirks_mode;
}

class NativeGumboElement extends Struct {
  external NativeGumboVector children;
  @Int32()
  external int tag;

  @Int32()
  external int tag_namespace;

  external NativeGumboStringPiece original_tag;

  external NativeGumboStringPiece original_end_tag;

  external NativeGumboSourcePosition start_pos;

  external NativeGumboSourcePosition end_pos;

  external NativeGumboVector attributes;
}

class NativeGumboText extends Struct {
  external Pointer<Utf8> text;

  external NativeGumboStringPiece original_text;

  external NativeGumboSourcePosition start_pos;
}

class NativeGumboAttribute extends Struct {
  @Int32()
  external int attr_namespace;

  external Pointer<Utf8> name;

  external NativeGumboStringPiece original_name;

  external Pointer<Utf8> value;

  external NativeGumboStringPiece original_value;

  external NativeGumboSourcePosition name_start;
  external NativeGumboSourcePosition name_end;

  external NativeGumboSourcePosition value_start;
  external NativeGumboSourcePosition value_end;
}

void debugPrintGumboNodeTree(Pointer<NativeGumboNode> nodePtr, [int indent = 0]) {
  final p = ' ' * (indent * 2);
  final type = nodePtr.ref.type;
  print('$p node type: $type');
  switch(type) {
    case GumboNodeType.GUMBO_NODE_ELEMENT: {
      // element
      final element = nodePtr.ref.v.element;
      final children = element.children;
      final tag = element.tag;
      final tagName = element.original_tag.length != 0 ? element.original_tag.data.toDartString(length: element.original_tag.length) : '(none)';

      print('$p tag: $tag($tagName) in namespace ${element.tag_namespace} with ${children.length} child');

      final attributes = element.attributes;
      for (int i = 0; i < attributes.length; i++) {
        final attr = attributes.data[i] as Pointer<NativeGumboAttribute>;
        final name = attr.ref.name.toDartString();
        final value = attr.ref.value.toDartString();
        print('$p $name=$value');
      }

      for (int i = 0; i < children.length; i++) {
        final childRef = children.data[i] as Pointer<NativeGumboNode>;
        debugPrintGumboNodeTree(childRef, indent + 1);
      }
      break;
    }
    case GumboNodeType.GUMBO_NODE_TEXT:
    case GumboNodeType.GUMBO_NODE_COMMENT: {
      final node = nodePtr.ref.v.text;
      final content = node.text.toDartString();
      print('$p "$content"');
      break;
    }
    case GumboNodeType.GUMBO_NODE_WHITESPACE: {
      // others whitespace, ignored
      break;
    }
  }
}
