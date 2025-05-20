part of 'pages.dart';

class DevicePairingPage extends StatefulWidget {
  const DevicePairingPage({super.key});

  @override
  State<DevicePairingPage> createState() => _DevicePairingPageState();
}

class _DevicePairingPageState extends State<DevicePairingPage> {
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedGender;
  String? _selectedDisease;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _diseases = [
    "Hipertensi",
    "Diabetes",
    "Asma",
    "Jantung",
    "Stroke",
    "Arthritis",
    "Kanker",
    "Pneumonia"
  ];

  @override
  void dispose() {
    _patientNameController.dispose();
    _addressController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1960),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _submitPairing() async {
    // Reset error message and set loading state
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validate form fields
    if (_patientNameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _serialNumberController.text.isEmpty ||
        _birthDate == null ||
        _selectedGender == null ||
        _selectedDisease == null) {
      setState(() {
        _errorMessage = "Please fill in all fields";
        _isLoading = false;
      });
      return;
    }

    try {
      // First, pair the patient
      final patientSuccess = await PairingService.pairPatient(
        name: _patientNameController.text,
        address: _addressController.text,
        gender: _selectedGender!,
        birthDate: _birthDate!,
        disease: _selectedDisease!,
        deviceId: _deviceIdController.text,
      );

      if (!patientSuccess) {
        setState(() {
          _errorMessage = "Failed to register patient. Please try again.";
          _isLoading = false;
        });
        return;
      }

      // Then, pair the device
      final deviceSuccess = await PairingService.pairDevice(
        serialNumber: _deviceIdController.text,
        tipe: "gelang", // Default value as shown in your PairingService
        status: "non-aktif", // Default value as shown in your PairingService
      );

      if (!deviceSuccess) {
        setState(() {
          _errorMessage =
              "Patient registered but device pairing failed. Please try again with the device.";
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        // Navigate to Dashboard if both pairing operations are successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: whiteColor,
        title: const Text("Device Pairing"),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(defaultMargin),
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  _buildStepCircle(1, true, "Registration"),
                  _buildStepLine(true),
                  _buildStepCircle(2, true, "Device Pairing"),
                  _buildStepLine(false),
                  _buildStepCircle(3, false, "Dashboard"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Connect Patient with Device",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please fill in patient details and pair with a device",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            // Error message display
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: dangerColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: dangerColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: dangerColor),
                      ),
                    ),
                  ],
                ),
              ),

            // Patient Information Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Patient Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Patient Name
                    TextField(
                      controller: _patientNameController,
                      decoration: InputDecoration(
                        labelText: "Patient Name",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.person, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Birth Date
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                              text: _birthDate != null
                                  ? DateFormat('dd-MM-yyyy').format(_birthDate!)
                                  : ''),
                          decoration: InputDecoration(
                            labelText: "Birth Date",
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            prefixIcon:
                                Icon(Icons.calendar_today, color: primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text("Select Gender",
                              style: TextStyle(color: Colors.grey[600])),
                          value: _selectedGender,
                          items: const [
                            DropdownMenuItem(
                                value: "L", child: Text("Male (L)")),
                            DropdownMenuItem(
                                value: "P", child: Text("Female (P)")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          icon:
                              Icon(Icons.arrow_drop_down, color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: "Address",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.home, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Disease
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text("Select Disease",
                              style: TextStyle(color: Colors.grey[600])),
                          value: _selectedDisease,
                          items: _diseases.map((disease) {
                            return DropdownMenuItem(
                              value: disease,
                              child: Text(disease),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDisease = value;
                            });
                          },
                          icon:
                              Icon(Icons.arrow_drop_down, color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Device Pairing Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Device Pairing",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _serialNumberController,
                      decoration: InputDecoration(
                        labelText: "Serial Number",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(Icons.device_hub, color: primaryColor),
                        hintText: "Enter device serial number (e.g. SN001)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Please enter the device serial number printed on the device",
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPairing,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: whiteColor,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Pairing device...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: whiteColor,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      "Complete Setup",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(int step, bool isActive, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? primaryColor : Colors.grey[300],
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? whiteColor : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? primaryColor : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? primaryColor : Colors.grey[300],
      ),
    );
  }
}
