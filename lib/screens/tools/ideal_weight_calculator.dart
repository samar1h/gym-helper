import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IdealWeightCalculator extends StatefulWidget {
  const IdealWeightCalculator({super.key});

  @override
  State<IdealWeightCalculator> createState() => _IdealWeightCalculatorState();
}

class _IdealWeightCalculatorState extends State<IdealWeightCalculator> {
  // Controllers
  final TextEditingController _heightCmController = TextEditingController();
  final TextEditingController _heightFtController = TextEditingController();
  final TextEditingController _heightInController = TextEditingController();
  final TextEditingController _currentWeightController =
      TextEditingController();
  final TextEditingController _wristController = TextEditingController();

  // State variables
  bool _isMetric = true;
  String _selectedGender = 'male';
  String _selectedFrame = 'medium';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _heightCmController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
    _currentWeightController.dispose();
    _wristController.dispose();
    super.dispose();
  }

  void _clearHeight() {
    _heightCmController.clear();
    _heightFtController.clear();
    _heightInController.clear();
  }

  void _clearWeight() => _currentWeightController.clear();
  void _clearWrist() => _wristController.clear();

  double _getHeightInCm() {
    if (_isMetric) {
      return double.parse(_heightCmController.text);
    } else {
      double feet = double.parse(_heightFtController.text);
      double inches = double.parse(_heightInController.text);
      return (feet * 12 + inches) * 2.54;
    }
  }

  double _getHeightInInchesOver5Feet() {
    double heightCm = _getHeightInCm();
    double totalInches = heightCm / 2.54;
    double feetAsInches = 5 * 12;
    return totalInches - feetAsInches;
  }

  // Calculate ideal weight using different formulas
  double _calculateDevineFormula() {
    double inchesOver5Feet = _getHeightInInchesOver5Feet();
    double baseWeight;

    if (_selectedGender == 'male') {
      baseWeight = 50 + (2.3 * inchesOver5Feet);
    } else {
      baseWeight = 45.5 + (2.3 * inchesOver5Feet);
    }

    // Adjust for frame size
    if (_selectedFrame == 'small') {
      baseWeight *= 0.9; // 10% reduction
    } else if (_selectedFrame == 'large') {
      baseWeight *= 1.1; // 10% increase
    }

    return baseWeight;
  }

  double _calculateRobinsonFormula() {
    double inchesOver5Feet = _getHeightInInchesOver5Feet();
    double baseWeight;

    if (_selectedGender == 'male') {
      baseWeight = 52 + (1.9 * inchesOver5Feet);
    } else {
      baseWeight = 49 + (1.7 * inchesOver5Feet);
    }

    // Adjust for frame size
    if (_selectedFrame == 'small') {
      baseWeight *= 0.9;
    } else if (_selectedFrame == 'large') {
      baseWeight *= 1.1;
    }

    return baseWeight;
  }

  double _calculateMillerFormula() {
    double inchesOver5Feet = _getHeightInInchesOver5Feet();
    double baseWeight;

    if (_selectedGender == 'male') {
      baseWeight = 56.2 + (1.41 * inchesOver5Feet);
    } else {
      baseWeight = 53.1 + (1.36 * inchesOver5Feet);
    }

    // Adjust for frame size
    if (_selectedFrame == 'small') {
      baseWeight *= 0.9;
    } else if (_selectedFrame == 'large') {
      baseWeight *= 1.1;
    }

    return baseWeight;
  }

  double _calculateHamwiFormula() {
    double inchesOver5Feet = _getHeightInInchesOver5Feet();
    double baseWeight;

    if (_selectedGender == 'male') {
      baseWeight = 48 + (2.7 * inchesOver5Feet);
    } else {
      baseWeight = 45.5 + (2.2 * inchesOver5Feet);
    }

    // Adjust for frame size
    if (_selectedFrame == 'small') {
      baseWeight *= 0.9;
    } else if (_selectedFrame == 'large') {
      baseWeight *= 1.1;
    }

    return baseWeight;
  }

  double _calculateBMIBasedIdealWeight() {
    // Using target BMI of 22 (middle of healthy range)
    double heightM = _getHeightInCm() / 100;
    double targetBMI = 22.0;
    double idealWeight = targetBMI * heightM * heightM;

    // Adjust for frame size
    if (_selectedFrame == 'small') {
      idealWeight *= 0.9;
    } else if (_selectedFrame == 'large') {
      idealWeight *= 1.1;
    }

    return idealWeight;
  }

  void _calculateAndNavigate() {
    if (_formKey.currentState!.validate()) {
      double devine = _calculateDevineFormula();
      double robinson = _calculateRobinsonFormula();
      double miller = _calculateMillerFormula();
      double hamwi = _calculateHamwiFormula();
      double bmi = _calculateBMIBasedIdealWeight();

      double average = (devine + robinson + miller + hamwi + bmi) / 5;
      double currentWeight = double.parse(_currentWeightController.text);
      double heightCm = _getHeightInCm();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdealWeightResultPage(
            devineWeight: devine,
            robinsonWeight: robinson,
            millerWeight: miller,
            hamwiWeight: hamwi,
            bmiWeight: bmi,
            averageWeight: average,
            currentWeight: currentWeight,
            heightCm: heightCm,
            gender: _selectedGender,
            frameSize: _selectedFrame,
          ),
        ),
      );
    }
  }

  String _suggestFrame() {
    if (_wristController.text.isEmpty) return 'Measure to determine';

    double wrist = double.parse(_wristController.text);
    double heightCm = _getHeightInCm();

    if (heightCm < 157) {
      // Below 5'2"
      if (wrist < 13.9) return 'Small';
      if (wrist <= 14.6) return 'Medium';
      return 'Large';
    } else if (heightCm < 165) {
      // 5'2" to 5'5"
      if (wrist < 15.2) return 'Small';
      if (wrist <= 15.8) return 'Medium';
      return 'Large';
    } else {
      // Over 5'5"
      if (wrist < 15.8) return 'Small';
      if (wrist <= 16.5) return 'Medium';
      return 'Large';
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
              Icons.self_improvement,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "Ideal Weight",
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
                            "Discover your recommended healthy weight range based on height and frame size",
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
                                _clearHeight();
                                _clearWeight();
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
                                _clearHeight();
                                _clearWeight();
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
                                  "Imperial (ft/in, lbs)",
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

                // Height Input
                Text(
                  _isMetric ? "Height (cm)" : "Height",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isMetric)
                  TextFormField(
                    controller: _heightCmController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: "Height (cm)",
                      hintText: "e.g., 170",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearHeight,
                        tooltip: "Clear height",
                      ),
                      prefixIcon: const Icon(Icons.height),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      final height = double.tryParse(value);
                      if (height == null || height < 100 || height > 250) {
                        return 'Please enter a valid height (100-250 cm)';
                      }
                      return null;
                    },
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightFtController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: "Feet",
                            hintText: "e.g., 5",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.height),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final feet = int.tryParse(value);
                            if (feet == null || feet < 3 || feet > 8) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _heightInController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: "Inches",
                            hintText: "e.g., 6",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearHeight,
                              tooltip: "Clear height",
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final inches = int.tryParse(value);
                            if (inches == null || inches < 0 || inches > 11) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),

                // Current Weight
                Text(
                  _isMetric ? "Current Weight (kg)" : "Current Weight (lbs)",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _currentWeightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: _isMetric ? "kg" : "lbs",
                    hintText: _isMetric ? "e.g., 70" : "e.g., 154",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearWeight,
                      tooltip: "Clear weight",
                    ),
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Wrist Circumference for Frame Size
                Text(
                  _isMetric
                      ? "Wrist Circumference (cm)"
                      : "Wrist Circumference (inches)",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _wristController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: _isMetric ? "cm" : "inches",
                    hintText: _isMetric ? "e.g., 16" : "e.g., 6.25",
                    helperText: "Around wrist bone",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearWrist,
                      tooltip: "Clear wrist",
                    ),
                    prefixIcon: const Icon(Icons.straighten),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                if (_wristController.text.isNotEmpty)
                  Card(
                    color: Colors.blue.withAlpha(30),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Suggested Frame: ${_suggestFrame()}",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // Frame Size Selection
                Text(
                  "Body Frame Size",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._buildFrameCards(),
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
                        "Calculate Ideal Weight",
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

  List<Widget> _buildFrameCards() {
    return ['small', 'medium', 'large'].map((frame) {
      String label = frame.toUpperCase() + frame.substring(1);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedFrame = frame;
            });
          },
          child: Card(
            elevation: _selectedFrame == frame ? 4 : 1,
            color: _selectedFrame == frame
                ? Theme.of(context).primaryColor.withAlpha(100)
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _selectedFrame == frame
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
                    color: _selectedFrame == frame
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _selectedFrame == frame
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                        Text(
                          frame == 'small'
                              ? 'Smaller bones, ±10% reduction'
                              : frame == 'large'
                              ? 'Larger bones, ±10% increase'
                              : 'Average bone structure',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (_selectedFrame == frame)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// Result Page
class IdealWeightResultPage extends StatelessWidget {
  final double devineWeight;
  final double robinsonWeight;
  final double millerWeight;
  final double hamwiWeight;
  final double bmiWeight;
  final double averageWeight;
  final double currentWeight;
  final double heightCm;
  final String gender;
  final String frameSize;

  const IdealWeightResultPage({
    super.key,
    required this.devineWeight,
    required this.robinsonWeight,
    required this.millerWeight,
    required this.hamwiWeight,
    required this.bmiWeight,
    required this.averageWeight,
    required this.currentWeight,
    required this.heightCm,
    required this.gender,
    required this.frameSize,
  });

  double _getBMI(double weight) {
    return weight / ((heightCm / 100) * (heightCm / 100));
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMICategoryColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getWeightStatus() {
    double difference = currentWeight - averageWeight;
    if (difference.abs() < 1) return 'very close to';
    if (difference < 0) {
      return '${difference.abs().toStringAsFixed(1)} kg below';
    }
    return '${difference.toStringAsFixed(1)} kg above';
  }

  @override
  Widget build(BuildContext context) {
    double currentBMI = _getBMI(currentWeight);
    double idealBMI = _getBMI(averageWeight);
    double minIdealWeight = averageWeight * 0.95;
    double maxIdealWeight = averageWeight * 1.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your Ideal Weight Range"),
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
                      colors: [Colors.green, Colors.green.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.scale, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "Ideal Weight Range",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${minIdealWeight.toStringAsFixed(1)} - ${maxIdealWeight.toStringAsFixed(1)} kg",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Your current weight: ${currentWeight.toStringAsFixed(1)} kg",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You are ${_getWeightStatus()} ideal",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Current vs Ideal BMI
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BMI Comparison",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Current BMI",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getBMICategoryColor(
                                      currentBMI,
                                    ).withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        currentBMI.toStringAsFixed(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _getBMICategoryColor(
                                                currentBMI,
                                              ),
                                            ),
                                      ),
                                      Text(
                                        _getBMICategory(currentBMI),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: _getBMICategoryColor(
                                                currentBMI,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ideal BMI",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        idealBMI.toStringAsFixed(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                      ),
                                      Text(
                                        "Healthy Weight",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Formula Breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Formula Comparison ($frameSize frame)",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Average: ${averageWeight.toStringAsFixed(1)} kg",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildFormulaRow(
                        context,
                        "Devine Formula",
                        devineWeight,
                        "Most medically validated",
                      ),
                      _buildFormulaRow(
                        context,
                        "Robinson Formula",
                        robinsonWeight,
                        "Empirical data-based",
                      ),
                      _buildFormulaRow(
                        context,
                        "Miller Formula",
                        millerWeight,
                        "Modern modification",
                      ),
                      _buildFormulaRow(
                        context,
                        "Hamwi Formula",
                        hamwiWeight,
                        "Alternative approach",
                      ),
                      _buildFormulaRow(
                        context,
                        "BMI-Based Formula",
                        bmiWeight,
                        "0.5-0.7% accuracy",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // BMI Categories
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BMI Categories",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryRow(
                        context,
                        "Underweight",
                        "< 18.5",
                        Colors.blue,
                      ),
                      _buildCategoryRow(
                        context,
                        "Healthy Weight",
                        "18.5 - 24.9",
                        Colors.green,
                      ),
                      _buildCategoryRow(
                        context,
                        "Overweight",
                        "25.0 - 29.9",
                        Colors.orange,
                      ),
                      _buildCategoryRow(context, "Obese", "≥ 30.0", Colors.red),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Important Notes
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
                            "Important Notes",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "• This is an ESTIMATE based on formulas developed from population averages\n• Muscle mass, body composition, and bone structure vary significantly\n• Athletes may have higher weight with low body fat\n• These ranges are guidelines, not absolute targets\n• Consult healthcare professionals for personalized advice\n• Frame size adjustment: ±10% based on wrist circumference\n• Formulas are less accurate for very short or very tall individuals",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Science Background
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Scientific Basis",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildScienceItem(
                        context,
                        "Devine Formula (1974)",
                        "Used by physicians for drug dosing calculations",
                      ),
                      _buildScienceItem(
                        context,
                        "Robinson Formula (1983)",
                        "Based on empirical data from large populations",
                      ),
                      _buildScienceItem(
                        context,
                        "Peterson Formula (2016)",
                        "0.5-0.7% accuracy when applied to NHANES data",
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

  Widget _buildFormulaRow(
    BuildContext context,
    String name,
    double weight,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${weight.toStringAsFixed(1)} kg",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String category,
    String range,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(category, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Text(
            range,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildScienceItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
