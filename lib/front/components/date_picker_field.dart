import 'package:flutter/material.dart';
import 'package:following_practices/back/validators/input_validator.dart';

/// Campo de formulario de solo lectura que abre un selector de fecha.
class DatePickerField extends StatefulWidget {
  const DatePickerField({
    super.key,
    required this.controller,
    required this.labelText,
    this.required = true,
    this.initialPickerDate,
    this.firstDate,
    this.lastDate,
    this.minSelectableDate,
    this.clearable = false,
    this.onSelected,
    this.onClear,
    this.beforePick,
    this.validator,
    this.helpText,
  });

  final TextEditingController controller;
  final String labelText;
  final bool required;
  final DateTime? initialPickerDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? minSelectableDate;
  final bool clearable;
  final ValueChanged<DateTime>? onSelected;
  final VoidCallback? onClear;
  final Future<bool> Function()? beforePick;
  final String? Function(String?)? validator;
  final String? helpText;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  Future<void> _pick() async {
    if (widget.beforePick != null) {
      final canPick = await widget.beforePick!();
      if (!canPick || !mounted) return;
    }

    final now = DateTime.now();
    final parsed = DateTime.tryParse(widget.controller.text.trim());
    var initial = widget.initialPickerDate ?? parsed ?? now;

    final first = widget.minSelectableDate ?? widget.firstDate ?? DateTime(2020);
    final last = widget.lastDate ?? DateTime(2035, 12, 31);

    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: widget.helpText ?? widget.labelText,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked == null) return;

    widget.controller.text = InputValidator.formatoFecha(picked);
    widget.onSelected?.call(picked);
    setState(() {});
  }

  void _clear() {
    widget.controller.clear();
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.isNotEmpty;

    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      onTap: _pick,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: widget.clearable && hasValue
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clear,
                    tooltip: 'Quitar fecha',
                  ),
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 12),
                ],
              )
            : const Icon(Icons.calendar_today),
      ),
      validator: widget.validator ??
          (value) {
            if (!widget.required && (value == null || value.isEmpty)) return null;
            return InputValidator.requiredText(value, label: widget.labelText) ??
                InputValidator.fechaIso(value);
          },
    );
  }
}
