import '../../domain/entities/finance_record.dart';
import '../../domain/repositories/finance_repository.dart';
import '../models/finance_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  @override
  Future<List<FinanceRecord>> getFinanceRecords() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(15, (i) => FinanceModel.dummy(i));
  }

  @override
  Future<void> addRecord(FinanceRecord record) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> updateRecord(FinanceRecord record) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> deleteRecord(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
