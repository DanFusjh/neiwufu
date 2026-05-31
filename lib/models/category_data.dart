import 'package:flutter/material.dart';

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  final bool isExpense;

  const CategoryInfo({
    required this.name,
    required this.icon,
    required this.color,
    this.isExpense = true,
  });
}

class CategoryData {
  static const Map<String, CategoryInfo> expenseCategories = {
    '早餐': CategoryInfo(name: '早餐', icon: Icons.free_breakfast, color: Color(0xFFFF9F43)),
    '午餐': CategoryInfo(name: '午餐', icon: Icons.restaurant, color: Color(0xFFFF6B6B)),
    '晚餐': CategoryInfo(name: '晚餐', icon: Icons.dinner_dining, color: Color(0xFFFF8A65)),
    '零食': CategoryInfo(name: '零食', icon: Icons.cookie, color: Color(0xFFFFD93D)),
    '水果': CategoryInfo(name: '水果', icon: Icons.apple, color: Color(0xFF6BCB77)),
    '外卖': CategoryInfo(name: '外卖', icon: Icons.delivery_dining, color: Color(0xFF4D96FF)),
    '公交': CategoryInfo(name: '公交', icon: Icons.directions_bus, color: Color(0xFF6C63FF)),
    '地铁': CategoryInfo(name: '地铁', icon: Icons.directions_subway, color: Color(0xFFFF6584)),
    '打车': CategoryInfo(name: '打车', icon: Icons.local_taxi, color: Color(0xFFFFB347)),
    '加油': CategoryInfo(name: '加油', icon: Icons.local_gas_station, color: Color(0xFFFF4757)),
    '购物': CategoryInfo(name: '购物', icon: Icons.shopping_cart, color: Color(0xFFFF6B81)),
    '网购': CategoryInfo(name: '网购', icon: Icons.shopping_bag, color: Color(0xFFA29BFE)),
    '服装': CategoryInfo(name: '服装', icon: Icons.checkroom, color: Color(0xFFFD79A8)),
    '数码': CategoryInfo(name: '数码', icon: Icons.phone_android, color: Color(0xFF74B9FF)),
    '房租': CategoryInfo(name: '房租', icon: Icons.home, color: Color(0xFF55EFC4)),
    '水电': CategoryInfo(name: '水电', icon: Icons.bolt, color: Color(0xFFFFEAA7)),
    '日用品': CategoryInfo(name: '日用品', icon: Icons.inventory, color: Color(0xFFDFE6E9)),
    '电影': CategoryInfo(name: '电影', icon: Icons.movie, color: Color(0xFF6C5CE7)),
    '游戏': CategoryInfo(name: '游戏', icon: Icons.sports_esports, color: Color(0xFFFD79A8)),
    '运动': CategoryInfo(name: '运动', icon: Icons.fitness_center, color: Color(0xFF00B894)),
    '医疗': CategoryInfo(name: '医疗', icon: Icons.medical_services, color: Color(0xFFFF7675)),
    '学习': CategoryInfo(name: '学习', icon: Icons.school, color: Color(0xFF74B9FF)),
    '红包': CategoryInfo(name: '红包', icon: Icons.card_giftcard, color: Color(0xFFFF4757)),
    '其他': CategoryInfo(name: '其他', icon: Icons.more_horiz, color: Color(0xFFB2BEC3)),
  };

  static const Map<String, CategoryInfo> incomeCategories = {
    '工资': CategoryInfo(name: '工资', icon: Icons.account_balance, color: Color(0xFF00B894), isExpense: false),
    '兼职': CategoryInfo(name: '兼职', icon: Icons.work, color: Color(0xFF6C5CE7), isExpense: false),
    '红包收入': CategoryInfo(name: '红包收入', icon: Icons.card_giftcard, color: Color(0xFFFF4757), isExpense: false),
    '理财': CategoryInfo(name: '理财', icon: Icons.trending_up, color: Color(0xFF00CEC9), isExpense: false),
    '其他收入': CategoryInfo(name: '其他收入', icon: Icons.attach_money, color: Color(0xFF636E72), isExpense: false),
  };

  static List<String> get expenseCategoryNames => expenseCategories.keys.toList();
  static List<String> get incomeCategoryNames => incomeCategories.keys.toList();

  static CategoryInfo? getInfo(String name) {
    return expenseCategories[name] ?? incomeCategories[name];
  }

  static String inferCategory(String text) {
    final map = <String, String>{
      '早餐': '早餐', '早饭': '早餐', '早': '早餐',
      '午餐': '午餐', '午饭': '午餐', '中饭': '午餐', '中': '午餐',
      '晚餐': '晚餐', '晚饭': '晚餐', '晚': '晚餐', '夜宵': '晚餐',
      '零食': '零食', '小吃': '零食', '奶茶': '零食', '饮料': '零食',
      '水果': '水果',
      '外卖': '外卖',
      '公交': '公交', '巴士': '公交', '公车': '公交',
      '地铁': '地铁',
      '打车': '打车', '出租': '打车', '滴滴': '打车', 'taxi': '打车',
      '加油': '加油', '油费': '加油', '汽油': '加油',
      '购物': '购物', '超市': '购物', '百货': '购物', '买': '购物',
      '网购': '网购', '淘宝': '网购', '京东': '网购', '拼多多': '网购',
      '服装': '服装', '衣服': '服装', '裤子': '服装', '鞋': '服装',
      '数码': '数码', '手机': '数码', '电脑': '数码',
      '房租': '房租', '租金': '房租', '房': '房租',
      '水电': '水电', '水费': '水电', '电费': '水电', '燃气': '水电',
      '日用品': '日用品', '纸巾': '日用品', '牙刷': '日用品',
      '电影': '电影', '影院': '电影', '演出': '电影',
      '游戏': '游戏', 'steam': '游戏',
      '运动': '运动', '健身': '运动',
      '医疗': '医疗', '看病': '医疗', '药': '医疗', '医院': '医疗',
      '学习': '学习', '书': '学习', '课程': '学习',
      '红包': '红包', '礼金': '红包',
      '工资': '工资', '薪水': '工资',
      '兼职': '兼职',
      '理财': '理财', '基金': '理财', '股票': '理财', '利息': '理财',
    };

    for (final entry in map.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }
    return '其他';
  }

  static String extractAmount(String text) {
    final regex = RegExp(r'(\d+\.?\d*)');
    final match = regex.firstMatch(text);
    if (match != null) {
      return match.group(1)!;
    }
    return '';
  }

  static TransactionParseResult parseTransaction(String text) {
    final amountStr = extractAmount(text);
    final amount = double.tryParse(amountStr) ?? 0;
    final isIncome = text.contains('收入') || text.contains('工资') || text.contains('赚') || text.contains('理财收入');
    final category = isIncome
        ? inferCategory(text + '_income')
        : inferCategory(text);

    return TransactionParseResult(
      category: category,
      amount: amount,
      note: text,
      isIncome: isIncome,
      confidence: amount > 0 ? 0.9 : 0.0,
    );
  }
}

class TransactionParseResult {
  final String category;
  final double amount;
  final String note;
  final bool isIncome;
  final double confidence;

  TransactionParseResult({
    required this.category,
    required this.amount,
    required this.note,
    this.isIncome = false,
    this.confidence = 0.0,
  });

  bool get isValid => amount > 0;
}
