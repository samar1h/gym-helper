import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DailyStepsCalculator extends StatefulWidget {
  const DailyStepsCalculator({super.key});

  @override
  State<DailyStepsCalculator> createState() => _DailyStepsCalculatorState();
}

class _DailyStepsCalculatorState extends State<DailyStepsCalculator> {
  // Page tracking
  int _currentPage = 0;

  // Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _currentStepsController = TextEditingController();
  final TextEditingController _minutesAvailableController =
      TextEditingController();

  // State variables
  String _ageGroup = '30-45'; // 18-29, 30-45, 46-60, 60+
  String _activityLevel =
      'lightly_active'; // sedentary, lightly, moderate, very, super
  String _workType = 'desk'; // desk, active, mixed
  int _busyLevel = 5; // 1-10 scale
  // ignore: unused_field
  final Set<String> _healthConditions = {};
  String _fitnessGoal = 'general'; // general, weight_loss, cardio, strength
  bool _hasHeartCondition = false;
  bool _hasDiabetes = false;
  bool _hasArthritis = false;

  // Age group multipliers (based on research)
  // ignore: unused_field
  final Map<String, double> _ageMultipliers = {
    '18-29': 1.3, // Higher baseline due to youth
    '30-45': 1.1,
    '46-60': 1.0,
    '60+': 0.85, // Lower plateau for older adults
  };

  // Activity level multipliers
  final Map<String, double> _activityMultipliers = {
    'sedentary': 0.7,
    'lightly_active': 0.9,
    'moderate': 1.0,
    'very_active': 1.2,
    'super_active': 1.4,
  };

  // Work type adds baseline steps
  // ignore: unused_field
  final Map<String, int> _workTypeBaseline = {
    'desk': 2000,
    'active': 5000,
    'mixed': 3500,
  };

  @override
  void dispose() {
    _ageController.dispose();
    _currentStepsController.dispose();
    _minutesAvailableController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 7) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  double _calculateGoalSteps() {
    // Base recommendation by age (Lancet study plateau points)
    double baseTarget;
    switch (_ageGroup) {
      case '18-29':
      case '30-45':
        baseTarget = 8000; // 8000-10000 for younger adults
        break;
      case '46-60':
        baseTarget = 7500; // 7000-8000 for middle aged
        break;
      case '60+':
        baseTarget = 6500; // 6000-8000 for older adults
        break;
      default:
        baseTarget = 7500;
    }

    // Apply activity multiplier
    double adjusted = baseTarget * _activityMultipliers[_activityLevel]!;

    // Apply goal adjustment
    switch (_fitnessGoal) {
      case 'weight_loss':
        adjusted *= 1.2; // 20% higher for weight loss
        break;
      case 'cardio':
        adjusted *= 1.15; // 15% higher for cardio health
        break;
      case 'strength':
        adjusted *= 0.9; // 10% lower (priority is strength training)
        break;
      default:
        adjusted *= 1.0;
    }

    // Adjust for health conditions
    if (_hasHeartCondition || _hasDiabetes) {
      adjusted *= 1.1; // Higher benefit for these conditions
    }
    if (_hasArthritis) {
      adjusted *= 0.95; // Slightly lower due to joint impact
    }

    // Adjust for life busyness (realistic achievability)
    if (_busyLevel >= 8) {
      adjusted *= 0.85; // Very busy - more realistic goal
    } else if (_busyLevel <= 3) {
      adjusted *= 1.1; // More time available - can aim higher
    }

    return adjusted.clamp(4000.0, 15000.0); // Realistic range
  }

  double _getPlateauPoint() {
    // Where health benefits plateau by age (Lancet research)
    switch (_ageGroup) {
      case '18-29':
      case '30-45':
        return 9000; // Younger: benefits plateau ~9000
      case '46-60':
        return 7500; // Middle-aged: ~7500
      case '60+':
        return 6500; // Older: ~6500-7000
      default:
        return 8000;
    }
  }

