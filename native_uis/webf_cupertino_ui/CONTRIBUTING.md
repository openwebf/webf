# Contributing to WebF Cupertino UI

We love your input! We want to make contributing to WebF Cupertino UI as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## We Develop with Github
We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## We Use [Github Flow](https://guides.github.com/introduction/flow/index.html)
Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Any contributions you make will be under the Apache 2.0 Software License
In short, when you submit code changes, your submissions are understood to be under the same [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0) that covers the project. Feel free to contact the maintainers if that's a concern.

## Report bugs using Github's [issues](https://github.com/openwebf/webf-cupertino-ui/issues)
We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/openwebf/webf-cupertino-ui/issues/new); it's that easy!

## Write bug reports with detail, background, and sample code

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Development Process

### Prerequisites
- Flutter SDK 3.0 or later
- Dart SDK 3.6.0 or later
- Node.js and npm (for building TypeScript definitions)

### Getting Started
1. Clone the repository
   ```bash
   git clone https://github.com/openwebf/webf-cupertino-ui.git
   cd webf-cupertino-ui
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the example app
   ```bash
   cd example
   flutter run
   ```

### Code Style
- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for issues
- Format code with `dart format`
- Maximum line length is 120 characters

### Testing
- Write unit tests for new functionality
- Ensure all tests pass before submitting PR
- Run tests with `flutter test`

### Adding New Components
When adding a new Cupertino component:

1. Create the Dart implementation in `lib/src/`
2. Add TypeScript definitions in `lib/src/component_name.d.ts`
3. Generate bindings using the WebF CLI
4. Export the component in `lib/webf_cupertino_ui.dart`
5. Add example usage in the example app
6. Update documentation

## License
By contributing, you agree that your contributions will be licensed under its Apache 2.0 License.