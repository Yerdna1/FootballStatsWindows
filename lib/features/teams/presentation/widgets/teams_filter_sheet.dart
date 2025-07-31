import 'package:flutter/material.dart';

class TeamsFilterSheet extends StatefulWidget {
  final int? currentLeagueId;
  final String? currentCountry;
  final Function(int?, String?) onApplyFilters;

  const TeamsFilterSheet({
    super.key,
    this.currentLeagueId,
    this.currentCountry,
    required this.onApplyFilters,
  });

  @override
  State<TeamsFilterSheet> createState() => _TeamsFilterSheetState();
}

class _TeamsFilterSheetState extends State<TeamsFilterSheet> {
  int? selectedLeagueId;
  String? selectedCountry;

  // Popular leagues
  final List<Map<String, dynamic>> leagues = [
    {'id': 2021, 'name': 'Premier League', 'country': 'England'},
    {'id': 2014, 'name': 'La Liga', 'country': 'Spain'},
    {'id': 2019, 'name': 'Serie A', 'country': 'Italy'},
    {'id': 2002, 'name': 'Bundesliga', 'country': 'Germany'},
    {'id': 2015, 'name': 'Ligue 1', 'country': 'France'},
    {'id': 2017, 'name': 'Primeira Liga', 'country': 'Portugal'},
    {'id': 2003, 'name': 'Eredivisie', 'country': 'Netherlands'},
    {'id': 2001, 'name': 'Champions League', 'country': 'Europe'},
  ];

  // Popular countries
  final List<String> countries = [
    'England',
    'Spain',
    'Italy',
    'Germany',
    'France',
    'Portugal',
    'Netherlands',
    'Brazil',
    'Argentina',
    'Belgium',
  ];

  @override
  void initState() {
    super.initState();
    selectedLeagueId = widget.currentLeagueId;
    selectedCountry = widget.currentCountry;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Teams',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedLeagueId = null;
                      selectedCountry = null;
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Filter Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // League Filter
                  Text(
                    'League',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: leagues.map((league) {
                      final isSelected = selectedLeagueId == league['id'];
                      return FilterChip(
                        label: Text(league['name']),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedLeagueId = selected ? league['id'] : null;
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Country Filter
                  Text(
                    'Country',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: countries.map((country) {
                      final isSelected = selectedCountry == country;
                      return FilterChip(
                        label: Text(country),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCountry = selected ? country : null;
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Apply Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilters(selectedLeagueId, selectedCountry);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}