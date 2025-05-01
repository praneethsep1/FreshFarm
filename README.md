# FarmFresh

## Project Description

FarmFresh is a Flutter-based mobile application that connects farmers directly with consumers to facilitate the purchase of fresh vegetables and farm products. The app enables farmers to list and manage their products and orders, while consumers can browse products, add them to a cart, place orders, and track order history. It is designed for:
- **Consumers**: Individuals seeking fresh, locally sourced produce with a user-friendly shopping experience.
- **Farmers**: Small-scale farmers looking to sell directly to consumers without intermediaries.

The app leverages Firebase for authentication, Firestore for data storage, and Firebase Storage for product images, ensuring a scalable and secure platform.

## Architecture

FarmFresh follows a client-server architecture with Flutter as the front-end and Firebase as the back-end. The high-level architecture consists of:

- **Client (Flutter App)**:
    - **UI Layer**: Widgets for screens like `ConsumerHomeScreen`, `PlaceOrderScreen`, and `FarmerOrderManagement`, built with Flutter’s Material Design.
    - **Business Logic**: Services like `AuthService`, `ProductRepository`, and `CartService` handle authentication, product management, and cart operations.
    - **Data Layer**: Interacts with Firebase SDKs for authentication, Firestore, and Storage.

- **Server (Firebase)**:
    - **Firebase Authentication**: Manages user sign-up, sign-in, and sign-out.
    - **Firestore**: Stores user profiles, products, cart items, and orders.
    - **Firebase Storage**: Hosts product images.

**Architecture Diagram**:

![FarmFresh Architecture](docs/architecture_diagram.png)

*Note*: The UML diagram is stored in `docs/architecture_diagram.png`. It illustrates the app’s components, including UI screens, services, and Firebase interactions. [Replace with actual diagram in your repo.]

## Getting Started / Installation

### Prerequisites
- **Flutter**: Version 3.16.0 or higher (stable channel).
- **Dart**: Version 3.2.0 or higher (included with Flutter).
- **Firebase Account**: For Authentication, Firestore, and Storage.
- **IDE**: Android Studio, VS Code, or any IDE with Flutter support.
- **Emulator/Device**: Android/iOS emulator or physical device.
- **Python**: For Sphinx documentation (optional for docs generation).

### Setup Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/farmfresh.git
   cd farmfresh
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
    - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
    - Enable Email/Password Authentication, Firestore, and Storage.
    - Install the Firebase CLI:
      ```bash
      npm install -g firebase-tools
      ```
    - Run FlutterFire CLI to configure:
      ```bash
      flutterfire configure
      ```
      Select your Firebase project to generate `lib/firebase_options.dart`.

4. **Update Firestore Rules**:
   In the Firebase Console, set Firestore rules:
   ```firestore
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

5. **Update Storage Rules**:
   In the Firebase Console, set Storage rules:
   ```firestore
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

6. **Set Up Emulator (Optional)**:
    - Android: Configure an Android Virtual Device (AVD) in Android Studio.
    - iOS: Set up an iOS simulator in Xcode (macOS only).
    - Alternatively, connect a physical device with USB debugging enabled.

## Usage / Examples

FarmFresh is designed for non-technical users (consumers and farmers). Below are examples of how to use the app:

### For Consumers
1. **Register**: Open the app, go to the Register screen, select "Consumer," and enter your name, email, phone, address, and password.
2. **Browse Products**: On the Home screen, view available vegetables (e.g., "Apples, ₹10/kg"). Tap a product to see details.
3. **Add to Cart**: Click "Add to Cart" on a product. Adjust quantity in the Cart screen.
4. **Place Order**: Go to the Cart, tap "Proceed to Checkout," enter shipping details (e.g., "123 Test St, Test City"), select payment (e.g., Cash on Delivery), and confirm.
5. **View Orders**: Check past orders in the Order History screen, including status (e.g., "Shipped") and delivery details.
6. **Update Profile**: Edit your name, phone, or address in the Profile screen.

### For Farmers
1. **Register**: On the Register screen, select "Farmer," and enter your name, email, phone, farm name, and farm location.
2. **Add Products**: In the Product Management screen, click "Add New Product," enter details (e.g., "Tomatoes, ₹15/kg, 100kg"), upload images, and save.
3. **Manage Orders**: In the Order Management screen, view incoming orders, update status (e.g., from "Pending" to "Shipped"), and add tracking details.
4. **Update Profile**: Edit farm details in the Profile screen.

## Folder Structure Overview

```
farmfresh/
├── docs/                     # Documentation files (using dart doc)
│   ├── api/                  # Generated HTML documentation
│       ├── index.html        # Generated HTML documentation
├── lib/                      # Source code
│   ├── add_product_screen.dart        # Farmer product addition screen
│   ├── authentication.dart            # Authentication and product services
│   ├── consumer_cart_screen.dart      # Consumer cart management
│   ├── consumer_home_screen.dart      # Consumer product browsing
│   ├── consumer_order_history_screen.dart # Consumer order history
│   ├── consumer_product_listing.dart  # Product list widget
│   ├── consumer_profile_screen.dart   # Consumer profile management
│   ├── farmer_order_management.dart   # Farmer order management
│   ├── farmer_product_management.dart # Farmer product management
│   ├── farmer_profile_screen.dart     # Farmer profile management
│   ├── login_screen.dart              # Login screen
│   ├── models.dart                    # Data models (UserModel, Product, CartItem)
│   ├── place_order_screen.dart        # Order placement screen
│   ├── product_detail_screen.dart     # Product details view
│   ├── register_screen.dart           # Registration screen
│   ├── app_constants.dart             # App-wide constants
│   └── firebase_options.dart          # Firebase configuration
├── test/                     # Unit and widget tests
│   ├── ui_test.dart              # UI widget tests for all features
├── pubspec.yaml              # Project dependencies and configuration
├── README.md                 # Project documentation (this file)
└── testing.md                # Test coverage and details
```

