import 'api_service.dart';

class MarketplaceService {
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final result = await ApiService.get('/auth/me.php');
    if (!result.success) throw Exception(result.message);
    return Map<String, dynamic>.from(result.data as Map);
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final result = await ApiService.get('/categories/read.php');
    if (!result.success) throw Exception(result.message);
    return (result.data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getProducts({
    String search = '',
    int? categoryId,
  }) async {
    final query = <String, String>{
      if (search.isNotEmpty) 'search': search,
      if (categoryId != null && categoryId > 0) 'id_kategori': '$categoryId',
    };
    final qs = Uri(queryParameters: query).query;
    final result = await ApiService.get(
      '/products/read.php${qs.isEmpty ? '' : '?$qs'}',
    );
    if (!result.success) throw Exception(result.message);
    return (result.data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<ApiResult> createCategory(String name) =>
      ApiService.post('/categories/create.php', {'nama_kategori': name});

  static Future<ApiResult> createProduct(Map<String, dynamic> product) =>
      ApiService.post('/products/create.php', product);

  static Future<ApiResult> updateProduct(Map<String, dynamic> product) =>
      ApiService.post('/products/update.php', product);

  static Future<ApiResult> deleteProduct(int id) =>
      ApiService.post('/products/delete.php', {'id_produk': id});

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final result = await ApiService.get('/transactions/read.php');
    if (!result.success) throw Exception(result.message);
    return (result.data as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<ApiResult> updateTransactionStatus(int id, String status) =>
      ApiService.post('/transactions/update_status.php', {
        'id_transaksi': id,
        'status': status,
      });

  static Future<ApiResult> checkout(List<Map<String, dynamic>> items) =>
      ApiService.post('/transactions/create.php', {'items': items});

  static Future<Map<String, dynamic>> getDashboardSummary() async {
    final result = await ApiService.get('/dashboard/summary.php');
    if (!result.success) throw Exception(result.message);
    return Map<String, dynamic>.from(result.data as Map);
  }
}
