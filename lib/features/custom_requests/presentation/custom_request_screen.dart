import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_notifier.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../data/custom_request_repository.dart';
import '../domain/custom_request_model.dart';

class CustomRequestScreen extends StatefulWidget {
  const CustomRequestScreen({super.key});

  @override
  State<CustomRequestScreen> createState() => _CustomRequestScreenState();
}

class _CustomRequestScreenState extends State<CustomRequestScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _localityController = TextEditingController();
  final DateTime _neededDate = DateTime.now().add(const Duration(days: 2));

  List<CustomServiceRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final addr = authState.user.primaryAddress;
      if (addr != null && addr.locality.isNotEmpty) {
        _localityController.text = '${addr.locality}, ${addr.city}';
      }
    }
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final list = await sl<CustomRequestRepository>().getCustomRequests();
    if (mounted) {
      setState(() {
        _requests = list;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _localityController.dispose();
    super.dispose();
  }

  Future<void> _submitCustomRequest() async {
    if (_titleController.text.trim().isEmpty) {
      AppNotifier.showWarning(context, title: 'Title Required', description: 'Please briefly describe the need.');
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final primaryAddr = user?.primaryAddress;

    final newReq = CustomServiceRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      consumerId: user?.id ?? 'guest_consumer',
      consumerName: user?.fullName ?? 'Valued Customer',
      consumerPhone: user?.phoneNumber ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      locality: _localityController.text.trim().isNotEmpty
          ? _localityController.text.trim()
          : (primaryAddr?.locality ?? 'Local Area'),
      pincode: primaryAddr?.pincode ?? '',
      budgetEstimate: double.tryParse(_budgetController.text),
      neededDate: _neededDate,
      neededTime: 'Flexible Timing',
      status: 'open',
      createdAt: DateTime.now(),
    );

    await sl<CustomRequestRepository>().createCustomRequest(newReq);

    setState(() {
      _requests.insert(0, newReq);
      _titleController.clear();
      _descriptionController.clear();
      _budgetController.clear();
    });

    if (mounted) {
      AppNotifier.showSuccess(
        context,
        title: 'Custom Request Posted!',
        description: 'Local service providers in ${_localityController.text} can now respond.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Custom Service Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanatory Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainerLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryLight, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Can\'t find an exact category? Describe your requirement and receive responses from suitable local providers.',
                      style: TextStyle(fontSize: 12, color: AppColors.textPrimaryLight),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'Requirement Title',
              hint: 'e.g. Balcony pigeon netting, aquarium setup, sofa repair',
              controller: _titleController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Detailed Description',
              hint: 'Mention size, materials required, or specific tools needed...',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Estimated Budget (₹)',
                    hint: 'e.g. 1500',
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Locality',
                    controller: _localityController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppButton(
              label: 'Post to Nearby Providers',
              icon: Icons.send_rounded,
              onPressed: _submitCustomRequest,
            ),
            const Divider(height: 40),

            Text(
              'Your Active Custom Requests (${_requests.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_requests.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No custom requests posted yet.\nPost any non-standard household requirement above.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                  ),
                ),
              )
            else
              ..._requests.map((req) => _buildRequestCard(req)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(CustomServiceRequest req) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    req.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    req.status.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            if (req.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(req.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (req.budgetEstimate != null)
                  Text(
                    'Budget: ₹${req.budgetEstimate!.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight, fontSize: 12),
                  )
                else
                  const Text('Budget: Flexible', style: TextStyle(fontSize: 12)),
                Text(
                  '${req.responsesCount} Provider responses',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryLight, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
