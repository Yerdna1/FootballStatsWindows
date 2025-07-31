import 'package:flutter/material.dart';

import '../../domain/entities/team_entity.dart';

class TeamSquadSection extends StatefulWidget {
  final TeamEntity team;

  const TeamSquadSection({super.key, required this.team});

  @override
  State<TeamSquadSection> createState() => _TeamSquadSectionState();
}

class _TeamSquadSectionState extends State<TeamSquadSection> {
  String selectedPosition = 'All';
  final List<String> positions = ['All', 'Goalkeeper', 'Defender', 'Midfielder', 'Attacker'];

  @override
  Widget build(BuildContext context) {
    if (widget.team.squad == null || widget.team.squad!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No squad information available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final filteredPlayers = selectedPosition == 'All'
        ? widget.team.squad!
        : widget.team.squad!.where((player) => 
            _normalizePosition(player.position) == selectedPosition).toList();

    return Column(
      children: [
        // Position Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: positions.length,
            itemBuilder: (context, index) {
              final position = positions[index];
              final isSelected = selectedPosition == position;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(position),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedPosition = position;
                    });
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ),
        
        // Players List
        Expanded(
          child: filteredPlayers.isEmpty
              ? Center(
                  child: Text(
                    'No $selectedPosition players found',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = filteredPlayers[index];
                    return _buildPlayerCard(context, player);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(BuildContext context, PlayerEntity player) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Player Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    _getPlayerInitials(player.name),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Player Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildPositionChip(context, player.position),
                          if (player.nationality != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              player.nationality!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Age
                if (player.age != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${player.age}y',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Contract Information
            if (player.contract != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.description,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contract: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _getContractInfo(player.contract!),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (player.contract!.isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Expired',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPositionChip(BuildContext context, String position) {
    Color chipColor;
    switch (_normalizePosition(position)) {
      case 'Goalkeeper':
        chipColor = Colors.orange;
        break;
      case 'Defender':
        chipColor = Colors.blue;
        break;
      case 'Midfielder':
        chipColor = Colors.green;
        break;
      case 'Attacker':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        position,
        style: TextStyle(
          fontSize: 12,
          color: chipColor[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getPlayerInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, 2).toUpperCase();
    }
    return 'P';
  }

  String _normalizePosition(String position) {
    final pos = position.toLowerCase();
    if (pos.contains('goal')) return 'Goalkeeper';
    if (pos.contains('defence') || pos.contains('defender') || pos.contains('back')) return 'Defender';
    if (pos.contains('midfield') || pos.contains('midfielder')) return 'Midfielder';
    if (pos.contains('forward') || pos.contains('attacker') || pos.contains('winger')) return 'Attacker';
    return position;
  }

  String _getContractInfo(ContractEntity contract) {
    if (contract.start != null && contract.until != null) {
      return '${_formatDate(contract.start!)} - ${_formatDate(contract.until!)}';
    } else if (contract.until != null) {
      return 'Until ${_formatDate(contract.until!)}';
    } else if (contract.start != null) {
      return 'From ${_formatDate(contract.start!)}';
    }
    return 'Contract details not available';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}