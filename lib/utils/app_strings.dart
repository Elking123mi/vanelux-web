import 'package:flutter/material.dart';

// App Constants and Strings in English
class AppConstants {
  // App Info
  static const String appName = 'VaneLux';
  static const String appTagline = 'Luxury Rides, Premium Experience';

  // Colors
  static const int primaryGold = 0xFFD4AF37;
  static const int primaryDark = 0xFF1A1A2E;
  static const int secondaryDark = 0xFF16213E;
  static const int accentGreen = 0xFF50C878;

  // Auth Strings
  static const String welcomeBack = 'Welcome Back';
  static const String signInToContinue = 'Sign in to continue';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String signIn = 'Sign In';
  static const String dontHaveAccount = "Don't have an account?";
  static const String signUp = 'Sign Up';
  static const String areYouDriver = 'Are you a driver?';
  static const String driverSignIn = 'Driver Sign In';

  // Registration
  static const String joinVaneLux = 'Join VaneLux';
  static const String createAccountEnjoyLuxury =
      'Create your account and enjoy luxury';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String confirmPassword = 'Confirm Password';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String applyToBecomeDriver = 'Apply to become a Driver';

  // Driver Registration
  static const String becomeDriver = 'Become a VaneLux Driver';
  static const String earnWithLuxury = 'Earn money driving luxury vehicles';
  static const String licenseNumber = 'Driver License Number';
  static const String vehicleMake = 'Vehicle Make';
  static const String vehicleModel = 'Vehicle Model';
  static const String vehicleYear = 'Vehicle Year';
  static const String submitApplication = 'Submit Application';

  // Home Screen
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String whereToToday = 'Where to today?';
  static const String currentLocation = 'Current Location';
  static const String gettingLocation = 'Getting location...';
  static const String bookRide = 'Book a Ride';
  static const String quickActions = 'Quick Actions';
  static const String rideHistory = 'Ride History';
  static const String savedPlaces = 'Saved Places';
  static const String promotions = 'Promotions';

  // Vehicle Types
  static const String sedan = 'Sedan';
  static const String suv = 'SUV';
  static const String luxury = 'Luxury';
  static const String van = 'Van';

  // Booking
  static const String bookYourRide = 'Book Your Ride';
  static const String whereAreYou = 'Where are you?';
  static const String whereToGo = 'Where do you want to go?';
  static const String selectVehicle = 'Select Vehicle Type';
  static const String paymentMethod = 'Payment Method';
  static const String estimatedFare = 'Estimated Fare';
  static const String bookNow = 'Book Now';

  // Payment Methods
  static const String cash = 'Cash';
  static const String creditCard = 'Credit Card';
  static const String debitCard = 'Debit Card';
  static const String digitalWallet = 'Digital Wallet';
  static const String applePay = 'Apple Pay';
  static const String googlePay = 'Google Pay';
  static const String paypal = 'PayPal';

  // Profile
  static const String profile = 'Profile';
  static const String personalInfo = 'Personal Information';
  static const String preferences = 'Preferences';
  static const String paymentMethods = 'Payment Methods';
  static const String notifications = 'Notifications';
  static const String support = 'Support';
  static const String about = 'About';
  static const String signOut = 'Sign Out';

  // Trip History
  static const String tripHistory = 'Trip History';
  static const String allTrips = 'All Trips';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';
  static const String thisMonth = 'This Month';
  static const String rateTrip = 'Rate Trip';
  static const String rateDriver = 'Rate Driver';

  // Status
  static const String requested = 'Requested';
  static const String accepted = 'Accepted';
  static const String inProgress = 'In Progress';
  static const String finished = 'Finished';

  // Messages
  static const String loginSuccessful = 'Login successful';
  static const String registrationSuccessful = 'Registration successful';
  static const String errorOccurred = 'An error occurred';
  static const String pleaseWait = 'Please wait...';
  static const String loading = 'Loading...';
  static const String noTripsFound = 'No trips found';
  static const String tryAgain = 'Try Again';

  // Validation
  static const String pleaseEnterEmail = 'Please enter your email';
  static const String pleaseEnterValidEmail = 'Please enter a valid email';
  static const String pleaseEnterPassword = 'Please enter your password';
  static const String passwordTooShort =
    'Password must be at least 8 characters';
  static const String pleaseEnterName = 'Please enter your name';
  static const String pleaseEnterPhone = 'Please enter your phone number';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidName = 'Invalid name';
  static const String invalidEmail = 'Invalid email';
  static const String invalidPhone = 'Invalid phone number';
  static const String pleaseConfirmPassword = 'Please confirm your password';

  // UI Constants
  static const double defaultRadius = 15.0;
  static const int minPasswordLength = 8;
  static const double defaultPadding = 20.0;

  // Animation durations used across widgets
  static const Duration shortAnimationDuration = Duration(milliseconds: 250);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Color palette (used across widgets expecting AppConstants colors)
  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color secondaryColor = Color(0xFFFFD700);
  static const Color accentColor = Color(0xFF16213E);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF50C878);
  static const Color warningColor = Color(0xFFFFA500);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography sizes used in widgets
  static const double titleFontSize = 24.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;

  // Layout / UI
  static const double cardElevation = 8.0;

  // Missing strings
  static const String orSignUpWith = 'Or sign up with';
}
