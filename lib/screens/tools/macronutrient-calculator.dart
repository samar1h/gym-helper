import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MacronutrientCalculator extends StatefulWidget {
  const MacronutrientCalculator({super.key});

  @override
  State<MacronutrientCalculator> createState() => _MacronutrientCalculatorState();
}

class _MacronutrientCalculatorState extends State<MacronutrientCalculator> {
  // Page tracking
  int _currentPage = 0;

  // Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightCmController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _calorieSurplusController = TextEditingController(text: '300');
  final TextEditingController _calorieDeficitController = TextEditingController(text: '400');
  final TextEditingController _customCaloriesController = TextEditingController();

  // State variables
  String _gender = 'male';
  bool _isMetric = true;
  String _activityLevel = 'moderate'; // sedentary, light, moderate, very, super
  String _fitnessGoal = 'general'; // weight_loss, muscle_gain, maintenance, body_recomp, athletic
  String _trainingType = 'strength'; // strength, cardio, endurance, mixed
  bool _highBodyFat = false;
  String _dietApproach = 'flexible'; // flexible, keto, high_carb, bb_cut_bulk, mediterranean

  // ignore: unused_field
  final double _currentTDEE = 0;
  bool _customTDEE = false;

  // Macronutrient state
  Map<String, double> _macroRatios = {'protein': 0, 'carbs': 0, 'fats': 0};

  @override
  void dispose() {
    _ageController.dispose();
    _heightCmController.dispose();
    _weightController.dispose();
    _calorieSurplusController.dispose();
    _calorieDeficitController.dispose();
    _customCaloriesController.dispose();
    super.dispose();
  }

