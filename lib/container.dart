import 'package:lacakind_frontend/data/repositories/auth_repository.dart';
import 'package:lacakind_frontend/data/repositories/client_repository.dart';
import 'package:lacakind_frontend/data/repositories/contract_repository.dart';
import 'package:lacakind_frontend/data/repositories/device_repository.dart';
import 'package:lacakind_frontend/data/repositories/log_repository.dart';
import 'package:lacakind_frontend/data/repositories/repair_repository.dart';

final authRepo     = AuthRepository();
final deviceRepo   = DeviceRepository();
final clientRepo   = ClientRepository();
final contractRepo = ContractRepository();
final logRepo      = LogRepository();
final repairRepo   = RepairRepository();