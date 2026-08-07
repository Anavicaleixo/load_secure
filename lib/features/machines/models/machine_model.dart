import '../../../core/constants/app_constants.dart';

/// Status possíveis de uma máquina industrial.
enum MachineStatus { online, offline, maintenance, alert }

extension MachineStatusExtension on MachineStatus {
  String get label {
    switch (this) {
      case MachineStatus.online:      return 'Online';
      case MachineStatus.offline:     return 'Offline';
      case MachineStatus.maintenance: return 'Manutenção';
      case MachineStatus.alert:       return 'Alerta';
    }
  }

  static MachineStatus fromString(String value) {
    switch (value) {
      case AppConstants.statusOnline:      return MachineStatus.online;
      case AppConstants.statusOffline:     return MachineStatus.offline;
      case AppConstants.statusMaintenance: return MachineStatus.maintenance;
      case AppConstants.statusAlert:       return MachineStatus.alert;
      default:                             return MachineStatus.offline;
    }
  }
}

/// Modelo de máquina/equipamento industrial.
class MachineModel {
  final String id;
  final String name;
  final String type;
  final String sector;
  final MachineStatus status;
  final double efficiency;       // 0.0 a 100.0
  final double temperature;      // em graus Celsius
  final int upTimeMinutes;
  final DateTime lastMaintenance;
  final String? imageUrl;

  const MachineModel({
    required this.id,
    required this.name,
    required this.type,
    required this.sector,
    required this.status,
    required this.efficiency,
    required this.temperature,
    required this.upTimeMinutes,
    required this.lastMaintenance,
    this.imageUrl,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      id:               json['id'] as String,
      name:             json['name'] as String,
      type:             json['type'] as String,
      sector:           json['sector'] as String,
      status:           MachineStatusExtension.fromString(json['status'] as String),
      efficiency:       (json['efficiency'] as num).toDouble(),
      temperature:      (json['temperature'] as num).toDouble(),
      upTimeMinutes:    json['up_time_minutes'] as int,
      lastMaintenance:  DateTime.parse(json['last_maintenance'] as String),
      imageUrl:         json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':               id,
      'name':             name,
      'type':             type,
      'sector':           sector,
      'status':           status.name,
      'efficiency':       efficiency,
      'temperature':      temperature,
      'up_time_minutes':  upTimeMinutes,
      'last_maintenance': lastMaintenance.toIso8601String(),
      'image_url':        imageUrl,
    };
  }

  MachineModel copyWith({
    String? id,
    String? name,
    String? type,
    String? sector,
    MachineStatus? status,
    double? efficiency,
    double? temperature,
    int? upTimeMinutes,
    DateTime? lastMaintenance,
    String? imageUrl,
  }) {
    return MachineModel(
      id:               id ?? this.id,
      name:             name ?? this.name,
      type:             type ?? this.type,
      sector:           sector ?? this.sector,
      status:           status ?? this.status,
      efficiency:       efficiency ?? this.efficiency,
      temperature:      temperature ?? this.temperature,
      upTimeMinutes:    upTimeMinutes ?? this.upTimeMinutes,
      lastMaintenance:  lastMaintenance ?? this.lastMaintenance,
      imageUrl:         imageUrl ?? this.imageUrl,
    );
  }
}
