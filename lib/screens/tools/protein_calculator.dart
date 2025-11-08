import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';

class ProteinCalculator extends StatefulWidget {
  const ProteinCalculator({super.key});

  @override
  State<ProteinCalculator> createState() => _ProteinCalculatorState();
}

class _ProteinCalculatorState extends State<ProteinCalculator> {
  // Controllers
  final TextEditingController _weightController = TextEditingController();

  // State variables
  bool _isMetric = true;
  String _selectedGoal = 'maintenance';
  String _selectedActivityLevel = 'moderately_active';
  final _formKey = GlobalKey<FormState>();

  // Protein multipliers (g/kg body weight)
  final Map<String, Map<String, double>> _proteinMultipliers = {
    'maintenance': {
      'sedentary': 0.8,
      'lightly_active': 0.9,
      'moderately_active': 1.0,
      'very_active': 1.1,
      'super_active': 1.2,
    },
    'muscle_gain': {
      'sedentary': 1.4,
      'lightly_active': 1.6,
      'moderately_active': 1.8,
      'very_active': 2.0,
      'super_active': 2.2,
    },
    'weight_loss': {
      'sedentary': 1.2,
      'lightly_active': 1.4,
      'moderately_active': 1.8,
      'very_active': 2.0,
      'super_active': 2.4,
    },
  };

  final Map<String, String> _goalLabels = {
    'maintenance': 'Maintenance',
    'muscle_gain': 'Muscle Gain',
    'weight_loss': 'Weight Loss',
  };

  final Map<String, String> _activityLabels = {
    'sedentary': 'Sedentary (little or no exercise)',
    'lightly_active': 'Lightly Active (1-3 days/week)',
    'moderately_active': 'Moderately Active (3-5 days/week)',
    'very_active': 'Very Active (6-7 days/week)',
    'super_active': 'Super Active (2x training/day)',
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

  double _calculateProtein() {
    double weightInKg = _getWeightInKg();
    double multiplier =
        _proteinMultipliers[_selectedGoal]?[_selectedActivityLevel] ?? 1.0;
    return weightInKg * multiplier;
  }

  void _calculateAndNavigate() {
    if (_formKey.currentState!.validate()) {
      double proteinGrams = _calculateProtein();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProteinResultPage(
            proteinGrams: proteinGrams,
            weight: double.parse(_weightController.text),
            isMetric: _isMetric,
            goal: _selectedGoal,
            activityLevel: _selectedActivityLevel,
            goalLabels: _goalLabels,
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
              Icons.egg,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "Protein Calculator",
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
                            "Calculate your ideal daily protein intake based on your fitness goals",
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
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
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
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
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
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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

                // Fitness Goal
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
                        "Calculate Protein",
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

  Widget _buildGoalCard(BuildContext context, String value, String label,
      IconData icon, Color color) {
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

// Result Page
class ProteinResultPage extends StatelessWidget {
  final double proteinGrams;
  final double weight;
  final bool isMetric;
  final String goal;
  final String activityLevel;
  final Map<String, String> goalLabels;
  final Map<String, String> activityLabels;

  const ProteinResultPage({
    super.key,
    required this.proteinGrams,
    required this.weight,
    required this.isMetric,
    required this.goal,
    required this.activityLevel,
    required this.goalLabels,
    required this.activityLabels,
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
        return 'Higher protein intake preserves muscle mass during weight loss, keeps you fuller longer, and boosts metabolism.';
      case 'muscle_gain':
        return 'Optimal protein supports muscle protein synthesis, repairs exercise-induced damage, and maximizes gains.';
      case 'maintenance':
      default:
        return 'Adequate protein maintains muscle mass, supports recovery, and keeps you healthy.';
    }
  }

  String _getGoalReason() {
    switch (goal) {
      case 'weight_loss':
        return 'Research shows high protein during caloric deficit preserves muscle while maximizing fat loss. Aim for 1.8-2.4 g/kg.';
      case 'muscle_gain':
        return 'To maximize muscle protein synthesis with resistance training, aim for 1.6-2.2 g/kg of body weight daily.';
      case 'maintenance':
      default:
        return 'For general health and maintenance, 0.8-1.2 g/kg of body weight is sufficient for most adults.';
    }
  }

  @override
  Widget build(BuildContext context) {
    double proteinPerMeal = proteinGrams / 3;
    //double proteinPer100Cal = proteinGrams / 20; // Assuming ~2000 cal diet

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your Protein Target"),
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
                      colors: [
                        _getGoalColor(),
                        _getGoalColor().withAlpha(180),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.egg,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        goalLabels[goal]!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${proteinGrams.round()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "grams per day",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Goal Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Why ${goalLabels[goal]}?",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getGoalDescription(),
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
                          _getGoalReason(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Breakdown Cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daily Protein Breakdown",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildBreakdownItem(
                              context,
                              Icons.restaurant,
                              "Per Meal",
                              "${proteinPerMeal.round()}g",
                              "÷ 3 meals",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBreakdownItem(
                              context,
                              Icons.local_drink_outlined,
                              "Per Serving",
                              "~20-30g",
                              "Protein per serving",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Distribute protein evenly throughout the day for optimal muscle protein synthesis.",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Protein Sources Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "High-Protein Food Sources",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildFoodItem(
                        context,
                        "Chicken Breast",
                        "31g per 100g",
                        Icons.favorite,
                      ),
                      const SizedBox(height: 12),
                      _buildFoodItem(
                        context,
                        "Eggs",
                        "13g per 100g",
                        Icons.egg,
                      ),
                      const SizedBox(height: 12),
                      _buildFoodItem(
                        context,
                        "Greek Yogurt",
                        "10g per 100g",
                        IonIcons.ice_cream,
                      ),
                      const SizedBox(height: 12),
                      _buildFoodItem(
                        context,
                        "Tuna",
                        "29g per 100g",
                        FontAwesome.fish_solid,
                      ),
                      const SizedBox(height: 12),
                      _buildFoodItem(
                        context,
                        "Lentils",
                        "9g per 100g (cooked)",
                        Icons.grain,
                      ),
                      const SizedBox(height: 12),
                      _buildFoodItem(
                        context,
                        "Protein Powder",
                        "20-25g per scoop",
                        FontAwesome.circle_dot,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Distribution Tips
              Card(
                color: Colors.amber.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tips_and_updates_outlined,
                              color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            "Distribution Tips",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(context, "Spread evenly across meals",
                          "Aim for 20-40g per meal for optimal muscle protein synthesis."),
                      const SizedBox(height: 12),
                      _buildTipItem(context, "Post-workout protein",
                          "Consume protein within 2 hours after training to support recovery."),
                      const SizedBox(height: 12),
                      _buildTipItem(context, "Quality matters",
                          "Choose complete proteins (all 9 amino acids) like meat, eggs, or dairy."),
                      const SizedBox(height: 12),
                      _buildTipItem(context, "Stay hydrated",
                          "Drink plenty of water to help your body process protein efficiently."),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Disclaimer
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
                            "Important Note",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "If you have kidney disease or other medical conditions, consult a healthcare professional before increasing protein intake. These recommendations are for healthy adults only.",
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

  Widget _buildBreakdownItem(BuildContext context, IconData icon, String title,
      String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(BuildContext context, String foodName,
      String proteinContent, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                foodName,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                proteinContent,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(
      BuildContext context, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline,
            color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
