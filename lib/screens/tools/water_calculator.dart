import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaterIntakeCalculator extends StatefulWidget {
  const WaterIntakeCalculator({super.key});

  @override
  State<WaterIntakeCalculator> createState() => _WaterIntakeCalculatorState();
}

class _WaterIntakeCalculatorState extends State<WaterIntakeCalculator> {
  // Controllers
  final TextEditingController _weightController = TextEditingController();

  // State variables
  bool _isMetric = true;
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderately_active';
  String _selectedClimate = 'moderate';
  final _formKey = GlobalKey<FormState>();

  // Gender-specific multipliers (based on clinical studies)
  // Males: generally higher dehydration risk (NHANES III data)
  // Females: lower baseline requirements
  final Map<String, double> _genderBaseMultipliers = {
    'male': 0.035, // 35ml per kg (higher baseline)
    'female': 0.031, // 31ml per kg (lower baseline)
  };

  // Activity level multipliers
  final Map<String, double> _activityMultipliers = {
    'sedentary': 1.0,
    'lightly_active': 1.1,
    'moderately_active': 1.25,
    'very_active': 1.5,
    'super_active': 1.75,
  };

  final Map<String, String> _activityLabels = {
    'sedentary': 'Sedentary (little or no exercise)',
    'lightly_active': 'Lightly Active (1-3 days/week)',
    'moderately_active': 'Moderately Active (3-5 days/week)',
    'very_active': 'Very Active (6-7 days/week)',
    'super_active': 'Super Active (intense training daily)',
  };

  // Climate adjustments
  final Map<String, double> _climateMultipliers = {
    'cold': 1.0,
    'moderate': 1.0,
    'hot': 1.2,
  };

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _clearWeight() => _weightController.clear();

  double _getWeightInKg() {
    double weight = double.parse(_weightController.text);
    if (!_isMetric) {
      weight = weight / 2.205; // lbs to kg
    }
    return weight;
  }

  double _calculateDailyWater() {
    double weightInKg = _getWeightInKg();

    // Base formula with gender adjustment
    double genderMultiplier = _genderBaseMultipliers[_selectedGender] ?? 0.035;
    double baseWater = weightInKg * genderMultiplier;

    // Apply activity multiplier
    double activityMultiplier =
        _activityMultipliers[_selectedActivityLevel] ?? 1.0;
    double waterAfterActivity = baseWater * activityMultiplier;

    // Apply climate adjustment
    double climateMultiplier = _climateMultipliers[_selectedClimate] ?? 1.0;
    double waterAfterClimate = waterAfterActivity * climateMultiplier;

    return waterAfterClimate;
  }

