import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/plot_form_data.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_form_local_storage.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlotFormPage extends StatefulWidget {
  const PlotFormPage({
    super.key,
    required this.plotId,
  });

  final String plotId;

  @override
  State<PlotFormPage> createState() => _PlotFormPageState();
}

class _PlotFormPageState extends State<PlotFormPage> {
  final _formKey = GlobalKey<FormState>();
  final PlotLocalStorage _plotLocalStorage = PlotLocalStorage();
  final PlotFormLocalStorage _plotFormLocalStorage = PlotFormLocalStorage();
  final _ownerName = TextEditingController();
  final _ownerAddress = TextEditingController();
  final _ownershipStartDate = TextEditingController();
  final _previousOwner = TextEditingController();
  final _ownershipThrough = TextEditingController();
  final _operatorName = TextEditingController();
  final _operatorAddress = TextEditingController();
  final _leasePeriod = TextEditingController();
  final _typeOfSeaweed = TextEditingController();
  final _plantingCycle = TextEditingController();
  final _productionCapacity = TextEditingController();
  final _adjacentPlotOwners1 = TextEditingController();
  final _adjacentPlotOwners2 = TextEditingController();
  final _adjacentPlotOwners3 = TextEditingController();
  final _adjacentPlotOwners4 = TextEditingController();
  bool _isSameAsOwner = false;
  bool _hasPreviousOwner = false;
  bool _isLeasedOperator = false;
  bool _isLoading = true;
  bool _isSaving = false;
  SavedPlot? _plot;
  PlotFormData? _savedForm;

  Future<String?> _getCurrentUserId() async {
    final authUserId = FirebaseAuth.instance.currentUser?.uid;
    if (authUserId != null && authUserId.trim().isNotEmpty) {
      return authUserId;
    }

    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('user_id');
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _ownerName.dispose();
    _ownerAddress.dispose();
    _ownershipStartDate.dispose();
    _previousOwner.dispose();
    _ownershipThrough.dispose();
    _operatorName.dispose();
    _operatorAddress.dispose();
    _leasePeriod.dispose();
    _typeOfSeaweed.dispose();
    _plantingCycle.dispose();
    _productionCapacity.dispose();
    _adjacentPlotOwners1.dispose();
    _adjacentPlotOwners2.dispose();
    _adjacentPlotOwners3.dispose();
    _adjacentPlotOwners4.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final plot = await _plotLocalStorage.getPlotById(widget.plotId);
    final savedForm = await _plotFormLocalStorage.getFormByPlotId(widget.plotId);

    if (!mounted) {
      return;
    }

    if (savedForm != null) {
      _ownerName.text = savedForm.ownerName;
      _ownerAddress.text = savedForm.ownerAddress;
      _ownershipStartDate.text = savedForm.ownershipStartDate;
      _previousOwner.text = savedForm.previousOwner;
      _ownershipThrough.text = savedForm.ownershipThrough;
      _operatorName.text = savedForm.operatorName;
      _operatorAddress.text = savedForm.operatorAddress;
      _leasePeriod.text = savedForm.leasePeriod;
      _typeOfSeaweed.text = savedForm.typeOfSeaweed;
      _plantingCycle.text = savedForm.plantingCycle;
      _productionCapacity.text = savedForm.productionCapacity;
      final owners = savedForm.adjacentPlotOwners;
      if (owners.isNotEmpty) _adjacentPlotOwners1.text = owners[0];
      if (owners.length > 1) _adjacentPlotOwners2.text = owners[1];
      if (owners.length > 2) _adjacentPlotOwners3.text = owners[2];
      if (owners.length > 3) _adjacentPlotOwners4.text = owners[3];
      _isSameAsOwner = savedForm.isSameAsOwner;
      _hasPreviousOwner = savedForm.previousOwner.trim().isNotEmpty;
      _isLeasedOperator = savedForm.leasePeriod.trim().isNotEmpty;
    }

    setState(() {
      _plot = plot;
      _savedForm = savedForm;
      _isLoading = false;
    });
  }

  PlotFormData _buildFormData({required bool isSynced}) {
    final now = DateTime.now();
    return PlotFormData(
      plotId: widget.plotId,
      ownerName: _ownerName.text.trim(),
      ownerAddress: _ownerAddress.text.trim(),
      ownershipStartDate: _ownershipStartDate.text.trim(),
      previousOwner: _previousOwner.text.trim(),
      ownershipThrough: _ownershipThrough.text.trim(),
      isSameAsOwner: _isSameAsOwner,
      operatorName: _isSameAsOwner ? _ownerName.text.trim() : _operatorName.text.trim(),
      operatorAddress: _isSameAsOwner ? _ownerAddress.text.trim() : _operatorAddress.text.trim(),
      leasePeriod: _isSameAsOwner ? '' : _leasePeriod.text.trim(),
      typeOfSeaweed: _typeOfSeaweed.text.trim(),
      plantingCycle: _plantingCycle.text.trim(),
      productionCapacity: _productionCapacity.text.trim(),
      adjacentPlotOwners: [
        _adjacentPlotOwners1.text.trim(),
        _adjacentPlotOwners2.text.trim(),
        _adjacentPlotOwners3.text.trim(),
        _adjacentPlotOwners4.text.trim(),
      ].where((owner) => owner.isNotEmpty).toList(),
      createdAt: _savedForm?.createdAt ?? now,
      updatedAt: now,
      isSynced: isSynced,
    );
  }

