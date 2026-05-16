import 'package:flutter_bloc/flutter_bloc.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String emoji;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.emoji,
  });
}

const availableProducts = [
  Product(id: '1', name: 'Casque Audio', price: 79.99, emoji: '🎧'),
  Product(id: '2', name: 'Clavier Mécanique', price: 129.99, emoji: '⌨️'),
  Product(id: '3', name: 'Souris Gamer', price: 59.99, emoji: '🖱️'),
  Product(id: '4', name: 'Webcam HD', price: 89.99, emoji: '📷'),
];

sealed class CartState {}

class CartInitial extends CartState {
  final List<Product> items;
  final double total;

  CartInitial({this.items = const [], this.total = 0});
}

class CartLoading extends CartState {
  final List<Product> items;
  final double total;

  CartLoading({required this.items, required this.total});
}

class CartOrderSuccess extends CartState {}

class CartOrderFailure extends CartState {
  final String message;
  final List<Product> items;
  final double total;

  CartOrderFailure({
    required this.message,
    required this.items,
    required this.total,
  });
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  List<Product> get _currentItems => switch (state) {
        CartInitial s => s.items,
        CartLoading s => s.items,
        CartOrderFailure s => s.items,
        CartOrderSuccess() => [],
      };

  double get _currentTotal => switch (state) {
        CartInitial s => s.total,
        CartLoading s => s.total,
        CartOrderFailure s => s.total,
        CartOrderSuccess() => 0,
      };

  void addProduct(Product product) {
    final updated = [..._currentItems, product];
    final total = updated.fold(0.0, (sum, p) => sum + p.price);
    emit(CartInitial(items: updated, total: total));
  }

  void removeProduct(Product product) {
    final updated = List<Product>.from(_currentItems)
      ..removeWhere((p) => p.id == product.id);
    final total = updated.fold(0.0, (sum, p) => sum + p.price);
    emit(CartInitial(items: updated, total: total));
  }

  Future<void> commander() async {
    if (_currentItems.isEmpty) return;

    final items = _currentItems;
    final total = _currentTotal;

    emit(CartLoading(items: items, total: total));

    // Simulation appel API paiement
    await Future.delayed(const Duration(seconds: 2));

    // Simule un échec si le total dépasse 250€
    if (total > 250) {
      emit(CartOrderFailure(
        message: 'Paiement refusé : limite dépassée (250€ max).',
        items: items,
        total: total,
      ));
    } else {
      emit(CartOrderSuccess());
    }
  }

  void reset() => emit(CartInitial());
}