  void _calculateAndNavigate() {
    if (_formKey.currentState!.validate()) {
      double dailyWater = _calculateDailyWater();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaterResultPage(
            dailyWaterLiters: dailyWater,
            weight: double.parse(_weightController.text),
            isMetric: _isMetric,
            gender: _selectedGender,
            activityLevel: _selectedActivityLevel,
            climate: _selectedClimate,
            activityLabels: _activityLabels,
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
              Icons.water_drop,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "Water Intake",
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
                            "Calculate your minimum daily water intake based on scientific research",
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
                                  "Metric (kg)",
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
                                  "Imperial (lbs)",
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
                  _isMetric ? "Body Weight (kg)" : "Body Weight (lbs)",
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
                      return 'Please enter your body weight';
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
                const SizedBox(height: 24),

                // Activity Level
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
                                Icons.directions_run,
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

                // Climate Selection
                Text(
                  "Climate/Temperature",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildClimateCard(
                        context,
                        'cold',
                        'Cold',
                        Icons.cloud_queue,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildClimateCard(
                        context,
                        'moderate',
                        'Moderate',
                        Icons.wb_cloudy,
                        Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildClimateCard(
                        context,
                        'hot',
                        'Hot',
                        Icons.wb_sunny,
                        Colors.orange,
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
                        "Calculate Water Intake",
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

  Widget _buildClimateCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedClimate = value;
        });
      },
      child: Card(
        elevation: _selectedClimate == value ? 8 : 1,
        color: _selectedClimate == value ? color.withAlpha(100) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _selectedClimate == value
                ? color
                : Colors.grey.withAlpha(50),
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
                color: _selectedClimate == value ? color : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: _selectedClimate == value ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Result Page
class WaterResultPage extends StatelessWidget {
  final double dailyWaterLiters;
  final double weight;
  final bool isMetric;
  final String gender;
  final String activityLevel;
  final String climate;
  final Map<String, String> activityLabels;

  const WaterResultPage({
    super.key,
    required this.dailyWaterLiters,
    required this.weight,
    required this.isMetric,
    required this.gender,
    required this.activityLevel,
    required this.climate,
    required this.activityLabels,
  });

  double _getWaterInOunces() {
    return dailyWaterLiters * 33.814;
  }

  double _getWaterInCups() {
    return dailyWaterLiters * 4.227;
  }

  @override
  Widget build(BuildContext context) {
    double waterInOz = _getWaterInOunces();
    double waterInCups = _getWaterInCups();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your Minimum Hydration Target"),
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
                      colors: [Colors.cyan, Colors.cyan.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.water_drop, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "Minimum Daily Water Target",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${dailyWaterLiters.toStringAsFixed(2)}L",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${waterInCups.toStringAsFixed(1)} cups / ${waterInOz.toStringAsFixed(0)} oz",
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

              // Important Disclaimer - MINIMUM
              Card(
                color: Colors.red.withAlpha(30),
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
                            "This is the MINIMUM",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "This calculation shows your minimum daily water requirement based on your body weight and activity level. Your actual water needs may be significantly higher depending on individual factors, diet, medications, health conditions, and environmental exposure.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Science Background Card
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
                        "Calculation Formula",
                        gender == 'male'
                            ? "Male: 35ml × body weight (kg) × activity factor × climate factor"
                            : "Female: 31ml × body weight (kg) × activity factor × climate factor",
                      ),
                      const SizedBox(height: 12),
                      _buildScienceItem(
                        context,
                        "Gender Differences",
                        gender == 'male'
                            ? "Males show higher dehydration risk (23% in men vs 16% in women, NHANES III)"
                            : "Females typically have lower baseline water requirements",
                      ),
                      const SizedBox(height: 12),
                      _buildScienceItem(
                        context,
                        "Activity Adjustment",
                        "Accounts for increased sweat loss during exercise",
                      ),
                      const SizedBox(height: 12),
                      _buildScienceItem(
                        context,
                        "Climate Factor",
                        "Hot climates increase water loss by up to 20%",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Forehead Pinch Test Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forehead Pinch Test (Skin Turgor)",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Gently pinch the skin on your forehead between two fingers to create a small tent. Release and observe how quickly it returns to normal.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTurgorItem(
                        context,
                        "Well Hydrated",
                        "Skin snaps back immediately (<1 second)",
                        true,
                      ),
                      const SizedBox(height: 12),
                      _buildTurgorItem(
                        context,
                        "Mild Dehydration",
                        "Skin takes 1-2 seconds to return to normal",
                        false,
                      ),
                      const SizedBox(height: 12),
                      _buildTurgorItem(
                        context,
                        "Moderate-Severe Dehydration",
                        "Skin takes >2 seconds or remains tented",
                        false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Important Limitations Card
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
                            "Test Limitations",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "• Skin turgor has MODERATE RELIABILITY per peer-reviewed clinical studies\n• Less reliable in older adults due to natural skin elasticity loss\n• Can be affected by skin condition, collagen disorders, extreme weight loss\n• Best used as one of multiple hydration indicators, not as sole assessment\n• If severely dehydrated or experiencing dizziness/confusion, seek immediate medical attention",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Factors Increasing Water Needs Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Factors That Increase Water Needs",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFactorItem(
                        context,
                        Icons.local_cafe,
                        "Caffeine & Alcohol",
                        "Both act as diuretics, increasing water loss",
                      ),
                      const SizedBox(height: 12),
                      _buildFactorItem(
                        context,
                        Icons.medication,
                        "Certain Medications",
                        "Diuretics, antihistamines, and others",
                      ),
                      const SizedBox(height: 12),
                      _buildFactorItem(
                        context,
                        Icons.favorite,
                        "Health Conditions",
                        "Diabetes, kidney disease, fever, diarrhea",
                      ),
                      const SizedBox(height: 12),
                      _buildFactorItem(
                        context,
                        Icons.child_care,
                        "Pregnancy & Breastfeeding",
                        "Increased physiological water demands",
                      ),
                      const SizedBox(height: 12),
                      _buildFactorItem(
                        context,
                        Icons.elderly,
                        "Age & Metabolism",
                        "Older adults have reduced thirst sensation",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Research Summary Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Key Research Findings",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildResearchItem(
                        context,
                        "Gender Differences",
                        "NHANES III Study: 23% of men showed signs of dehydration vs 16% of women across all ages",
                      ),
                      const SizedBox(height: 12),
                      _buildResearchItem(
                        context,
                        "Skin Turgor Reliability",
                        "Systematic review: Skin turgor shows only MODERATE reliability; forehead/sternum sites are more reliable than other body locations",
                      ),
                      const SizedBox(height: 12),
                      _buildResearchItem(
                        context,
                        "Minimum Requirements",
                        "Based on clinical consensus: 0.03-0.035L per kg for baseline hydration in adults",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Medical Disclaimer Card
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
                            "Medical Disclaimer",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "This calculator provides general guidelines only. People with kidney disease, heart conditions, certain medical disorders, or on specific medications should consult their healthcare provider before making significant changes to water intake. In case of severe dehydration symptoms (dizziness, confusion, rapid heartbeat), seek immediate medical attention.",
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

  Widget _buildScienceItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Column(
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
    );
  }

  Widget _buildTurgorItem(
    BuildContext context,
    String status,
    String description,
    bool isGood,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isGood
                ? Colors.green.withAlpha(30)
                : Colors.orange.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isGood ? Icons.check_circle : Icons.info_outline,
            color: isGood ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
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

  Widget _buildFactorItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
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
              const SizedBox(height: 2),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResearchItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.school_outlined,
          color: Theme.of(context).primaryColor,
          size: 20,
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
