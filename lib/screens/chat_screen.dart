import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category_data.dart';
import '../services/transaction_service.dart';
import '../db/database_helper.dart';
import '../widgets/scribble_theme.dart';
import 'manual_entry_screen.dart';
import 'transaction_list_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TransactionService _service = TransactionService();
  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _addEunuchMessage(
      '皇上驾到！奴才给皇上请安。'
      '\n\n皇上只管跟奴才说花了多少钱，奴才给您记着。'
      '\n\n比如：'午餐吃了28''打车花了35''这个月吃饭花了多少'',
      '\n或者点下面"记一笔"自己写也行。',
    );
  }

  void _addEunuchMessage(String text) {
    setState(() => _messages.add(ChatMessage(text: text, isUser: false)));
    _scrollDown();
  }

  void _addUserMessage(String text) {
    setState(() => _messages.add(ChatMessage(text: text, isUser: true)));
    _scrollDown();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _isProcessing = true);

    _addUserMessage(text);
    _controller.clear();

    final lowerText = text.toLowerCase();

    // Check for query-like messages
    if (lowerText.contains('多少') || lowerText.contains('花了') || lowerText.contains('还剩') || lowerText.contains('统计')) {
      await _handleQuery(text);
    } else {
      await _handleTransaction(text);
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _handleTransaction(String text) async {
    final result = CategoryData.parseTransaction(text);

    if (!result.isValid) {
      _addEunuchMessage(
        '回皇上，奴才愚钝，没听明白花了多少银子……'
        '\n\n皇上能不能再说一遍，带个数儿？'
        '\n比如 "打车28" 或 "吃饭花了45"',
      );
      return;
    }

    final type = result.isIncome ? TransactionType.income : TransactionType.expense;
    await _service.addTransaction(
      category: result.category,
      amount: result.amount,
      type: type,
      note: text,
    );

    final typeWord = type == TransactionType.expense ? '花了' : '收入';
    final categoryInfo = CategoryData.getInfo(result.category);
    final emoji = categoryInfo != null ? _getEmoji(result.category) : '';

    if (type == TransactionType.expense) {
      _addEunuchMessage(
        '嗻！奴才记下了。'
        '\n\n$emoji $result.category  ${result.amount.toStringAsFixed(0)} 两银子，奴才已登记上册。'
        '\n\n皇上还有别的要记吗？',
      );
    } else {
      _addEunuchMessage(
        '恭喜皇上！'
        '\n\n$emoji $result.category 入账 ${result.amount.toStringAsFixed(0)} 两，奴才已记入内库。'
        '\n\n皇上还有吩咐吗？',
      );
    }

    // Auto-show recent spending if expense
    if (type == TransactionType.expense) {
      final todayTotal = await _service.getTodayTransactions();
      final todaySum = todayTotal
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);
      if (todaySum > 0) {
        _addEunuchMessage(
          '回皇上，今日至今已支出 ${todaySum.toStringAsFixed(0)} 两银子。',
        );
      }
    }
  }

  Future<void> _handleQuery(String text) async {
    final now = DateTime.now();
    final monthTotal = await _service.getMonthExpense(now.year, now.month);
    final todayTotal = await _service.getTodayTransactions();
    final todaySum = todayTotal
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final monthIncome = await _service.getMonthIncome(now.year, now.month);

    if (text.contains('今天')) {
      _addEunuchMessage(
        '回皇上，今日支出 $todaySum 两银子。'
        '\n\n具体账目：'
        '\n${_formatTodayTransactions(todayTotal)}',
      );
    } else if (text.contains('月') || text.contains('这个月')) {
      _addEunuchMessage(
        '回皇上，本月支出共 ${monthTotal.toStringAsFixed(0)} 两。'
        '\n收入共 ${monthIncome.toStringAsFixed(0)} 两。'
        '\n结余 ${(monthIncome - monthTotal).toStringAsFixed(0)} 两。'
        '\n\n要看看详细分类吗？',
      );
    } else {
      _addEunuchMessage(
        '皇上问的是这个月？到今天为止支出 $monthTotal 两，入账 $monthIncome 两。'
        '\n\n皇上想看哪天的账？跟奴才说就行。',
      );
    }
  }

  String _formatTodayTransactions(List<TransactionModel> txs) {
    if (txs.isEmpty) return '今日尚无账目。';
    final expenseTxs = txs.where((t) => t.type == TransactionType.expense).toList();
    if (expenseTxs.isEmpty) return '今日尚无支出。';
    return expenseTxs
        .map((t) => '  ${_getEmoji(t.category)} ${t.category}  ${t.amount.toStringAsFixed(0)} 两')
        .join('\n');
  }

  String _getEmoji(String category) {
    final map = {
      '早餐': '🥟', '午餐': '🍜', '晚餐': '🍛', '零食': '🍪', '水果': '🍎',
      '外卖': '🛵', '公交': '🚌', '地铁': '🚇', '打车': '🚕', '加油': '⛽',
      '购物': '🛒', '网购': '📦', '服装': '👗', '数码': '📱',
      '房租': '🏠', '水电': '💡', '日用品': '🧻',
      '电影': '🎬', '游戏': '🎮', '运动': '🏃', '医疗': '🏥', '学习': '📚',
      '红包': '🧧', '工资': '💰', '兼职': '💼', '理财': '📈', '其他': '📝',
    };
    return map[category] ?? '📝';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScribbleTheme.primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildChatList()),
            _buildInputBar(),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: ScribbleTheme.primaryBg,
        border: Border(
          bottom: BorderSide(color: ScribbleTheme.scribbleLine.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ScribbleTheme.accent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ScribbleTheme.scribbleLine.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Text('内', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('内务府', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ScribbleTheme.textPrimary)),
              const SizedBox(height: 2),
              Text('皇上请吩咐', style: TextStyle(fontSize: 12, color: ScribbleTheme.textSecondary)),
            ],
          ),
          const Spacer(),
          Icon(Icons.more_horiz, color: ScribbleTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ScribbleTheme.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('奴', style: TextStyle(fontSize: 12, color: Colors.white))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? ScribbleTheme.accent.withValues(alpha: 0.15) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: ScribbleTheme.scribbleLine.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 15,
                  color: ScribbleTheme.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: ScribbleTheme.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('奴', style: TextStyle(fontSize: 12, color: Colors.white))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: ScribbleTheme.accent, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: ScribbleTheme.accent, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: ScribbleTheme.accent, shape: BoxShape.circle)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: ScribbleTheme.scribbleLine.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (v) => _handleSend(v),
              decoration: InputDecoration(
                hintText: '跟奴才说花了多少……',
                hintStyle: TextStyle(color: ScribbleTheme.textSecondary.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: ScribbleTheme.secondaryBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _handleSend(_controller.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ScribbleTheme.accent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'list',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionListScreen())),
          backgroundColor: ScribbleTheme.cardColor,
          child: Icon(Icons.receipt_long, color: ScribbleTheme.accentDark),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'add',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualEntryScreen())),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
