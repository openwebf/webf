interface FlutterCupertinoSliderProperties {
  val?: double;
  min?: double;
  max?: double;
  step?: int;
  disabled?: boolean;
}

interface FlutterCupertinoSliderMethods {
  getValue(): double;
  setValue(val: double): void;
}

interface FlutterCupertinoSliderEvents {
  change: CustomEvent<double>;
  changestart: CustomEvent<double>;
  changeend: CustomEvent<double>;
}
