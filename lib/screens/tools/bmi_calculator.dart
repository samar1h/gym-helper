import 'package:flutter/material.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  
  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both height and weight'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    double height = double.tryParse(_heightController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;
    
    if (height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid values'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Convert to metric
    if (_heightUnit == 'ft') {
      height = height * 30.48; // feet to cm
    } else if (_heightUnit == 'in') {
      height = height * 2.54; // inches to cm
    }
    
    if (_weightUnit == 'lb') {
      weight = weight * 0.453592; // pounds to kg
    }
    
    // Calculate BMI
    double heightInMeters = height / 100;
    double bmi = weight / (heightInMeters * heightInMeters);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BMIResultPage(bmi: bmi),
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
              Icons.monitor_weight_outlined,
              size: Theme.of(context).textTheme.headlineMedium?.fontSize,
            ),
            SizedBox(width: 10),
            Text(
              "BMI Calculator",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: "Go Back",
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Height Input
            Text(
              'Height',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter height',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: _heightController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  _heightController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _heightUnit,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: ['cm', 'ft', 'in'].map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _heightUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Weight Input
            Text(
              'Weight',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter weight',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      suffixIcon: _weightController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  _weightController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _weightUnit,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: ['kg', 'lb'].map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _weightUnit = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 32),
            
            // Calculate Button
            FilledButton(
              onPressed: _calculate,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Calculate BMI',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Info Card
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'About BMI',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Body Mass Index (BMI) is a simple calculation using height and weight. It provides a general indicator of body composition.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BMIResultPage extends StatelessWidget {
  final double bmi;
  
  const BMIResultPage({super.key, required this.bmi});
  
  String _getCategory() {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
  
  Color _getCategoryColor(BuildContext context) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
  
  String _getAdvice() {
    if (bmi < 18.5) {
      return 'Consider consulting with a healthcare provider about healthy weight gain strategies.';
    } else if (bmi < 25) {
      return 'Great! Maintain your healthy weight through balanced diet and regular exercise.';
    } else if (bmi < 30) {
      return 'Consider incorporating more physical activity and a balanced diet to reach a healthier weight.';
    } else {
      return 'Consult with a healthcare provider for personalized advice on healthy weight management.';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final category = _getCategory();
    final categoryColor = _getCategoryColor(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha(100),
        title: Text('Your Result'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: "Go Back",
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BMI Score Card
            Card(
              elevation: 0,
              color: categoryColor.withAlpha(30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: categoryColor.withAlpha(100), width: 2),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      'Your BMI',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    Text(
                      bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // BMI Scale Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildCategoryRow('Underweight', '< 18.5', Colors.blue),
                    _buildCategoryRow('Normal', '18.5 - 24.9', Colors.green),
                    _buildCategoryRow('Overweight', '25.0 - 29.9', Colors.orange),
                    _buildCategoryRow('Obese', '≥ 30.0', Colors.red),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Advice Card
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Advice',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      _getAdvice(),
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Recalculate Button
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Recalculate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Disclaimer
            Text(
              'Note: BMI is a general indicator and may not be accurate for athletes, pregnant women, or elderly individuals. Always consult healthcare professionals for personalized advice.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryRow(String label, String range, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}