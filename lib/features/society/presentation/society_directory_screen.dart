import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/service_icon_badge.dart';
import '../../discovery/presentation/bloc/discovery_bloc.dart';

class SocietyDirectoryScreen extends StatelessWidget {
  const SocietyDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discoveryState = context.watch<DiscoveryBloc>().state;
    final societies = discoveryState is DiscoveryLoaded ? discoveryState.societies : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apartment & Society Directory'),
      ),
      body: societies.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.apartment_rounded, size: 54, color: AppColors.textTertiaryLight),
                    const SizedBox(height: 16),
                    Text(
                      'No societies registered yet',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When local workers register and list their served apartment complexes, societies will appear here for fast neighborhood hiring.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: societies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final soc = societies[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      context.read<DiscoveryBloc>().add(
                            DiscoveryFilterChanged(societyFilter: soc.name),
                          );
                      context.pop();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.apartment_rounded, color: AppColors.primaryLight),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      soc.name,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      soc.locality.isNotEmpty ? '${soc.locality}, ${soc.city}' : 'Local Housing Complex',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiaryLight),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.people_alt_outlined, size: 16, color: AppColors.secondaryLight),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${soc.activeWorkersCount} Active Workers',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 4,
                                children: soc.availableCategories.take(4).map((cat) {
                                  return ServiceIconBadge(categoryId: cat, size: 24);
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
