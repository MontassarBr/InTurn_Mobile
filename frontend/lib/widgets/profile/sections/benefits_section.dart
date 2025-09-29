import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../../providers/company_profile_provider.dart';

class BenefitsSection extends StatefulWidget {
  final bool isOwner;
  const BenefitsSection({Key? key, required this.isOwner}) : super(key: key);

  @override
  State<BenefitsSection> createState() => _BenefitsSectionState();
}

class _BenefitsSectionState extends State<BenefitsSection> {
  late final TextEditingController addController;

  @override
  void initState() {
    super.initState();
    addController = TextEditingController();
  }

  @override
  void dispose() {
    addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CompanyProfileProvider>();
    final benefits = provider.benefits;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.card_giftcard_outlined, size: 20, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text('Benefits', style: AppConstants.subheadingStyle.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${benefits.length} listed', style: TextStyle(color: AppConstants.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const Divider(),
            if (widget.isOwner) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: addController,
                        decoration: const InputDecoration(
                          hintText: 'Add a new benefit (e.g., Health insurance)...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        final text = addController.text.trim();
                        if (text.isNotEmpty) {
                          provider.addBenefit(text);
                          addController.clear();
                        }
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            benefits.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        widget.isOwner ? 'Add your benefits above' : 'No benefits listed',
                        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: benefits
                        .map((benefit) => _BenefitChip(
                              label: benefit,
                              isOwner: widget.isOwner,
                              onDelete: () => provider.deleteBenefit(benefit),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final String label;
  final bool isOwner;
  final VoidCallback onDelete;

  const _BenefitChip({required this.label, required this.isOwner, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppConstants.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          if (isOwner) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onDelete,
              child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
