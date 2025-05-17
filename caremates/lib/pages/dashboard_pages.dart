part of 'pages.dart';

// Simul Authentication - buat konek ke Backend
class AuthService {
  static Future<bool> login(String email, String password) async {
    // Simul API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    return email.isNotEmpty && password.isNotEmpty;
  }
  
  static Future<bool> register(String name, String email, String password, String confirmPassword) async {
    // Simul API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Basic validation
    return name.isNotEmpty && 
           email.isNotEmpty && 
           password.isNotEmpty && 
           password == confirmPassword;
  }
}

class DashboardPage extends StatefulWidget {
  final String patientName;
  final String patientId;

  const DashboardPage({
    super.key, 
    this.patientName = "Viktor", 
    this.patientId = "ABC123456789"
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Data to-do list
  final List<Map<String, dynamic>> _scheduleItems = [
    {
      'title': 'Minum obat pagi',
      'time': '08:00 AM',
      'isCompleted': false,
    },
    {
      'title': 'Cek tekanan darah',
      'time': '10:30 AM',
      'isCompleted': true,
    },
    {
      'title': 'Makan siang',
      'time': '12:00 PM',
      'isCompleted': false,
    },
    {
      'title': 'Jalan Sore',
      'time': '04:00 PM',
      'isCompleted': false,
    },
    {
      'title': 'Minum obat malam',
      'time': '08:00 PM',
      'isCompleted': false,
    },
  ];

  // Patient health data (yang dari sensor gua gatau apa aja hehe)
  final Map<String, dynamic> _healthData = {
    'heartRate': 78,
    'bloodPressure': '120/80',
    'oxygenLevel': 98,
    'temperature': 36.5,
    'glucose': 95,
    'lastUpdated': '10 minutes ago'
  };

  // Mockup jarak
  final double _distance = 0.5; // in kilometers

  // Nambahin schedule items
  final TextEditingController _newTaskController = TextEditingController();
  final TextEditingController _newTimeController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _newTaskController.dispose();
    _newTimeController.dispose();
    super.dispose();
  }

  void _addScheduleItem() {
    if (_newTaskController.text.isNotEmpty && _newTimeController.text.isNotEmpty) {
      setState(() {
        _scheduleItems.add({
          'title': _newTaskController.text,
          'time': _newTimeController.text,
          'isCompleted': false,
        });
        _newTaskController.clear();
        _newTimeController.clear();
      });
      Navigator.pop(context);
    }
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _scheduleItems[index]['isCompleted'] = !_scheduleItems[index]['isCompleted'];
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        // Format time to AM/PM format
        final hour = _selectedTime.hourOfPeriod;
        final minute = _selectedTime.minute.toString().padLeft(2, '0');
        final period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
        _newTimeController.text = '$hour:$minute $period';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Add notification functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Add profile functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(defaultMargin),
          children: [
            // Patient Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryColor,
                      child: Text(
                        widget.patientName.substring(0, 1),
                        style: TextStyle(
                          fontSize: 24,
                          color: whiteColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Patient ID: ${widget.patientId}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Distance Tracker
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Distance from Patient',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '${_distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _distance < 1 ? Colors.green : primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _distance < 1 ? 'You are nearby' : 'Distance to patient',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 1 - (_distance / 5), // Scale from 0-5km
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _distance < 1 ? Colors.green : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Health Information
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: dangerColor),
                            const SizedBox(width: 8),
                            const Text(
                              'Health Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Updated: ${_healthData['lastUpdated']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildHealthIndicator(
                          icon: Icons.favorite_border,
                          label: 'Heart Rate',
                          value: '${_healthData['heartRate']}',
                          unit: 'bpm',
                          color: dangerColor,
                        ),
                        _buildHealthIndicator(
                          icon: Icons.speed,
                          label: 'Blood Pressure',
                          value: _healthData['bloodPressure'],
                          unit: 'mmHg',
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildHealthIndicator(
                          icon: Icons.air,
                          label: 'Oxygen',
                          value: '${_healthData['oxygenLevel']}',
                          unit: '%',
                          color: Colors.lightBlue,
                        ),
                        _buildHealthIndicator(
                          icon: Icons.thermostat,
                          label: 'Temperature',
                          value: '${_healthData['temperature']}',
                          unit: '°C',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildHealthIndicator(
                          icon: Icons.bloodtype,
                          label: 'Glucose',
                          value: '${_healthData['glucose']}',
                          unit: 'mg/dL',
                          color: Colors.purple,
                          isLastRow: true,
                        ),
                        Expanded(child: Container()), // Empty container for alignment
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Schedule/To-Do List
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: primaryColor),
                            const SizedBox(width: 8),
                            const Text(
                              'Schedule',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          onPressed: () {
                            // Show add task dialog
                            _showAddTaskDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: whiteColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (int i = 0; i < _scheduleItems.length; i++)
                      _buildScheduleItem(i),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    bool isLastRow = false,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(int index) {
    final item = _scheduleItems[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CheckboxListTile(
          value: item['isCompleted'],
          onChanged: (_) => _toggleTaskCompletion(index),
          title: Text(
            item['title'],
            style: TextStyle(
              decoration: item['isCompleted'] ? TextDecoration.lineThrough : null,
              color: item['isCompleted'] ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                item['time'],
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          secondary: Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: item['isCompleted'] ? Colors.green : primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          activeColor: primaryColor,
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Task',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newTaskController,
              decoration: InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.task, color: primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newTimeController,
              readOnly: true,
              onTap: () => _selectTime(context),
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.access_time, color: primaryColor),
                suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: _addScheduleItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add Task'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}