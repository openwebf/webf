interface DOMMatrix extends DOMMatrixReadonly{
  m11: DartImpl<double>;
  m12: DartImpl<double>;
  m13: DartImpl<double>;
  m14: DartImpl<double>;
  m21: DartImpl<double>;
  m22: DartImpl<double>;
  m23: DartImpl<double>;
  m24: DartImpl<double>;
  m31: DartImpl<double>;
  m32: DartImpl<double>;
  m33: DartImpl<double>;
  m34: DartImpl<double>;
  m41: DartImpl<double>;
  m42: DartImpl<double>;
  m43: DartImpl<double>;
  m44: DartImpl<double>;
  a: DartImpl<double>;
  b: DartImpl<double>;
  c: DartImpl<double>;
  d: DartImpl<double>;
  e: DartImpl<double>;
  f: DartImpl<double>;
  
  new(init?: double[]): DOMMatrix;
}