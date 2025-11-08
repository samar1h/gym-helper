import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BMRCalculator extends StatefulWidget {
  const BMRCalculator({super.key});

  @override
  State<BMRCalculator> createState() => _BMRCalculatorState();
}

class _BMRCalculatorState extends State<BMRCalculator> {
  // Controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchesController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // State variables
  bool _isMetric = true;
  String _selectedGender = 'male';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _clearWeight() {
    _weightController.clear();
  }

  void _clearHeight() {
    _heightController.clear();
    _feetController.clear();
    _inchesController.clear();
  }

  void _clearAge() {
    _ageController.clear();
  }

  double _calculateBMR() {
    double weight = double.parse(_weightController.text);
    double height;
    double age = double.parse(_ageController.text);

    // Convert to metric if imperial
    if (!_isMetric) {
      weight = weight * 0.453592; // lbs to kg
      double feet = double.parse(_feetController.text);
      double inches = double.parse(_inchesController.text);
      height = (feet * 12 + inches) * 2.54; // total inches to cm
    } else {
      height = double.parse(_heightController.text);
    }

    // Mifflin-St Jeor Equation
    double bmr;
    if (_selectedGender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    return bmr;
  }

  void _calculateAndNavigate() {
    if (_formKey.currentState!.validate()) {
      double bmr = _calculateBMR();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BMRResultPage(
            bmr: bmr,
            gender: _selectedGender,
            age: int.parse(_ageController.text),
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
              Icons.local_fire_department,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "BMR Calculator",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
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
                            "BMR is the number of calories your body burns at complete rest",
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
                                  "Metric (kg, cm)",
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
                                  "Imperial (lbs, ft)",
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
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGender = 'male';
                          });
                        },
                        child: Card(
                          elevation: _selectedGender == 'male' ? 8 : 1,
                          color: _selectedGender == 'male'
                              ? Theme.of(context).primaryColor.withAlpha(100)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _selectedGender == 'male'
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
                                  Icons.male,
                                  size: 48,
                                  color: _selectedGender == 'male'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Male",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedGender == 'male'
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGender = 'female';
                          });
                        },
                        child: Card(
                          elevation: _selectedGender == 'female' ? 8 : 1,
                          color: _selectedGender == 'female'
                              ? Theme.of(context).primaryColor.withAlpha(100)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _selectedGender == 'female'
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
                                  Icons.female,
                                  size: 48,
                                  color: _selectedGender == 'female'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Female",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedGender == 'female'
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Weight Input
                Text(
                  _isMetric ? "Weight (kg)" : "Weight (lbs)",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
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
                      return 'Please enter your weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Please enter a valid weight';
                    }
                    if (_isMetric && (weight < 20 || weight > 300)) {
                      return 'Weight should be between 20-300 kg';
                    }
                    if (!_isMetric && (weight < 44 || weight > 660)) {
                      return 'Weight should be between 44-660 lbs';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

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
                      if (height == null || height <= 0) {
                        return 'Please enter a valid height';
                      }
                      if (height < 100 || height > 250) {
                        return 'Height should be between 100-250 cm';
                      }
                      return null;
                    },
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _feetController,
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
                          controller: _inchesController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: "Inches",
                            hintText: "e.g., 7",
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

                // Age Input
                Text(
                  "Age (years)",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: "e.g., 25",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearAge,
                      tooltip: "Clear age",
                    ),
                    prefixIcon: const Icon(Icons.cake),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) {
                      return 'Please enter a valid age';
                    }
                    if (age < 15 || age > 100) {
                      return 'Age should be between 15-100 years';
                    }
                    return null;
                  },
                ),
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
                        "Calculate BMR",
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
}

// Result Page
class BMRResultPage extends StatelessWidget {
  final double bmr;
  final String gender;
  final int age;

  const BMRResultPage({
    super.key,
    required this.bmr,
    required this.gender,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your BMR Results"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
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
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withAlpha(180),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Your Basal Metabolic Rate",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${bmr.round()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "calories/day",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // What is BMR Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "What is BMR?",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Basal Metabolic Rate (BMR) is the number of calories your body needs to perform basic life-sustaining functions while at complete rest. This includes breathing, circulation, cell production, and nutrient processing.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // How it's calculated Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calculate,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "How it's calculated",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "This calculator uses the Mifflin-St Jeor Equation, which is considered the most accurate method for calculating BMR.",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          gender == 'male'
                              ? "Men: BMR = (10 × weight kg) + (6.25 × height cm) - (5 × age) + 5"
                              : "Women: BMR = (10 × weight kg) + (6.25 × height cm) - (5 × age) - 161",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Important Note Card
              Card(
                color: Colors.amber.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Important Note",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Your BMR represents calories burned at complete rest. To calculate your Total Daily Energy Expenditure (TDEE), you would multiply your BMR by an activity factor (1.2 for sedentary, up to 1.9 for very active).",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Factors Affecting BMR Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Factors Affecting BMR",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFactorItem(
                        context,
                        Icons.fitness_center,
                        "Muscle Mass",
                        "More muscle increases BMR",
                      ),
                      const SizedBox(height: 12),
                      _buildFactorItem(
                        context,
                        Icons.calendar_today,
                        "Age",
                        "BMR decreases with age",
                      ),
                      const SizedBox(height: 12),
                      _buildFactorItem(
                        context,
                        Icons.person,
                        "Gender",
                        "Men typically have higher BMR",
                      ),
                      const SizedBox(height: 12),
                      _buildFactorItem(
                        context,
                        Icons.info,
                        "Genetics",
                        "Inherited traits affect metabolism",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recalculate Button
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
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

  Widget _buildFactorItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
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
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
