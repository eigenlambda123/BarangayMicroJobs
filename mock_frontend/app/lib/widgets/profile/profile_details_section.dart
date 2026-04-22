import 'package:flutter/material.dart';

class ProfileDetailsSection extends StatelessWidget {
  final bool isEditMode;
  final bool isSaving;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController locationController;
  final TextEditingController skillInputController;
  final List<String> skills;
  final VoidCallback onToggleEdit;
  final VoidCallback onSave;
  final VoidCallback onAddSkill;
  final ValueChanged<String> onRemoveSkill;

  const ProfileDetailsSection({
    required this.isEditMode,
    required this.isSaving,
    required this.phoneController,
    required this.emailController,
    required this.locationController,
    required this.skillInputController,
    required this.skills,
    required this.onToggleEdit,
    required this.onSave,
    required this.onAddSkill,
    required this.onRemoveSkill,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            TextButton(
              onPressed: onToggleEdit,
              child: Text(isEditMode ? 'Cancel' : 'Edit'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isEditMode) ...[
          _buildEditMode(context, colorScheme),
        ] else ...[
          _buildViewMode(colorScheme),
        ],
      ],
    );
  }

  Widget _buildViewMode(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Phone', phoneController.text, colorScheme),
          const SizedBox(height: 12),
          _buildDetailRow('Email', emailController.text, colorScheme),
          const SizedBox(height: 12),
          _buildDetailRow('Location', locationController.text, colorScheme),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSkillsView(colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.56),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? 'Not provided' : value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: value.isEmpty
                ? colorScheme.onSurface.withValues(alpha: 0.4)
                : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsView(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.56),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: skills
              .map(
                (skill) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEditMode(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditField('Phone', phoneController, colorScheme),
          const SizedBox(height: 14),
          _buildEditField('Email', emailController, colorScheme),
          const SizedBox(height: 14),
          _buildEditField('Location', locationController, colorScheme),
          const SizedBox(height: 16),
          _buildSkillsEditor(colorScheme),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSaving ? null : onSave,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.56),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: !isSaving,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsEditor(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.56),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: skillInputController,
                enabled: !isSaving,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Add skill',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: isSaving ? null : onAddSkill,
              icon: Icon(Icons.add_circle, color: colorScheme.primary),
            ),
          ],
        ),
        if (skills.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildSkillChips(colorScheme),
        ],
      ],
    );
  }

  Widget _buildSkillChips(ColorScheme colorScheme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: skills
          .map(
            (skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: isSaving ? null : () => onRemoveSkill(skill),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
