import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SleepCalculator extends StatefulWidget {
  const SleepCalculator({super.key});

  @override
  State<SleepCalculator> createState() => _SleepCalculatorState();
}

class _SleepCalculatorState extends State<SleepCalculator> {
  // Page tracking
  int _currentPage = 0;

  // Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weekdayHoursController = TextEditingController();
  final TextEditingController _weekdayMinutesController = TextEditingController();
  final TextEditingController _weekendHoursController = TextEditingController();
  final TextEditingController _weekendMinutesController = TextEditingController();
  final TextEditingController _bedtimeController = TextEditingController();
  final TextEditingController _wakeTimeController = TextEditingController();
  final TextEditingController _sleepOnsetController = TextEditingController();

  // State variables
  String _gender = 'male';
  int _chronotypeScore = 50; // 0-100, 0=morning, 100=evening
  bool _hasHealthConditions = false;
  bool _regularExercise = false;
  bool _caffeineLate = false;
  bool _screenBefore = false;

  // PSQI components (0-3 scale each, except duration)
  int _sleepQuality = 0; // 0=very good, 3=very bad
  int _sleepLatency = 0; // 0=<15min, 3=>60min
  int _sleepDuration = 0; // 0=>7h, 3=<5h
  int _sleepEfficiency = 0; // 0=>85%, 3=<65%
  int _sleepDisturbances = 0; // 0=none, 3=many
  int _sleepMeds = 0; // 0=never, 3=always
  int _daytimeDysfunction = 0; // 0=none, 3=severe

  // ignore: unused_field
  final int _currentPage0 = 0; // For multi-page on first page
  
  @override
  void dispose() {
    _ageController.dispose();
    _weekdayHoursController.dispose();
    _weekdayMinutesController.dispose();
    _weekendHoursController.dispose();
    _weekendMinutesController.dispose();
    _bedtimeController.dispose();
    _wakeTimeController.dispose();
    _sleepOnsetController.dispose();
    super.dispose();
  }

  double _getOptimalSleepHours() {
    int age = int.tryParse(_ageController.text) ?? 0;
    
    if (age < 13) return 9.0; // Teens need 8-10
    if (age < 65) return 7.0; // Adults: optimal is 7 (Nature Aging study)
    return 7.0; // Older adults: also 7 (same as younger adults)
  }

  // ignore: unused_element
  double _getRecommendedSleepRange() {
    int age = int.tryParse(_ageController.text) ?? 0;
    
    if (age < 18) return 8.5; // 8-10 hours, use upper bound
    return 7.5; // 7-9 hours, use upper bound
  }

  double _getActualWeekdaySleep() {
    int hours = int.tryParse(_weekdayHoursController.text) ?? 0;
    int minutes = int.tryParse(_weekdayMinutesController.text) ?? 0;
    return hours + (minutes / 60);
  }

  double _getActualWeekendSleep() {
    int hours = int.tryParse(_weekendHoursController.text) ?? 0;
    int minutes = int.tryParse(_weekendMinutesController.text) ?? 0;
    return hours + (minutes / 60);
  }