  Future<void> _saveLocally({
    required bool showFeedback,
    required bool requireValidation,
  }) async {
    if (requireValidation && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final form = _buildFormData(isSynced: false);
      await _plotFormLocalStorage.saveForm(form);
      if (!mounted) {
        return;
      }
      setState(() {
        _savedForm = form;
        _isSaving = false;
      });
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form saved locally')),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving form locally: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (_plot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lahan tidak ditemukan')),
      );
      return;
    }

    final userId = await _getCurrentUserId();
    if (userId == null || userId.trim().isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    await _saveLocally(showFeedback: false, requireValidation: false);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final syncedForm = _buildFormData(isSynced: true);
      final plotPoints = _plot!.points
          .asMap()
          .entries
          .map(
            (entry) => {
              'point_order': entry.key,
              'latitude': entry.value.latitude,
              'longitude': entry.value.longitude,
              'accuracy': entry.value.accuracy,
              'recorded_at': entry.value.recordedAt.millisecondsSinceEpoch,
            },
          )
          .toList();
      final firstPoint = _plot!.points.first;
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final plotDoc = firestore.collection('plots').doc(widget.plotId);
      final plotFormDoc = firestore.collection('plot_forms').doc(widget.plotId);

      batch.set(
        plotDoc,
        {
          'plot_id': widget.plotId,
          'user_id': userId,
          'farmer_id': userId,
          'plot_name': _plot!.name,
          'plot_status': 'submitted',
          'area_square_meters': _plot!.areaSquareMeters,
          'source': _plot!.source,
          'gps_latitude': firstPoint.latitude,
          'gps_longitude': firstPoint.longitude,
          'points': plotPoints,
          'created_at': _plot!.createdAt.millisecondsSinceEpoch,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      batch.set(
        plotFormDoc,
        {
          'plot_id': widget.plotId,
          'user_id': userId,
          'owner_name': syncedForm.ownerName,
          'owner_address': syncedForm.ownerAddress,
          'ownership_start_date': syncedForm.ownershipStartDate,
          'previous_owner': syncedForm.previousOwner,
          'ownership_through': syncedForm.ownershipThrough,
          'is_same_as_owner': syncedForm.isSameAsOwner,
          'operator_name': syncedForm.operatorName,
          'operator_address': syncedForm.operatorAddress,
          'lease_period': syncedForm.leasePeriod,
          'type_of_seaweed': syncedForm.typeOfSeaweed,
          'planting_cycle': syncedForm.plantingCycle,
          'production_capacity': syncedForm.productionCapacity,
          'adjacent_plot_owners': syncedForm.adjacentPlotOwners,
          'status': 'submitted',
          'submitted_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      await _plotFormLocalStorage.updateFormSyncStatus(
        plotId: widget.plotId,
        isSynced: true,
      );
      await _plotLocalStorage.updatePlotSyncStatus(
        plotId: widget.plotId,
        isSynced: true,
      );

      if (!mounted) {
        return;
      }
      final updatedPlot = _plot!.copyWith(
        isSynced: true,
        updatedAt: DateTime.now(),
      );
      setState(() {
        _plot = updatedPlot;
        _savedForm = syncedForm.copyWith(
          isSynced: true,
          updatedAt: DateTime.now(),
        );
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plot and form submitted successfully')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Formulir Lahan'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_plot == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Formulir Lahan'),
        ),
        body: const Center(child: Text('Lahan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Lahan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_plot!.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Area: ${_plot!.areaSquareMeters.toStringAsFixed(2)} m^2'),
                    const SizedBox(height: 8),
                    Text('Vertices: ${_plot!.points.length}/4'),
                    if (_savedForm != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _savedForm!.isSynced
                            ? 'Local status: synced'
                            : 'Local status: saved offline',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerName,
              decoration: const InputDecoration(
                labelText: 'Nama pemilik', //owner name
              ),
              maxLength: 255,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\p{M}'\- ]", unicode: true)),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Owner Name is required';
                }
                return null;
              },
              onChanged: (value) {
                _ownerName.value = _ownerName.value.copyWith(
                  text: value.trimLeft(),
                );
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _ownerAddress,
              decoration: const InputDecoration(
                labelText: 'Alamat pemilik [Street, Desa, Kecamatan, Kabupaten]', //owner address
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Owner Address is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _ownershipStartDate,
              decoration: const InputDecoration(
                labelText: 'Tanggal mulai kepemilikan', //Ownership Start Date
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ownership Start Date is required';
                }
                return null;
              },
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  _ownershipStartDate.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                }
              },
            ),

            const SizedBox(height: 16),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pemilik sebelumnya?'), //previous owner?
              value: _hasPreviousOwner,
              tristate: false,
              onChanged: (value) {
                setState(() {
                  _hasPreviousOwner = value ?? false;
                  if (!_hasPreviousOwner) {
                    _previousOwner.clear();
                  }
                });
              },
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _previousOwner,
              enabled: _hasPreviousOwner,
              decoration: const InputDecoration(
                labelText: 'Nama pemilik sebelumnya', //previous owner name
              ),
              maxLength: 255,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\p{M}'\- ]", unicode: true)),
              ],
              validator: (value) {
                if (_hasPreviousOwner && (value == null || value.trim().isEmpty)) {
                  return 'Previous Owner is required';
                }
                return null;
              },
              onChanged: (value) {
                _previousOwner.value = _previousOwner.value.copyWith(
                  text: value.trimLeft(),
                );
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _ownershipThrough.text.trim().isEmpty
                  ? null
                  : _ownershipThrough.text.trim(),
              decoration: const InputDecoration(
                labelText: 'Kepemilikan melalui', //ownership through
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Owner Through is required';
                }
                return null;
              },
              items: const [
                DropdownMenuItem(value: 'Inherited', child: Text('Diwariskan')),
                DropdownMenuItem(value: 'Purchased', child: Text('Pembelian')),
                DropdownMenuItem(value: 'Leased', child: Text('Disewakan')),
                DropdownMenuItem(value: 'Gifted', child: Text('Hibah')), //grant/gift/donation formally 
                DropdownMenuItem(value: 'Other', child: Text('Lainnya')),
              ],
              onChanged: (value) {
                _ownershipThrough.text = value ?? '';
              },
            ),

            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text('Saya adalah pengelola'), //I am the operator 
              value: _isSameAsOwner,
              tristate: false,
              onChanged: (value) {
                setState(() {
                  _isSameAsOwner = value ?? false;
                  if (_isSameAsOwner) {
                    _operatorName.text = _ownerName.text;
                    _operatorAddress.text = _ownerAddress.text;
                    _isLeasedOperator = false;
                    _leasePeriod.clear();
                  } else {
                    _operatorName.clear();
                    _operatorAddress.clear();
                  }
                });
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _operatorName,
              enabled: !_isSameAsOwner,
              decoration: const InputDecoration(
                labelText: 'Nama pengelola (sama dengan pemilik jika tidak disewa/bagi hasil)', //operator name (same as owner if not leased/shared)
              ),
              maxLength: 255,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\p{M}'\- ]", unicode: true)),
              ],
              validator: (value) {
                if (!_isSameAsOwner && (value == null || value.trim().isEmpty)) {
                  return 'Operator Name is required';
                }
                return null;
              },
              onChanged: (value) {
                _operatorName.value = _operatorName.value.copyWith(
                  text: value.trimLeft(),
                );
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _operatorAddress,
              enabled: !_isSameAsOwner,
              validator: (value) {
                if (!_isSameAsOwner && (value == null || value.trim().isEmpty)) {
                  return 'Operator Address is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Alamat pengelola [Street, Desa, Kecamatan, Kabupaten]', //operator address
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _leasePeriod,
              enabled: !_isSameAsOwner && _isLeasedOperator,
              validator: (value) {
                if (!_isSameAsOwner &&
                    _isLeasedOperator &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Lease Period is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Periode sewa', //lease period
              ),
            ),

            const SizedBox(height: 16),

            if (!_isSameAsOwner) ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pengelola ini menggunakan perjanjian sewa.'), //this operator uses a lease arrangement
                value: _isLeasedOperator,
                tristate: false,
                onChanged: (value) {
                  setState(() {
                    _isLeasedOperator = value ?? false;
                    if (!_isLeasedOperator) {
                      _leasePeriod.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
            ],

            TextFormField(
              controller: _typeOfSeaweed,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Type of Seaweed is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Jenis Rumput Laut yang Ditanam dalam 1 Tahun Terakhir', //Type of Seaweed Planted in the Last 1 Year
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _plantingCycle,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Planting Cycle is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Siklus Tanam Per Tahun', //planting cycle per year
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _productionCapacity,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Production Capacity is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Kapasitas Produksi Per Siklus Tanam (kg)', //Production Capacity Per Planting Cycle (kg)
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adjacentPlotOwners1,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'At least 1 Adjacent Plot Owner is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Pemilik Lahan yang Berbatasan', //Owners of bordering land
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adjacentPlotOwners2,
              decoration: const InputDecoration(
                labelText: 'Pemilik Lahan yang Berbatasan', //Owners of bordering land
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adjacentPlotOwners3,
              decoration: const InputDecoration(
                labelText: 'Pemilik Lahan yang Berbatasan', //Owners of bordering land
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adjacentPlotOwners4,
              decoration: const InputDecoration(
                labelText: 'Pemilik Lahan yang Berbatasan', //Owners of bordering land
              ),
            ),
  
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _saveLocally(
                              showFeedback: true,
                              requireValidation: false,
                            ),
                    child: Text(_isSaving ? 'Menyimpan...' : 'Simpan'), //saving, save
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: Text(_isSaving ? 'Mengirim...' : 'Kirim'), //submitting, submit
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}
