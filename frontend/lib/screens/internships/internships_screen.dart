import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/internship_provider.dart';
import 'internship_detail_screen.dart';

class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({Key? key}) : super(key: key);

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen> {

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      context.read<InternshipProvider>().fetchInternships();
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internships'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Consumer<InternshipProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          if (provider.internships.isEmpty) {
            return const Center(child: Text('No internships found'));
          }
          return ListView.separated(
            itemCount: provider.internships.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final internship = provider.internships[index];
              return ListTile(
                title: Text(internship.title),
                subtitle: Text('${internship.location} • ${internship.workArrangement ?? ''}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => InternshipDetailScreen(internship: internship),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
