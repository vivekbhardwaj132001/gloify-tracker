import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tracker_app/providers/location_provider.dart';
import 'package:tracker_app/screens/map_route_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _launchExternalMap(BuildContext context, double startLat, double startLng, double endLat, double endLng) async {
    // google.navigation:q=lat,lng format or maps.apple.com
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyLogsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Location History', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E2C),
              Color(0xFF232526),
              Color(0xFF414345),
            ],
          ),
        ),
        child: SafeArea(
          child: historyAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 80, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        'NO HISTORY LOGS AVAILABLE.',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), letterSpacing: 1.5),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 32),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final startLoc = log['startLoc'];
                  final endLoc = log['endLoc'];
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _launchExternalMap(
                        context, 
                        startLoc['lat'], startLoc['lng'],
                        endLoc['lat'], endLoc['lng']
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF00C6FF).withOpacity(0.5), blurRadius: 8),
                                    ],
                                  ),
                                  child: const Icon(Icons.route, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    DateFormat('MMM d, yyyy - h:mm a').format(log['startTime']),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.map, color: Colors.white70),
                                  tooltip: 'View Route in App',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapRouteScreen(
                                          sessionId: log['sessionId'],
                                          startLoc: startLoc,
                                          endLoc: endLoc,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.my_location, color: Color(0xFF00FF87), size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Start Location', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                                      Text('${startLoc['lat'].toStringAsFixed(5)}, ${startLoc['lng'].toStringAsFixed(5)}', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
                              child: Icon(Icons.more_vert, size: 16, color: Colors.white.withOpacity(0.3)),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFFFF3B30), size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('End Location', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                                      Text('${endLoc['lat'].toStringAsFixed(5)}, ${endLoc['lng'].toStringAsFixed(5)}', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: Text(
                                    '${log['endTime'].difference(log['startTime']).inMinutes} mins • ${log['pointCount']} points',
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0072FF).withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.navigation, size: 18, color: Colors.white),
                                    label: const Text('Navigate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                    ),
                                    onPressed: () => _launchExternalMap(
                                      context, 
                                      startLoc['lat'], startLoc['lng'],
                                      endLoc['lat'], endLoc['lng']
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00FF87))),
            error: (err, stack) => Center(child: Text('Error loading history: $err', style: const TextStyle(color: Colors.redAccent))),
          ),
        ),
      ),
    );
  }
}
