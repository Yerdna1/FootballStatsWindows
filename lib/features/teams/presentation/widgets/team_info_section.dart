import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/team_entity.dart';

class TeamInfoSection extends StatelessWidget {
  final TeamEntity team;

  const TeamInfoSection({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information Card
          _buildInfoCard(
            context,
            'Basic Information',
            [
              _buildInfoRow('Full Name', team.name),
              _buildInfoRow('Short Name', team.shortName),
              _buildInfoRow('TLA', team.tla),
              if (team.founded != null)
                _buildInfoRow('Founded', team.founded.toString()),
              if (team.countryName != null)
                _buildInfoRow('Country', team.countryName!),
              if (team.venue != null)
                _buildInfoRow('Venue', team.venue!),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Contact Information Card
          if (team.address != null || team.website != null)
            _buildInfoCard(
              context,
              'Contact Information',
              [
                if (team.address != null)
                  _buildInfoRow('Address', team.address!),
                if (team.website != null)
                  _buildWebsiteRow(context, 'Website', team.website!),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Club Colors Card
          if (team.clubColors != null)
            _buildInfoCard(
              context,
              'Club Information',
              [
                _buildInfoRow('Club Colors', team.clubColors!),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Coach Information Card
          if (team.coach != null)
            _buildCoachCard(context, team.coach!),
          
          const SizedBox(height: 16),
          
          // Competitions Card
          if (team.competitions != null && team.competitions!.isNotEmpty)
            _buildCompetitionsCard(context, team.competitions!),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteRow(BuildContext context, String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _launchUrl(url),
              child: Text(
                url,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachCard(BuildContext context, CoachEntity coach) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coach',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', coach.name),
            if (coach.nationality != null)
              _buildInfoRow('Nationality', coach.nationality!),
            if (coach.age != null)
              _buildInfoRow('Age', '${coach.age} years old'),
            if (coach.contract != null) ...[
              if (coach.contract!.start != null)
                _buildInfoRow('Contract Start', _formatDate(coach.contract!.start!)),
              if (coach.contract!.until != null)
                _buildInfoRow('Contract Until', _formatDate(coach.contract!.until!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitionsCard(BuildContext context, List<CompetitionEntity> competitions) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Competitions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...competitions.map((competition) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      competition.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    competition.type,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}