import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notifier.dart';
import '../../../core/utils/phone_launcher.dart';

enum HouseholdServiceType { milk, maid }

enum DayAttendanceStatus { delivered, skipped }

class HouseholdBillTrackerScreen extends StatefulWidget {
  const HouseholdBillTrackerScreen({super.key});

  @override
  State<HouseholdBillTrackerScreen> createState() => _HouseholdBillTrackerScreenState();
}

class _HouseholdBillTrackerScreenState extends State<HouseholdBillTrackerScreen> {
  HouseholdServiceType _serviceType = HouseholdServiceType.milk;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  // Rates
  double _milkRatePerLiter = 66.0;
  double _milkDailyLiters = 1.5;

  double _maidMonthlySalary = 3500.0;
  final bool _maidUsePerDayDeduction = true;

  // Day status map: key is day number (1..31), value is status
  final Map<int, DayAttendanceStatus> _attendance = {};

  final TextEditingController _providerPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMonthData();
  }

  @override
  void dispose() {
    _providerPhoneController.dispose();
    super.dispose();
  }

  String get _storageKey =>
      'tracker_${_serviceType.name}_${_currentMonth.year}_${_currentMonth.month}';

  void _loadMonthData() {
    _attendance.clear();
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);

    final storage = sl<HiveStorageService>();
    final cachedData = storage.getCached(HiveBoxes.appSettings, _storageKey);

    if (cachedData != null && cachedData is Map) {
      for (int day = 1; day <= daysInMonth; day++) {
        final val = cachedData['$day'];
        if (val == 'skipped') {
          _attendance[day] = DayAttendanceStatus.skipped;
        } else {
          _attendance[day] = DayAttendanceStatus.delivered;
        }
      }
    } else {
      // Default: all days delivered
      for (int day = 1; day <= daysInMonth; day++) {
        _attendance[day] = DayAttendanceStatus.delivered;
      }
    }
    setState(() {});
  }

  Future<void> _saveMonthData() async {
    final Map<String, dynamic> dataToSave = {};
    _attendance.forEach((day, status) {
      dataToSave['$day'] = status == DayAttendanceStatus.skipped ? 'skipped' : 'delivered';
    });

    final storage = sl<HiveStorageService>();
    await storage.putCached(HiveBoxes.appSettings, _storageKey, dataToSave);
  }

  void _toggleDay(int day) {
    setState(() {
      final current = _attendance[day] ?? DayAttendanceStatus.delivered;
      _attendance[day] = current == DayAttendanceStatus.delivered
          ? DayAttendanceStatus.skipped
          : DayAttendanceStatus.delivered;
    });
    _saveMonthData();
  }

  int get _daysInMonth => DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);

  int get _deliveredDays =>
      _attendance.values.where((s) => s == DayAttendanceStatus.delivered).length;

  int get _skippedDays =>
      _attendance.values.where((s) => s == DayAttendanceStatus.skipped).length;

  List<int> get _skippedDates {
    final list = <int>[];
    _attendance.forEach((day, status) {
      if (status == DayAttendanceStatus.skipped) list.add(day);
    });
    list.sort();
    return list;
  }

  double get _totalBill {
    if (_serviceType == HouseholdServiceType.milk) {
      final totalLiters = _deliveredDays * _milkDailyLiters;
      return totalLiters * _milkRatePerLiter;
    } else {
      if (_maidUsePerDayDeduction) {
        final dailyRate = _maidMonthlySalary / _daysInMonth;
        return _deliveredDays * dailyRate;
      } else {
        return _maidMonthlySalary;
      }
    }
  }

  String _formatMonthYear(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  void _shareBillOnWhatsApp() {
    final monthName = _formatMonthYear(_currentMonth);
    final serviceName = _serviceType == HouseholdServiceType.milk
        ? 'Milk Delivery (दूध)'
        : 'Maid / Helper (कामवाली बाई)';

    final skippedStr = _skippedDates.isEmpty
        ? 'None (0 days)'
        : '${_skippedDates.length} days (${_skippedDates.map((d) => '$d').join(', ')})';

    final buffer = StringBuffer();
    buffer.writeln('📋 *Daily-Ease Monthly Attendance & Bill*');
    buffer.writeln('----------------------------------------');
    buffer.writeln('👤 *Service:* $serviceName');
    buffer.writeln('📅 *Month:* $monthName');
    if (_serviceType == HouseholdServiceType.milk) {
      buffer.writeln('🥛 *Rate:* ₹${_milkRatePerLiter.toStringAsFixed(0)}/L ($_milkDailyLiters L/day)');
      buffer.writeln('✅ *Delivered Days:* $_deliveredDays days (${(_deliveredDays * _milkDailyLiters).toStringAsFixed(1)} L)');
    } else {
      buffer.writeln('🧹 *Base Salary:* ₹${_maidMonthlySalary.toStringAsFixed(0)}');
      buffer.writeln('✅ *Present Days:* $_deliveredDays / $_daysInMonth days');
    }
    buffer.writeln('❌ *Skipped / Off Days:* $skippedStr');
    buffer.writeln('💰 *Total Payable:* ₹${_totalBill.toStringAsFixed(0)}');
    buffer.writeln('----------------------------------------');
    buffer.writeln('Calculated automatically via Daily-Ease.');

    PhoneLauncher.openWhatsApp(
      context,
      rawPhoneNumber: _providerPhoneController.text.trim(),
      recipientName: serviceName,
      prefilledMessage: buffer.toString(),
    );
  }

  void _showRateDialog() {
    final literRateCtrl = TextEditingController(text: _milkRatePerLiter.toStringAsFixed(0));
    final dailyLitersCtrl = TextEditingController(text: _milkDailyLiters.toString());
    final salaryCtrl = TextEditingController(text: _maidMonthlySalary.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_serviceType == HouseholdServiceType.milk ? 'Configure Milk Rate' : 'Configure Maid Salary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_serviceType == HouseholdServiceType.milk) ...[
              TextField(
                controller: literRateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price per Liter (₹)', suffixText: '₹/L'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dailyLitersCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Daily Liters Quantity', suffixText: 'L/day'),
              ),
            ] else ...[
              TextField(
                controller: salaryCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Agreed Salary (₹)', prefixText: '₹ '),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {
                if (_serviceType == HouseholdServiceType.milk) {
                  _milkRatePerLiter = double.tryParse(literRateCtrl.text) ?? _milkRatePerLiter;
                  _milkDailyLiters = double.tryParse(dailyLitersCtrl.text) ?? _milkDailyLiters;
                } else {
                  _maidMonthlySalary = double.tryParse(salaryCtrl.text) ?? _maidMonthlySalary;
                }
              });
              Navigator.pop(ctx);
              AppNotifier.showSuccess(context, title: 'Rates Updated', description: 'Bill recalculated.');
            },
            child: const Text('Save Rate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Bill & Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configure Rates',
            onPressed: _showRateDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Type Toggle (Milk vs Maid)
            SegmentedButton<HouseholdServiceType>(
              segments: const [
                ButtonSegment(
                  value: HouseholdServiceType.milk,
                  label: Text('Milk Delivery (दूध)'),
                  icon: Icon(Icons.water_drop_rounded),
                ),
                ButtonSegment(
                  value: HouseholdServiceType.maid,
                  label: Text('Maid / Helper (बाई)'),
                  icon: Icon(Icons.cleaning_services_rounded),
                ),
              ],
              selected: {_serviceType},
              onSelectionChanged: (val) {
                setState(() => _serviceType = val.first);
                _loadMonthData();
              },
            ),
            const SizedBox(height: 16),

            // Month Navigation Card
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                        });
                        _loadMonthData();
                      },
                    ),
                    Text(
                      _formatMonthYear(_currentMonth),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                        });
                        _loadMonthData();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Calculation Bill Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable This Month',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _serviceType == HouseholdServiceType.milk
                              ? '₹${_milkRatePerLiter.toStringAsFixed(0)}/L'
                              : '₹${_maidMonthlySalary.toStringAsFixed(0)}/mo',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ ${_totalBill.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryStat('Present / Delivered', '$_deliveredDays days', Colors.white),
                      _buildSummaryStat('Skipped / Leave', '$_skippedDays days', const Color(0xFFFCA5A5)),
                      if (_serviceType == HouseholdServiceType.milk)
                        _buildSummaryStat('Total Liters', '${(_deliveredDays * _milkDailyLiters).toStringAsFixed(1)} L', Colors.white)
                      else
                        _buildSummaryStat('Daily Wage', '₹${(_maidMonthlySalary / _daysInMonth).toStringAsFixed(0)}/day', Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Attendance Grid Instructions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Attendance (Tap to toggle)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    _buildLegendChip(Colors.green, 'Delivered'),
                    const SizedBox(width: 8),
                    _buildLegendChip(Colors.redAccent, 'Skipped'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Calendar Days Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.95,
              ),
              itemCount: _daysInMonth,
              itemBuilder: (context, index) {
                final dayNumber = index + 1;
                final status = _attendance[dayNumber] ?? DayAttendanceStatus.delivered;
                final isDelivered = status == DayAttendanceStatus.delivered;

                final dayDate = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                final weekdayLetter = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][dayDate.weekday - 1];

                return InkWell(
                  onTap: () => _toggleDay(dayNumber),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : const Color(0xFFEF4444).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDelivered ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDelivered ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                          ),
                        ),
                        Text(
                          weekdayLetter,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Icon(
                          isDelivered ? Icons.check_rounded : Icons.close_rounded,
                          size: 14,
                          color: isDelivered ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // WhatsApp Share Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF1EBE5D), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Share Bill on WhatsApp',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'Send detailed monthly breakdown to your helper or milkman',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _providerPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone Number',
                        hintText: 'Enter mobile number (e.g. +91...)',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Send Bill Breakdown via WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _shareBillOnWhatsApp,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildLegendChip(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
