import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class VO2MaxEstimator extends StatefulWidget {
  const VO2MaxEstimator({super.key});

  @override
  State<VO2MaxEstimator> createState() => _VO2MaxEstimatorState();
}

class _VO2MaxEstimatorState extends State<VO2MaxEstimator> {
  // Method tracking
  String _selectedMethod = 'heart_rate'; // heart_rate, cooper, running, step_test, friend

  // Common inputs
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _gender = 'male';
  final bool _isMetric = true;

  // Method-specific inputs
  // Heart rate method
  final TextEditingController _restingHRController = TextEditingController();
  final TextEditingController _maxHRController = TextEditingController();

  // Cooper test
  final TextEditingController _cooperDistanceController = TextEditingController();

  // Running performance
  final TextEditingController _raceDistanceController = TextEditingController();
  final TextEditingController _raceMinutesController = TextEditingController();
  final TextEditingController _raceSecondsController = TextEditingController();

  // Step test
  final TextEditingController _stepTestHRController = TextEditingController();
  final TextEditingController _stepTestPeakHRController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _restingHRController.dispose();
    _maxHRController.dispose();
    _cooperDistanceController.dispose();
    _raceDistanceController.dispose();
    _raceMinutesController.dispose();
    _raceSecondsController.dispose();
    _stepTestHRController.dispose();
    _stepTestPeakHRController.dispose();
    super.dispose();
  }

  // Heart Rate Method: VO2max = 15 × (HRmax / HRrest)
  double _calculateHeartRateVO2Max() {
    double restHR = double.parse(_restingHRController.text);
    double maxHR = double.parse(_maxHRController.text);
    return 15 * (maxHR / restHR);
  }

  // Cooper Test: VO2max = (distance in meters - 504.9) / 44.75
  double _calculateCooperVO2Max() {
    double distance = double.parse(_cooperDistanceController.text);
    if (!_isMetric) {
      distance = distance * 1609.34; // miles to meters
    }
    return (distance - 504.9) / 44.75;
  }

  // VDOT Formula (Daniels & Gilbert) for running
  double _calculateVDOTVO2Max() {
    double distance = double.parse(_raceDistanceController.text);
    int minutes = int.parse(_raceMinutesController.text);
    int seconds = int.parse(_raceSecondsController.text);

    if (!_isMetric) {
      distance = distance * 1.60934; // miles to km
    }

    double timeInMinutes = minutes + (seconds / 60);
    double speedMPS = (distance * 1000) / (timeInMinutes * 60);

    double numerator = -4.60 + (0.182258 * speedMPS) + (0.000104 * pow(speedMPS, 2));
    double denominator = 0.8 + (0.1894393 * exp(-0.012778 * timeInMinutes)) +
        (0.2989558 * exp(-0.1932605 * timeInMinutes));

    return numerator / denominator;
  }

  // Step Test Method: Based on HRR2 (heart rate 2 minutes post-exercise)
  double _calculateStepTestVO2Max() {
    double weight = double.parse(_weightController.text);
    if (!_isMetric) {
      weight = weight * 0.453592; // lbs to kg
    }

    double peakHR = double.parse(_stepTestPeakHRController.text);
    double recoveryHR = double.parse(_stepTestHRController.text);
    double hrr2 = peakHR - recoveryHR;

    int genderCode = _gender == 'male' ? 1 : 2;

    // Simplified from: VO2max = -0.528 + 0.039*weight - 3.463*bodyfatrate + 0.042*HRR2 - 0.180*gender
    // Using estimated body fat for simplification
    double estimatedBodyFat = _estimateBodyFat();

    double absoluteVO2 = -0.528 +
        (0.039 * weight) -
        (3.463 * estimatedBodyFat) +
        (0.042 * hrr2) -
        (0.180 * genderCode);

    double relativeVO2 = absoluteVO2 / weight;
    return relativeVO2;
  }

  double _estimateBodyFat() {
    // Rough estimate based on BMI
    double bmi = _calculateBMI();
    if (_gender == 'male') {
      return (1.20 * bmi) + (0.23 * int.parse(_ageController.text)) - 16.2;
    } else {
      return (1.20 * bmi) + (0.23 * int.parse(_ageController.text)) - 5.4;
    }
  }

  double _calculateBMI() {
    double weight = double.parse(_weightController.text);
    double height = 170; // placeholder, should get from input
    if (!_isMetric) {
      weight = weight * 0.453592;
    }
    return weight / ((height / 100) * (height / 100));
  }

  // FRIEND Formula: VO2max = 79.9 - 0.39*age - 13.7*gender - 0.127*weight(lbs)
  double _calculateFRIENDVO2Max() {
    int age = int.parse(_ageController.text);
    double weight = double.parse(_weightController.text);
    int genderCode = _gender == 'male' ? 0 : 1;

    if (_isMetric) {
      weight = weight * 2.20462; // kg to lbs
    }

    return 79.9 - (0.39 * age) - (13.7 * genderCode) - (0.127 * weight);
  }

  void _calculateVO2Max() {
    if (_formKey.currentState!.validate()) {
      double vo2max;
      double accuracy;

      switch (_selectedMethod) {
        case 'heart_rate':
          vo2max = _calculateHeartRateVO2Max();
          accuracy = 4.5;
          break;
        case 'cooper':
          vo2max = _calculateCooperVO2Max();
          accuracy = 5.0;
          break;
        case 'running':
          vo2max = _calculateVDOTVO2Max();
          accuracy = 3.0;
          break;
        case 'step_test':
          vo2max = _calculateStepTestVO2Max();
          accuracy = 6.0;
          break;
        case 'friend':
          vo2max = _calculateFRIENDVO2Max();
          accuracy = 8.0;
          break;
        default:
          vo2max = 0;
          accuracy = 0;
      }

      int age = int.parse(_ageController.text);
      double weight = double.parse(_weightController.text);
      if (!_isMetric) {
        weight = weight * 0.453592;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VO2MaxResultPage(
            vo2max: vo2max,
            accuracy: accuracy,
            method: _selectedMethod,
            age: age,
            weight: weight,
            gender: _gender,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: Row(
          children: [
            Icon(
              Icons.favorite,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "VO2 Max Estimator",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: "Go Back",
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info card
                Card(
                  color: Theme.of(context).primaryColor.withAlpha(30),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              "What is VO2 Max?",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "VO2 max is the maximum amount of oxygen your body can utilize during intense exercise, measured in milliliters of oxygen per kilogram of body weight per minute (mL/kg/min). It's a key indicator of cardiovascular fitness and aerobic endurance.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Common inputs
                Text(
                  "Basic Information",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Age
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Age",
                    hintText: "e.g., 25",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.cake),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Gender
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _gender = 'male'),
                        child: Card(
                          elevation: _gender == 'male' ? 4 : 1,
                          color: _gender == 'male' ? Theme.of(context).primaryColor.withAlpha(100) : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _gender == 'male' ? Theme.of(context).primaryColor : Colors.grey.withAlpha(50),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.male, size: 32, color: _gender == 'male' ? Theme.of(context).primaryColor : Colors.grey),
                                const SizedBox(height: 8),
                                Text("Male", style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _gender = 'female'),
                        child: Card(
                          elevation: _gender == 'female' ? 4 : 1,
                          color: _gender == 'female' ? Theme.of(context).primaryColor.withAlpha(100) : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _gender == 'female' ? Theme.of(context).primaryColor : Colors.grey.withAlpha(50),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.female, size: 32, color: _gender == 'female' ? Theme.of(context).primaryColor : Colors.grey),
                                const SizedBox(height: 8),
                                Text("Female", style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Weight
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  decoration: InputDecoration(
                    labelText: _isMetric ? "Weight (kg)" : "Weight (lbs)",
                    hintText: _isMetric ? "e.g., 70" : "e.g., 154",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Method selection
                Text(
                  "Estimation Method",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Method cards
                ..._buildMethodCards(),
                const SizedBox(height: 24),

                // Method-specific inputs
                _buildMethodInputs(),
                const SizedBox(height: 32),

                // Calculate button
                FilledButton(
                  onPressed: _calculateVO2Max,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calculate),
                      const SizedBox(width: 8),
                      Text(
                        "Calculate VO2 Max",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMethodCards() {
    const methods = [
      ('heart_rate', 'Heart Rate', 'Using resting & max HR'),
      ('cooper', 'Cooper Test', '12-minute run distance'),
      ('running', 'Running Performance', 'Recent race time'),
      ('step_test', 'Step Test', '3-minute aerobic step'),
      ('friend', 'FRIEND Formula', 'Age/weight/gender'),
    ];

    return methods.map((m) => Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = m.$1),
        child: Card(
          elevation: _selectedMethod == m.$1 ? 4 : 1,
          color: _selectedMethod == m.$1 ? Theme.of(context).primaryColor.withAlpha(100) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _selectedMethod == m.$1 ? Theme.of(context).primaryColor : Colors.grey.withAlpha(50),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.$2, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(m.$3, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                if (_selectedMethod == m.$1)
                  Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ),
      ),
    )).toList();
  }

  Widget _buildMethodInputs() {
    switch (_selectedMethod) {
      case 'heart_rate':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Heart Rate Inputs",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _restingHRController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Resting Heart Rate (bpm)",
                hintText: "e.g., 60",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.favorite),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _maxHRController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Max Heart Rate (bpm)",
                hintText: "e.g., 190",
                helperText: "Or use: 220 - age",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.favorite),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
          ],
        );
      case 'cooper':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cooper 12-Minute Run Test",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.amber.withAlpha(30),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Run as far as you can in 12 minutes on a flat surface. Measure the distance covered.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cooperDistanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              decoration: InputDecoration(
                labelText: _isMetric ? "Distance (meters)" : "Distance (miles)",
                hintText: _isMetric ? "e.g., 2500" : "e.g., 1.5",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.straighten),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
          ],
        );
      case 'running':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recent Race Performance",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _raceDistanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              decoration: InputDecoration(
                labelText: _isMetric ? "Distance (km)" : "Distance (miles)",
                hintText: _isMetric ? "e.g., 5" : "e.g., 5",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _raceMinutesController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: "Minutes",
                      hintText: "30",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _raceSecondsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: "Seconds",
                      hintText: "45",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      case 'step_test':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "3-Minute Step Test",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.amber.withAlpha(30),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Step up and down from 8-inch step at 24 steps/min for 3 minutes. Measure heart rate immediately and at 2 minutes post-exercise.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stepTestPeakHRController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Peak HR during test (bpm)",
                hintText: "e.g., 130",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.favorite),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stepTestHRController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "HR at 2 minutes recovery (bpm)",
                hintText: "e.g., 100",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.favorite),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                return null;
              },
            ),
          ],
        );
      case 'friend':
        return Card(
          color: Colors.green.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      "FRIEND Formula",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Using age, weight, and gender data you've provided above. This is the most accurate general population formula, validated on 7,783 healthy participants.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }
}

