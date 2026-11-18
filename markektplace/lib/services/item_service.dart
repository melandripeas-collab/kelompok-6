import '../models/item.dart';
import 'api_service.dart';

class ItemService {
  static Future<List<Item>> fetch({String search = '', int? categoryId}) async {
    final q = <String, String>{
      if (search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': '$categoryId',
    };
    final qs = Uri(queryParameters: q).query;
    final res = await ApiService.get(
      '/items/read.php${qs.isEmpty ? '' : '?$qs'}',
    );
    if (!res.success) throw Exception(res.message);
    return (res.data as List).map((e) => Item.fromJson(e)).toList();
  }
}
