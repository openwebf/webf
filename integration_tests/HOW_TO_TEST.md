# WebF Integration Testing Guide

This document provides a step-by-step guide for creating, running, and verifying integration tests for WebF.

## Creating Integration Tests

1. **Test location**: Place test files in appropriate directories under `integration_tests/specs/`. Follow the existing pattern:
   - CSS tests go under `specs/css/`
   - DOM tests go under `specs/dom/`
   - Create a specific subdirectory for your feature (e.g., `css-text-color/`)

2. **Test format**: Write tests in TypeScript with Jasmine-style syntax:
   ```typescript
   describe('Feature being tested', () => {
     it('should behave in a specific way', async () => {
       // Setup test elements
       const element = document.createElement('div');
       document.body.appendChild(element);
       
       // Initial state
       await snapshot();
       
       // Change something
       element.style.color = 'red';
       
       // Verify changes
       await snapshot();
       
       // Clean up
       document.body.removeChild(element);
     });
   });
   ```

3. **Test utilities**:
   - `await snapshot()`: Takes a snapshot of the current state for visual comparison
   - Use `async/await` with snapshot calls to ensure proper rendering
   - Add cleanup code at the end of each test to remove added elements

4. **Update spec_group.json5**: Add your test directory to the appropriate group in `integration_tests/spec_group.json5`:
   ```json
   {
     "name": "YourTestGroup",
     "specs": [
       "specs/path/to/your/tests/**/*.{js,jsx,ts,tsx,html}"
     ]
   }
   ```

## Running Tests

1. **Run a specific test**:
   ```bash
   cd integration_tests
   WEBF_TEST_FILTER="your_test_name" npm run integration
   ```

2. **Run all tests in a group**:
   ```bash
   cd integration_tests
   npm run integration
   ```

## Managing Snapshots

1. **Important**: Snapshots are deleted every time you run the integration test command. You need to add them to git after each run if you want to keep them.

2. **Snapshot location**: Snapshots are saved to `integration_tests/snapshots/` in a directory structure mirroring your test files.

3. **Verify snapshots**: Check the generated snapshots to ensure they show the expected rendering:
   ```bash
   ls -la integration_tests/snapshots/path/to/your/tests/
   ```

4. **Add snapshots to git**: After verifying the snapshots look correct, add them to git:
   ```bash
   git add integration_tests/snapshots/path/to/your/tests/
   ```

5. **Important workflow**:
   - Run first test → Add snapshots to git
   - Run second test → Add snapshots to git
   - Continue this pattern for each test

## Documenting Tests

1. **Add a README.md**: Explain what the tests are verifying and why they're important.

2. **Add notes**: Create a NOTES.md with details about the issue being fixed, how the tests verify the fix, and any other relevant information.

## Best Practices

1. **Test isolation**: Each test should be self-contained and clean up after itself.

2. **Visual snapshots**: Use snapshots strategically to verify visual changes.

3. **Descriptive names**: Use clear, descriptive test names that explain what's being tested.

4. **Verify before committing**: Always run and verify tests before committing changes.

5. **Commit snapshots**: Always commit snapshot images along with your test files.

## Troubleshooting

- If snapshots aren't being generated, check that your test is actually running (look for PASS in the output).
- If tests are failing, verify that the feature is working as expected and that your test logic is correct.
- If the same test generates different snapshots on different runs, the feature might have non-deterministic behavior that needs to be fixed.