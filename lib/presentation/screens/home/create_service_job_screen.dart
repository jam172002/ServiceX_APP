import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:servicex_client_app/presentation/screens/home/service_provider_profile_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/constants/images.dart';

import '../../controllers/vipeep_location_controller.dart';
import '../../widgets/all_services_dialog.dart';
import '../../widgets/common_appbar.dart';
import '../../widgets/create_job_budget_section.dart';
import '../../widgets/create_job_confirmation_dialog.dart';
import '../../widgets/create_job_date_time_section.dart';
import '../../widgets/create_job_details_section.dart';
import '../../widgets/create_job_location_section.dart';
import '../../widgets/create_job_payment_section.dart';
import '../../widgets/create_job_service_type_section.dart';
import '../../widgets/location_bottom_sheet.dart';

class CreateServiceJobScreen extends StatefulWidget {
  final bool showServiceProviderCard;
  final String? spName;
  final String? spType;
  final String? spImage;
  const CreateServiceJobScreen({
    super.key,
    required this.showServiceProviderCard,
    this.spName,
    this.spType,
    this.spImage,
  });

  @override
  State<CreateServiceJobScreen> createState() => _CreateServiceJobScreenState();
}

class _CreateServiceJobScreenState extends State<CreateServiceJobScreen> {
  // Controllers & state
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  final LocationController locationController = Get.find<LocationController>();

  int? _selectedServiceIndex;
  String? _selectedSubType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  RangeValues _budgetRange = const RangeValues(50, 150);
  String _selectedPayment = "Master Card";
  final ImagePicker _picker = ImagePicker();
  final List<File> _pickedImages = [];

  // Services
  final List<Map<String, String>> _allServices = [
    {'title': "Electric", 'img': 'assets/icons/flash.png'},
    {'title': "AC Repair", 'img': 'assets/icons/ac.png'},
    {'title': "Plumber", 'img': 'assets/icons/plumber.png'},
    {'title': "Car Wash", 'img': 'assets/icons/carwash.png'},
    {'title': "Painter", 'img': 'assets/icons/paint.png'},
    {'title': "Gardener", 'img': 'assets/icons/garden.png'},
    {'title': "Cleaning", 'img': 'assets/icons/cleaning.png'},
    {'title': "Mechanic", 'img': 'assets/icons/mechanic.png'},
    {'title': "Roofing", 'img': 'assets/icons/flash.png'},
    {'title': "Furniture", 'img': 'assets/icons/flash.png'},
    {'title': "Pest Control", 'img': 'assets/icons/flash.png'},
    {'title': "Plastering", 'img': 'assets/icons/flash.png'},
    {'title': "Car Wash", 'img': 'assets/icons/carwash.png'},
    {'title': "Painter", 'img': 'assets/icons/paint.png'},
    {'title': "Gardener", 'img': 'assets/icons/garden.png'},
    {'title': "Cleaning", 'img': 'assets/icons/cleaning.png'},
    {'title': "Mechanic", 'img': 'assets/icons/mechanic.png'},
    {'title': "Roofing", 'img': 'assets/icons/flash.png'},
  ];

  final Map<String, List<String>> _serviceSubTypes = {
    "Electric": ["Wiring", "Switch Repair", "Lighting Installation"],
    "AC Repair": ["Window AC", "Split AC", "Portable AC"],
    "Plumber": ["Pipe Fixing", "Leak Repair", "Drain Cleaning"],
    "Car Wash": ["Exterior", "Interior", "Full Service"],
    "Painter": ["Wall Painting", "Furniture Painting", "Spray Painting"],
    "Gardener": ["Lawn Care", "Planting", "Pruning"],
    "Cleaning": ["Home", "Office", "Carpet"],
    "Mechanic": ["Engine", "Transmission", "Brakes"],
    "Roofing": ["Roof Installation", "Repair", "Maintenance"],
    "Furniture": ["Assembly", "Repair", "Refinishing"],
    "Pest Control": ["Termite", "Rodent", "Insect"],
    "Plastering": ["Wall Plastering", "Ceiling Plastering"],
  };

