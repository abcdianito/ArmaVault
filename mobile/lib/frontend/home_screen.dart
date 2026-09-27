import 'package:flutter/material.dart';

import '../models/firearm.dart';
import '../services/api_service.dart';
import 'add_firearm_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  List<Firearm> _allFirearms = [];
  List<Firearm> _filteredFirearms = [];

  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedType = 'All';

  final List<String> _filterTypes = [
    'All',
    'Pistol',
    'Rifle',
    'Shotgun',
    'Revolver',
    'Other',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadFirearms();
  }

  // ============================================================
  // LOAD FIREARMS
  // ============================================================

  Future<void> _loadFirearms() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final firearms =
          await _apiService.getFirearms();

      if (!mounted) return;

      setState(() {
        _allFirearms = firearms;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load firearms: $e',
          ),
          backgroundColor:
              Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // SEARCH + FILTER
  // ============================================================

  void _applyFilters() {
    final query =
        _searchQuery.toLowerCase().trim();

    final results =
        _allFirearms.where((firearm) {
      final matchesSearch =
          firearm.name
                  .toLowerCase()
                  .contains(query) ||
              firearm.manufacturer
                  .toLowerCase()
                  .contains(query) ||
              firearm.caliber
                  .toLowerCase()
                  .contains(query) ||
              firearm.countryOfOrigin
                  .toLowerCase()
                  .contains(query);

      final matchesType =
          _selectedType == 'All' ||
              firearm.firearmType
                      .toLowerCase() ==
                  _selectedType
                      .toLowerCase();

      return matchesSearch &&
          matchesType;
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredFirearms = results;
    });
  }

  // ============================================================
  // ADD
  // ============================================================

  Future<void> _openAddFirearm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AddFirearmScreen(),
      ),
    );

    await _loadFirearms();
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> _openEditFirearm(
      Firearm firearm) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddFirearmScreen(
          existing: firearm,
        ),
      ),
    );

    await _loadFirearms();
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteFirearm(
      Firearm firearm) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF121D30),
          title: const Text(
            'Delete Firearm',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${firearm.name}"?',
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        firearm.id == null) {
      return;
    }

    try {
      await _apiService.deleteFirearm(
        firearm.id!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Firearm deleted successfully.',
          ),
        ),
      );

      await _loadFirearms();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete firearm: $e',
          ),
          backgroundColor:
              Colors.redAccent,
        ),
      );
    }
  }

  // ============================================================
  // IMAGE WIDGET
  // ============================================================

  Widget _buildFirearmImage(
    Firearm firearm, {
    double width = 105,
    double height = 105,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFF121D30),
        child: ApiService.buildImageWidget(
          firearm.imageUrl,
          width: width,
          height: height,
          fit: BoxFit.contain,
          placeholder: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF64748B),
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FIREARM DETAILS
  // ============================================================

  void _showFirearmDetails(
      Firearm firearm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          const Color(0xFF0B101D),
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.60,
          maxChildSize: 0.95,
          expand: false,
          builder: (
            context,
            scrollController,
          ) {
            return SingleChildScrollView(
              controller:
                  scrollController,
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                                0xFF334155),
                        borderRadius:
                            BorderRadius.circular(
                                10),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // IMAGE
                  Container(
                    width: double.infinity,
                    height: 230,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                              0xFF121D30),
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                    child:
                        _buildFirearmImage(
                      firearm,
                      width:
                          double.infinity,
                      height: 230,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // TYPE
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                              0xFF183258),
                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),
                    child: Text(
                      firearm.firearmType
                          .toUpperCase(),
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF60A5FA),
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // NAME
                  Text(
                    firearm.name,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    firearm.manufacturer,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF94A3B8),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  _detailItem(
                    'Country of Origin',
                    firearm.countryOfOrigin,
                  ),

                  _detailItem(
                    'Caliber',
                    firearm.caliber,
                  ),

                  _detailItem(
                    'Year Introduced',
                    firearm
                            .yearIntroduced
                            ?.toString() ??
                        'N/A',
                  ),

                  _detailItem(
                    'Weight',
                    firearm.weightKg !=
                            null
                        ? '${firearm.weightKg} kg'
                        : 'N/A',
                  ),

                  _detailItem(
                    'Barrel Length',
                    firearm.barrelLengthCm !=
                            null
                        ? '${firearm.barrelLengthCm} cm'
                        : 'N/A',
                  ),

                  _detailItem(
                    'Magazine Capacity',
                    firearm
                                .magazineCapacity !=
                            null
                        ? '${firearm.magazineCapacity} rounds'
                        : 'N/A',
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  const Text(
                    'Description',
                    style:
                        TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    firearm.description
                                ?.isNotEmpty ==
                            true
                        ? firearm
                            .description!
                        : 'No description available.',
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF94A3B8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // EDIT BUTTON
                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        ElevatedButton.icon(
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      label:
                          const Text(
                        'Edit Firearm',
                        style:
                            TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                                0xFF2563EB),
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(
                            context);

                        await _openEditFirearm(
                            firearm);
                      },
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // DELETE BUTTON
                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        OutlinedButton.icon(
                      icon: const Icon(
                        Icons
                            .delete_outline,
                        color:
                            Colors.redAccent,
                      ),
                      label:
                          const Text(
                        'Delete Firearm',
                        style:
                            TextStyle(
                          color:
                              Colors.redAccent,
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style:
                          OutlinedButton
                              .styleFrom(
                        side:
                            const BorderSide(
                          color:
                              Colors.redAccent,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(
                            context);

                        await _deleteFirearm(
                            firearm);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DETAIL ITEM
  // ============================================================

  Widget _detailItem(
    String label,
    String? value,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            const Color(0xFF10192A),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              const Color(0xFF1E2D4A),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style:
                  const TextStyle(
                color:
                    Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIREARM CARD
  // ============================================================

  Widget _buildFirearmCard(
      Firearm firearm) {
    return GestureDetector(
      onTap: () {
        _showFirearmDetails(
            firearm);
      },
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 14,
        ),
        padding:
            const EdgeInsets.all(12),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFF10192A),
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color:
                const Color(0xFF1E2D4A),
          ),
        ),
        child: Row(
          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            _buildFirearmImage(
              firearm,
            ),

            const SizedBox(
              width: 14,
            ),

            // ==================================================
            // INFORMATION
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                              0xFF183258),
                      borderRadius:
                          BorderRadius.circular(
                              10),
                    ),
                    child: Text(
                      firearm.firearmType,
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF60A5FA),
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  Text(
                    firearm.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    firearm.manufacturer,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons.public,
                        size: 13,
                        color:
                            Color(0xFF64748B),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          firearm
                              .countryOfOrigin,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Color(
                                    0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    firearm.caliber,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // EDIT / DELETE
            // ==================================================

            Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  icon:
                      const Icon(
                    Icons
                        .edit_outlined,
                    color:
                        Color(0xFF60A5FA),
                    size: 20,
                  ),
                  onPressed: () {
                    _openEditFirearm(
                        firearm);
                  },
                ),

                IconButton(
                  tooltip: 'Delete',
                  icon:
                      const Icon(
                    Icons
                        .delete_outline,
                    color:
                        Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () {
                    _deleteFirearm(
                        firearm);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0B101D),

      // ==========================================================
      // ADD BUTTON
      // ==========================================================

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            const Color(0xFF3B82F6),
        onPressed:
            _openAddFirearm,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                15,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Firearms Catalog',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 24,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            SizedBox(
                                height: 3),
                            Text(
                              'Academic reference database',
                              style:
                                  TextStyle(
                                color:
                                    Color(
                                        0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                                  0xFF183258),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child: Text(
                          '${_allFirearms.length} records',
                          style:
                              const TextStyle(
                            color:
                                Color(
                                    0xFF60A5FA),
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 15),

                  // ==================================================
                  // SEARCH
                  // ==================================================

                  TextField(
                    onChanged: (value) {
                      _searchQuery =
                          value;
                      _applyFilters();
                    },
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                    decoration:
                        InputDecoration(
                      hintText:
                          'Search firearms, manufacturers, caliber...',
                      hintStyle:
                          const TextStyle(
                        color:
                            Color(
                                0xFF64748B),
                        fontSize: 13,
                      ),
                      prefixIcon:
                          const Icon(
                        Icons.search,
                        color:
                            Color(
                                0xFF64748B),
                      ),
                      filled: true,
                      fillColor:
                          const Color(
                              0xFF10192A),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(
                                  0xFF1E2D4A),
                        ),
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(
                                  0xFF1E2D4A),
                        ),
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                        borderSide:
                            const BorderSide(
                          color:
                              Color(
                                  0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 13),

                  // ==================================================
                  // FILTERS
                  // ==================================================

                  SizedBox(
                    height: 36,
                    child:
                        ListView.separated(
                      scrollDirection:
                          Axis.horizontal,
                      itemCount:
                          _filterTypes
                              .length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        width: 8,
                      ),
                      itemBuilder:
                          (context,
                              index) {
                        final type =
                            _filterTypes[
                                index];

                        final selected =
                            _selectedType ==
                                type;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType =
                                  type;
                            });

                            _applyFilters();
                          },
                          child:
                              Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  14,
                              vertical: 8,
                            ),
                            decoration:
                                BoxDecoration(
                              color: selected
                                  ? const Color(
                                      0xFF2563EB)
                                  : const Color(
                                      0xFF10192A),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                              border:
                                  Border.all(
                                color: selected
                                    ? const Color(
                                        0xFF2563EB)
                                    : const Color(
                                        0xFF1E2D4A),
                              ),
                            ),
                            child: Text(
                              type,
                              style:
                                  TextStyle(
                                color: selected
                                    ? Colors
                                        .white
                                    : const Color(
                                        0xFF94A3B8),
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // LIST
            // ==================================================

            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh:
                          _loadFirearms,
                      child: _filteredFirearms
                              .isEmpty
                          ? ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(
                                    height:
                                        100),
                                Center(
                                  child:
                                      Icon(
                                    Icons
                                        .search_off_rounded,
                                    color:
                                        Color(
                                            0xFF475569),
                                    size: 50,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        15),
                                Center(
                                  child:
                                      Text(
                                    'No firearms found',
                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                              0xFF64748B),
                                      fontSize:
                                          15,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView
                              .builder(
                              padding:
                                  const EdgeInsets
                                      .fromLTRB(
                                20,
                                10,
                                20,
                                100,
                              ),
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              itemCount:
                                  _filteredFirearms
                                      .length,
                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                return _buildFirearmCard(
                                  _filteredFirearms[
                                      index],
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}