  int _calculatePSQIScore() {
    // PSQI Global Score: sum of 7 component scores
    // Maximum possible: 21
    return _sleepQuality +
        _sleepLatency +
        _sleepDuration +
        _sleepEfficiency +
        _sleepDisturbances +
        _sleepMeds +
        _daytimeDysfunction;
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
    int age = int.tryParse(_ageController.text) ?? 30;
    double weekdaySleep = _getActualWeekdaySleep();
    double weekendSleep = _getActualWeekendSleep();
    double avgSleep = (weekdaySleep * 5 + weekendSleep * 2) / 7;
    int psqiScore = _calculatePSQIScore();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SleepResultPage(
          age: age,
          gender: _gender,
          weekdaySleep: weekdaySleep,
          weekendSleep: weekendSleep,
          averageSleep: avgSleep,
          optimalSleep: _getOptimalSleepHours(),
          psqiScore: psqiScore,
          chronotypeScore: _chronotypeScore,
          hasHealthConditions: _hasHealthConditions,
          regularExercise: _regularExercise,
          caffeineLate: _caffeineLate,
          screenBefore: _screenBefore,
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
              Icons.nightlight_round,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            const SizedBox(width: 10),
            Text(
              "Sleep Calculator",
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
                            _currentPage == 6 ? "Get Results" : "Next",
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
          "Sleep Quality & Health Assessment",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          "Let's assess your sleep patterns and quality to provide personalized recommendations.",
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
                      "The Sleep Sweet Spot",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "A 2022 Cambridge study on 500,000 adults found that 7 hours is optimal for all adults regardless of age. Both too little AND too much sleep are associated with poor cognitive function, mental health issues, and cardiovascular risks.",
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
                      "What We'll Assess",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "• Your actual sleep duration (weekday & weekend)\n• Sleep quality (Pittsburgh Sleep Quality Index)\n• Your chronotype (morning vs evening preference)\n• Lifestyle factors affecting sleep\n• Health risks from your current sleep pattern",
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
            hintText: "e.g., 30",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.cake),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
        ),
        const SizedBox(height: 16),

        Text("Gender", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
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
      ],
    );
  }

  Widget _buildPage2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Current Sleep Duration",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        Text(
          "Weekday Sleep",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _weekdayHoursController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: "Hours",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _weekdayMinutesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: "Minutes",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          "Weekend Sleep",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _weekendHoursController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: "Hours",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _weekendMinutesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: "Minutes",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPage3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sleep Quality (PSQI)",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        Text("How would you rate your overall sleep quality?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        ..._buildQualitySlider("Sleep Quality", _sleepQuality, ["Very Good", "Fairly Good", "Fairly Bad", "Very Bad"],
            (val) => setState(() => _sleepQuality = val)),

        const SizedBox(height: 16),
        Text("How long does it take you to fall asleep?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        ..._buildQualitySlider("Sleep Latency", _sleepLatency, ["<15 min", "15-30 min", "30-60 min", ">60 min"],
            (val) => setState(() => _sleepLatency = val)),

        const SizedBox(height: 16),
        Text("How would you rate your sleep duration?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        ..._buildQualitySlider("Sleep Duration", _sleepDuration, [">7h", "6-7h", "5-6h", "<5h"],
            (val) => setState(() => _sleepDuration = val)),
      ],
    );
  }

  Widget _buildPage4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sleep Quality Continued",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        Text("Sleep efficiency (% of time in bed actually asleep)?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        ..._buildQualitySlider("Sleep Efficiency", _sleepEfficiency, [">85%", "75-85%", "65-75%", "<65%"],
            (val) => setState(() => _sleepEfficiency = val)),

        const SizedBox(height: 16),
        Text("How often do sleep disturbances bother you?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        ..._buildQualitySlider("Sleep Disturbances", _sleepDisturbances, ["Never", "Rarely", "Sometimes", "Frequently"],
            (val) => setState(() => _sleepDisturbances = val)),

        const SizedBox(height: 16),
        Text("Do you use sleeping medications?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        ..._buildQualitySlider("Sleep Meds", _sleepMeds, ["Never", "Rarely", "Sometimes", "Always"],
            (val) => setState(() => _sleepMeds = val)),

        const SizedBox(height: 16),
        Text("Daytime sleepiness or dysfunction?", style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        ..._buildQualitySlider("Daytime Dysfunction", _daytimeDysfunction, ["Never", "Sometimes", "Often", "Severe"],
            (val) => setState(() => _daytimeDysfunction = val)),
      ],
    );
  }

  Widget _buildPage5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chronotype & Lifestyle",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        Text(
          "Are you a morning person or evening person?",
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
                Text("Morning ← ${_chronotypeScore.toInt()} → Evening", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: _chronotypeScore.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: _chronotypeScore.toInt().toString(),
          onChanged: (value) => setState(() => _chronotypeScore = value.toInt()),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Morning Person", style: Theme.of(context).textTheme.bodySmall),
            Text("Evening Person", style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 24),

        CheckboxListTile(
          title: const Text("I exercise regularly (3+ times/week)"),
          value: _regularExercise,
          onChanged: (v) => setState(() => _regularExercise = v ?? false),
        ),
        CheckboxListTile(
          title: const Text("I consume caffeine late in the day"),
          value: _caffeineLate,
          onChanged: (v) => setState(() => _caffeineLate = v ?? false),
        ),
        CheckboxListTile(
          title: const Text("I use screens 1+ hour before bed"),
          value: _screenBefore,
          onChanged: (v) => setState(() => _screenBefore = v ?? false),
        ),
        CheckboxListTile(
          title: const Text("I have health conditions (sleep apnea, insomnia, etc.)"),
          value: _hasHealthConditions,
          onChanged: (v) => setState(() => _hasHealthConditions = v ?? false),
        ),
      ],
    );
  }

  Widget _buildPage6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Review Summary",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow("Age", "${int.tryParse(_ageController.text) ?? 0} years"),
                _buildSummaryRow("Gender", _gender.toUpperCase() + _gender.substring(1)),
                _buildSummaryRow("Weekday Sleep", "${_getActualWeekdaySleep().toStringAsFixed(1)} hours"),
                _buildSummaryRow("Weekend Sleep", "${_getActualWeekendSleep().toStringAsFixed(1)} hours"),
                _buildSummaryRow("Optimal Sleep", "${_getOptimalSleepHours()} hours"),
                _buildSummaryRow("PSQI Score", "${_calculatePSQIScore()} / 21"),
                _buildSummaryRow("Chronotype", _chronotypeScore < 30 ? "Morning Person" : _chronotypeScore > 70 ? "Evening Person" : "Intermediate"),
              ],
            ),
          ),
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
                    "Click 'Get Results' to see your personalized sleep analysis and recommendations.",
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

  List<Widget> _buildQualitySlider(String label, int value, List<String> labels, Function(int) onChanged) {
    return [
      Slider(
        value: value.toDouble(),
        min: 0,
        max: 3,
        divisions: 3,
        label: labels[value],
        onChanged: (val) => onChanged(val.toInt()),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          4,
          (i) => Text(labels[i], style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Result Page
class SleepResultPage extends StatelessWidget {
  final int age;
  final String gender;
  final double weekdaySleep;
  final double weekendSleep;
  final double averageSleep;
  final double optimalSleep;
  final int psqiScore;
  final int chronotypeScore;
  final bool hasHealthConditions;
  final bool regularExercise;
  final bool caffeineLate;
  final bool screenBefore;

  const SleepResultPage({
    super.key,
    required this.age,
    required this.gender,
    required this.weekdaySleep,
    required this.weekendSleep,
    required this.averageSleep,
    required this.optimalSleep,
    required this.psqiScore,
    required this.chronotypeScore,
    required this.hasHealthConditions,
    required this.regularExercise,
    required this.caffeineLate,
    required this.screenBefore,
  });

  String _getSleepQualityCategory() {
    if (psqiScore <= 5) return 'Good';
    if (psqiScore <= 10) return 'Fair';
    if (psqiScore <= 15) return 'Poor';
    return 'Very Poor';
  }

  Color _getQualityCategoryColor() {
    String cat = _getSleepQualityCategory();
    switch (cat) {
      case 'Good':
        return Colors.green;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      case 'Very Poor':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  String _getHealthRiskAssessment() {
    if (averageSleep >= 6 && averageSleep <= 8) {
      return 'Healthy range - optimal for cardiovascular health';
    } else if (averageSleep < 5) {
      return 'Short sleep increases 48% risk of cardiovascular disease';
    } else if (averageSleep > 9) {
      return 'Long sleep also increases health risks (41% CVD mortality increase)';
    } else {
      return 'Borderline - aim to optimize';
    }
  }

  @override
  Widget build(BuildContext context) {
    String qualityCategory = _getSleepQualityCategory();
    Color qualityColor = _getQualityCategoryColor();
    String chronotype = chronotypeScore < 30 ? 'Morning' : chronotypeScore > 70 ? 'Evening' : 'Intermediate';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: const Text("Your Sleep Analysis"),
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
                      colors: [qualityColor, qualityColor.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.nightlight_round, size: 64, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        qualityCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "PSQI Score: ${psqiScore.toStringAsFixed(0)} / 21",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Average: ${averageSleep.toStringAsFixed(1)}h (Optimal: ${optimalSleep}h)",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sleep duration analysis
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Sleep Pattern",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildComparisonRow(context, "Weekday Sleep", "${weekdaySleep.toStringAsFixed(1)}h", "📅"),
                      _buildComparisonRow(context, "Weekend Sleep", "${weekendSleep.toStringAsFixed(1)}h", "🛏️"),
                      _buildComparisonRow(context, "Average Sleep", "${averageSleep.toStringAsFixed(1)}h", "📊"),
                      _buildComparisonRow(context, "Optimal Sleep", "${optimalSleep}h", "✓"),
                      const SizedBox(height: 12),
                      if (averageSleep < optimalSleep - 0.5)
                        Row(
                          children: [
                            Icon(Icons.warning_outlined, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "You're sleeping ${(optimalSleep - averageSleep).toStringAsFixed(1)} hours less than optimal",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.orange),
                              ),
                            ),
                          ],
                        )
                      else if (averageSleep > optimalSleep + 0.5)
                        Row(
                          children: [
                            Icon(Icons.warning_outlined, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "You're sleeping ${(averageSleep - optimalSleep).toStringAsFixed(1)} hours more than optimal",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Health risk assessment
              Card(
                color: averageSleep >= 6 && averageSleep <= 8 ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite, color: averageSleep >= 6 && averageSleep <= 8 ? Colors.green : Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            "Health Risk Assessment",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getHealthRiskAssessment(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Research findings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Science Behind Your Results",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildFinding(
                        context,
                        "7 Hours is Optimal",
                        "Nature Aging study (500,000 adults): 7h optimal for cognition and mental health. Both <6h and >9h linked to cognitive decline.",
                      ),
                      _buildFinding(
                        context,
                        "Cardiovascular Risk",
                        "<5h sleep: 1.48× higher CHD risk, 1.26× cardiovascular mortality. >9h: 1.38× higher CHD risk.",
                      ),
                      _buildFinding(
                        context,
                        "PSQI Score",
                        "Score >5 indicates poor sleep quality. Used by sleep specialists worldwide. Your score: $psqiScore",
                      ),
                      _buildFinding(
                        context,
                        "Chronotype: $chronotype",
                        "Your natural sleep timing preference. Aligning with your chronotype improves sleep quality significantly.",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lifestyle recommendations
              Card(
                color: Colors.blue.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            "Personalized Recommendations",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (!regularExercise) _buildRecommendation(context, "Add regular exercise (3-5x/week) to improve sleep quality"),
                      if (caffeineLate) _buildRecommendation(context, "Avoid caffeine after 2 PM - it stays in your system 5-6 hours"),
                      if (screenBefore) _buildRecommendation(context, "Stop screens 1 hour before bed (blue light disrupts melatonin)"),
                      if (hasHealthConditions) _buildRecommendation(context, "Consult sleep specialist for your sleep condition"),
                      if (averageSleep < 6) _buildRecommendation(context, "Prioritize sleep - you're at significant health risk"),
                      if (averageSleep > 9) _buildRecommendation(context, "Gradually reduce sleep - excessive sleep also poses risks"),
                      _buildRecommendation(context, "Maintain consistent sleep schedule (±30 min on weekends)"),
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

  Widget _buildComparisonRow(BuildContext context, String label, String value, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$emoji $label", style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFinding(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context, String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(recommendation, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}
