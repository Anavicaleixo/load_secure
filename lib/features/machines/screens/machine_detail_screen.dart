import 'package:flutter/material.dart';

/// Tela de detalhe de uma máquina específica.
/// TODO: Implementar UI
class MachineDetailScreen extends StatefulWidget {
  final String machineId;

  const MachineDetailScreen({super.key, required this.machineId});

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Machine Detail Screen [${widget.machineId}] — TODO')),
    );
  }
}
