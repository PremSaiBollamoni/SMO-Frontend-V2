import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/hr_controller.dart';

/// Profile management view widget
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static const List<String> _employeeStatuses = [
    'ACTIVE',
    'RESIGNED',
    'TERMINATED',
  ];

  final _profileNameController = TextEditingController();
  final _profileEmailController = TextEditingController();
  final _profilePhoneController = TextEditingController();
  final _profileAddressController = TextEditingController();
  final _profileDobController = TextEditingController();
  final _profileBloodController = TextEditingController();
  final _profileEmergencyController = TextEditingController();
  final _profileAadharController = TextEditingController();
  final _profilePanCardController = TextEditingController();
  String _profileStatus = 'ACTIVE';
  final _profilePasswordController = TextEditingController();

  @override
  void dispose() {
    _profileNameController.dispose();
    _profileEmailController.dispose();
    _profilePhoneController.dispose();
    _profileAddressController.dispose();
    _profileDobController.dispose();
    _profileBloodController.dispose();
    _profileEmergencyController.dispose();
    _profileAadharController.dispose();
    _profilePanCardController.dispose();
    _profilePasswordController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final controller = Get.find<HrController>();
    final profile = controller.currentProfile.value;
    if (profile != null) {
      _profileNameController.text = profile.empName;
      _profileEmailController.text = profile.email;
      _profilePhoneController.text = profile.phone;
      _profileAddressController.text = profile.address;
      _profileDobController.text = profile.dob;
      _profileBloodController.text = profile.bloodGroup;
      _profileEmergencyController.text = profile.emergencyContact;
      _profileAadharController.text = profile.aadharNumber;
      _profilePanCardController.text = profile.panCardNumber;
      _profileStatus = _employeeStatuses.contains(profile.status.toUpperCase())
          ? profile.status.toUpperCase()
          : 'ACTIVE';
    }
  }

  Future<void> _handleProfileUpdate() async {
    final controller = Get.find<HrController>();

    if (_profileNameController.text.trim().isEmpty ||
        _profileEmailController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Name and email are required');
      return;
    }

    final success = await controller.updateProfile(
      empName: _profileNameController.text.trim(),
      email: _profileEmailController.text.trim(),
      phone: _profilePhoneController.text.trim().isEmpty
          ? null
          : _profilePhoneController.text.trim(),
      address: _profileAddressController.text.trim().isEmpty
          ? null
          : _profileAddressController.text.trim(),
      dob: _profileDobController.text.trim().isEmpty
          ? null
          : _profileDobController.text.trim(),
      bloodGroup: _profileBloodController.text.trim().isEmpty
          ? null
          : _profileBloodController.text.trim(),
      emergencyContact: _profileEmergencyController.text.trim().isEmpty
          ? null
          : _profileEmergencyController.text.trim(),
      aadharNumber: _profileAadharController.text.trim().isEmpty
          ? null
          : _profileAadharController.text.trim(),
      panCardNumber: _profilePanCardController.text.trim().isEmpty
          ? null
          : _profilePanCardController.text.trim(),
      status: _profileStatus,
      password: _profilePasswordController.text.trim().isEmpty
          ? null
          : _profilePasswordController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      CustomSnackbar.showSuccess(context, 'Profile updated');
      _profilePasswordController.clear();
      controller.toggleProfileEditMode();
    } else {
      CustomSnackbar.showError(context, 'Profile update failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrController>();

    return Obx(() {
      final profile = controller.currentProfile.value;
      final isEditMode = controller.isProfileEditMode.value;

      if (profile == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Profile', style: AppTheme.headlineMedium),
                IconButton(
                  icon: Icon(isEditMode ? Icons.close : Icons.edit),
                  onPressed: () {
                    controller.toggleProfileEditMode();
                    if (!isEditMode) {
                      _loadProfileData();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isEditMode) ...[
              _buildTextField(_profileNameController, 'Name'),
              _buildTextField(_profileEmailController, 'Email'),
              _buildTextField(_profilePhoneController, 'Phone'),
              _buildTextField(_profileAddressController, 'Address'),
              _buildTextField(_profileDobController, 'DOB (YYYY-MM-DD)'),
              _buildTextField(_profileBloodController, 'Blood Group'),
              _buildTextField(_profileEmergencyController, 'Emergency Contact'),
              _buildTextField(_profileAadharController, 'Aadhar Number'),
              _buildTextField(_profilePanCardController, 'PAN Card Number'),
              _buildStatusDropdown(),
              _buildTextField(_profilePasswordController, 'New Password (optional)'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleProfileUpdate,
                child: const Text('Save Changes'),
              ),
            ] else ...[
              _buildReadOnlyField('Employee ID', profile.empId),
              _buildReadOnlyField('Name', profile.empName),
              _buildReadOnlyField('Role', profile.role.roleName),
              _buildReadOnlyField('Email', profile.email),
              _buildReadOnlyField('Phone', profile.phone),
              _buildReadOnlyField('Address', profile.address),
              _buildReadOnlyField('DOB', profile.dob),
              _buildReadOnlyField('Blood Group', profile.bloodGroup),
              _buildReadOnlyField('Emergency Contact', profile.emergencyContact),
              _buildReadOnlyField('Aadhar', profile.aadharNumber),
              _buildReadOnlyField('PAN', profile.panCardNumber),
              _buildReadOnlyField('Status', profile.status),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkInputDecoration(label)
            : AppTheme.inputDecoration(label),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: _profileStatus,
        items: _employeeStatuses
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _profileStatus = value);
          }
        },
        decoration: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkInputDecoration('Status')
            : AppTheme.inputDecoration('Status'),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelMedium.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value.trim().isEmpty ? '-' : value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
