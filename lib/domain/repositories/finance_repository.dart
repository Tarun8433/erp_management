import '../entities/finance_record.dart';

abstract class FinanceRepository {
  Future<List<FinanceRecord>> getFinanceRecords();
  Future<void> addRecord(FinanceRecord record);
  Future<void> updateRecord(FinanceRecord record);
  Future<void> deleteRecord(String id);
}
