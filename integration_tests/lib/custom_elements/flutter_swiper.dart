import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';
import 'package:card_swiper/card_swiper.dart';


class SwiperElement extends WidgetElement {
  SwiperElement(BindingContext? context) : super(context);

  late SwiperController _swiperController;

  String get index => getAttribute('index') ?? '0';

  set index(value) {
    internalSetAttribute('index', value?.toString() ?? '0');
  }

  String get direction => getAttribute('direction') ?? 'left';

  set direction(value) {
    internalSetAttribute('direction', value?.toString() ?? 'left');
  }

  String get loop => getAttribute('loop') ?? 'false';

  set loop(value) {
    internalSetAttribute('loop', value?.toString() ?? 'false');
  }

  String get interval => getAttribute('interval') ?? '3000';

  set interval(value) {
    internalSetAttribute('interval', value?.toString() ?? '3000');
  }

  String get duration => getAttribute('duration') ?? '300';

  set duration(value) {
    internalSetAttribute('duration', value?.toString() ?? '300');
  }
  late ScrollController controller;


  @override
  void initState() {
    controller = ScrollController();
    _swiperController = SwiperController();
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    properties['index'] = BindingObjectProperty(
        getter: () => index, setter: (value) => index = value);
    properties['direction'] = BindingObjectProperty(
        getter: () => direction, setter: (value) => direction = value);
    properties['loop'] = BindingObjectProperty(
        getter: () => loop, setter: (value) => loop = value);
    properties['interval'] = BindingObjectProperty(
        getter: () => interval, setter: (value) => interval = value);
    properties['duration'] = BindingObjectProperty(
        getter: () => duration, setter: (value) => duration = value);
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);
    methods['move'] = BindingObjectMethodSync(call: (List args) {
      _move(args[0]);
    });
  }

  void _move(int index) {
    _swiperController.move(index);
  }

  _getScrollDirection() {
    direction = direction.toLowerCase();
    if (direction == 'left' || direction == 'right') {
      return Axis.horizontal;
    }
    return Axis.vertical;
  }

  _getAxisDirection() {
    direction = direction.toLowerCase();
    if (direction == 'left') {
      return AxisDirection.left;
    } else if (direction == 'right') {
      return AxisDirection.right;
    } else if (direction == 'up') {
      return AxisDirection.up;
    } else if (direction == 'down') {
      return AxisDirection.down;
    }
    return AxisDirection.left;
  }

  void _onIndexChanged(int index) {
    CustomEvent event = CustomEvent('indexChange', detail: index);
    dispatchEvent(event);
  }

  @override
  WebFWidgetElementState createState() {
    return SwiperElementState(this);
  }
}

class SwiperElementState extends WebFWidgetElementState {
  SwiperElementState(super.widgetElement);

  @override
  SwiperElement get widgetElement => super.widgetElement as SwiperElement;

  @override
  Widget build(BuildContext context) {
    print('SwiperElement build children: ${widgetElement.children.length}');
    return Swiper.children(
      children: widgetElement.childNodes.toWidgetList(),
      scrollDirection: widgetElement._getScrollDirection(),
      axisDirection: widgetElement._getAxisDirection(),
      autoplayDelay: int.parse(widgetElement.interval),
      loop: widgetElement.loop != 'false',
      autoplay: false,
      onIndexChanged: widgetElement._onIndexChanged,
      physics:
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      duration: int.parse(widgetElement.duration),
      controller: widgetElement._swiperController,
      index: int.parse(widgetElement.index),
    );
  }
}
