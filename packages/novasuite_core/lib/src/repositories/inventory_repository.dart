import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory.dart';

class InventoryRepository {
  final SupabaseClient _client;

  InventoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch all warehouses for a tenant company
  Future<List<WarehouseModel>> fetchWarehouses(String companyId) async {
    final response = await _client
        .from('warehouses')
        .select()
        .eq('company_id', companyId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => WarehouseModel.fromMap(json)).toList();
  }

  /// Create Inter-Warehouse Stock Transfer Waybill
  Future<StockTransferModel> createStockTransfer({
    required String companyId,
    required String sourceWarehouseId,
    required String destinationWarehouseId,
    required String initiatedByUserId,
    required String waybillNumber,
    String? notes,
  }) async {
    final response = await _client
        .from('stock_transfers')
        .insert({
          'company_id': companyId,
          'waybill_number': waybillNumber,
          'source_warehouse_id': sourceWarehouseId,
          'destination_warehouse_id': destinationWarehouseId,
          'initiated_by_user_id': initiatedByUserId,
          'status': 'dispatched',
          'dispatch_date': DateTime.now().toIso8601String(),
          'notes': notes,
        })
        .select()
        .single();

    return StockTransferModel.fromMap(response);
  }

  /// Confirm Stock Transfer Receipt & Restock Destination Warehouse
  Future<StockTransferModel> confirmStockReceipt({
    required String transferId,
    required String receivedByUserId,
  }) async {
    final response = await _client
        .from('stock_transfers')
        .update({
          'status': 'completed',
          'received_by_user_id': receivedByUserId,
          'received_date': DateTime.now().toIso8601String(),
        })
        .eq('id', transferId)
        .select()
        .single();

    return StockTransferModel.fromMap(response);
  }
}
