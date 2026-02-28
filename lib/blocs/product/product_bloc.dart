import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/product.dart';
import '../../repositories/api_repository.dart';
part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiRepository _repo;
  final String? category;

  final List<Product> _fullList = [];

  ProductBloc(this._repo, {this.category})
      : super(const ProductInitial()) {
    on<ProductFetchRequested>(_onFetch);
    on<ProductRefreshRequested>(_onRefresh);
    on<ProductSearchChanged>(_onSearchChanged);
  }

  Future<void> _onFetch(
      ProductFetchRequested _, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) return;
    emit(const ProductLoading());
    await _load(emit);
  }

  Future<void> _onRefresh(
      ProductRefreshRequested _, Emitter<ProductState> emit) async {
    emit(const ProductLoading());
    await _load(emit);
  }

  void _onSearchChanged(
      ProductSearchChanged event, Emitter<ProductState> emit) {
    final query = event.query.trim().toLowerCase();

    final filtered = query.isEmpty
        ? _fullList
        : _fullList.where((p) {
      return p.title.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
    }).toList();

    emit(ProductLoaded(
      products: filtered,
      searchQuery: query,
    ));
  }

  Future<void> _load(Emitter<ProductState> emit) async {
    try {
      final products = category == null
          ? await _repo.getAllProducts()
          : await _repo.getByCategory(category!);

      _fullList..clear()..addAll(products);

      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}

// class ProductBloc extends Bloc<ProductEvent, ProductState> {
//   final ApiRepository _repo;
//   final String? category;
//
//   ProductBloc(this._repo, {this.category}) : super(const ProductInitial()) {
//     on<ProductFetchRequested>(_onFetch);
//     on<ProductRefreshRequested>(_onRefresh);
//   }
//
//   Future<void> _onFetch(
//       ProductFetchRequested _, Emitter<ProductState> emit) async {
//     // Already loaded → do nothing (instant tab switch, no re-fetch).
//     if (state is ProductLoaded) return;
//     emit(const ProductLoading());
//     await _load(emit);
//   }
//
//   Future<void> _onRefresh(
//       ProductRefreshRequested _, Emitter<ProductState> emit) async {
//     // Refresh always re-fetches regardless of current state.
//     await _load(emit);
//   }
//
//   Future<void> _load(Emitter<ProductState> emit) async {
//     try {
//       final products = category == null
//           ? await _repo.getAllProducts()
//           : await _repo.getByCategory(category!);
//       emit(ProductLoaded(products: products));
//     } catch (e) {
//       emit(ProductError(e.toString()));
//     }
//   }
// }