  void _submitAssessment() {
    int currentSteps = int.tryParse(_currentStepsController.text) ?? 0;
    int minutesAvailable = int.tryParse(_minutesAvailableController.text) ?? 0;
    double goalSteps = _calculateGoalSteps();
    double plateauPoint = _getPlateauPoint();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyStepsResultPage(
          goalSteps: goalSteps,
          plateauPoint: plateauPoint,
          currentSteps: currentSteps,
          ageGroup: _ageGroup,
          activityLevel: _activityLevel,
          fitnessGoal: _fitnessGoal,
          busyLevel: _busyLevel,
          workType: _workType,
          hasHeartCondition: _hasHeartCondition,
          hasDiabetes: _hasDiabetes,
          hasArthritis: _hasArthritis,
          minutesAvailable: minutesAvailable,
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
              Icons.directions_walk,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "Daily Steps",
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
                value: (_currentPage + 1) / 8,
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              Text(
                "Step ${_currentPage + 1} of 8",
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
              if (_currentPage == 7) _buildPage7(),

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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _currentPage == 7
                          ? _submitAssessment
                          : _nextPage,
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
                            _currentPage == 7 ? "Get My Goal" : "Next",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == 7
                                ? Icons.check_circle
                                : Icons.arrow_forward,
                          ),
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
          "Personalized Daily Steps Goal",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          "Discover how many steps YOU should walk daily based on your age, activity level, and goals.",
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
                      "Myth Buster",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "The \"10,000 steps\" goal is a marketing myth from 1960s Japan, not science! Recent research shows the real number varies by age and can be as low as 4,000-7,000 steps for significant health benefits.",
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
                      "What You'll Learn",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "• Your personalized daily step goal\n• Where health benefits plateau for your age\n• How to progress safely from your baseline\n• Realistic targets based on your busy schedule",
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
          "Age Group",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ..._buildAgeGroupCards(),
      ],
    );
  }

  Widget _buildPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Activity Level",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Text(
          "How much planned, structured exercise do you currently do?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
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
          "Work Type",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Text(
          "What's your typical work environment?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ..._buildWorkTypeCards(),
      ],
    );
  }

  Widget _buildPage4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Life Busyness",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Text(
          "How busy is your typical day?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.cyan.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Relaxed ← $_busyLevel → Hectic",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _busyLevel.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: _busyLevel.toString(),
          onChanged: (value) => setState(() => _busyLevel = value.toInt()),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "1 (Very relaxed)",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              "10 (Super hectic)",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPage5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Step Count",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Text(
          "How many steps do you currently walk per day?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _currentStepsController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: "steps/day",
            hintText: "e.g., 5000",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.directions_walk),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: Colors.amber.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      "Tip",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "If unsure, wear a fitness tracker for a few days or check your phone's health app. We'll help you progress from your current baseline.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Health Conditions",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Text(
          "Do you have any of these conditions?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _buildCheckboxTile(
          "Heart condition",
          _hasHeartCondition,
          (v) => setState(() => _hasHeartCondition = v ?? false),
        ),
        _buildCheckboxTile(
          "Diabetes",
          _hasDiabetes,
          (v) => setState(() => _hasDiabetes = v ?? false),
        ),
        _buildCheckboxTile(
          "Arthritis",
          _hasArthritis,
          (v) => setState(() => _hasArthritis = v ?? false),
        ),
      ],
    );
  }

  Widget _buildPage7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fitness Goal",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Text(
          "What's your primary fitness goal?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ..._buildGoalCards(),
        const SizedBox(height: 24),
        Text(
          "Time Available (Optional)",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _minutesAvailableController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: "minutes/day for exercise",
            hintText: "e.g., 30",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.timer),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAgeGroupCards() {
    const groups = ['18-29', '30-45', '46-60', '60+'];
    return groups
        .map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GestureDetector(
              onTap: () => setState(() => _ageGroup = group),
              child: Card(
                elevation: _ageGroup == group ? 4 : 1,
                color: _ageGroup == group
                    ? Theme.of(context).primaryColor.withAlpha(100)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _ageGroup == group
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withAlpha(50),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        group,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (_ageGroup == group)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildActivityCards() {
    const activities = [
      ('sedentary', 'Sedentary', 'Little to no exercise'),
      ('lightly_active', 'Lightly Active', '1-3 days/week'),
      ('moderate', 'Moderately Active', '3-5 days/week'),
      ('very_active', 'Very Active', '6-7 days/week'),
      ('super_active', 'Super Active', 'Intense training daily'),
    ];
    return activities
        .map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: GestureDetector(
              onTap: () => setState(() => _activityLevel = a.$1),
              child: Card(
                elevation: _activityLevel == a.$1 ? 4 : 1,
                color: _activityLevel == a.$1
                    ? Theme.of(context).primaryColor.withAlpha(100)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _activityLevel == a.$1
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withAlpha(50),
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
                            Text(
                              a.$2,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              a.$3,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (_activityLevel == a.$1)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildWorkTypeCards() {
    const types = [
      ('desk', 'Desk Job', '~2000 steps baseline'),
      ('active', 'Active Job', '~5000 steps baseline'),
      ('mixed', 'Mixed Work', '~3500 steps baseline'),
    ];
    return types
        .map(
          (t) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: GestureDetector(
              onTap: () => setState(() => _workType = t.$1),
              child: Card(
                elevation: _workType == t.$1 ? 4 : 1,
                color: _workType == t.$1
                    ? Theme.of(context).primaryColor.withAlpha(100)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _workType == t.$1
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withAlpha(50),
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
                            Text(
                              t.$2,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              t.$3,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      if (_workType == t.$1)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildGoalCards() {
    const goals = [
      ('general', 'General Health', Icons.favorite),
      ('weight_loss', 'Weight Loss', Icons.trending_down),
      ('cardio', 'Cardio Health', Icons.favorite_border),
      ('strength', 'Strength Training', Icons.fitness_center),
    ];
    return goals
        .map(
          (g) => Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: GestureDetector(
              onTap: () => setState(() => _fitnessGoal = g.$1),
              child: Card(
                elevation: _fitnessGoal == g.$1 ? 4 : 1,
                color: _fitnessGoal == g.$1
                    ? Theme.of(context).primaryColor.withAlpha(100)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _fitnessGoal == g.$1
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withAlpha(50),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        g.$3,
                        color: _fitnessGoal == g.$1
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          g.$2,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_fitnessGoal == g.$1)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}

// Result Page
class DailyStepsResultPage extends StatelessWidget {
  final double goalSteps;
  final double plateauPoint;
  final int currentSteps;
  final String ageGroup;
  final String activityLevel;
  final String fitnessGoal;
  final int busyLevel;
  final String workType;
  final bool hasHeartCondition;
  final bool hasDiabetes;
  final bool hasArthritis;
  final int minutesAvailable;

  const DailyStepsResultPage({
    super.key,
    required this.goalSteps,
    required this.plateauPoint,
    required this.currentSteps,
    required this.ageGroup,
    required this.activityLevel,
    required this.fitnessGoal,
    required this.busyLevel,
    required this.workType,
    required this.hasHeartCondition,
    required this.hasDiabetes,
    required this.hasArthritis,
    required this.minutesAvailable,
  });

  String _getProgressMessage() {
    if (currentSteps >= goalSteps) {
      return "✓ You're already exceeding your goal!";
    }
    double remaining = goalSteps - currentSteps;
    if (remaining < 1000) {
      return "Almost there! Just ${remaining.toInt()} more steps needed.";
    }
    return "Need to add ${remaining.toInt()} more steps to reach goal.";
  }

  @override
  Widget build(BuildContext context) {
    double stepsPerMonth = (goalSteps - currentSteps) * 30;
    // ignore: unused_local_variable
    int weeksToGoal = (stepsPerMonth / 7 / 1000 > 0)
        ? ((stepsPerMonth / 7 / 1000) * 2).toInt()
        : 4;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your Daily Steps Goal"),
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
              // Main goal card
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
                      Icon(
                        Icons.directions_walk,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Your Daily Goal",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${goalSteps.toInt()} steps",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "per day",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Plateau at: ${plateauPoint.toInt()} steps",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Current vs Goal
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Progress",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            "$currentSteps steps",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Goal",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            "${goalSteps.toInt()} steps",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (currentSteps / goalSteps).clamp(0, 1),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getProgressMessage(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Key Research Findings
              Card(
                color: Colors.blue.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.school_outlined, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            "Why This Number?",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildResearchItem(
                        context,
                        "Lancet Study (2022)",
                        "Analyzed 15 studies with 500,000+ participants. Found age-specific plateaus.",
                      ),
                      _buildResearchItem(
                        context,
                        "Your Age Group: $ageGroup",
                        "Plateau at: ${plateauPoint.toInt()} steps where benefits level off.",
                      ),
                      _buildResearchItem(
                        context,
                        "Health Benefits",
                        "Step 1: 47% lower mortality risk (vs 2000 steps baseline). Step 2: Beyond plateau = diminishing returns.",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progressive Plan
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Progression Plan",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPlanStep(
                        context,
                        "Week 1-2",
                        "+500 steps",
                        "Get comfortable with walking routine",
                      ),
                      _buildPlanStep(
                        context,
                        "Week 3-4",
                        "+1000 steps total",
                        "Increase pace slightly, add variety",
                      ),
                      _buildPlanStep(
                        context,
                        "Week 5-8",
                        "+1500 steps total",
                        "Mix pace variations (intervals)",
                      ),
                      _buildPlanStep(
                        context,
                        "Week 9+",
                        "Reach goal gradually",
                        "Maintain at goal, focus on consistency",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Benefits for Your Goals
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Health Benefits (Your Profile)",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (hasHeartCondition)
                        _buildBenefit(
                          context,
                          "47% lower cardiovascular mortality risk",
                        ),
                      if (hasDiabetes)
                        _buildBenefit(
                          context,
                          "25% lower type 2 diabetes incidence",
                        ),
                      if (hasArthritis)
                        _buildBenefit(
                          context,
                          "Lower joint stress with gradual increase",
                        ),
                      _buildBenefit(
                        context,
                        "Improved bone density and muscle strength",
                      ),
                      _buildBenefit(context, "Better mental health and mood"),
                      _buildBenefit(
                        context,
                        "Reduced dementia and cognitive decline risk",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Science Note
              Card(
                color: Colors.amber.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            "Important Note",
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "This goal is personalized but individual variation is normal. Focus on consistency over perfection. Even small increases in daily steps provide significant health benefits. If you have health concerns, consult your doctor.",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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

  Widget _buildResearchItem(
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

  Widget _buildPlanStep(
    BuildContext context,
    String period,
    String increase,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$period: $increase",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(BuildContext context, String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(benefit, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
