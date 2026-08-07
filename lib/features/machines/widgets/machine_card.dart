import 'package:flutter/material.dart';
import '../models/machine_model.dart';

/// Card de máquina para exibição em lista.
/// TODO: Implementar UI
class MachineCard extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback? onTap;

  const MachineCard({
    super.key,
    required this.machine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(machine.name),
        subtitle: Text(machine.status.label),
      ),
    );
  }
}
