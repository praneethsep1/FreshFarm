# Testing in FreshNest

## Overview

The FarmFresh project includes comprehensive UI widget tests to ensure the reliability and correctness of all user-facing features. These tests verify the rendering, user interactions, and form validation of the application's screens, focusing on the user experience for both consumers and farmers. The tests are written using Flutter's `flutter_test` framework and utilize `mockito` to mock dependencies, ensuring isolation from external services like Firebase.

## Test Location

All tests are located in the `test/` directory of the repository:
- **`test/ui_test.dart`**: Contains widget tests for all major features, organized by screen and functionality.

## Test Coverage

The tests in `ui_test.dart` cover **all features** of the FarmFresh application, ensuring that every user-facing screen and interaction is verified. The coverage includes both consumer and farmer functionalities, as well as authentication flows. Below is a detailed breakdown of the tested features:

### Consumer Features
- **`ConsumerHomeScreen`**:
    - Verifies that the product list is rendered correctly with product names, prices, and images.
    - Tests navigation to the product details screen via tap gestures.
    - Ensures the bottom navigation bar displays and switches between Home, Cart, Orders, and Profile screens.
- **`ConsumerCartScreen`**:
    - Tests the display of cart items, including product names, quantities, and totals.
    - Verifies quantity update controls (increment/decrement) and the remove item button.
    - Ensures the "Proceed to Checkout" button is rendered and tappable.
- **`PlaceOrderScreen`**:
    - Tests the rendering of the order summary (items, total) and shipping details form (name, phone, address, city, pin code).
    - Verifies form validation errors for empty or invalid inputs.
    - Ensures payment method and delivery option dropdowns are displayed and selectable.
- **`ConsumerOrderHistoryScreen`**:
    - Tests the rendering of the order history list with order IDs, items, totals, and statuses.
    - Verifies the "No orders yet" message when the order history is empty.
    - Ensures shipping details are displayed for each order.
- **`ConsumerProfileScreen`**:
    - Tests the rendering of the profile form with fields for name, email, phone, and address.
    - Verifies validation errors for invalid profile updates.
    - Ensures the update button is rendered and tappable.

### Farmer Features
- **`AddProductScreen`**:
    - Tests the rendering of the product form (name, price, quantity, description, unit, category).
    - Verifies the image picker button and form validation for empty or invalid inputs.
    - Ensures the "Save Product" button is rendered and tappable.
- **`FarmerProductManagement`**:
    - Tests the rendering of the product list with names, prices, quantities, and images.
    - Verifies the "No products added yet" message and "Add New Product" button when the list is empty.
    - Tests the dismissible widget for deleting products and the "Add New Product" button navigation.
- **`FarmerOrderManagement`**:
    - Tests the rendering of the order list with order IDs, items, totals, statuses, and shipping details.
    - Verifies the status dropdown displays options (Pending, Processing, Shipped, Completed, Cancelled) and is selectable.
    - Ensures the "No orders yet" message when the order list is empty.
- **`FarmerProfileScreen`**:
    - Tests the rendering of the farm profile form (farm name, location, contact details).
    - Verifies validation errors for invalid updates.
    - Ensures the update button is rendered and tappable.

### Authentication Features
- **`LoginScreen`**:
    - Tests the rendering of the login form (email, password) and "Login" button.
    - Verifies validation errors for empty or invalid email/password inputs.
- **`RegisterScreen`**:
    - Tests the rendering of the registration form (full name, email, phone, password, confirm password, address/farm details).
    - Verifies the user type toggle (Consumer/Farmer) and corresponding fields (e.g., farm name for farmers).
    - Ensures validation errors for empty or invalid inputs.

### Test Metrics
- **Total Tests**: Approximately 20 widget tests across 7 test groups, covering all screens.
- **Coverage**: Achieves high coverage for UI components, verified via `lcov` reports (see below for generating reports).
- **Isolation**: Tests mock `FirebaseAuth`, `FirebaseFirestore`, `AuthService`, and other dependencies to focus on UI behavior.

## Running Tests

To run the tests and verify the application’s UI functionality, follow these steps:

1. **Generate Mocks**:
   The tests use `mockito` to mock dependencies. Generate mock classes with:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Run Tests**:
   Execute all tests in `ui_test.dart`:
   ```bash
   flutter test test/ui_test.dart
   ```
   This runs the tests and outputs pass/fail results in the terminal.

3. **Generate Coverage Report**:
   To assess test coverage:
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html
   ```
   This generates an HTML coverage report, viewable in a browser, showing which UI components and code paths are tested.

## Testing Approach

- **Widget Tests**: The tests are written as widget tests using `flutter_test`, focusing on UI rendering and user interactions (e.g., taps, form submissions).
- **Mocking**: `mockito` is used to mock external dependencies (`FirebaseAuth`, `FirebaseFirestore`, `AuthService`), ensuring tests are isolated from network or backend issues.
- **Structure**: Tests are organized into `group` blocks by screen (e.g., `PlaceOrderScreen UI Tests`), with individual `testWidgets` for specific behaviors (e.g., form validation, list rendering).
- **Focus**: Tests prioritize user-facing functionality, verifying that widgets render correctly, respond to inputs, and display appropriate feedback (e.g., validation errors).

## Future Testing Improvements

To enhance the testing strategy in future iterations:
- **Integration Tests**: Add end-to-end tests to verify complete user flows (e.g., sign-up to order placement) using Flutter’s `integration_test` package.
- **Performance Tests**: Include tests to measure UI responsiveness and rendering performance, especially for product lists and image loading.
- **Edge Cases**: Expand test cases to cover rare scenarios (e.g., network failures, invalid image uploads).
- **CI/CD Integration**: Set up GitHub Actions to run tests automatically on pull requests, ensuring consistent quality.
- **Mock Data Expansion**: Add more varied mock data to test UI behavior under different conditions (e.g., large order lists, empty carts).

## Conclusion

The tests in `ui_test.dart` provide robust coverage for FarmFresh’s UI, ensuring that all consumer, farmer, and authentication features are reliable and user-friendly. The use of `flutter_test` and `mockito` enables isolated, repeatable tests, and the coverage report helps identify any gaps. For detailed test implementation, refer to `test/ui_test.dart` in the repository.