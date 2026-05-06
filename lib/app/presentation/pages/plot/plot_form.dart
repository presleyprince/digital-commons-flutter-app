import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlotFormPage extends StatefulWidget {
  const PlotFormPage({super.key});

  @override
  State<PlotFormPage> createState() => _PlotFormPageState();
}

class _PlotFormPageState extends State<PlotFormPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plot Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _ownerName,
              decoration: const InputDecoration(
                labelText: 'Owner Name',
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
                labelText: 'Owner Address [Street, Desa, Kecamatan, Kabupaten]',
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
                labelText: 'Ownership Start Date',
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

            TextFormField(
              controller: _previousOwner,
              decoration: const InputDecoration(
                labelText: 'Previous Owner',
              ),
              maxLength: 255,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\p{M}'\- ]", unicode: true)),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
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
              decoration: const InputDecoration(
                labelText: 'Ownership Through',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Owner Through is required';
                }
                return null;
              },
              items: const [
                DropdownMenuItem(value: 'Inherited', child: Text('Inherited')),
                DropdownMenuItem(value: 'Purchased', child: Text('Purchased')),
                DropdownMenuItem(value: 'Leased', child: Text('Leased')),
                DropdownMenuItem(value: 'Gifted', child: Text('Gifted')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                _ownershipThrough.text = value ?? '';
              },
            ),

            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text('I am the Operator'),
              value: _isSameAsOwner,
              tristate: false,
              onChanged: (value) {
                setState(() {
                  _isSameAsOwner = value ?? false;
                  if (_isSameAsOwner) {
                    _operatorName.text = _ownerName.text;
                    _operatorAddress.text = _ownerAddress.text;
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
                labelText: 'Operator Name (same as owner if not leased/shared)',
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
                labelText: 'Operator Address [Street, Desa, Kecamatan, Kabupaten]',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _leasePeriod,
              enabled: !_isSameAsOwner,
              validator: (value) {
                if (!_isSameAsOwner && (value == null || value.trim().isEmpty)) {
                  return 'Lease Period is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Lease Period',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _typeOfSeaweed,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Type of Seaweed is required';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Type of Seaweed Planted in the Last 1 Year',
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
                labelText: 'Planting Cycle Per Year',
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
                labelText: 'Production Capacity Per Planting Cycle (kg)',
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
                labelText: 'Adjacent Plot Owners',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adjacentPlotOwners2,
              decoration: const InputDecoration(
                labelText: 'Adjacent Plot Owners',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adjacentPlotOwners3,
              decoration: const InputDecoration(
                labelText: 'Adjacent Plot Owners',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _adjacentPlotOwners4,
              decoration: const InputDecoration(
                labelText: 'Adjacent Plot Owners',
              ),
            ),
  
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('plot_forms').add({
                    'owner_name': _ownerName.text.trim(),
                    'owner_address': _ownerAddress.text.trim(),
                    'ownership_start_date': _ownershipStartDate.text,
                    'previous_owner': _previousOwner.text.trim(),
                    'ownership_through': _ownershipThrough.text,
                    'operator_name': _isSameAsOwner ? _ownerName.text.trim() : _operatorName.text.trim(),
                    'operator_address': _isSameAsOwner ? _ownerAddress.text.trim() : _operatorAddress.text.trim(),
                    'lease_period': _leasePeriod.text.trim(),
                    'type_of_seaweed': _typeOfSeaweed.text.trim(),
                    'planting_cycle': _plantingCycle.text.trim(),
                    'production_capacity': _productionCapacity.text.trim(),
                    'adjacent_plot_owners': [
                      _adjacentPlotOwners1.text.trim(),
                      _adjacentPlotOwners2.text.trim(),
                      _adjacentPlotOwners3.text.trim(),
                      _adjacentPlotOwners4.text.trim(),
                    ].where((e) => e.isNotEmpty).toList(),
                    'submitted_at': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Form submitted successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error submitting form: $e')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}