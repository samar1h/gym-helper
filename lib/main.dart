// Updated main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_helper/screens/tools/bmi_calculator.dart';
import 'package:gym_helper/screens/home_screen.dart';
import 'package:gym_helper/screens/tools/bmr-calculator.dart';
import 'package:gym_helper/screens/tools/body_fat_calculator.dart';
import 'package:gym_helper/screens/tools/calorie_calculator.dart';
import 'package:gym_helper/screens/tools/daily-steps-calculator.dart';
import 'package:gym_helper/screens/tools/gym-assesment.dart';
import 'package:gym_helper/screens/tools/ideal_weight_calculator.dart';
import 'package:gym_helper/screens/tools/macronutrient-calculator.dart';
import 'package:gym_helper/screens/tools/protein_calculator.dart';
import 'package:gym_helper/screens/tools/sleep-calculator.dart';
import 'package:gym_helper/screens/tools/vo2-max-estimator.dart';
import 'package:gym_helper/screens/tools/water_calculator.dart';
import 'package:gym_helper/theme_provider.dart';
import 'package:gym_helper/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: "Gym Helper",
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              );
            },
            routes: {
              "/": (context) => const HomeScreen(),
              "/settings": (context) => const SettingsScreen(),
              "/bmi-calculator": (context) => const BMICalculator(),
              "/bmr-calculator": (context) => const BMRCalculator(),
              '/calorie-calculator': (context) => const CalorieCalculator(),
              '/protein-calculator': (context) => const ProteinCalculator(),
              "/body-fat-calculator": (context) => const BodyFatCalculator(),
              "/water-calculator": (context) => const WaterIntakeCalculator(),
              "/ideal-weight-calculator": (context) =>
                  const IdealWeightCalculator(),
              "/macronutrient-calculator": (context) =>
                  const MacronutrientCalculator(),
              "/vo2-max-estimator": (context) => const VO2MaxEstimator(),
              "/is-gym-for-me": (context) => const GymReadinessAssessment(),
              "/daily-steps": (context) => const DailyStepsCalculator(),
              "/sleep-calculator": (context) => const SleepCalculator(),
            },
            initialRoute: "/",
          );
        },
      ),
    );
  }
}
