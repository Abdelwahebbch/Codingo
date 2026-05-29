import 'package:flutter/material.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/auth/login_screen.dart';
import 'package:pfe_test/widgets/rank_widget.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int rank;
  bool isReady = true;

  Future<void> getRank() async {
    final authService = Provider.of<DataProvider>(context, listen: false);
    rank =  authService.progress.rank;
    setState(() {
      isReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<DataProvider>(context, listen: false);

    rank =  authService.progress.rank;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<DataProvider>(context);

    final auth = Provider.of<AuthProvider>(context);
    final user = authService.authProvider.currentUser;
    final String userImage = authService.progress.imageId;

    NetworkImage dataBaseImage = NetworkImage(
        'https://fra.cloud.appwrite.io/v1/storage/buckets/69891b1d0012c9a7e862/files/$userImage/view?project=697295e70021593c3438&mode=admin');
    if (!isReady) {
      return const SafeArea(
          child: Scaffold(
        body: Center(
            child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ))),
      ));
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
                await auth.signOut();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryColor,
                backgroundImage: userImage.isEmpty ? null : dataBaseImage,
                child: userImage.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? "Guest",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                authService.progress.bio,
                style: const TextStyle(color: AppTheme.accentColor),
              ),
              const SizedBox(height: 32),
              _buildStatRow(context),
              const SizedBox(height: 32),
              _buildSectionTitle(context, "Elo Rank"),
              const SizedBox(height: 16),
              RankWidget(
                elo: authService.progress.elo,
                rank: rank,
                showBar: true,
                height: 100,
                width: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(context) {
    final authService = Provider.of<DataProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Missions", "${authService.progress.nbMissions}"),
        _buildStatItem("Points", "${authService.progress.totalPoints}"),
        _buildStatItem("Rank", "#$rank"),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
