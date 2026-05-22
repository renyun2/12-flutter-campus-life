import '../../core/api/api_client.dart';
import '../../data/models/models.dart';

class CampusApi {
  CampusApi(this._client);

  final ApiClient _client;

  Future<LoginResult> login(String studentId, String password) async {
    final data = await _client.post('/api/auth/login', body: {
      'studentId': studentId,
      'password': password,
    });
    return LoginResult(
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    await _client.post('/api/auth/logout');
  }

  Future<List<CourseModel>> getCourses() async {
    final data = await _client.get('/api/schedule');
    return (data['courses'] as List)
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CourseModel> getCourse(String id) async {
    final data = await _client.get('/api/schedule/$id');
    return CourseModel.fromJson(data['course'] as Map<String, dynamic>);
  }

  Future<CourseModel> addCourse(Map<String, dynamic> body) async {
    final data = await _client.post('/api/schedule', body: body);
    return CourseModel.fromJson(data['course'] as Map<String, dynamic>);
  }

  Future<({List<String> terms, List<GradeItem> grades})> getGrades() async {
    final data = await _client.get('/api/grades');
    return (
      terms: (data['terms'] as List).cast<String>(),
      grades: (data['grades'] as List)
          .map((e) => GradeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<({String term, double gpa, double totalCredit, List<GradeItem> items})> getTermGrades(
    String term,
  ) async {
    final data = await _client.get('/api/grades/term/${Uri.encodeComponent(term)}');
    return (
      term: data['term'] as String,
      gpa: (data['gpa'] as num).toDouble(),
      totalCredit: (data['totalCredit'] as num).toDouble(),
      items: (data['items'] as List)
          .map((e) => GradeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<({List<BookModel> books, int borrowedCount, int maxBorrow})> getBooks({String? q}) async {
    final data = await _client.get('/api/library', query: q == null ? null : {'q': q});
    return (
      books: (data['books'] as List)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      borrowedCount: data['borrowedCount'] as int,
      maxBorrow: data['maxBorrow'] as int,
    );
  }

  Future<BookModel> getBook(String id) async {
    final data = await _client.get('/api/library/$id');
    return BookModel.fromJson(data['book'] as Map<String, dynamic>);
  }

  Future<List<BorrowRecord>> getBorrowRecords() async {
    final data = await _client.get('/api/library/records');
    return (data['records'] as List)
        .map((e) => BorrowRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> borrowBook(String id) async {
    await _client.post('/api/library/$id/borrow');
  }

  Future<void> renewBook(String recordId) async {
    await _client.post('/api/library/records/$recordId/renew');
  }

  Future<({List<Map<String, String>> canteens, List<DishModel> dishes})> getCanteen() async {
    final data = await _client.get('/api/canteen');
    return (
      canteens: (data['canteens'] as List)
          .map((e) => {'id': e['id'] as String, 'name': e['name'] as String})
          .toList(),
      dishes: (data['dishes'] as List)
          .map((e) => DishModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<DishModel> getDish(String id) async {
    final data = await _client.get('/api/canteen/$id');
    return DishModel.fromJson(data['dish'] as Map<String, dynamic>);
  }

  Future<({double balance, List<CardTransaction> transactions})> getCampusCard({int days = 7}) async {
    final data = await _client.get('/api/campus-card', query: {'days': '$days'});
    return (
      balance: (data['balance'] as num).toDouble(),
      transactions: (data['transactions'] as List)
          .map((e) => CardTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<double> topup(double amount) async {
    final data = await _client.post('/api/campus-card/topup', body: {'amount': amount});
    return (data['balance'] as num).toDouble();
  }

  Future<List<LostFoundItem>> getLostFound({String? type}) async {
    final data = await _client.get('/api/lost-found', query: type == null ? null : {'type': type});
    return (data['items'] as List)
        .map((e) => LostFoundItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> publishLostFound(Map<String, dynamic> body) async {
    await _client.post('/api/lost-found', body: body);
  }

  Future<List<ClubModel>> getClubs() async {
    final data = await _client.get('/api/clubs');
    return (data['clubs'] as List)
        .map((e) => ClubModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ClubModel> getClub(String id) async {
    final data = await _client.get('/api/clubs/$id');
    return ClubModel.fromJson(data['club'] as Map<String, dynamic>);
  }

  Future<void> registerClub(String id) async {
    await _client.post('/api/clubs/$id/register');
  }

  Future<List<MapPoi>> getMapPois() async {
    final data = await _client.get('/api/map');
    return (data['pois'] as List).map((e) => MapPoi.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MarketItem>> getMarket({String? q}) async {
    final data = await _client.get('/api/market', query: q == null ? null : {'q': q});
    return (data['items'] as List)
        .map((e) => MarketItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MarketItem> getMarketItem(String id) async {
    final data = await _client.get('/api/market/$id');
    return MarketItem.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<void> publishMarket(Map<String, dynamic> body) async {
    await _client.post('/api/market', body: body);
  }

  Future<void> favoriteMarket(String id) async {
    await _client.post('/api/market/$id/favorite');
  }

  Future<void> unfavoriteMarket(String id) async {
    await _client.delete('/api/market/$id/favorite');
  }

  Future<void> reportMarket(String id) async {
    await _client.post('/api/market/$id/report');
  }

  Future<List<MessageModel>> getMessages() async {
    final data = await _client.get('/api/messages');
    return (data['messages'] as List)
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, List<Map<String, String>>>> search(String q) async {
    final data = await _client.get('/api/search', query: {'q': q});
    List<Map<String, String>> mapList(String key) => (data[key] as List? ?? [])
        .map((e) => {
              'id': e['id'] as String,
              'title': e['title'] as String,
              'type': e['type'] as String? ?? key,
            })
        .toList();
    return {
      'courses': mapList('courses'),
      'books': mapList('books'),
      'market': mapList('market'),
    };
  }
}
