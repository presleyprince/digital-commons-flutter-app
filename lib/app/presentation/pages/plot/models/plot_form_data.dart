class PlotFormData {
  final String plotId;
  final String ownerName;
  final String ownerAddress;
  final String ownershipStartDate;
  final String previousOwner;
  final String ownershipThrough;
  final bool isSameAsOwner;
  final String operatorName;
  final String operatorAddress;
  final String leasePeriod;
  final String typeOfSeaweed;
  final String plantingCycle;
  final String productionCapacity;
  final List<String> adjacentPlotOwners;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  const PlotFormData({
    required this.plotId,
    required this.ownerName,
    required this.ownerAddress,
    required this.ownershipStartDate,
    required this.previousOwner,
    required this.ownershipThrough,
    required this.isSameAsOwner,
    required this.operatorName,
    required this.operatorAddress,
    required this.leasePeriod,
    required this.typeOfSeaweed,
    required this.plantingCycle,
    required this.productionCapacity,
    required this.adjacentPlotOwners,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });

  Map<String, Object?> toMap() {
    return {
      'plot_id': plotId,
      'owner_name': ownerName,
      'owner_address': ownerAddress,
      'ownership_start_date': ownershipStartDate,
      'previous_owner': previousOwner,
      'ownership_through': ownershipThrough,
      'is_same_as_owner': isSameAsOwner ? 1 : 0,
      'operator_name': operatorName,
      'operator_address': operatorAddress,
      'lease_period': leasePeriod,
      'type_of_seaweed': typeOfSeaweed,
      'planting_cycle': plantingCycle,
      'production_capacity': productionCapacity,
      'adjacent_plot_owners': adjacentPlotOwners.join('\n'),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory PlotFormData.fromMap(Map<String, Object?> map) {
    final ownersText = (map['adjacent_plot_owners'] as String?) ?? '';
    return PlotFormData(
      plotId: map['plot_id'] as String,
      ownerName: (map['owner_name'] as String?) ?? '',
      ownerAddress: (map['owner_address'] as String?) ?? '',
      ownershipStartDate: (map['ownership_start_date'] as String?) ?? '',
      previousOwner: (map['previous_owner'] as String?) ?? '',
      ownershipThrough: (map['ownership_through'] as String?) ?? '',
      isSameAsOwner: ((map['is_same_as_owner'] as int?) ?? 0) == 1,
      operatorName: (map['operator_name'] as String?) ?? '',
      operatorAddress: (map['operator_address'] as String?) ?? '',
      leasePeriod: (map['lease_period'] as String?) ?? '',
      typeOfSeaweed: (map['type_of_seaweed'] as String?) ?? '',
      plantingCycle: (map['planting_cycle'] as String?) ?? '',
      productionCapacity: (map['production_capacity'] as String?) ?? '',
      adjacentPlotOwners: ownersText.isEmpty
          ? const <String>[]
          : ownersText.split('\n').where((owner) => owner.trim().isNotEmpty).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isSynced: ((map['is_synced'] as int?) ?? 0) == 1,
    );
  }

  PlotFormData copyWith({
    String? plotId,
    String? ownerName,
    String? ownerAddress,
    String? ownershipStartDate,
    String? previousOwner,
    String? ownershipThrough,
    bool? isSameAsOwner,
    String? operatorName,
    String? operatorAddress,
    String? leasePeriod,
    String? typeOfSeaweed,
    String? plantingCycle,
    String? productionCapacity,
    List<String>? adjacentPlotOwners,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return PlotFormData(
      plotId: plotId ?? this.plotId,
      ownerName: ownerName ?? this.ownerName,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      ownershipStartDate: ownershipStartDate ?? this.ownershipStartDate,
      previousOwner: previousOwner ?? this.previousOwner,
      ownershipThrough: ownershipThrough ?? this.ownershipThrough,
      isSameAsOwner: isSameAsOwner ?? this.isSameAsOwner,
      operatorName: operatorName ?? this.operatorName,
      operatorAddress: operatorAddress ?? this.operatorAddress,
      leasePeriod: leasePeriod ?? this.leasePeriod,
      typeOfSeaweed: typeOfSeaweed ?? this.typeOfSeaweed,
      plantingCycle: plantingCycle ?? this.plantingCycle,
      productionCapacity: productionCapacity ?? this.productionCapacity,
      adjacentPlotOwners: adjacentPlotOwners ?? this.adjacentPlotOwners,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
