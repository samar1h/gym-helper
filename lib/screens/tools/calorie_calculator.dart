import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalorieCalculator extends StatefulWidget {
  const CalorieCalculator({super.key});

  @override
  State<CalorieCalculator> createState() => _CalorieCalculatorState();
}

class _CalorieCalculatorState extends State<CalorieCalculator> {
  // Controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchesController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // State variables
  bool _isMetric = true;
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'lightly_active';
  String _selectedGoal = 'maintenance';
  final _formKey = GlobalKey<FormState>();

  // Activity level multipliers and labels
  final Map<String, double> _activityMultipliers = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'super_active': 1.9,
  };

  final Map<String, String> _activityLabels = {
    'sedentary': 'Sedentary (little or no exercise)',
    'lightly_active': 'Lightly Active (1-3 days/week)',
    'moderately_active': 'Moderately Active (3-5 days/week)',
    'very_active': 'Very Active (6-7 days/week)',
    'super_active': 'Super Active (2x training/day)',
  };

  final Map<String, String> _goalLabels = {
    'weight_loss': 'Weight Loss',
    'maintenance': 'Maintenance',
    'muscle_gain': 'Muscle Gain',
  };

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _clearWeight() => _weightController.clear();
  void _clearHeight() {
    _heightController.clear();
    _feetController.clear();
    _inchesController.clear();
  }

  void _clearAge() => _ageController.clear();

  double _calculateBMR() {
    double weight = double.parse(_weightController.text);
    double height;
    double age = double.parse(_ageController.text);

    if (!_isMetric) {
      weight = weight * 0.453592; // lbs to kg
      double feet = double.parse(_feetController.text);
      double inches = double.parse(_inchesController.text);
      height = (feet * 12 + inches) * 2.54; // inches to cm
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

  double _calculateTDEE(double bmr) {
    double multiplier = _activityMultipliers[_selectedActivityLevel] ?? 1.375;
    return bmr * multiplier;
  }

  double _calculateCalorieTarget(double tdee) {
    switch (_selectedGoal) {
      case 'weight_loss':
        return tdee - 500;
      case 'muscle_gain':
        return tdee + 300;
      case 'maintenance':
      default:
        return tdee;
    }
  }

  void _calculateAndNavigate() {
    if (_formKey.currentState!.validate()) {
      double bmr = _calculateBMR();
      double tdee = _calculateTDEE(bmr);
      double calorieTarget = _calculateCalorieTarget(tdee);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FitnessResultPage(
            bmr: bmr,
            tdee: tdee,
            calorieTarget: calorieTarget,
            goal: _selectedGoal,
            activityLevel: _selectedActivityLevel,
            gender: _selectedGender,
            age: int.parse(_ageController.text),
            activityLabels: _activityLabels,
            goalLabels: _goalLabels,
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
              Icons.fitness_center,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "Calorie Calculator",
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
                            "Calculate BMR, TDEE, and daily calorie targets for your fitness goals",
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
                const SizedBox(height: 24),

                // Activity Level Section
                Text(
                  "Activity Level",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._activityLabels.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedActivityLevel = entry.key;
                        });
                      },
                      child: Card(
                        elevation: _selectedActivityLevel == entry.key ? 4 : 1,
                        color: _selectedActivityLevel == entry.key
                            ? Theme.of(context).primaryColor.withAlpha(100)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _selectedActivityLevel == entry.key
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
                                Icons.favorite_border,
                                color: _selectedActivityLevel == entry.key
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedActivityLevel == entry.key
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              if (_selectedActivityLevel == entry.key)
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
                }),
                const SizedBox(height: 24),

                // Goal Selection Section
                Text(
                  "Fitness Goal",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGoalCard(
                        context,
                        'weight_loss',
                        'Weight Loss',
                        Icons.trending_down,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGoalCard(
                        context,
                        'maintenance',
                        'Maintenance',
                        Icons.scale,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGoalCard(
                        context,
                        'muscle_gain',
                        'Muscle Gain',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                  ],
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
                        "Calculate",
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

  Widget _buildGoalCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      child: Card(
        elevation: _selectedGoal == value ? 8 : 1,
        color: _selectedGoal == value ? color.withAlpha(100) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _selectedGoal == value ? color : Colors.grey.withAlpha(50),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: _selectedGoal == value ? color : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: _selectedGoal == value ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Result Page - Shows all calculations
class FitnessResultPage extends StatelessWidget {
  final double bmr;
  final double tdee;
  final double calorieTarget;
  final String goal;
  final String activityLevel;
  final String gender;
  final int age;
  final Map<String, String> activityLabels;
  final Map<String, String> goalLabels;

  const FitnessResultPage({
    super.key,
    required this.bmr,
    required this.tdee,
    required this.calorieTarget,
    required this.goal,
    required this.activityLevel,
    required this.gender,
    required this.age,
    required this.activityLabels,
    required this.goalLabels,
  });

  Color _getGoalColor() {
    switch (goal) {
      case 'weight_loss':
        return Colors.red;
      case 'muscle_gain':
        return Colors.green;
      case 'maintenance':
      default:
        return Colors.blue;
    }
  }

  String _getGoalDescription() {
    switch (goal) {
      case 'weight_loss':
        return 'A 500-calorie daily deficit creates sustainable weight loss of about 0.5 kg (1 lb) per week.';
      case 'muscle_gain':
        return 'A 300-calorie daily surplus supports muscle growth while minimizing excess fat gain.';
      case 'maintenance':
      default:
        return 'Eat this amount to maintain your current weight without gaining or losing.';
    }
  }

  @override
  Widget build(BuildContext context) {
    double deficit = goal == 'weight_loss' ? (tdee - calorieTarget).abs() : 0;
    double surplus = goal == 'muscle_gain' ? (calorieTarget - tdee).abs() : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your Results"),
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
              // BMR Card
              _buildMetricCard(
                context,
                'Basal Metabolic Rate (BMR)',
                '${bmr.round()} cal/day',
                Icons.local_fire_department,
                Theme.of(context).primaryColor,
                'Calories your body burns at complete rest',
              ),
              const SizedBox(height: 12),

              // Arrow
              Center(child: Icon(Icons.arrow_downward, color: Colors.grey)),
              const SizedBox(height: 12),

              // TDEE Card
              _buildMetricCard(
                context,
                'Total Daily Energy Expenditure (TDEE)',
                '${tdee.round()} cal/day',
                Icons.directions_run,
                Colors.orange,
                'BMR × Activity Level (${_getActivityMultiplier().toStringAsFixed(2)})',
              ),
              const SizedBox(height: 12),

              // Arrow
              Center(child: Icon(Icons.arrow_downward, color: Colors.grey)),
              const SizedBox(height: 12),

              // Daily Calorie Target Card
              _buildMetricCard(
                context,
                goalLabels[goal]!,
                '${calorieTarget.round()} cal/day',
                Icons.restaurant,
                _getGoalColor(),
                _getGoalDescription(),
              ),
              const SizedBox(height: 24),

              // Explanation Cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How These Calculations Work',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildExplanationItem(
                        context,
                        '1. BMR Calculation',
                        'Uses the Mifflin-St Jeor equation based on your age, gender, weight, and height.',
                        Icons.calculate,
                      ),
                      const SizedBox(height: 16),
                      _buildExplanationItem(
                        context,
                        '2. TDEE Calculation',
                        'Your BMR is multiplied by an activity factor (${_getActivityMultiplier().toStringAsFixed(2)}) to account for daily movement and exercise.',
                        Icons.directions_run,
                      ),
                      const SizedBox(height: 16),
                      _buildExplanationItem(
                        context,
                        '3. Goal-Based Calories',
                        goal == 'weight_loss'
                            ? 'Subtract 500 calories from TDEE for safe, sustainable weight loss (3,500 cal deficit = 0.5 kg loss).'
                            : goal == 'muscle_gain'
                            ? 'Add 300 calories to TDEE to support muscle growth while minimizing fat gain.'
                            : 'Eat at TDEE level to maintain current weight.',
                        Icons.restaurant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Deficit/Surplus Info
              if (goal != 'maintenance')
                Card(
                  color: _getGoalColor().withAlpha(30),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal == 'weight_loss'
                              ? 'Your Calorie Deficit'
                              : 'Your Calorie Surplus',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getGoalColor(),
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (goal == 'weight_loss')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Deficit: ${deficit.round()} calories',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Weekly Deficit: ${(deficit * 7).round()} calories',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Expected Weight Loss: ~0.5 kg (1 lb) per week',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Surplus: ${surplus.round()} calories',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Weekly Surplus: ${(surplus * 7).round()} calories',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Expected Weight Gain: ~0.3 kg per week (with strength training)',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Tips Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips for Success',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTipItem(
                        context,
                        'Track Your Intake',
                        'Use a food tracking app to monitor daily calories',
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        context,
                        'Stay Consistent',
                        'Results take time; aim for consistency over perfection',
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        context,
                        'Adjust as Needed',
                        'Recalculate every 4-6 weeks as your weight changes',
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        context,
                        'Prioritize Protein',
                        'Helps with satiety and muscle preservation/growth',
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        context,
                        'Move More',
                        'Increase daily activity to boost results',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Disclaimer Card
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
                            Icons.warning_outlined,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Important Disclaimer',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'These are estimates. Individual metabolic rates vary based on genetics, muscle mass, hormones, and medical conditions. For personalized advice, consult a registered dietitian or healthcare professional.',
                        style: Theme.of(context).textTheme.bodyMedium,
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

  double _getActivityMultiplier() {
    const Map<String, double> multipliers = {
      'sedentary': 1.2,
      'lightly_active': 1.375,
      'moderately_active': 1.55,
      'very_active': 1.725,
      'super_active': 1.9,
    };
    return multipliers[activityLevel] ?? 1.375;
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String description,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withAlpha(180)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(BuildContext context, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).primaryColor,
            size: 18,
          ),
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
              const SizedBox(height: 2),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