// Result Page
class VO2MaxResultPage extends StatelessWidget {
  final double vo2max;
  final double accuracy;
  final String method;
  final int age;
  final double weight;
  final String gender;

  const VO2MaxResultPage({
    super.key,
    required this.vo2max,
    required this.accuracy,
    required this.method,
    required this.age,
    required this.weight,
    required this.gender,
  });

  String _getFitnessLevel() {
    if (gender == 'male') {
      if (vo2max >= 60) return 'Superior';
      if (vo2max >= 52) return 'Excellent';
      if (vo2max >= 42) return 'Good';
      if (vo2max >= 35) return 'Average';
      if (vo2max >= 25) return 'Fair';
      return 'Poor';
    } else {
      if (vo2max >= 51) return 'Superior';
      if (vo2max >= 43) return 'Excellent';
      if (vo2max >= 34) return 'Good';
      if (vo2max >= 27) return 'Average';
      if (vo2max >= 18) return 'Fair';
      return 'Poor';
    }
  }

  Color _getFitnessLevelColor() {
    String level = _getFitnessLevel();
    switch (level) {
      case 'Superior':
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Average':
        return Colors.orange;
      case 'Fair':
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  double _getAbsoluteVO2() {
    return (vo2max * weight) / 1000; // L/min
  }

  @override
  Widget build(BuildContext context) {
    double absoluteVO2 = _getAbsoluteVO2();
    String fitnessLevel = _getFitnessLevel();
    Color levelColor = _getFitnessLevelColor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your VO2 Max Results"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: "Go Back",
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main result card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [levelColor, levelColor.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.favorite, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        fitnessLevel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${vo2max.toStringAsFixed(1)} mL/kg/min",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Absolute: ${absoluteVO2.toStringAsFixed(2)} L/min",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Accuracy note
              Card(
                color: Colors.amber.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            "Accuracy: ±${accuracy.toStringAsFixed(1)}%",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Method: ${_getMethodName()}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Comparison to norms
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Age/Gender Comparison",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildComparisonRow(context, "Your Result", vo2max.toStringAsFixed(1)),
                      _buildComparisonRow(context, "Expected Average*", _getAverageVO2().toStringAsFixed(1)),
                      _buildComparisonRow(context, "Status", _getComparisonStatus()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Training zones
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Training Zones",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildZoneItem(context, "Zone 1: Recovery", "50-60% effort", "Easy pace, recovery"),
                      _buildZoneItem(context, "Zone 2: Base", "60-70% effort", "Conversational pace"),
                      _buildZoneItem(context, "Zone 3: Tempo", "70-80% effort", "Harder, less talk"),
                      _buildZoneItem(context, "Zone 4: Threshold", "80-90% effort", "Very hard, difficult"),
                      _buildZoneItem(context, "Zone 5: Maximum", "90-100% effort", "All out sprint"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Improvement suggestions
              Card(
                color: Colors.green.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "How to Improve",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(context, "HIIT Training", "High-intensity intervals boost VO2 max most effectively"),
                      _buildTipItem(context, "Distance Running", "Regular long-distance runs build aerobic capacity"),
                      _buildTipItem(context, "Cycling", "Low-impact option for sustained cardio work"),
                      _buildTipItem(context, "Consistency", "Training 3-4x per week yields best results"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getMethodName() {
    switch (method) {
      case 'heart_rate':
        return 'Heart Rate Method';
      case 'cooper':
        return 'Cooper 12-Minute Run Test';
      case 'running':
        return 'VDOT Running Formula';
      case 'step_test':
        return 'Aerobic Step Test';
      case 'friend':
        return 'FRIEND Registry Formula';
      default:
        return 'Unknown';
    }
  }

  double _getAverageVO2() {
    if (gender == 'male') {
      return 35.0; // Approximate average for sedentary male
    } else {
      return 27.0; // Approximate average for sedentary female
    }
  }

  String _getComparisonStatus() {
    double avg = _getAverageVO2();
    if (vo2max > avg * 1.5) return 'Well above average';
    if (vo2max > avg * 1.2) return 'Above average';
    if (vo2max > avg * 0.8) return 'Average';
    return 'Below average';
  }

  Widget _buildComparisonRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildZoneItem(BuildContext context, String zone, String intensity, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(zone, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text("$intensity • $description", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
