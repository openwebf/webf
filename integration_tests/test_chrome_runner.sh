#!/bin/bash

echo "Testing Chrome Runner with specific test file..."
echo "Test file: specs/svg/styling/display.ts"
echo ""

cd chrome_runner
npm test -- specs/svg/styling/display.ts --verbose

echo ""
echo "Chrome runner completed."