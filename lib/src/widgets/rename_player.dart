import 'package:backstreets_widgets/screens.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'custom_text.dart';

/// A widget for renaming a player.
class RenamePlayer extends StatefulWidget {
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

  @override
  State<RenamePlayer> createState() => _RenamePlayerState();
}

class _RenamePlayerState extends State<RenamePlayer> {
  /// The form key to use.
  late final GlobalKey<FormState> formKey;

  /// The controller to use.
  late final TextEditingController controller;

  /// Initialise state.
  @override
  void initState() {
    super.initState();
    formKey = GlobalKey();
    controller = TextEditingController(text: widget.name);
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
  }

  /// Dispose of the widget.
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  /// Build the widget.
  @override
  Widget build(final BuildContext builderContext) => PopScope(
        onPopInvokedWithResult: (final didPop, final result) => submitForm(),
        child: SimpleScaffold(
          title: 'Rename Player',
          body: Center(
            child: Form(
              key: formKey,
              child: TextFormField(
                autofocus: true,
                controller: controller,
                decoration: const InputDecoration(
                  label: CustomText('Player name'),
                  helperText: 'This will be the new name for the player',
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'The player name cannot be empty',
                ),
                onFieldSubmitted: (final _) => Navigator.pop(context),
              ),
            ),
          ),
        ),
      );

  /// Submit the form.
  void submitForm() {
    if (formKey.currentState?.validate() ?? false) {
      final newName = controller.text;
      widget.onChanged(newName);
    }
  }
}