## Tech Stack / Dependencies

- **Flutter**: Framework for cross-platform mobile app development (iOS, Android).
- **Dart**: Programming language for Flutter.
- **Firebase**:
    - **Firebase Authentication**: Email/password-based user authentication.
    - **Firestore**: NoSQL database for storing users, products, carts, and orders.
    - **Firebase Storage**: Cloud storage for product images.
- **Provider**: State management for dependency injection and UI updates.
- **Image Picker**: For uploading product images from device gallery or camera.
- **UUID**: For generating unique IDs for orders and products.
- **Testing**:
    - **flutter_test**: Flutter’s testing framework for unit and widget tests.
    - **Mockito**: Mocking library for isolating dependencies in tests.
    - **Build Runner**: For generating mock classes.
- **Documentation**:
    - **dartdoc**: Generates API documentation from Dart docstrings.
    - **Sphinx**: Generates HTML documentation site with README and API docs.

**pubspec.yaml Dependencies**:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  provider: ^6.0.5
  image_picker: ^1.0.4
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.6
  dartdoc: ^6.3.0
```

## Contribution

The FarmFresh project was developed by the following team members (replace with actual names and roles):

- **[Your Name]** (Design Lead): Designed UI/UX, implemented consumer-facing screens (`ConsumerHomeScreen`, `PlaceOrderScreen`), and created architecture diagrams.
- **[Team Member 2]** (Test Lead): Wrote UI widget tests (`ui_test.dart`), ensured test coverage, and set up `testing.md`.
- **[Team Member 3]** (Backend Lead): Implemented Firebase integration (`AuthService`, `ProductRepository`) and Firestore/Storage logic.
- **[Team Member 4]** (Documentation Lead): Added Google-style docstrings, set up Sphinx documentation, and wrote README.

Contributions are tracked via Git commits. Each member focused on specific modules, with collaborative code reviews to ensure quality.

## Development Retrospective

### Mistakes and Lessons Learned
- **Firebase Configuration Delays**: Initial misconfiguration of Firestore rules caused access issues. We learned to test Firebase setup early and document rules clearly.
- **Test Coverage Gaps**: Early tests focused on logic but missed UI validation. Adding `ui_test.dart` later increased effort. Future projects should prioritize UI tests from the start.
- **Scope Creep**: Adding features like image uploads stretched timelines. Better initial scoping and prioritization would have saved time.
- **Documentation Overhead**: Docstrings and Sphinx setup were added late, causing a rush. Integrating documentation incrementally would be more efficient.

### Process Improvements
- **Agile Iterations**: Use shorter sprints (1-2 weeks) with clear deliverables to catch issues early.
- **Automated CI/CD**: Set up GitHub Actions for automated testing and linting to reduce manual checks.
- **Early Documentation**: Write docstrings during development and generate Sphinx docs in each sprint.
- **Pair Programming**: Pair on complex features (e.g., Firebase integration) to reduce bugs and knowledge silos.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

*Note*: A placeholder LICENSE file is included. Update with specific terms if needed.

## Testing

FarmFresh includes comprehensive UI widget tests in `test/ui_test.dart`, covering all major features:
- **Consumer Features**: Product browsing (`ConsumerHomeScreen`), cart management (`ConsumerCartScreen`), order placement (`PlaceOrderScreen`), order history (`ConsumerOrderHistoryScreen`), and profile updates (`ConsumerProfileScreen`).
- **Farmer Features**: Product management (`AddProductScreen`, `FarmerProductManagement`), order management (`FarmerOrderManagement`), and profile updates (`FarmerProfileScreen`).
- **Authentication**: Login (`LoginScreen`) and registration (`RegisterScreen`).

### Test Details
- **Location**: `test/ui_test.dart`
- **Coverage**: Tests verify UI rendering, form validation, and user interactions (e.g., button taps, dropdown selections) for all screens. Mockito mocks Firebase dependencies to isolate UI behavior.
- **Running Tests**:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  flutter test test/ui_test.dart
  ```
- **Coverage Report**:
  ```bash
  flutter test --coverage
  genhtml coverage/lcov.info -o coverage/html
  open coverage/html/index.html
  ```

See `testing.md` in the repository root for detailed test coverage and explanations.

## Documentation

The project includes full source code documentation:
- **Docstrings**: All functions, classes, modules, and tests use Google-style docstrings (e.g., `authentication.dart`, `place_order_screen.dart`, `ui_test.dart`).
- **Automated Documentation**:
    - **dartdoc**: Generates API documentation from Dart docstrings:
      ```bash
      dart doc
      ```
      Output: `doc/api/`
    - **Sphinx**: Generates an HTML documentation site combining API docs, README, and architecture details:
      ```bash
      cd docs
      pip install -r requirements.txt
      make html
      ```
      Output: `docs/_build/html/index.html`

The `docs/` directory contains Sphinx configuration (`conf.py`, `index.rst`) and requirements (`requirements.txt`).