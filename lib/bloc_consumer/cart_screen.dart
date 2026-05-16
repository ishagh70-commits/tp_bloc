import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/cart_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit(),
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier — BlocConsumer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // BlocConsumer = BlocBuilder + BlocListener combinés
      body: BlocConsumer<CartCubit, CartState>(
        // LISTENER — side effects uniquement
        listener: (context, state) {
          if (state is CartOrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Commande confirmée ! Merci pour votre achat.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const _ConfirmationScreen()),
            );
          } else if (state is CartOrderFailure) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Paiement échoué'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            );
          }
        },
        // BUILDER — UI uniquement
        builder: (context, state) {
          final items = switch (state) {
            CartInitial s => s.items,
            CartLoading s => s.items,
            CartOrderFailure s => s.items,
            CartOrderSuccess() => <Product>[],
          };
          final total = switch (state) {
            CartInitial s => s.total,
            CartLoading s => s.total,
            CartOrderFailure s => s.total,
            CartOrderSuccess() => 0.0,
          };
          final isLoading = state is CartLoading;

          return Column(
            children: [
              // Liste des produits disponibles
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Produits disponibles',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: availableProducts.length,
                  itemBuilder: (context, index) {
                    final product = availableProducts[index];
                    return _ProductCard(
                      product: product,
                      onAdd: isLoading
                          ? null
                          : () => context.read<CartCubit>().addProduct(product),
                    );
                  },
                ),
              ),

              const Divider(height: 24),

              // Contenu du panier
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Mon panier',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    if (items.isNotEmpty)
                      Text(
                        '${items.length} article${items.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Votre panier est vide',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final product = items[index];
                          return ListTile(
                            leading: Text(product.emoji,
                                style: const TextStyle(fontSize: 28)),
                            title: Text(product.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${product.price.toStringAsFixed(2)} MRU',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                if (!isLoading)
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        color: Colors.red),
                                    onPressed: () => context
                                        .read<CartCubit>()
                                        .removeProduct(product),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Zone total + bouton commander (BUILDER gère le loading)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        // BUILDER affiche le total dynamiquement
                        Text(
                          '${total.toStringAsFixed(2)} MRU',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (total > 10000)
                      const Text(
                        '⚠️ Total > 10 000 MRU : le paiement sera refusé (test)',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading || items.isEmpty
                            ? null
                            : () => context.read<CartCubit>().commander(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        // BUILDER affiche le spinner pendant le loading
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Commander',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAdd;

  const _ProductCard({required this.product, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(product.emoji, style: const TextStyle(fontSize: 28)),
              Text(product.name,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              Text('${product.price.toStringAsFixed(2)} MRU',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmationScreen extends StatelessWidget {
  const _ConfirmationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        backgroundColor: Colors.green.shade100,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Commande confirmée !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Votre commande a bien été enregistrée.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Retour au panier'),
            ),
          ],
        ),
      ),
    );
  }
}
