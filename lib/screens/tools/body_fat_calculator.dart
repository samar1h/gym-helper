import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class BodyFatCalculator extends StatefulWidget {
  const BodyFatCalculator({super.key});

  @override
  State<BodyFatCalculator> createState() => _BodyFatCalculatorState();
}

class _BodyFatCalculatorState extends State<BodyFatCalculator> {
  // Controllers for US Navy Method
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _neckController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // Controllers for Jackson-Pollock Method
  final TextEditingController _chestSkinfoldController =
      TextEditingController();
  final TextEditingController _abdominalSkinfoldController =
      TextEditingController();
  final TextEditingController _thighSkinfoldController =
      TextEditingController();
  final TextEditingController _tricepSkinfoldController =
      TextEditingController();
  final TextEditingController _suprailiacSkinfoldController =
      TextEditingController();

  // State variables
  bool _isMetric = true;
  String _selectedGender = 'male';
  String _selectedMethod = 'navy'; // 'navy' or 'pollock'
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _heightController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _chestSkinfoldController.dispose();
    _abdominalSkinfoldController.dispose();
    _thighSkinfoldController.dispose();
    _tricepSkinfoldController.dispose();
    _suprailiacSkinfoldController.dispose();
    super.dispose();
  }

  void _clearNavyFields() {
    _heightController.clear();
    _neckController.clear();
    _waistController.clear();
    _hipController.clear();
    _weightController.clear();
    _ageController.clear();
  }

  void _clearPollockFields() {
    if (_selectedGender == 'male') {
      _chestSkinfoldController.clear();
      _abdominalSkinfoldController.clear();
      _thighSkinfoldController.clear();
    } else {
      _tricepSkinfoldController.clear();
      _suprailiacSkinfoldController.clear();
      _thighSkinfoldController.clear();
    }
    _ageController.clear();
  }

  double _calculateNavyMethod() {
    double height = double.parse(_heightController.text);
    double neck = double.parse(_neckController.text);
    double waist = double.parse(_waistController.text);
    double hip = _selectedGender == 'female'
        ? double.parse(_hipController.text)
        : 0;

    // Convert to cm if imperial
    if (!_isMetric) {
      height = height * 2.54;
      neck = neck * 2.54;
      waist = waist * 2.54;
      if (_selectedGender == 'female') {
        hip = hip * 2.54;
      }
    }

    double bodyFat;

    if (_selectedGender == 'male') {
      // Male formula: BFP = 495 / (1.0324 - 0.19077 × log10(waist-neck) + 0.15456 × log10(height)) - 450
      double calculation =
          1.0324 -
          (0.19077 * log(waist - neck) / log(10)) +
          (0.15456 * log(height) / log(10));
      bodyFat = (495 / calculation) - 450;
    } else {
      // Female formula: BFP = 495 / (1.29579 - 0.35004 × log10(waist+hip-neck) + 0.22100 × log10(height)) - 450
      double calculation =
          1.29579 -
          (0.35004 * log(waist + hip - neck) / log(10)) +
          (0.22100 * log(height) / log(10));
      bodyFat = (495 / calculation) - 450;
    }

    return bodyFat.clamp(2.0, 70.0);
  }

  double _calculatePollockMethod() {
    double sumSkinfolds = 0;
    double age = double.parse(_ageController.text);

    if (_selectedGender == 'male') {
      // 3-site: chest, abdomen, thigh
      double chest = double.parse(_chestSkinfoldController.text);
      double abdominal = double.parse(_abdominalSkinfoldController.text);
      double thigh = double.parse(_thighSkinfoldController.text);

      sumSkinfolds = chest + abdominal + thigh;

      // Male 3-site equation
      // %BF = (0.29288 × sum) - (0.0005 × sum²) + (0.15845 × age) - 5.76377
      double bodyFat =
          (0.29288 * sumSkinfolds) -
          (0.0005 * pow(sumSkinfolds, 2)) +
          (0.15845 * age) -
          5.76377;

      return bodyFat.clamp(2.0, 70.0);
    } else {
      // 3-site: tricep, suprailiac, thigh
      double tricep = double.parse(_tricepSkinfoldController.text);
      double suprailiac = double.parse(_suprailiacSkinfoldController.text);
      double thigh = double.parse(_thighSkinfoldController.text);

      sumSkinfolds = tricep + suprailiac + thigh;

      // Female 3-site equation
      // %BF = (0.41563 × sum) - (0.00112 × sum²) + (0.03661 × age) + 4.03653
      double bodyFat =
          (0.41563 * sumSkinfolds) -
          (0.00112 * pow(sumSkinfolds, 2)) +
          (0.03661 * age) +
          4.03653;

      return bodyFat.clamp(2.0, 70.0);
    }
  }

  void _calculateAndNavigate() {
    if (_formKey.currentState!.validate()) {
      double bodyFatPercentage;
      String method;

      if (_selectedMethod == 'navy') {
        bodyFatPercentage = _calculateNavyMethod();
        method = 'US Navy';
      } else {
        bodyFatPercentage = _calculatePollockMethod();
        method = 'Jackson-Pollock';
      }

      double weight = double.parse(_weightController.text);
      if (!_isMetric) {
        weight = weight * 0.453592; // lbs to kg
      }

      double fatMass = (weight * bodyFatPercentage) / 100;
      double leanMass = weight - fatMass;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BodyFatResultPage(
            bodyFatPercentage: bodyFatPercentage,
            fatMass: fatMass,
            leanMass: leanMass,
            weight: weight,
            age: int.parse(_ageController.text),
            gender: _selectedGender,
            method: method,
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
              Icons.straighten,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "Body Fat Calculator",
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
                // Info Card
                Card(
                  color: Theme.of(context).primaryColor.withAlpha(30),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Estimate your body fat percentage using simple measurements",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Unit Toggle
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).primaryColor.withAlpha(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMetric = true;
                                _clearNavyFields();
                                _clearPollockFields();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isMetric
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Metric (cm, kg)",
                                  style: TextStyle(
                                    color: _isMetric
                                        ? Colors.white
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMetric = false;
                                _clearNavyFields();
                                _clearPollockFields();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isMetric
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Imperial (in, lbs)",
                                  style: TextStyle(
                                    color: !_isMetric
                                        ? Colors.white
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Gender Selection
                Text(
                  "Gender",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderCard(
                        context,
                        'male',
                        'Male',
                        Icons.male,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenderCard(
                        context,
                        'female',
                        'Female',
                        Icons.female,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Method Selection
                Text(
                  "Measurement Method",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMethodCard(
                  context,
                  'navy',
                  'US Navy Method',
                  'Circumference measurements\n(Accuracy: ±3-4%)',
                ),
                const SizedBox(height: 12),
                _buildMethodCard(
                  context,
                  'pollock',
                  'Jackson-Pollock Method',
                  'Skinfold measurements\n(Accuracy: ±3.5%)',
                ),
                const SizedBox(height: 24),

                // Common fields
                Text(
                  "Basic Information",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Weight
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: _isMetric ? "Weight (kg)" : "Weight (lbs)",
                    hintText: _isMetric ? "e.g., 70" : "e.g., 154",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Height
                TextFormField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: _isMetric ? "Height (cm)" : "Height (inches)",
                    hintText: _isMetric ? "e.g., 170" : "e.g., 67",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.height),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height <= 0) {
                      return 'Please enter a valid height';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Age
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: "Age (years)",
                    hintText: "e.g., 25",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.cake),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0 || age > 120) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Conditional measurement fields
                if (_selectedMethod == 'navy') ...[
                  Text(
                    "Circumference Measurements",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMeasurementField(
                    _neckController,
                    _isMetric ? "Neck (cm)" : "Neck (inches)",
                    "Just below larynx",
                  ),
                  const SizedBox(height: 12),
                  _buildMeasurementField(
                    _waistController,
                    _isMetric ? "Waist (cm)" : "Waist (inches)",
                    _selectedGender == 'male'
                        ? "At navel level"
                        : "At smallest width",
                  ),
                  if (_selectedGender == 'female') ...[
                    const SizedBox(height: 12),
                    _buildMeasurementField(
                      _hipController,
                      _isMetric ? "Hip (cm)" : "Hip (inches)",
                      "At widest part of buttocks",
                    ),
                  ],
                ] else ...[
                  Text(
                    _selectedGender == 'male'
                        ? "Skinfold Measurements (Male - 3 Sites in mm)"
                        : "Skinfold Measurements (Female - 3 Sites in mm)",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedGender == 'male') ...[
                    _buildSkinfoldField(
                      _chestSkinfoldController,
                      "Chest (mm)",
                      "Diagonal fold between axilla and nipple",
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    _buildSkinfoldField(
                      _tricepSkinfoldController,
                      "Tricep (mm)",
                      "Vertical fold at midpoint of tricep",
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildSkinfoldField(
                    _abdominalSkinfoldController,
                    _selectedGender == 'male'
                        ? "Abdominal (mm)"
                        : "Suprailiac (mm)",
                    _selectedGender == 'male'
                        ? "Vertical fold 2cm right of navel"
                        : "Diagonal fold parallel to iliac crest",
                  ),
                  const SizedBox(height: 12),
                  _buildSkinfoldField(
                    _thighSkinfoldController,
                    "Thigh (mm)",
                    "Midpoint of anterior thigh",
                  ),
                ],
                const SizedBox(height: 32),

                // Calculate Button
                FilledButton(
                  onPressed: _calculateAndNavigate,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calculate),
                      const SizedBox(width: 8),
                      Text(
                        "Calculate Body Fat",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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

  Widget _buildGenderCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Card(
        elevation: _selectedGender == value ? 8 : 1,
        color: _selectedGender == value
            ? Theme.of(context).primaryColor.withAlpha(100)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _selectedGender == value
                ? Theme.of(context).primaryColor
                : Colors.grey.withAlpha(50),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: _selectedGender == value
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _selectedGender == value
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard(
    BuildContext context,
    String value,
    String title,
    String description,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Card(
        elevation: _selectedMethod == value ? 4 : 1,
        color: _selectedMethod == value
            ? Theme.of(context).primaryColor.withAlpha(100)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _selectedMethod == value
                ? Theme.of(context).primaryColor
                : Colors.grey.withAlpha(50),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.straighten,
                color: _selectedMethod == value
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _selectedMethod == value
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _selectedMethod == value ? null : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedMethod == value)
                Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: "e.g., 35",
        helperText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.straighten),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter this measurement';
        }
        final measurement = double.tryParse(value);
        if (measurement == null || measurement <= 0) {
          return 'Please enter a valid measurement';
        }
        return null;
      },
    );
  }

  Widget _buildSkinfoldField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: "e.g., 12.5",
        helperText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.pinch),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter this measurement';
        }
        final measurement = double.tryParse(value);
        if (measurement == null || measurement <= 0) {
          return 'Please enter a valid measurement';
        }
        return null;
      },
    );
  }
}

// Result Page
class BodyFatResultPage extends StatelessWidget {
  final double bodyFatPercentage;
  final double fatMass;
  final double leanMass;
  final double weight;
  final int age;
  final String gender;
  final String method;

  const BodyFatResultPage({
    super.key,
    required this.bodyFatPercentage,
    required this.fatMass,
    required this.leanMass,
    required this.weight,
    required this.age,
    required this.gender,
    required this.method,
  });

  String _getCategory() {
    if (gender == 'male') {
      if (bodyFatPercentage < 6) return 'Essential Fat';
      if (bodyFatPercentage < 14) return 'Athletes';
      if (bodyFatPercentage < 18) return 'Fitness';
      if (bodyFatPercentage < 25) return 'Overweight';
      return 'Obese';
    } else {
      if (bodyFatPercentage < 14) return 'Essential Fat';
      if (bodyFatPercentage < 21) return 'Athletes';
      if (bodyFatPercentage < 25) return 'Fitness';
      if (bodyFatPercentage < 32) return 'Overweight';
      return 'Obese';
    }
  }

  Color _getCategoryColor() {
    String category = _getCategory();
    switch (category) {
      case 'Essential Fat':
      case 'Athletes':
        return Colors.green;
      case 'Fitness':
        return Colors.blue;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getIdealRange() {
    if (gender == 'male') {
      if (age < 20) return '7-17%';
      if (age < 30) return '7-17%';
      if (age < 40) return '11-20%';
      if (age < 50) return '13-21%';
      return '15-22%';
    } else {
      if (age < 20) return '10-24%';
      if (age < 30) return '10-24%';
      if (age < 40) return '14-27%';
      if (age < 50) return '16-29%';
      return '18-30%';
    }
  }

  @override
  Widget build(BuildContext context) {
    Color categoryColor = _getCategoryColor();
    String category = _getCategory();
    String idealRange = _getIdealRange();

    final rangeParts = idealRange.split('-');
    final minValue = double.parse(rangeParts[0].replaceAll('%', ''));
    final maxValue = double.parse(rangeParts[1].replaceAll('%', ''));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your Body Fat Results"),
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
              // Main Result Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [categoryColor, categoryColor.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.fitness_center, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${bodyFatPercentage.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Body Fat Percentage",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Accuracy Disclaimer
              Card(
                color: Colors.amber.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            "Accuracy: ±3-4%",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "$method method estimates your body fat percentage within ±3-4% accuracy. For medical-grade assessment, DEXA scans (±2-3%) are more accurate but require specialized equipment.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Body Composition Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Body Composition",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCompositionItem(
                        context,
                        "Total Weight",
                        "${weight.toStringAsFixed(1)} kg",
                        Icons.monitor_weight_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildCompositionItem(
                        context,
                        "Fat Mass",
                        "${fatMass.toStringAsFixed(1)} kg (${bodyFatPercentage.toStringAsFixed(1)}%)",
                        Icons.favorite,
                      ),
                      const SizedBox(height: 12),
                      _buildCompositionItem(
                        context,
                        "Lean Body Mass",
                        "${leanMass.toStringAsFixed(1)} kg (${(100 - bodyFatPercentage).toStringAsFixed(1)}%)",
                        Icons.favorite_border,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Comparison
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Body Fat Categories",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (gender == 'male') ...[
                        _buildCategoryRow(context, "Essential Fat", "< 6%"),
                        _buildCategoryRow(context, "Athletes", "6-14%"),
                        _buildCategoryRow(context, "Fitness", "14-18%"),
                        _buildCategoryRow(context, "Overweight", "18-25%"),
                        _buildCategoryRow(context, "Obese", "> 25%"),
                      ] else ...[
                        _buildCategoryRow(context, "Essential Fat", "< 14%"),
                        _buildCategoryRow(context, "Athletes", "14-21%"),
                        _buildCategoryRow(context, "Fitness", "21-25%"),
                        _buildCategoryRow(context, "Overweight", "25-32%"),
                        _buildCategoryRow(context, "Obese", "> 32%"),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ideal Range for Age/Gender
              Card(
                color: Colors.green.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Your Ideal Range",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "For $gender age $age: $idealRange",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bodyFatPercentage >= minValue &&
                                bodyFatPercentage <= maxValue
                            ? "✓ You are within your ideal range!"
                            : "Your current body fat is outside the recommended range.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Scientific Background
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Calculation Method",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        method == 'US Navy'
                            ? "US Navy Method (NHRC)\nDeveloped by Naval Health Research Center\nFormula: Circumference-based calculation\nPopulation: Validated on 500+ adults\nAccuracy: ±3-4%"
                            : "Jackson-Pollock Method\nDeveloped by Jackson & Pollock\nFormula: Skinfold measurement based\nPopulation: Validated on 400+ adults\nAccuracy: ±3.5%",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Important Notes
              Card(
                color: Colors.red.withAlpha(20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_outlined, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            "Important Notes",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "• This is an ESTIMATE only, not a clinical measurement\n• Accuracy varies based on measurement technique\n• Jackson-Pollock method underestimates body fat >120mm sum skinfolds\n• For clinical assessment, consult healthcare professionals\n• Consider measuring at the same time/conditions for consistency\n• Muscle mass significantly affects body composition",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recalculate Button
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: 8),
                    Text(
                      "Recalculate",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    );
  }

  Widget _buildCompositionItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String category,
    String range,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: Theme.of(context).textTheme.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              range,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
