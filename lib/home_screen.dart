import 'package:flutter/material.dart';
import 'bloc_selector/register_screen.dart';
import 'bloc_listener/login_screen.dart';
import 'bloc_consumer/cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TP BLoC'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choisir une partie',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _PartCard(
              number: '1',
              title: 'BlocSelector',
              description: 'Inscription avec visibilité des mots de passe.\nChaque champ se rebuilde indépendamment.',
              color: Colors.deepPurple,
              icon: Icons.tune,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _PartCard(
              number: '2',
              title: 'BlocListener',
              description: 'Login avec authentification simulée.\nBlocBuilder → UI / BlocListener → side effects.',
              color: Colors.indigo,
              icon: Icons.hearing,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _PartCard(
              number: '3',
              title: 'BlocConsumer',
              description: 'Panier e-commerce avec paiement simulé.\nBuilder + Listener combinés en un seul widget.',
              color: Colors.teal,
              icon: Icons.merge_type,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _PartCard({
    required this.number,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partie $number — $title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
