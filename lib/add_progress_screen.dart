import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'app_constants.dart';
import 'app_theme.dart';
import 'extensions.dart';
import 'progress_model.dart';
import 'progress_provider.dart';

class AddProgressScreen extends ConsumerStatefulWidget {
  const AddProgressScreen({super.key, this.existing});
  final ProgressModel? existing;

  @override
  ConsumerState<AddProgressScreen> createState() =>
      _AddProgressScreenState();
}

class _AddProgressScreenState extends ConsumerState<AddProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _totalCtrl;
  late final TextEditingController _currentCtrl;

  late Color _selectedColor;
  String? _imagePath;
  bool _saving = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.subjectName ?? '');
    _totalCtrl =
        TextEditingController(text: e != null ? '${e.totalPages}' : '');
    _currentCtrl =
        TextEditingController(text: e != null ? '${e.currentPage}' : '');
    _selectedColor =
        e != null ? Color(e.colorValue) : AppConstants.taskColors[2];
    _imagePath = e?.bookmarkImagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _totalCtrl.dispose();
    _currentCtrl.dispose();
    super.dispose();
  }

  // ── Computed ───────────────────────────────────────────────────────────────

  double get _previewPercent {
    final total = int.tryParse(_totalCtrl.text) ?? 0;
    final current = int.tryParse(_currentCtrl.text) ?? 0;
    if (total <= 0) return 0;
    return (current / total).clamp(0.0, 1.0);
  }

  // ── Image Picker ───────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close bottom sheet
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (picked != null && mounted) {
      setState(() => _imagePath = picked.path);
    }
  }

  void _showImageSourceSheet(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library_rounded),
              title: const Text('Photo Library'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red),
                title: const Text('Remove image',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final repo = await ref.read(progressRepositoryProvider.future);
      final total = int.parse(_totalCtrl.text.trim());
      final current = int.parse(_currentCtrl.text.trim());

      if (widget.existing == null) {
        await repo.create(
          subjectName: _nameCtrl.text.trim(),
          totalPages: total,
          currentPage: current,
          color: _selectedColor,
          bookmarkImagePath: _imagePath,
        );
      } else {
        final updated = widget.existing!.copyWith(
          subjectName: _nameCtrl.text.trim(),
          totalPages: total,
          currentPage: current,
          colorValue: _selectedColor.value,
          bookmarkImagePath: _imagePath,
          clearImage: _imagePath == null &&
              widget.existing!.bookmarkImagePath != null,
        );
        await repo.update(updated);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existing != null;
    final pct = _previewPercent;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editProgress : l10n.addProgress),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(l10n.save),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 60),
          physics: const BouncingScrollPhysics(),
          children: [
            // ── Live Progress Preview ──────────────────────────────────────
            _ProgressPreview(
              color: _selectedColor,
              percent: pct,
              subjectName: _nameCtrl.text.isEmpty
                  ? (l10n.subjectHint)
                  : _nameCtrl.text,
            ),
            Gap(24),

            // ── Subject Name ──────────────────────────────────────────────
            _SectionLabel(l10n.subjectName),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: l10n.subjectHint,
                prefixIcon: Icon(Icons.book_rounded,
                    color: context.colors.onSurfaceVariant),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.required : null,
            ),
            Gap(16),

            // ── Pages ─────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(l10n.totalPages),
                      TextFormField(
                        controller: _totalCtrl,
                        decoration: InputDecoration(
                          hintText: '300',
                          prefixIcon: Icon(Icons.library_books_rounded,
                              color: context.colors.onSurfaceVariant),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.required;
                          final n = int.tryParse(v);
                          if (n == null || n <= 0) return l10n.invalidNumber;
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(l10n.currentPage),
                      TextFormField(
                        controller: _currentCtrl,
                        decoration: InputDecoration(
                          hintText: '0',
                          prefixIcon: Icon(Icons.bookmark_rounded,
                              color: context.colors.onSurfaceVariant),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.isEmpty) return l10n.required;
                          final n = int.tryParse(v);
                          if (n == null || n < 0) return l10n.invalidNumber;
                          final total =
                              int.tryParse(_totalCtrl.text) ?? 0;
                          if (n > total) return l10n.currentPageError;
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(16),

            // ── Color ─────────────────────────────────────────────────────
            _SectionLabel(l10n.color),
            _ColorPicker(
              selected: _selectedColor,
              onChanged: (c) => setState(() => _selectedColor = c),
            ),
            Gap(16),

            // ── Bookmark Image ─────────────────────────────────────────────
            _SectionLabel(l10n.attachImage),
            _BookmarkImagePicker(
              imagePath: _imagePath,
              onTap: () => _showImageSourceSheet(l10n),
              l10n: l10n,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressPreview extends StatelessWidget {
  const _ProgressPreview({
    required this.color,
    required this.percent,
    required this.subjectName,
  });
  final Color color;
  final double percent;
  final String subjectName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subjectName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color.darker,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            percent: percent,
            lineHeight: 10,
            backgroundColor: color.withOpacity(0.15),
            progressColor: color,
            barRadius: const Radius.circular(100),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 500,
          ),
        ],
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onChanged});
  final Color selected;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppConstants.taskColors.map((c) {
        final isSelected = selected.value == c.value;
        return GestureDetector(
          onTap: () => onChanged(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _BookmarkImagePicker extends StatelessWidget {
  const _BookmarkImagePicker({
    required this.imagePath,
    required this.onTap,
    required this.l10n,
  });
  final String? imagePath;
  final VoidCallback onTap;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: imagePath != null ? 180 : 100,
        decoration: BoxDecoration(
          color: context.isDark
              ? const Color(0xFF252540)
              : const Color(0xFFF0F1F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: imagePath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(imagePath!), fit: BoxFit.cover),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      color: Colors.black54,
                      child: Row(
                        children: [
                          const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            l10n.changeImage,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded,
                      size: 32,
                      color: context.colors.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    l10n.attachImage,
                    style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: context.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.colors.onSurface,
        ),
      ),
    );
  }
}