  double _calculateBMR() {
    int age = int.tryParse(_ageController.text) ?? 30;
    double weight = double.tryParse(_weightController.text) ?? 70;
    double height = double.tryParse(_heightCmController.text) ?? 170;

    if (_gender == 'male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  double _getActivityMultiplier() {
    switch (_activityLevel) {
      case 'sedentary':
        return 1.2;
      case 'light':
        return 1.375;
      case 'moderate':
        return 1.55;
      case 'very':
        return 1.725;
      case 'super':
        return 1.9;
      default:
        return 1.55;
    }
  }

  double _calculateTDEE() {
    if (_customTDEE && _customCaloriesController.text.isNotEmpty) {
      return double.tryParse(_customCaloriesController.text) ?? 2000;
    }

    double bmr = _calculateBMR();
    double multiplier = _getActivityMultiplier();
    return bmr * multiplier;
  }

  void _calculateMacroRatios() {
    switch (_fitnessGoal) {
      case 'weight_loss':
        _macroRatios = {'protein': 0.30, 'carbs': 0.40, 'fats': 0.30};
        break;
      case 'muscle_gain':
        _macroRatios = {'protein': 0.30, 'carbs': 0.50, 'fats': 0.20};
        break;
      case 'body_recomp':
        _macroRatios = {'protein': 0.35, 'carbs': 0.45, 'fats': 0.20};
        break;
      case 'athletic':
        if (_trainingType == 'endurance') {
          _macroRatios = {'protein': 0.15, 'carbs': 0.60, 'fats': 0.25};
        } else if (_trainingType == 'strength') {
          _macroRatios = {'protein': 0.30, 'carbs': 0.50, 'fats': 0.20};
        } else {
          _macroRatios = {'protein': 0.20, 'carbs': 0.55, 'fats': 0.25};
        }
        break;
      default:
        _macroRatios = {'protein': 0.25, 'carbs': 0.50, 'fats': 0.25};
    }

    // Apply diet approach modifiers
    switch (_dietApproach) {
      case 'keto':
        _macroRatios = {'protein': 0.25, 'carbs': 0.05, 'fats': 0.70};
        break;
      case 'high_carb':
        _macroRatios = {'protein': 0.15, 'carbs': 0.65, 'fats': 0.20};
        break;
      case 'mediterranean':
        _macroRatios = {'protein': 0.20, 'carbs': 0.45, 'fats': 0.35};
        break;
      default:
        break;
    }
  }

  void _nextPage() {
    if (_currentPage < 6) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _submitAssessment() {
    _calculateMacroRatios();
    
    double tdee = _calculateTDEE();
    double finalCalories = tdee;

    if (_fitnessGoal == 'weight_loss') {
      double deficit = double.tryParse(_calorieDeficitController.text) ?? 400;
      finalCalories = tdee - deficit;
    } else if (_fitnessGoal == 'muscle_gain') {
      double surplus = double.tryParse(_calorieSurplusController.text) ?? 300;
      finalCalories = tdee + surplus;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MacroResultPage(
          tdee: tdee,
          dailyCalories: finalCalories,
          macroRatios: _macroRatios,
          fitnessGoal: _fitnessGoal,
          dietApproach: _dietApproach,
          trainingType: _trainingType,
          gender: _gender,
          weight: double.tryParse(_weightController.text) ?? 70,
          activityLevel: _activityLevel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: Row(
          children: [
            Icon(
              Icons.restaurant_menu,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "Macro Calculator",
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentPage + 1) / 7,
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              Text(
                "Step ${_currentPage + 1} of 7",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),

              // Page content
              if (_currentPage == 0) _buildPage0(),
              if (_currentPage == 1) _buildPage1(),
              if (_currentPage == 2) _buildPage2(),
              if (_currentPage == 3) _buildPage3(),
              if (_currentPage == 4) _buildPage4(),
              if (_currentPage == 5) _buildPage5(),
              if (_currentPage == 6) _buildPage6(),

              const SizedBox(height: 32),

              // Navigation buttons
              Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back),
                            const SizedBox(width: 8),
                            Text(
                              "Previous",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _currentPage == 6 ? _submitAssessment : _nextPage,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 6 ? "Calculate Macros" : "Next",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Icon(_currentPage == 6 ? Icons.check_circle : Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Macronutrient Calculator",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          "Get personalized macronutrient recommendations for your fitness goals.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      "What Are Macronutrients?",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Macronutrients (macros) are the three nutrients your body needs in large amounts:\n\n• **Protein** (4 cal/g): Builds & repairs muscle\n• **Carbohydrates** (4 cal/g): Fuel for energy & brain\n• **Fats** (9 cal/g): Hormone production & cell function",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
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
                      "Why Track Macros?",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "• Know exactly how much protein, carbs, fat to eat daily\n• Supports specific goals (lose fat, gain muscle, athletic performance)\n• More flexible than restrictive diets\n• Prevents nutritional imbalances\n• Backed by sports nutrition science",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Basic Information",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

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
        ),
        const SizedBox(height: 12),

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

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(50)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isMetric = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isMetric ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Metric",
                          style: TextStyle(
                            color: _isMetric ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isMetric = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isMetric ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Imperial",
                          style: TextStyle(
                            color: !_isMetric ? Colors.white : Colors.grey,
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
        const SizedBox(height: 12),

        TextFormField(
          controller: _heightCmController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          decoration: InputDecoration(
            labelText: _isMetric ? "Height (cm)" : "Height (inches)",
            hintText: _isMetric ? "e.g., 170" : "e.g., 67",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.height),
          ),
        ),
        const SizedBox(height: 12),

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
        ),
      ],
    );
  }

  Widget _buildPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Activity Level",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        Text("How active are you?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        ..._buildActivityCards(),
      ],
    );
  }

  Widget _buildPage3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fitness Goal",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        Text("What's your primary goal?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        ..._buildGoalCards(),
      ],
    );
  }

  Widget _buildPage4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Training Type & TDEE",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        if (_fitnessGoal == 'athletic') ...[
          Text("Training type:", style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          ..._buildTrainingCards(),
          const SizedBox(height: 24),
        ],

        Text("Calorie Adjustment", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_fitnessGoal == 'weight_loss') ...[
          TextFormField(
            controller: _calorieDeficitController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: "Calorie Deficit (calories)",
              hintText: "e.g., 400",
              helperText: "How many calories below TDEE? 300-500 recommended.",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ] else if (_fitnessGoal == 'muscle_gain') ...[
          TextFormField(
            controller: _calorieSurplusController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: "Calorie Surplus (calories)",
              hintText: "e.g., 300",
              helperText: "How many calories above TDEE? 200-400 recommended.",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ] else ...[
          CheckboxListTile(
            title: const Text("Use custom calorie target"),
            value: _customTDEE,
            onChanged: (v) => setState(() => _customTDEE = v ?? false),
          ),
          if (_customTDEE)
            TextFormField(
              controller: _customCaloriesController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Daily Calories",
                hintText: "e.g., 2000",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildPage5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Diet Approach",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        Text("Preferred diet approach?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        ..._buildDietCards(),
      ],
    );
  }

  Widget _buildPage6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Additional Information",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        CheckboxListTile(
          title: const Text("I have high body fat % (>25% men, >35% women)"),
          value: _highBodyFat,
          onChanged: (v) => setState(() => _highBodyFat = v ?? false),
        ),
        const SizedBox(height: 16),

        Card(
          color: Colors.blue.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Click 'Calculate Macros' to get your personalized recommendations.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActivityCards() {
    const activities = [
      ('sedentary', 'Sedentary', 'Little to no exercise'),
      ('light', 'Lightly Active', '1-3 days/week'),
      ('moderate', 'Moderately Active', '3-5 days/week'),
      ('very', 'Very Active', '6-7 days/week'),
      ('super', 'Super Active', 'Intense daily training'),
    ];
    return activities.map((a) => Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () => setState(() => _activityLevel = a.$1),
        child: Card(
          elevation: _activityLevel == a.$1 ? 4 : 1,
          color: _activityLevel == a.$1 ? Theme.of(context).primaryColor.withAlpha(100) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _activityLevel == a.$1 ? Theme.of(context).primaryColor : Colors.grey.withAlpha(50),
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
                      Text(a.$2, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(a.$3, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                if (_activityLevel == a.$1) Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ),
      ),
    )).toList();
  }

  List<Widget> _buildGoalCards() {
    const goals = [
      ('weight_loss', 'Weight Loss', 'Calorie deficit + high protein'),
      ('muscle_gain', 'Muscle Gain', 'Calorie surplus + high protein'),
      ('body_recomp', 'Body Recomposition', 'Lose fat & gain muscle'),
      ('maintenance', 'Maintenance', 'Stay at current weight'),
      ('athletic', 'Athletic Performance', 'Sport-specific optimization'),
    ];
    return goals.map((g) => Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () => setState(() => _fitnessGoal = g.$1),
        child: Card(
          elevation: _fitnessGoal == g.$1 ? 4 : 1,
          color: _fitnessGoal == g.$1 ? Theme.of(context).primaryColor.withAlpha(100) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _fitnessGoal == g.$1 ? Theme.of(context).primaryColor : Colors.grey.withAlpha(50),
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
                      Text(g.$2, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(g.$3, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                if (_fitnessGoal == g.$1) Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ),
      ),
    )).toList();
  }

  List<Widget> _buildTrainingCards() {
    const trainings = [
      ('strength', 'Strength', 'Lifting, powerlifting'),
      ('cardio', 'Cardio', 'Running, cycling'),
      ('endurance', 'Endurance', 'Marathon, triathlon'),
      ('mixed', 'Mixed', 'CrossFit, sports'),
    ];
    return trainings.map((t) => Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () => setState(() => _trainingType = t.$1),
        child: Card(
          elevation: _trainingType == t.$1 ? 4 : 1,
          color: _trainingType == t.$1 ? Theme.of(context).primaryColor.withAlpha(100) : null,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.$2, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(t.$3, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                if (_trainingType == t.$1) Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ),
      ),
    )).toList();
  }

  List<Widget> _buildDietCards() {
    const diets = [
      ('flexible', 'Flexible Dieting', 'If It Fits Your Macros (IIFYM)'),
      ('keto', 'Ketogenic', 'Low carb, high fat'),
      ('high_carb', 'High Carb', 'Athlete-focused'),
      ('mediterranean', 'Mediterranean', 'Heart-healthy fats'),
    ];
    return diets.map((d) => Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () => setState(() => _dietApproach = d.$1),
        child: Card(
          elevation: _dietApproach == d.$1 ? 4 : 1,
          color: _dietApproach == d.$1 ? Theme.of(context).primaryColor.withAlpha(100) : null,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.$2, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(d.$3, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                if (_dietApproach == d.$1) Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ),
      ),
    )).toList();
  }
}

