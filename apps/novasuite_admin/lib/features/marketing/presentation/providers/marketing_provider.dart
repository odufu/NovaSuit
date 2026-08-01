import 'package:flutter/material.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../../domain/usecases/fetch_campaigns_usecase.dart';

class MarketingProvider extends ChangeNotifier {
  final FetchCampaignsUseCase fetchCampaignsUseCase;

  List<AdCampaignModel> _campaigns = [];
  double _totalMarketerBudget = 3500000.0;
  bool _isLoading = false;
  String? _errorMessage;

  MarketingProvider({required this.fetchCampaignsUseCase});

  List<AdCampaignModel> get campaigns => _campaigns;
  double get totalMarketerBudget => _totalMarketerBudget;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCampaigns({required String companyId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _campaigns = await fetchCampaignsUseCase.execute(companyId: companyId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void fundMarketerBudget(double amount) {
    _totalMarketerBudget += amount;
    notifyListeners();
  }
}
