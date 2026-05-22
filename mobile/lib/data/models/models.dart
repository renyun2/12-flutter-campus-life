class UserModel {
  UserModel({
    required this.id,
    required this.studentId,
    required this.name,
    this.major = '',
    this.grade = '',
  });

  final String id;
  final String studentId;
  final String name;
  final String major;
  final String grade;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        name: json['name'] as String,
        major: json['major'] as String? ?? '',
        grade: json['grade'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'name': name,
        'major': major,
        'grade': grade,
      };
}

class CourseModel {
  CourseModel({
    required this.id,
    required this.name,
    required this.teacher,
    required this.room,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.weeks,
    this.homework = '',
  });

  final String id;
  final String name;
  final String teacher;
  final String room;
  final int dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final List<int> weeks;
  final String homework;

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['id'] as String,
        name: json['name'] as String,
        teacher: json['teacher'] as String? ?? '',
        room: json['room'] as String? ?? '',
        dayOfWeek: json['dayOfWeek'] as int,
        startPeriod: json['startPeriod'] as int,
        endPeriod: json['endPeriod'] as int,
        weeks: (json['weeks'] as List<dynamic>? ?? []).cast<int>(),
        homework: json['homework'] as String? ?? '',
      );
}

class GradeItem {
  GradeItem({
    required this.id,
    required this.term,
    required this.courseName,
    required this.score,
    required this.credit,
  });

  final String id;
  final String term;
  final String courseName;
  final double score;
  final double credit;

  factory GradeItem.fromJson(Map<String, dynamic> json) => GradeItem(
        id: json['id'] as String,
        term: json['term'] as String,
        courseName: json['courseName'] as String,
        score: (json['score'] as num).toDouble(),
        credit: (json['credit'] as num).toDouble(),
      );
}

class BookModel {
  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.location,
    required this.available,
    required this.total,
    this.summary = '',
  });

  final String id;
  final String title;
  final String author;
  final String location;
  final int available;
  final int total;
  final String summary;

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String? ?? '',
        location: json['location'] as String? ?? '',
        available: json['available'] as int? ?? 0,
        total: json['total'] as int? ?? 0,
        summary: json['summary'] as String? ?? '',
      );
}

class BorrowRecord {
  BorrowRecord({
    required this.id,
    required this.bookId,
    required this.title,
    required this.dueDate,
    required this.renewed,
    required this.status,
  });

  final String id;
  final String bookId;
  final String title;
  final String dueDate;
  final bool renewed;
  final String status;

  factory BorrowRecord.fromJson(Map<String, dynamic> json) => BorrowRecord(
        id: json['id'] as String,
        bookId: json['bookId'] as String,
        title: json['title'] as String,
        dueDate: json['dueDate'] as String,
        renewed: json['renewed'] as bool? ?? false,
        status: json['status'] as String? ?? 'active',
      );
}

class DishModel {
  DishModel({
    required this.id,
    required this.canteenId,
    required this.name,
    required this.price,
    required this.rating,
    this.description = '',
    this.nutrition = const {},
  });

  final String id;
  final String canteenId;
  final String name;
  final double price;
  final double rating;
  final String description;
  final Map<String, dynamic> nutrition;

  factory DishModel.fromJson(Map<String, dynamic> json) => DishModel(
        id: json['id'] as String,
        canteenId: json['canteenId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        rating: (json['rating'] as num?)?.toDouble() ?? 4,
        description: json['description'] as String? ?? '',
        nutrition: Map<String, dynamic>.from(json['nutrition'] as Map? ?? {}),
      );
}

class ClubModel {
  ClubModel({
    required this.id,
    required this.name,
    required this.description,
    required this.eventDate,
    required this.location,
    required this.maxMembers,
    required this.registeredCount,
    this.registered = false,
  });

  final String id;
  final String name;
  final String description;
  final String eventDate;
  final String location;
  final int maxMembers;
  final int registeredCount;
  final bool registered;

  factory ClubModel.fromJson(Map<String, dynamic> json) => ClubModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        eventDate: json['eventDate'] as String,
        location: json['location'] as String? ?? '',
        maxMembers: json['maxMembers'] as int? ?? 50,
        registeredCount: json['registeredCount'] as int? ?? 0,
        registered: json['registered'] as bool? ?? false,
      );
}

class MapPoi {
  MapPoi({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.description,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;
  final String description;

  factory MapPoi.fromJson(Map<String, dynamic> json) => MapPoi(
        id: json['id'] as String,
        name: json['name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        description: json['description'] as String? ?? '',
      );
}

class MarketItem {
  MarketItem({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.sellerName,
    this.description = '',
    this.favorited = false,
  });

  final String id;
  final String title;
  final double price;
  final String category;
  final String sellerName;
  final String description;
  final bool favorited;

  factory MarketItem.fromJson(Map<String, dynamic> json) => MarketItem(
        id: json['id'] as String,
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        category: json['category'] as String? ?? '',
        sellerName: json['sellerName'] as String? ?? '',
        description: json['description'] as String? ?? '',
        favorited: json['favorited'] as bool? ?? false,
      );
}

class LostFoundItem {
  LostFoundItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final String status;

  factory LostFoundItem.fromJson(Map<String, dynamic> json) => LostFoundItem(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        status: json['status'] as String? ?? 'open',
      );
}

class MessageModel {
  MessageModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final String createdAt;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: json['type'] as String? ?? 'system',
        read: json['read'] as bool? ?? false,
        createdAt: json['createdAt'] as String? ?? '',
      );
}

class CardTransaction {
  CardTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String type;
  final String description;
  final String createdAt;

  factory CardTransaction.fromJson(Map<String, dynamic> json) => CardTransaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] as String,
        description: json['description'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? '',
      );
}

class LoginResult {
  LoginResult({required this.token, required this.user});

  final String token;
  final UserModel user;
}
