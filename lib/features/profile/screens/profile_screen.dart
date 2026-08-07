import 'package:flutter/material.dart';

/// Tela de perfil do usuário logado.
/// TODO: Implementar UI
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile Screen — TODO')),
    );
  }
}