  @override
  void initState() {
    super.initState();

    _minController.text = _budgetRange.start.round().toString();
    _maxController.text = _budgetRange.end.round().toString();

    _minController.addListener(() {
      final val = int.tryParse(_minController.text);
      if (val != null && val <= _budgetRange.end && val >= 0) {
        setState(
          () => _budgetRange = RangeValues(val.toDouble(), _budgetRange.end),
        );
      }
    });

    _maxController.addListener(() {
      final val = int.tryParse(_maxController.text);
      if (val != null && val >= _budgetRange.start && val <= 1000) {
        setState(
          () => _budgetRange = RangeValues(_budgetRange.start, val.toDouble()),
        );
      }
    });

    // --- NEW: Preselect SP service type if scenario 2 ---
    if (widget.showServiceProviderCard && widget.spType != null) {
      final index = _allServices.indexWhere((e) => e['title'] == widget.spType);
      if (index != -1) _selectedServiceIndex = index;
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  // -------------------------
  // IMAGE PICKER
  // -------------------------
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 75,
      );
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _pickedImages.addAll(pickedFiles.map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        setState(() => _pickedImages.add(File(pickedFile.path)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  // -------------------------
  // DATE & TIME
  // -------------------------
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: XColors.primary,
              onPrimary: Colors.white,
              onSurface: XColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: XColors.primary,
              onPrimary: Colors.white,
              onSurface: XColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // -------------------------
  // LOCATION
  // -------------------------
  Future<void> _editLocation() async {
    final pickedLocation = await showLocationBottomSheet(context);
    if (pickedLocation != null) {
      locationController.updateLocation(pickedLocation);
    }
  }

  // -------------------------
  // JOB SUBMIT
  // -------------------------
  void _submit() {
    if (_selectedServiceIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service type')),
      );
      return;
    }

    if (_selectedSubType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a sub-type')));
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    if (_detailsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please add details')));
      return;
    }

    if (_selectedPayment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    // Job type selection
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Create Job"),
        content: const Text("How do you want to create this job?"),
        backgroundColor: XColors.secondaryBG,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showConfirmationDialog(forAll: true);
            },
            child: const Text(
              "Open for All",
              style: TextStyle(color: XColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showConfirmationDialog(forAll: false);
            },
            child: const Text(
              "Send Request to Personal",
              style: TextStyle(color: XColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllServicesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AllServicesDialog(
        allServices: _allServices,
        selectedServiceIndex: _selectedServiceIndex,
        onServiceSelected: (index) {
          setState(() {
            final svc = _allServices[index];
            _allServices.removeWhere((e) => e['title'] == svc['title']);
            _allServices.insert(0, svc);
            _selectedServiceIndex = 0;
            _selectedSubType = null;
          });
        },
      ),
    );
  }

  void _showConfirmationDialog({required bool forAll}) {
    final jobData = {
      "service": _allServices[_selectedServiceIndex!]["title"],
      "sub_type": _selectedSubType,
      "details": _detailsController.text.trim(),
      "location": locationController.currentLocation.value,
      "date": _selectedDate!.toIso8601String(),
      "time": _selectedTime!.format(context),
      "budget_min": _budgetRange.start.round(),
      "budget_max": _budgetRange.end.round(),
      "payment": _selectedPayment,
      "images": _pickedImages,
      "forAll": forAll,
    };

    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        service: jobData["service"] as String,
        subType: jobData["sub_type"] as String?, // nullable
        details: jobData["details"] as String,
        location: jobData["location"] as String,
        date: jobData["date"] as String,
        time: jobData["time"] as String,
        budgetMin: jobData["budget_min"] as int,
        budgetMax: jobData["budget_max"] as int,
        payment: jobData["payment"] as String,
        images: jobData["images"] as List<File>,
        forAll: jobData["forAll"] as bool,
        onConfirm: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                (jobData["forAll"] as bool)
                    ? "Job created and opened for all users (demo)"
                    : "Job request sent to personal users only (demo)",
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------
  // BUILD
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const XAppBar(title: 'Create Job'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //? Service Provider Card
            if (widget.showServiceProviderCard) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Provider',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage(
                          widget.spImage ?? XImages.serviceProvider,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.spName ?? 'Unknown',
                            style: TextStyle(
                              color: XColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.spType ?? 'Unknown',
                            style: TextStyle(
                              color: XColors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton.filled(
                        onPressed: () {
                          Get.to(() => ServiceProviderProfileScreen());
                        },
                        icon: Icon(
                          Iconsax.user,
                          color: XColors.primary,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: XColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {},
                        icon: Icon(
                          Iconsax.sms,
                          color: XColors.primary,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: XColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
            ServiceTypeSection(
              allServices: _allServices,
              selectedIndex: _selectedServiceIndex,
              onServiceTap: (service, index) {
                if (service['title'] == 'Other') {
                  _showAllServicesDialog();
                } else {
                  if (!widget.showServiceProviderCard) {
                    // Move selected to first place
                    setState(() {
                      _allServices.removeAt(index!);
                      _allServices.insert(0, service);
                      _selectedServiceIndex = 0;
                      _selectedSubType = null; // reset sub-type
                    });
                  } else {
                    // Scenario 2: fixed selection for SP
                    setState(() => _selectedServiceIndex = index);
                  }
                }
              },
            ),

            const SizedBox(height: 12),
            Text(
              "Sub-Type",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSubType,
              hint: Text(
                _selectedServiceIndex != null
                    ? "Select sub-type"
                    : "Select category first",
                style: TextStyle(
                  color: XColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
              dropdownColor: XColors.secondaryBG,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: XColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: XColors.borderColor),
                ),
                filled: true,
                fillColor: XColors.secondaryBG,
              ),
              items:
                  (_selectedServiceIndex != null &&
                      _serviceSubTypes.containsKey(
                        _allServices[_selectedServiceIndex!]['title'],
                      ))
                  ? _serviceSubTypes[_allServices[_selectedServiceIndex!]['title']]!
                        .map(
                          (sub) => DropdownMenuItem<String>(
                            value: sub,
                            child: Text(sub, style: TextStyle(fontSize: 13)),
                          ),
                        )
                        .toList()
                  : null,
              onChanged: (_selectedServiceIndex != null)
                  ? (val) {
                      setState(() => _selectedSubType = val);
                    }
                  : null,
            ),

            const SizedBox(height: 12),
            DetailsSection(
              detailsController: _detailsController,
              pickedImages: _pickedImages,
              onPickImages: _pickImages,
              onPickCameraImage: _pickImageFromCamera,
              onRemoveImage: _removeImage,
            ),
            const SizedBox(height: 20),
            Obx(
              () => LocationSection(
                location: locationController.currentLocation.value,
                onEdit: _editLocation,
              ),
            ),
            const SizedBox(height: 20),
            DateTimeSection(
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              onSelectDate: _selectDate,
              onSelectTime: _selectTime,
            ),
            const SizedBox(height: 20),
            BudgetSection(
              minController: _minController,
              maxController: _maxController,
              budgetRange: _budgetRange,
              onChanged: (val) {
                setState(() {
                  _budgetRange = val;
                  _minController.text = val.start.round().toString();
                  _maxController.text = val.end.round().toString();
                });
              },
            ),
            const SizedBox(height: 20),
            PaymentSection(
              selectedPayment: _selectedPayment,
              onSelect: (val) {
                setState(() => _selectedPayment = val);
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: XColors.primary,
                ),
                child: const Text(
                  "Create Job",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
