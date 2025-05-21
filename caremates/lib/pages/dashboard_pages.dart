part of 'pages.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Dummy data for patient info
  Map<String, dynamic>? patientInfo;
  bool isLoading = true;

  // Dummy data for device status
  bool isDeviceOn = true;
  String deviceStatus = "Connected";

  // Dummy data for distance tracking
  double currentDistance = 5.2; // in meters
  String distanceStatus = 'Normal';
  Color statusColor = Colors.green;

  // Selected date for calendar
  DateTime selectedDate = DateTime.now();
  final Map<DateTime, List<Map<String, dynamic>>> calendarEvents = {};
  // Dummy data for calendar events/tasks
  List<Map<String, dynamic>> get eventsForSelectedDate =>
      calendarEvents[selectedDate] ?? [];

  // Controller for adding new task
  final TextEditingController _newTaskController = TextEditingController();
  final TextEditingController _newTimeController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCalendarEvents();
    _fetchPatientInfo();
    _simulateDistanceUpdate();
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    _newTimeController.dispose();
    _taskDescriptionController.dispose();
    super.dispose();
  }

  // Initialize some dummy events for the calendar
  void _initializeCalendarEvents() {
    final now = DateTime.now();

    // Today's events
    final today = DateTime(now.year, now.month, now.day);
    calendarEvents[today] = [
      {
        'title': 'Minum obat',
        'time': '08:00 AM',
        'description': 'Obat tekanan darah',
        'completed': true,
      },
      {
        'title': 'Cek tekanan darah',
        'time': '12:00 PM',
        'description': 'Catat hasil di buku monitoring',
        'completed': false,
      },
      {
        'title': 'Jalan sore',
        'time': '05:00 PM',
        'description': 'Jalan selama 15 menit dengan pendamping',
        'completed': false,
      },
    ];

    // Tomorrow's events
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    calendarEvents[tomorrow] = [
      {
        'title': 'Terapi fisik',
        'time': '09:00 AM',
        'description': 'Latihan kekuatan otot tangan',
        'completed': false,
      },
      {
        'title': 'Minum obat',
        'time': '08:00 PM',
        'description': 'Obat tidur',
        'completed': false,
      },
    ];

    // Day after tomorrow
    final dayAfterTomorrow = DateTime(now.year, now.month, now.day + 2);
    calendarEvents[dayAfterTomorrow] = [
      {
        'title': 'Dokter datang',
        'time': '10:00 AM',
        'description': 'Pemeriksaan rutin bulanan',
        'completed': false,
      },
    ];
  }

  TimeOfDay? _selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _newTimeController.text = picked.format(context); // shows readable time
      });
    }
  }

  Future<void> _fetchPatientInfo() async {
    final data = await PatientService.getMyPatientInfo();
    if (mounted) {
      setState(() {
        patientInfo = data;
        isLoading = false;
      });
    }
  }

  Future<void> _addCalendarEvent() async {
    final title = _newTaskController.text.trim();
    final description = _taskDescriptionController.text.trim();
    final time = _newTimeController.text.trim();

    if (title.isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter title and time')),
      );
      return;
    }

    final selectedDay = selectedDate;

    // Combine selected date and time into a DateTime object
    final parsedTime = _selectedTime!;
    final startDate = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      parsedTime.hour,
      parsedTime.minute,
    );
    final endDate = startDate.add(const Duration(hours: 1));

    try {
      // Step 1: Get the logged-in user ID
      final userData = await AuthService.getCurrentUser();
      if (userData == null || !mounted) return;
      final userId = userData['id'];

      // Step 3: Create the assignment
      final newAssignment = await CaregiverAssignmentService.createAssignment(
        patientId: userId,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;

      if (newAssignment != null) {
        _newTaskController.clear();
        _taskDescriptionController.clear();
        _newTimeController.clear();

        Navigator.pop(context);

        _onDaySelected(selectedDay, selectedDay); // Refresh tasks
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create assignment')),
      );
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Assignment',
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
                  labelText: 'Assignment Title',
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
              const SizedBox(height: 16),
              TextField(
                controller: _taskDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.description, color: primaryColor),
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
            onPressed: _addCalendarEvent,
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
    if (calendarEvents.containsKey(selectedDate)) {
      setState(() {
        calendarEvents[selectedDate]![index]['completed'] =
            !calendarEvents[selectedDate]![index]['completed'];
      });
    }
  }

  // Update jarak dari WebSocket
  void _simulateDistanceUpdate() {
    // GANTI PAKE WEBSOCKET LOGIC YG BENERAN
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          // Simulate random distance changes
          currentDistance = (currentDistance + (Random().nextDouble() * 2 - 1))
              .clamp(0.5, 50.0);

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

          // Simulate random device disconnections (5% chance)
          if (Random().nextInt(20) == 0) {
            isDeviceOn = !isDeviceOn;
            deviceStatus = isDeviceOn ? "Connected" : "Disconnected";
          }
        });
        _simulateDistanceUpdate();
      }
    });
  }

  String _formatTimeRange(String start, String end) {
    final startTime = DateTime.parse(start);
    final endTime = DateTime.parse(end);
    return "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}"
        " - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
  }

  // Calendar date selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      selectedDate = selectedDay;
    });

    final assignments =
        await CaregiverAssignmentService.getAssignmentsByDate(selectedDay);

    if (assignments != null) {
      setState(() {
        calendarEvents[selectedDay] = assignments
            .map((e) => {
                  'title': e['title'],
                  'description': e['description'],
                  'completed': false, // Or map e['status'] if exists
                  'time':
                      _formatTimeRange(e['tanggal_mulai'], e['tanggal_akhir']),
                })
            .toList();
      });
    }
  }

  // Format a date as a string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (date == today) {
      return "Today, ${DateFormat('d MMM').format(date)}";
    } else if (date == tomorrow) {
      return "Tomorrow, ${DateFormat('d MMM').format(date)}";
    } else {
      return DateFormat('EEEE, d MMM').format(date);
    }
  }

  // Check if a date has events

  @override
  Widget build(BuildContext context) {
    final eventsForSelectedDate = calendarEvents[selectedDate] ?? [];

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
              // Notification functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings functionality
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
                currentDistance =
                    (currentDistance + (Random().nextDouble() * 2 - 1))
                        .clamp(0.5, 50.0);
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
                              patientInfo?['nama']
                                      ?.toString()
                                      .substring(0, 1)
                                      .toUpperCase() ??
                                  '?',
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
                                  patientInfo?['nama'] ?? '',
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
                      _buildPatientInfoRow(Icons.cake, 'Birth Date',
                          patientInfo?['tanggal_lahir'] ?? '-'),
                      const SizedBox(height: 8),
                      _buildPatientInfoRow(Icons.person, 'Gender',
                          patientInfo?['jenis_kelamin'] ?? '-'),
                      const SizedBox(height: 8),
                      _buildPatientInfoRow(Icons.medical_services, 'Illness',
                          patientInfo?['penyakit'] ?? '-'),
                      const SizedBox(height: 8),
                      _buildPatientInfoRow(Icons.devices, 'Device ID',
                          patientInfo?['device']?['serial_number'] ?? '-'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Device Status Card
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
                      Text(
                        'Patient Bracelet Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Device Status - Fixed Width
                          Expanded(
                            child: Container(
                              height: 100, // Fixed height for both containers
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDeviceOn
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDeviceOn ? Colors.green : Colors.red,
                                  width: 0.8,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isDeviceOn ? Icons.power : Icons.power_off,
                                    color:
                                        isDeviceOn ? Colors.green : Colors.red,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    deviceStatus,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDeviceOn
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Distance Status - Fixed Width
                          Expanded(
                            child: Container(
                              height: 100, // Fixed height for both containers
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: statusColor,
                                  width: 0.8,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: statusColor,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${currentDistance.toStringAsFixed(1)} meters',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    distanceStatus,
                                    style: TextStyle(
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Last updated: ${DateFormat('hh:mm a').format(DateTime.now())}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Calendar and Tasks Card
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
                            'Caregiver Schedule',
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
                      const SizedBox(height: 16),

                      // Simple Calendar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: selectedDate,
                          selectedDayPredicate: (day) {
                            return isSameDay(selectedDate, day);
                          },
                          onDaySelected: _onDaySelected,
                          calendarStyle: CalendarStyle(
                            markersMaxCount: 3,
                            markerDecoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          eventLoader: (day) {
                            final normalizedDay =
                                DateTime(day.year, day.month, day.day);
                            return calendarEvents[normalizedDay] ?? [];
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Selected day events/tasks
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(selectedDate),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${eventsForSelectedDate.length} assignments",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Tasks for selected day
                      if (eventsForSelectedDate.isNotEmpty)
                        ...eventsForSelectedDate.asMap().entries.map((entry) {
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: item['completed'],
                                    activeColor: primaryColor,
                                    onChanged: (_) =>
                                        _toggleTaskCompletion(index),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['title'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  decoration: item['completed']
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                                  color: item['completed']
                                                      ? Colors.grey[600]
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              item['time'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['description'] ??
                                              'No description',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        calendarEvents[selectedDate]!
                                            .removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_available,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No assignments for this day',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _showAddTaskDialog,
                                  child: Text(
                                    'Add a new assignment',
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
