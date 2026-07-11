import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/extensions.dart';

import '../../data/models/reminder_model.dart';
import '../providers/reminder_providers.dart';

class AddReminderSheet extends ConsumerStatefulWidget {
  final String? initialCategory;

  const AddReminderSheet({super.key, this.initialCategory});

  @override
  ConsumerState<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<AddReminderSheet> {
  final _titleController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  String _repeatType = 'None';
  int _customInterval = 1;
  final List<int> _notifyOffsets = [0];
  bool _showCustomInterval = false;

  final List<Map<String, dynamic>> _allTemplates = [
    ...AppConstants.financialTemplates,
    ...AppConstants.subscriptionTemplates,
    ...AppConstants.personalTemplates,
    ...AppConstants.utilityTemplates,
  ];

  bool _initialCategoryHandled = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    final l10n = AppLocalizations.of(context);
    final localizedTitle = l10n?.getCategoryLocalizedName(category) ?? category;
    setState(() {
      _selectedCategory = category;
      _titleController.text = localizedTitle;
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (!mounted || time == null) return;
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.fillAllFields ?? 'Please fill in all fields',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.overdue,
        ),
      );
      return;
    }

    final reminder = ReminderModel(
      id: const Uuid().v4(),
      title: _titleController.text,
      category: _selectedCategory!,
      dateTime: _selectedDate,
      repeatType: _repeatType,
      customInterval: _repeatType == 'Custom' ? _customInterval : null,
      notifyOffsets: _notifyOffsets,
    );

    ref.read(allRemindersProvider.notifier).addReminder(reminder);
    AdService.showInterstitial();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Set localized title for initial category (from quick actions)
    if (!_initialCategoryHandled && widget.initialCategory != null) {
      _titleController.text = l10n?.getCategoryLocalizedName(widget.initialCategory!) ?? widget.initialCategory!;
      _initialCategoryHandled = true;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      l10n?.addReminder ?? 'Add Reminder',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Templates grid
                    Text(
                      l10n?.quickSelect ?? 'Quick Select',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _allTemplates.length,
                      itemBuilder: (context, index) {
                        final template = _allTemplates[index];
                        final templateName = template['name'] as String;
                        final isSelected =
                            _selectedCategory == templateName;
                        final color =
                            AppColors.getCategoryColor(templateName);
                        final icon =
                            AppColors.getCategoryIcon(templateName);
                        final localizedName = l10n?.getCategoryLocalizedName(templateName) ?? templateName;

                        return GestureDetector(
                          onTap: () => _selectCategory(templateName),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.15)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  icon,
                                  color: color,
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  localizedName,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? color
                                        : AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Title field
                    Text(
                      AppLocalizations.of(context)?.title ?? 'Title',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)?.enterTitle ?? 'Enter reminder title',
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date & Time
                    Text(
                      AppLocalizations.of(context)?.dateTime ?? 'Date & Time',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.financial,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('MMM dd, yyyy • hh:mm a', Localizations.localeOf(context).languageCode)
                                  .format(_selectedDate),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Repeat
                    Text(
                      AppLocalizations.of(context)?.repeat ?? 'Repeat',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.repeatTypes.map((type) {
                        final isSelected = _repeatType == type;
                        final localizedType = l10n?.getRepeatTypeLocalizedName(type) ?? type;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _repeatType = type;
                              _showCustomInterval = type == 'Custom';
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.financial
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              localizedType,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Custom interval
                    if (_showCustomInterval) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)?.every ?? 'Every',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (v) {
                                _customInterval = int.tryParse(v) ?? 1;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)?.days ?? 'days',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Notifications
                    Text(
                      AppLocalizations.of(context)?.notify ?? 'Notify',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _NotifyChip(
                          label: AppLocalizations.of(context)?.sameDay ?? 'Same day',
                          value: 0,
                          isSelected: _notifyOffsets.contains(0),
                          onTap: () {
                            setState(() {
                              if (_notifyOffsets.contains(0)) {
                                _notifyOffsets.remove(0);
                              } else {
                                _notifyOffsets.add(0);
                              }
                            });
                          },
                        ),
                        _NotifyChip(
                          label: AppLocalizations.of(context)?.oneDayBefore ?? '1 day before',
                          value: 1,
                          isSelected: _notifyOffsets.contains(1),
                          onTap: () {
                            setState(() {
                              if (_notifyOffsets.contains(1)) {
                                _notifyOffsets.remove(1);
                              } else {
                                _notifyOffsets.add(1);
                              }
                            });
                          },
                        ),
                        _NotifyChip(
                          label: AppLocalizations.of(context)?.threeDaysBefore ?? '3 days before',
                          value: 3,
                          isSelected: _notifyOffsets.contains(3),
                          onTap: () {
                            setState(() {
                              if (_notifyOffsets.contains(3)) {
                                _notifyOffsets.remove(3);
                              } else {
                                _notifyOffsets.add(3);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveReminder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.financial,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.saveReminder ?? 'Save Reminder',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotifyChip extends StatelessWidget {
  final String label;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const _NotifyChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.personal : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.personal
                : AppColors.textTertiary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(Icons.check, size: 16, color: Colors.white),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
