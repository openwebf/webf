/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

class InvalidationFlags {
  bool invalidateCustomPseudo;
  bool wholeSubtreeInvalid;
  bool treeBoundaryCrossing;
  bool insertionPointCrossing;
  bool invalidatesSlotted;
  bool invalidatesParts;

  InvalidationFlags()
      : invalidateCustomPseudo = false,
        wholeSubtreeInvalid = false,
        treeBoundaryCrossing = false,
        insertionPointCrossing = false,
        invalidatesSlotted = false,
        invalidatesParts = false;

  @override
  bool operator ==(Object other) {
    if (other is! InvalidationFlags) return false;
    return invalidateCustomPseudo == other.invalidateCustomPseudo &&
        wholeSubtreeInvalid == other.wholeSubtreeInvalid &&
        treeBoundaryCrossing == other.treeBoundaryCrossing &&
        insertionPointCrossing == other.insertionPointCrossing &&
        invalidatesSlotted == other.invalidatesSlotted &&
        invalidatesParts == other.invalidatesParts;
  }

  // This is an override of the hashcode function to ensure that the == operator works correctly.
  @override
  int get hashCode {
    return invalidateCustomPseudo.hashCode ^
    wholeSubtreeInvalid.hashCode ^
    treeBoundaryCrossing.hashCode ^
    insertionPointCrossing.hashCode ^
    invalidatesSlotted.hashCode ^
    invalidatesParts.hashCode;
  }

  void merge(InvalidationFlags other) {
    invalidateCustomPseudo |= other.invalidateCustomPseudo;
    treeBoundaryCrossing |= other.treeBoundaryCrossing;
    insertionPointCrossing |= other.insertionPointCrossing;
    wholeSubtreeInvalid |= other.wholeSubtreeInvalid;
    invalidatesSlotted |= other.invalidatesSlotted;
    invalidatesParts |= other.invalidatesParts;
  }
}
