import 'dart:math';

double findSlope(List<List<num>> coordinates) {
  if (coordinates.length < 2) {
    throw ArgumentError("At least two coordinates are required");
  }

  int n = coordinates.length;
  num sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

  for (List<num> coordinate in coordinates) {
    num x = coordinate[0];
    num y = coordinate[1];

    sumX += x;
    sumY += y;
    sumXY += x * y;
    sumX2 += x * x;
  }

  // Calculate the slope of the best-fitting line using the linear regression formula
  double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  return slope;
}

double findAngle(List<List<num>> coordinates) {
  double slope = findSlope(coordinates);
  double angleRadians = atan(slope); // Calculate angle in radians
  return angleRadians;
}

double radiansToDegrees(double radians) {
  return radians * 180 / pi;
}

int findMinValue(List<int> numbers) {
  if (numbers.isEmpty) {
    throw ArgumentError("List must not be empty");
  }

  int minValue = numbers[0];
  for (int number in numbers) {
    minValue = minValue > number ? number : minValue;
  }

  return minValue;
}

bool isMemLeaks(List<List<int>> mems) {
  List<List<int>> input = mems.map((e) => [e[0], e[1]]).toList();
  double angleRadians = findAngle(input);
  double angleDegrees = radiansToDegrees(angleRadians);

  print(input);
  print(angleDegrees);
  return angleDegrees > 30;
}