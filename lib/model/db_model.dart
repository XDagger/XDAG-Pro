import 'package:hive/hive.dart';
part 'db_model.g.dart';

@HiveType(typeId: 1)
class Wallet extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String amount;

  @HiveField(2)
  final String address;

  @HiveField(3)
  bool isDef;

  @HiveField(4)
  bool isBackup;

  Wallet(this.name, this.amount, this.address, this.isDef, this.isBackup);
}

// @HiveType(typeId: 1)
// class Transaction {
//   @HiveField(0)
//   final String time;
//   @HiveField(1)
//   final String amount;
//   @HiveField(3)
//   final String address;
//   @HiveField(4)
//   final String status;
//   @HiveField(5)
//   final String from;
//   @HiveField(6)
//   final String to;
//   @HiveField(7)
//   final int type;
//   @HiveField(8)
//   final double fee;
//   @HiveField(9)
//   final String hash;
//   Transaction({required this.time, required this.amount, required this.address, required this.status, required this.from, required this.to, required this.type, required this.hash, required this.fee});
// }
