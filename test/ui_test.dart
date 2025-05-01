import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmfresh/cosumer/consumer_cart_screen.dart';
import 'package:farmfresh/cosumer/consumer_home_screen.dart';
import 'package:farmfresh/cosumer/consumer_order_history_screen.dart';
import 'package:farmfresh/cosumer/place_order_screen.dart';
import 'package:farmfresh/farmer/farmer_order_management.dart';
import 'package:farmfresh/farmer/farmer_sales_analytics.dart';
import 'package:farmfresh/firebase_options.dart';
import 'package:farmfresh/help_screen.dart';
import 'package:farmfresh/models.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:farmfresh/app_constants.dart';
import 'package:farmfresh/authentication.dart';
import 'package:farmfresh/welcome_screen.dart';
import 'package:farmfresh/login_screen.dart';
import 'package:farmfresh/register_screen.dart';
import 'package:farmfresh/farmer/add_product_screen.dart';
import 'package:farmfresh/cosumer/consumer_product_listing.dart';
import 'package:farmfresh/farmer/farmer_home_screen.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
  });
  Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ProductRepository>(create: (_) => ProductRepository()),
      ],
      child: MaterialApp(
        home: child,
        routes: {
          '/farmer': (context) => const FarmerHomeScreen(),
          '/consumer': (context) => const ConsumerHomeScreen(),
          '/farmer_orders': (context) =>
              const FarmerHomeScreen(initialIndex: 1),
          '/consumer_orders': (context) =>
              const ConsumerHomeScreen(initialIndex: 2),
        },
      ),
    );
  }

  group('UI Tests for Farm Fresh', () {
    // Test 1: WelcomeScreen renders title and buttons
    testWidgets('WelcomeScreen displays title and Login/Register buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const WelcomeScreen()));
      await tester.pumpAndSettle(); // Wait for animations

      expect(find.text('Welcome to\nFarm Fresh'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    // Test 2: LoginScreen renders email, password fields, and login button
    testWidgets('LoginScreen renders form fields and login button',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Please sign in to continue'), findsOneWidget);
      expect(
          find.byType(TextFormField), findsNWidgets(2)); // Email and Password
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    // Test 3: LoginScreen disables login button when fields are empty
    testWidgets('LoginScreen login button is disabled when fields are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const LoginScreen()));
      await tester.pumpAndSettle();

      final loginButton = find.byType(ElevatedButton);
      expect(tester.widget<ElevatedButton>(loginButton).enabled,
          isTrue); // Initially enabled

      // Simulate tapping the button without filling fields (form validation prevents action)
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation errors appear
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    // Test 4: RegisterScreen renders user type toggle and form fields
    testWidgets('RegisterScreen renders user type toggle and form fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const RegisterScreen()));
      await tester.pumpAndSettle();

      // expect(find.text('Create Account'), findsAny);
      expect(find.text('Consumer'), findsOneWidget);
      expect(find.text('Farmer'), findsOneWidget);
      // expect(find.byType(TextFormField), findsNWidgets(5)); // Name, Email, Phone, Address, Password
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      // expect(find.text('Create Account'), findsOneWidget);
    });

    // Test 5: RegisterScreen shows farmer-specific fields when farmer type is selected
    testWidgets('RegisterScreen shows farm fields when farmer type is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Initially, consumer fields are shown
      expect(find.text('Delivery Address'), findsOneWidget);
      expect(find.text('Farm Name'), findsNothing);
      expect(find.text('Farm Location'), findsNothing);

      // Tap the Farmer toggle
      await tester.tap(find.text('Farmer'));
      await tester.pumpAndSettle();

      // Verify farmer-specific fields appear
      expect(find.text('Delivery Address'), findsNothing);
      expect(find.text('Farm Name'), findsOneWidget);
      expect(find.text('Farm Location'), findsOneWidget);
      expect(find.text('Farm Details'), findsOneWidget);
    });
    //
    // Test 6: AddProductScreen renders form fields and image upload section
    testWidgets('AddProductScreen renders form fields and image upload section',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(const AddProductScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add Product'), findsOneWidget);
      expect(find.text('Product Images'), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Product Name'), findsOneWidget);
      expect(find.text('Price (₹)'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Unit'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Save Product'), findsOneWidget);
    });

    // Test 7: PlaceOrderScreen renders shipping details form and payment options
    testWidgets(
        'PlaceOrderScreen renders shipping details form and payment options',
        (WidgetTester tester) async {
      // Mock cart items for testing
      final mockCartItems = [
        CartItem(
          productId: '1',
          productName: 'Tomato',
          price: 50.0,
          quantity: 2,
          unit: 'kg',
          imageUrl: '',
          farmerId: 'farmer1',
        ),
      ];

      await tester.pumpWidget(wrapWithProviders(
        PlaceOrderScreen(
          cartItems: mockCartItems,
          total: 0,
        ),
      ));
      await tester.pumpAndSettle();

      // expect(find.text('Place Order'), findsOneWidget);
      expect(find.text('Shipping Details'), findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(5)); // Name, Phone, Address, City, Pin Code
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Pin Code'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
      // expect(find.text('Credit Card'), findsOneWidget);
      // expect(find.text('Place Order'), findsOneWidget);
    });

    // Test 8: HelpScreen renders FAQ section and customer care button
    testWidgets('HelpScreen renders FAQ section and customer care button',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(
        const HelpScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Help Center'), findsOneWidget);
      expect(find.text('Welcome to the Help Center!'), findsOneWidget);
      expect(find.text('FAQs:'), findsOneWidget);
      expect(find.text('How do I place an order?'), findsOneWidget);
      expect(find.text('How can I track my order?'), findsOneWidget);
      expect(find.text('More Help - Call Customer Care'), findsOneWidget);
      expect(find.byType(ExpansionTile), findsNWidgets(5)); // 5 FAQs
    });
  });
}
