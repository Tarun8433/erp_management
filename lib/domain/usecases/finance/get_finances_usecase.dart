import '../../entities/finance_record.dart';
import '../../repositories/finance_repository.dart';

class GetFinancesUseCase {
  final FinanceRepository repository;

  GetFinancesUseCase(this.repository);

  Future<List<FinanceRecord>> call() => repository.getFinanceRecords();
}
