import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController personalNumberController = TextEditingController();

  Future<void> _register() async {
    final String name = nameController.text.trim();
    final String personalNumber = personalNumberController.text.trim();

    if (name.isEmpty || personalNumber.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fyll i alla fält")),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('persons')
          .insert({'name': name, 'personal_number': personalNumber})
          .select();

      if (!mounted) return;
    
    if ((response.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrering misslyckades")),
      );
      
       } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrering lyckades")),
      );
      Navigator.pop(context);
    }
  } catch (error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Fel vid registrering: $error"), duration: const Duration(seconds: 4),),
      
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrera dig'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Fullständigt namn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: personalNumberController,
              decoration: const InputDecoration(
                labelText: 'Personnummer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Registrera'),
            ),
          ],
        ),
      ),
    );
  }
}