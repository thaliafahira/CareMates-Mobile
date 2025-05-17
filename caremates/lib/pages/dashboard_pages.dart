part of 'pages.dart';

// Simul Authentication - buat connect ke Backend
class AuthService {
  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return email.isNotEmpty && password.isNotEmpty;
  }
  
  static Future<bool> register(String name, String email, String password, String confirmPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return name.isNotEmpty && 
           email.isNotEmpty && 
           password.isNotEmpty && 
           password == confirmPassword;
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Dummy data for patient info
  final Map<String, dynamic> patientInfo = {
    'name': 'Ujang',
    'birthDate': '17-08-1945',
    'gender': 'Pria',
    'illness': 'Stroke',
    'deviceId': 'CM-1234'
  };

  // Dummy data for distance tracking
  double currentDistance = 5.2; // in meters
  String distanceStatus = 'Normal';
  Color statusColor = Colors.green;

  // Dummy data for schedule/to-do list
  final List<Map<String, dynamic>> scheduleItems = [
    {
      'title': 'Minum obat',
      'time': '08:00 AM',
      'completed': true,
    },
    {
      'title': 'Cek tekanan darah',
      'time': '12:00 PM',
      'completed': false,
    },
    {
      'title': 'Jalan sore',
      'time': '05:00 PM',
      'completed': false,
    },
  ];

  // Controller nambahin schedule item
  final TextEditingController _newTaskController = TextEditingController();
  final TextEditingController _newTimeController = TextEditingController();

  @override
  void dispose() {
    _newTaskController.dispose();
    _newTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _newTimeController.text = picked.format(context);
      });
    }
  }

  void _addScheduleItem() {
    if (_newTaskController.text.isNotEmpty && _newTimeController.text.isNotEmpty) {
      setState(() {
        scheduleItems.add({
          'title': _newTaskController.text,
          'time': _newTimeController.text,
          'completed': false,
        });
        _newTaskController.clear();
        _newTimeController.clear();
      });
      Navigator.pop(context);
    }
  }

  void _showAddTaskDialog() {
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newTaskController,
                decoration: InputDecoration(
                  labelText: 'Task',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.task, color: primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: _newTimeController,
                    decoration: InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.access_time, color: primaryColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
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
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      scheduleItems[index]['completed'] = !scheduleItems[index]['completed'];
    });
  }

  // Update jarak dari WebSocket
  void _simulateDistanceUpdate() {
    // GANTI PAKE WEBSOCKET LOGIC YG BENERAN
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          // Simulate random distance changes
          currentDistance = (currentDistance + (Random().nextDouble() * 2 - 1)).clamp(0.5, 50.0);
          
          // Update status 
          if (currentDistance < 10) {
            distanceStatus = 'Normal';
            statusColor = Colors.green;
          } else if (currentDistance < 30) {
            distanceStatus = 'Warning';
            statusColor = Colors.orange;
          } else {
            distanceStatus = 'Alert';
            statusColor = Colors.red;
          }
        });
        _simulateDistanceUpdate(); 
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _simulateDistanceUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('CareMates Dashboard'),
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            if (mounted) {
              setState(() {
                // Update distance (ini demo aja)
                currentDistance = (currentDistance + (Random().nextDouble() * 2 - 1)).clamp(0.5, 50.0);
              });
            }
          },
          child: ListView(
            padding: EdgeInsets.all(defaultMargin),
            children: [
              // Patient Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            child: Text(
                              patientInfo['name'].substring(0, 1),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Patient Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  patientInfo['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildPatientInfoRow(Icons.cake, 'Birth Date', patientInfo['birthDate']),
                      const SizedBox(height: 8),
                      _buildPatientInfoRow(Icons.person, 'Gender', patientInfo['gender']),
                      const SizedBox(height: 8),
                      _buildPatientInfoRow(Icons.medical_services, 'Illness', patientInfo['illness']),
                      const SizedBox(height: 8),
                      _buildPatientInfoRow(Icons.devices, 'Device ID', patientInfo['deviceId']),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Distance Tracking Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Distance Tracking',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              distanceStatus,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 48,
                            color: statusColor,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${currentDistance.toStringAsFixed(1)} meters',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last updated: ${DateFormat('hh:mm a').format(DateTime.now())}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: (50 - currentDistance) / 50, // Inverse relationship - closer is better
                        backgroundColor: Colors.grey[300],
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // To-Do List Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jadwal & Tasks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: primaryColor),
                            onPressed: _showAddTaskDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...scheduleItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: item['completed'] 
                                  ? Colors.green.withOpacity(0.1) 
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: item['completed'] 
                                    ? Colors.green.withOpacity(0.5) 
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: item['completed'],
                                  activeColor: primaryColor,
                                  onChanged: (_) => _toggleTaskCompletion(index),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          decoration: item['completed'] 
                                              ? TextDecoration.lineThrough 
                                              : null,
                                          color: item['completed'] 
                                              ? Colors.grey[600] 
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        item['time'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      scheduleItems.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (scheduleItems.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No tasks yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextButton(
                                  onPressed: _showAddTaskDialog,
                                  child: Text(
                                    'Add a task',
                                    style: TextStyle(
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
