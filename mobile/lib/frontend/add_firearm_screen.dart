import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/firearm.dart';
import '../services/api_service.dart';
import '../services/wikipedia_services.dart';

class AddFirearmScreen extends StatefulWidget {
  final Firearm? existing;

  const AddFirearmScreen({
    super.key,
    this.existing,
  });

  @override
  State<AddFirearmScreen> createState() => _AddFirearmScreenState();
}

class _AddFirearmScreenState extends State<AddFirearmScreen> {
  final _formKey = GlobalKey<FormState>();

  final _modelController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _countryController = TextEditingController();
  final _caliberController = TextEditingController();
  final _yearController = TextEditingController();
  final _weightController = TextEditingController();
  final _barrelLengthController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();

  // Image URL controller
  final _imageUrlController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;

  String _selectedType = 'Pistol';

  bool _isSaving = false;
  bool _isFetchingWikipedia = false;

  final List<String> _firearmTypes = [
    'Pistol',
    'Rifle',
    'Shotgun',
    'Revolver',
    'Other',
  ];

  bool get _isEditing => widget.existing != null;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final firearm = widget.existing;

    if (firearm != null) {
      _modelController.text = firearm.name;
      _manufacturerController.text = firearm.manufacturer;
      _countryController.text = firearm.countryOfOrigin;
      _caliberController.text = firearm.caliber;

      _yearController.text =
          firearm.yearIntroduced?.toString() ?? '';

      _weightController.text =
          firearm.weightKg?.toString() ?? '';

      _barrelLengthController.text =
          firearm.barrelLengthCm?.toString() ?? '';

      _capacityController.text =
          firearm.magazineCapacity?.toString() ?? '';

      _descriptionController.text =
          firearm.description ?? '';

      _imageUrlController.text =
          firearm.imageUrl ?? '';

      if (_firearmTypes.contains(firearm.firearmType)) {
        _selectedType = firearm.firearmType;
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _modelController.dispose();
    _manufacturerController.dispose();
    _countryController.dispose();
    _caliberController.dispose();
    _yearController.dispose();
    _weightController.dispose();
    _barrelLengthController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF101726),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.gallery,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.camera,
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final pickedImage = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  // ============================================================
  // FETCH FROM WIKIPEDIA
  // ============================================================

  Future<void> _fetchFromWikipedia() async {
    final firearmName = _modelController.text.trim();

    if (firearmName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a firearm model name first.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isFetchingWikipedia = true;
    });

    try {
      final data =
          await WikipediaService.getFirearmInfo(
        firearmName,
      );

      if (!mounted) return;

      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No Wikipedia information found for this model.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final description =
          data['extract']?.toString() ?? '';

      final thumbnail =
          data['thumbnail'];

      final imageUrl = thumbnail is Map
          ? thumbnail['source']?.toString()
          : null;

      setState(() {
        if (description.isNotEmpty) {
          _descriptionController.text =
              description;
        }

        if (imageUrl != null &&
            imageUrl.isNotEmpty) {
          _imageUrlController.text = imageUrl;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wikipedia information fetched successfully!',
          ),
          backgroundColor: Color(0xFF2563EB),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to fetch Wikipedia data: $e',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingWikipedia = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE / UPDATE
  // ============================================================

  Future<void> _saveFirearm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? imageValue =
          _imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : widget.existing?.imageUrl;

      // If user selected a local image,
      // convert it to Base64.
      if (_selectedImage != null) {
        final bytes =
            await _selectedImage!.readAsBytes();

        final mimeType =
            _selectedImage!.mimeType ?? 'image/jpeg';

        imageValue =
            'data:$mimeType;base64,${base64Encode(bytes)}';
      }

      // IMPORTANT:
      // These field names match firearm.dart exactly.
      final firearm = Firearm(
        id: widget.existing?.id,

        name: _modelController.text.trim(),

        manufacturer:
            _manufacturerController.text.trim(),

        countryOfOrigin:
            _countryController.text.trim(),

        firearmType: _selectedType,

        caliber:
            _caliberController.text.trim(),

        yearIntroduced:
            int.tryParse(
          _yearController.text.trim(),
        ),

        weightKg:
            double.tryParse(
          _weightController.text.trim(),
        ),

        barrelLengthCm:
            double.tryParse(
          _barrelLengthController.text.trim(),
        ),

        magazineCapacity:
            int.tryParse(
          _capacityController.text.trim(),
        ),

        description:
            _descriptionController.text.trim(),

        imageUrl: imageValue,
      );

      if (_isEditing) {
  await _apiService.updateFirearm(firearm);
} else {
  await _apiService.createFirearm(firearm);
}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Firearm updated successfully!'
                : 'Firearm added successfully!',
          ),
          backgroundColor:
              const Color(0xFF2563EB),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save firearm: $e',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType =
        TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,

          style: const TextStyle(
            color: Colors.white,
          ),

          validator: required
              ? (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return '$label is required';
                  }

                  return null;
                }
              : null,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(
              color: Color(0xFF64748B),
            ),

            filled: true,

            fillColor:
                const Color(0xFF101726),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide:
                  const BorderSide(
                color: Color(0xFF1E2D4A),
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide:
                  const BorderSide(
                color: Color(0xFF1E2D4A),
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide:
                  const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),

            errorBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide:
                  const BorderSide(
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 14,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF60A5FA),
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE SECTION
  // ============================================================

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _pickImage,

      child: Container(
        width: double.infinity,
        height: 190,

        decoration: BoxDecoration(
          color: const Color(0xFF101726),

          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color: const Color(0xFF1E2D4A),
          ),
        ),

        child: _selectedImage != null
            ? ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),

                child: Image.file(
                  File(
                    _selectedImage!.path,
                  ),

                  width:
                      double.infinity,

                  height: 190,

                  fit: BoxFit.cover,
                ),
              )

            : _imageUrlController
                    .text
                    .trim()
                    .isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    child:
                        ApiService.buildImageWidget(
                      _imageUrlController
                          .text
                          .trim(),

                      width:
                          double.infinity,

                      height: 190,

                      fit: BoxFit.cover,
                    ),
                  )

