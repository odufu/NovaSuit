import 'package:flutter/foundation.dart';
import 'package:novasuite_core/novasuite_core.dart';

class OmnichannelChatProvider extends ChangeNotifier {
  final OmnichannelRepository _repository;

  OmnichannelChatProvider({OmnichannelRepository? repository})
      : _repository = repository ?? OmnichannelRepository();

  ConversationModel? _activeConversation;
  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String _selectedChannelFilter = 'All'; // 'All', 'whatsapp', 'voice_call', 'sms'
  String _draftText = '';

  ConversationModel? get activeConversation => _activeConversation;
  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String get selectedChannelFilter => _selectedChannelFilter;
  String get draftText => _draftText;

  List<ChatMessageModel> get filteredMessages {
    if (_selectedChannelFilter == 'All') return _messages;
    return _messages
        .where((m) => m.channel.value == _selectedChannelFilter || m.channel.name == _selectedChannelFilter)
        .toList();
  }

  void setChannelFilter(String filter) {
    _selectedChannelFilter = filter;
    notifyListeners();
  }

  void updateDraftText(String text) {
    _draftText = text;
  }

  Future<void> loadConversationForOrder({
    required String companyId,
    required String orderId,
    required String repId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _activeConversation = await _repository.fetchOrCreateConversation(
        companyId: companyId,
        orderId: orderId,
        repId: repId,
      );

      _messages = await _repository.fetchMessages(_activeConversation!.id);
    } catch (_) {
      // Offline fallback
      _activeConversation = _repository.getMockConversation(orderId: orderId, repId: repId);
      _messages = _repository.getMockMessages(_activeConversation!.id);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendOutboundMessage({
    required String repId,
    required String content,
    CommChannelType channel = CommChannelType.whatsapp,
    String? mediaUrl,
    String? mediaType,
    List<String> interactiveButtons = const [],
  }) async {
    if (content.trim().isEmpty || _activeConversation == null) return;

    final newMsg = await _repository.sendMessage(
      conversationId: _activeConversation!.id,
      senderId: repId,
      content: content,
      channel: channel,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      interactiveButtons: interactiveButtons,
    );

    _messages.add(newMsg);
    _draftText = '';
    notifyListeners();
  }

  Future<void> triggerQuickTemplate({
    required String repId,
    required String templateName,
    required String customerName,
    required String orderNumber,
    required double totalAmount,
  }) async {
    String content = '';
    List<String> buttons = [];

    if (templateName == 'confirm_order') {
      content = 'Hello $customerName! 👋 Thank you for your order #$orderNumber (₦${totalAmount.toStringAsFixed(0)}). Please confirm your delivery address:';
      buttons = ['Confirm Order ✅', 'Reschedule Delivery 📅'];
    } else if (templateName == 'dispatch_alert') {
      content = '🚚 Dispatch Alert: Your order #$orderNumber is out for delivery via NovaExpress. Please stay tuned!';
      buttons = ['Track Package 📦'];
    } else {
      content = 'Hello $customerName! This is your NovaCare Customer Service representative checking in.';
    }

    await sendOutboundMessage(
      repId: repId,
      content: content,
      channel: CommChannelType.whatsapp,
      interactiveButtons: buttons,
    );
  }
}
