import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// A widget for renaming a player.
class RenamePlayer extends StatelessWidget {
  /// Create an instance.
  const RenamePlayer({
    required this.name,
    required this.onChanged,
    super.key,
  });

  /// The current name of the player.
  final String name;

  /// The function to call with the new name.
  final void Function(String name) onChanged;

  /// Build the widget.
  @override
  Widget build(final BuildContext builderContext) => GetText(
        onDone: (final value) {
          Navigator.pop(builderContext);
          onChanged(value);
        },
        labelText: 'Player name',
        text: name,
        title: 'Rename Player',
        validator: FormBuilderValidators.required(),
      );
}