                : const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [
                        Icon(
                          Icons
                              .upload_file_rounded,

                          color:
                              Color(0xFF64748B),

                          size: 45,
                        ),

                        SizedBox(
                          height: 8,
                        ),

                        Text(
                          'Tap to upload a firearm picture',

                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF64748B,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0B101D),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0B101D),

        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),

        title: Text(
          _isEditing
              ? 'Edit Firearm'
              : 'Add Firearm',

          style: const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,

        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // PRIMARY INFORMATION
              // ==================================================

              _buildSectionTitle(
                'Primary Information',
              ),

              _buildTextField(
                label: 'Model Name',
                controller:
                    _modelController,
                hint: 'e.g. M16A2',
                required: true,
              ),

              const SizedBox(
                height: 12,
              ),

              // WIKIPEDIA BUTTON

              SizedBox(
                width:
                    double.infinity,

                height: 44,

                child:
                    OutlinedButton.icon(
                  onPressed:
                      _isFetchingWikipedia
                          ? null
                          : _fetchFromWikipedia,

                  icon:
                      _isFetchingWikipedia
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Color(
                                  0xFF60A5FA,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons
                                  .language_rounded,

                              color:
                                  Color(
                                0xFF60A5FA,
                              ),
                            ),

                  label: Text(
                    _isFetchingWikipedia
                        ? 'Fetching from Wikipedia...'
                        : 'Fetch from Wikipedia',

                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF60A5FA,
                      ),
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  style:
                      OutlinedButton.styleFrom(
                    side:
                        const BorderSide(
                      color:
                          Color(
                        0xFF2563EB,
                      ),
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              _buildTextField(
                label: 'Manufacturer',
                controller:
                    _manufacturerController,
                hint: 'e.g. Colt',
                required: true,
              ),

              const SizedBox(
                height: 12,
              ),

              _buildTextField(
                label: 'Country of Origin',
                controller:
                    _countryController,
                hint:
                    'e.g. United States',
                required: true,
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // CLASSIFICATION
              // ==================================================

              _buildSectionTitle(
                'Classification',
              ),

              const Text(
                'Firearm Type',
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              DropdownButtonFormField<
                  String>(
                value:
                    _selectedType,

                dropdownColor:
                    const Color(
                  0xFF101726,
                ),

                style:
                    const TextStyle(
                  color:
                      Colors.white,
                ),

                decoration:
                    InputDecoration(
                  filled:
                      true,

                  fillColor:
                      const Color(
                    0xFF101726,
                  ),

                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),

                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFF1E2D4A,
                      ),
                    ),
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),

                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFF1E2D4A,
                      ),
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),

                    borderSide:
                        const BorderSide(
                      color:
                          Color(
                        0xFF2563EB,
                      ),
                      width: 1.5,
                    ),
                  ),
                ),

                items:
                    _firearmTypes
                        .map(
                  (type) =>
                      DropdownMenuItem<
                          String>(
                    value:
                        type,

                    child:
                        Text(
                      type,
                    ),
                  ),
                ).toList(),

                onChanged:
                    (value) {
                  if (value !=
                      null) {
                    setState(() {
                      _selectedType =
                          value;
                    });
                  }
                },
              ),

              const SizedBox(
                height: 12,
              ),

              _buildTextField(
                label: 'Caliber',
                controller:
                    _caliberController,
                hint:
                    'e.g. 5.56×45mm NATO',
                required: true,
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // TECHNICAL SPECIFICATIONS
              // ==================================================

              _buildSectionTitle(
                'Technical Specifications',
              ),

              _buildTextField(
                label:
                    'Year Introduced',
                controller:
                    _yearController,
                hint: 'e.g. 1983',
                keyboardType:
                    TextInputType
                        .number,
              ),

              const SizedBox(
                height: 12,
              ),

              _buildTextField(
                label: 'Weight (kg)',
                controller:
                    _weightController,
                hint: 'e.g. 3.40',
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              _buildTextField(
                label:
                    'Barrel Length (cm)',
                controller:
                    _barrelLengthController,
                hint: 'e.g. 50.8',
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              _buildTextField(
                label:
                    'Magazine Capacity',
                controller:
                    _capacityController,
                hint: 'e.g. 30',
                keyboardType:
                    TextInputType
                        .number,
              ),

              const SizedBox(
                height: 12,
              ),

              _buildTextField(
                label:
                    'Description',
                controller:
                    _descriptionController,
                hint:
                    'Enter a description of the firearm',
                maxLines: 6,
              ),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // IMAGE
              // ==================================================

              _buildSectionTitle(
                'Image',
              ),

              _buildImageSection(),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // SAVE BUTTON
              // ==================================================

              SizedBox(
                width:
                    double.infinity,

                height: 52,

                child:
                    ElevatedButton(
                  onPressed:
                      _isSaving
                          ? null
                          : _saveFirearm,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF2563EB,
                    ),

                    disabledBackgroundColor:
                        const Color(
                      0xFF1E2D4A,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),

                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing
                              ? 'Update Firearm'
                              : 'Save Firearm',

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