// Result Page
class MacroResultPage extends StatelessWidget {
  final double tdee;
  final double dailyCalories;
  final Map<String, double> macroRatios;
  final String fitnessGoal;
  final String dietApproach;
  final String trainingType;
  final String gender;
  final double weight;
  final String activityLevel;

  const MacroResultPage({
    super.key,
    required this.tdee,
    required this.dailyCalories,
    required this.macroRatios,
    required this.fitnessGoal,
    required this.dietApproach,
    required this.trainingType,
    required this.gender,
    required this.weight,
    required this.activityLevel,
  });

  Map<String, double> _calculateMacroGrams() {
    double proteinCals = dailyCalories * macroRatios['protein']!;
    double carbsCals = dailyCalories * macroRatios['carbs']!;
    double fatsCals = dailyCalories * macroRatios['fats']!;

    return {
      'protein': proteinCals / 4,
      'carbs': carbsCals / 4,
      'fats': fatsCals / 9,
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> macroGrams = _calculateMacroGrams();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your Macronutrient Targets"),
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
              // Main calorie card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.orange.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.restaurant_menu, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "Daily Calorie Target",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${dailyCalories.toStringAsFixed(0)} cal",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "TDEE: ${tdee.toStringAsFixed(0)} cal ($fitnessGoal)",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Macro targets breakdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daily Macronutrient Targets",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _buildMacroRow(
                        context,
                        "Protein",
                        macroGrams['protein']!.toStringAsFixed(0),
                        "${(macroRatios['protein']! * 100).toStringAsFixed(0)}%",
                        Colors.red,
                        Icons.favorite,
                      ),
                      _buildMacroRow(
                        context,
                        "Carbohydrates",
                        macroGrams['carbs']!.toStringAsFixed(0),
                        "${(macroRatios['carbs']! * 100).toStringAsFixed(0)}%",
                        Colors.blue,
                        Icons.bolt,
                      ),
                      _buildMacroRow(
                        context,
                        "Fats",
                        macroGrams['fats']!.toStringAsFixed(0),
                        "${(macroRatios['fats']! * 100).toStringAsFixed(0)}%",
                        Colors.yellow,
                        Icons.stop_circle,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Meal distribution
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Meal Distribution (4 meals)",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildMealSuggestion(context, "Breakfast", macroGrams, 0.25),
                      _buildMealSuggestion(context, "Lunch", macroGrams, 0.35),
                      _buildMealSuggestion(context, "Snack", macroGrams, 0.15),
                      _buildMealSuggestion(context, "Dinner", macroGrams, 0.25),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Food examples
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Food Examples",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildFoodExample(context, "🥚 Protein", "Chicken, turkey, fish, eggs, Greek yogurt, cottage cheese"),
                      _buildFoodExample(context, "🥔 Carbs", "Brown rice, oats, sweet potato, whole wheat bread, pasta"),
                      _buildFoodExample(context, "🥑 Fats", "Olive oil, avocado, nuts, seeds, fatty fish, peanut butter"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tracking tips
              Card(
                color: Colors.green.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "Tracking Tips",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip(context, "Use MyFitnessPal, Cronometer, or MacroFactor to track"),
                      _buildTip(context, "Get a food scale for accuracy (±5g matters)"),
                      _buildTip(context, "Aim for targets ±5g per macro daily"),
                      _buildTip(context, "Track for 2-3 weeks, then assess progress"),
                      _buildTip(context, "Adjust calories if not seeing results after 4 weeks"),
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

  Widget _buildMacroRow(BuildContext context, String name, String grams, String percentage, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withAlpha(100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text("$percentage of calories", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$grams g", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text("(${(double.parse(grams) * 4).toStringAsFixed(0)} cal)", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealSuggestion(BuildContext context, String meal, Map<String, double> macroGrams, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$meal (${(percentage * 100).toStringAsFixed(0)}%)", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(
            "P: ${(macroGrams['protein']! * percentage).toStringAsFixed(0)}g | C: ${(macroGrams['carbs']! * percentage).toStringAsFixed(0)}g | F: ${(macroGrams['fats']! * percentage).toStringAsFixed(0)}g",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodExample(BuildContext context, String category, String foods) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(foods, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(tip, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
