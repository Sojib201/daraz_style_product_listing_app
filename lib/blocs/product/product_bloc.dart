// lib/blocs/product/product_bloc.dart
//
// One ProductBloc instance is created per tab. Each bloc independently
// loads and caches its category's products, making tab-switching instant
// after the first load without any shared mutable state.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/product.dart';
import '../../repositories/api_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiRepository _repo;

  ProductBloc(this._repo) : super(const ProductInitial()) {
    on<ProductFetchRequested>(_onFetch);
    on<ProductRefreshRequested>(_onRefresh);
  }

  Future<void> _onFetch(
    ProductFetchRequested event,
    Emitter<ProductState> emit,
  ) async {
    // If already loaded and same category, skip network call.
    if (state is ProductLoaded &&
        (state as ProductLoaded).category == event.category) return;

    emit(const ProductLoading());
    await _load(event.category, emit);
  }

  Future<void> _onRefresh(
    ProductRefreshRequested event,
    Emitter<ProductState> emit,
  ) async {
    // Keep existing data visible while refreshing (no full spinner).
    await _load(event.category, emit);
  }

  Future<void> _load(String? category, Emitter<ProductState> emit) async {
    try {
      final products = category == null
          ? await _repo.getAllProducts()
          : await _repo.getProductsByCategory(category);
      emit(ProductLoaded(products: products, category: category));
    } catch (e) {
      emit(ProductError(e.toString(), category: category));
    }
  }
}
