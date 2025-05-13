/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoIcon extends WidgetElement {
  FlutterCupertinoIcon(super.context);

  static final Map<String, IconData> _iconMap = {
    'add': CupertinoIcons.add,
    'add_circled': CupertinoIcons.add_circled,
    'add_circled_solid': CupertinoIcons.add_circled_solid,
    'arrow_left': CupertinoIcons.arrow_left,
    'arrow_right': CupertinoIcons.arrow_right,
    'back': CupertinoIcons.back,
    'check_mark': CupertinoIcons.check_mark,
    'check_mark_circled': CupertinoIcons.check_mark_circled,
    'check_mark_circled_solid': CupertinoIcons.check_mark_circled_solid,
    'clear': CupertinoIcons.clear,
    'clear_circled': CupertinoIcons.clear_circled,
    'clear_circled_solid': CupertinoIcons.clear_circled_solid,
    'delete': CupertinoIcons.delete,
    'delete_simple': CupertinoIcons.delete_simple,
    'exclamationmark': CupertinoIcons.exclamationmark,
    'eye': CupertinoIcons.eye,
    'forward': CupertinoIcons.forward,
    'forward_end': CupertinoIcons.forward_end,
    'forward_end_alt': CupertinoIcons.forward_end_alt,
    'forward_end_alt_fill': CupertinoIcons.forward_end_alt_fill,
    'forward_fill': CupertinoIcons.forward_fill,
    'gear': CupertinoIcons.gear,
    'gear_solid': CupertinoIcons.gear_solid,
    'hand_thumbsup': CupertinoIcons.hand_thumbsup,
    'hand_thumbsup_fill': CupertinoIcons.hand_thumbsup_fill,
    'hand_thumbsdown': CupertinoIcons.hand_thumbsdown,
    'hand_thumbsdown_fill': CupertinoIcons.hand_thumbsdown_fill,
    'home': CupertinoIcons.home,
    'info': CupertinoIcons.info,
    'info_circle': CupertinoIcons.info_circle,
    'info_circle_fill': CupertinoIcons.info_circle_fill,
    'link': CupertinoIcons.link,
    'list_bullet': CupertinoIcons.list_bullet,
    'list_bullet_indent': CupertinoIcons.list_bullet_indent,
    'list_dash': CupertinoIcons.list_dash,
    'list_number': CupertinoIcons.list_number,
    'location': CupertinoIcons.location,
    'location_fill': CupertinoIcons.location_fill,
    'lock': CupertinoIcons.lock,
    'lock_fill': CupertinoIcons.lock_fill,
    'minus': CupertinoIcons.minus,
    'pause_fill': CupertinoIcons.pause_fill,
    'pencil': CupertinoIcons.pencil,
    'person': CupertinoIcons.person,
    'person_2': CupertinoIcons.person_2,
    'person_2_fill': CupertinoIcons.person_2_fill,
    'person_3': CupertinoIcons.person_3,
    'person_3_fill': CupertinoIcons.person_3_fill,
    'person_crop_circle': CupertinoIcons.person_crop_circle,
    'person_crop_circle_badge_checkmark': CupertinoIcons.person_crop_circle_badge_checkmark,
    'person_crop_circle_badge_minus': CupertinoIcons.person_crop_circle_badge_minus,
    'person_crop_circle_badge_plus': CupertinoIcons.person_crop_circle_badge_plus,
    'person_crop_circle_badge_xmark': CupertinoIcons.person_crop_circle_badge_xmark,
    'person_crop_circle_fill': CupertinoIcons.person_crop_circle_fill,
    'person_crop_circle_fill_badge_checkmark': CupertinoIcons.person_crop_circle_fill_badge_checkmark,
    'person_crop_circle_fill_badge_minus': CupertinoIcons.person_crop_circle_fill_badge_minus,
    'person_crop_circle_fill_badge_plus': CupertinoIcons.person_crop_circle_fill_badge_plus,
    'person_crop_circle_fill_badge_xmark': CupertinoIcons.person_crop_circle_fill_badge_xmark,
    'person_fill': CupertinoIcons.person_fill,
    'phone': CupertinoIcons.phone,
    'phone_fill': CupertinoIcons.phone_fill,
    'photo': CupertinoIcons.photo,
    'photo_fill': CupertinoIcons.photo_fill,
    'play_fill': CupertinoIcons.play_fill,
    'plus': CupertinoIcons.plus,
    'plus_circle': CupertinoIcons.plus_circle,
    'plus_circle_fill': CupertinoIcons.plus_circle_fill,
    'question': CupertinoIcons.question,
    'question_circle': CupertinoIcons.question_circle,
    'question_circle_fill': CupertinoIcons.question_circle_fill,
    'rays': CupertinoIcons.rays,
    'search': CupertinoIcons.search,
    'settings': CupertinoIcons.settings,
    'share': CupertinoIcons.share,
    'star': CupertinoIcons.star,
    'star_fill': CupertinoIcons.star_fill,
    'star_lefthalf_fill': CupertinoIcons.star_lefthalf_fill,
    'star_slash': CupertinoIcons.star_slash,
    'star_slash_fill': CupertinoIcons.star_slash_fill,
    'stop_fill': CupertinoIcons.stop_fill,
    'tag': CupertinoIcons.tag,
    'tag_fill': CupertinoIcons.tag_fill,
    'text_justify': CupertinoIcons.text_justify,
    'text_justifyleft': CupertinoIcons.text_justifyleft,
    'text_justifyright': CupertinoIcons.text_justifyright,
    'textformat': CupertinoIcons.textformat,
    'textformat_alt': CupertinoIcons.textformat_alt,
    'textformat_size': CupertinoIcons.textformat_size,
    'trash': CupertinoIcons.trash,
    'trash_circle': CupertinoIcons.trash_circle,
    'trash_circle_fill': CupertinoIcons.trash_circle_fill,
    'trash_fill': CupertinoIcons.trash_fill,
    'tray': CupertinoIcons.tray,
    'tray_arrow_down': CupertinoIcons.tray_arrow_down,
    'tray_arrow_up': CupertinoIcons.tray_arrow_up,
    'tray_fill': CupertinoIcons.tray_fill,
    'tray_full': CupertinoIcons.tray_full,
    'tray_full_fill': CupertinoIcons.tray_full_fill,
    'wifi': CupertinoIcons.wifi,
    'wifi_exclamationmark': CupertinoIcons.wifi_exclamationmark,
    'wifi_slash': CupertinoIcons.wifi_slash,
    'xmark': CupertinoIcons.xmark,
    'xmark_circle': CupertinoIcons.xmark_circle,
    'xmark_circle_fill': CupertinoIcons.xmark_circle_fill,
    'xmark_octagon': CupertinoIcons.xmark_octagon,
    'xmark_octagon_fill': CupertinoIcons.xmark_octagon_fill,
    'xmark_rectangle': CupertinoIcons.xmark_rectangle,
    'xmark_rectangle_fill': CupertinoIcons.xmark_rectangle_fill,
    'xmark_seal': CupertinoIcons.xmark_seal,
    'xmark_seal_fill': CupertinoIcons.xmark_seal_fill,
    'xmark_shield': CupertinoIcons.xmark_shield,
    'xmark_shield_fill': CupertinoIcons.xmark_shield_fill,
    'xmark_square': CupertinoIcons.xmark_square,
    'xmark_square_fill': CupertinoIcons.xmark_square_fill,
    'zoom_in': CupertinoIcons.zoom_in,
    'zoom_out': CupertinoIcons.zoom_out,
    'bookmark': CupertinoIcons.bookmark,
    'bookmark_fill': CupertinoIcons.bookmark_fill,
    'ellipsis_circle': CupertinoIcons.ellipsis_circle,
    'chat_bubble': CupertinoIcons.chat_bubble,
    'doc_text': CupertinoIcons.doc_text,
    'heart': CupertinoIcons.heart,
    'heart_fill': CupertinoIcons.heart_fill,
  };

  static IconData? getIconType(String type) {
    return _iconMap[type];
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoIconState(this);
  }
}

class FlutterCupertinoIconState extends WebFWidgetElementState {
  FlutterCupertinoIconState(super.widgetElement);

  @override
  FlutterCupertinoIcon get widgetElement => super.widgetElement as FlutterCupertinoIcon;

  @override
  Widget build(BuildContext context) {
    IconData? iconType = FlutterCupertinoIcon.getIconType(widgetElement.getAttribute('type') ?? '');
    if (iconType == null) return SizedBox.shrink();

    return Icon(
      iconType,
      color: widgetElement.renderStyle.color.value,
      size: widgetElement.renderStyle.fontSize.value,
      semanticLabel: widgetElement.getAttribute('label') ?? 'Text to announce in accessibility modes',
    );
  }
}
