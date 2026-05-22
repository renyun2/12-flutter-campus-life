import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/models.dart';
import '../../shared/application/api_providers.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  List<MapPoi>? _pois;

  @override
  void initState() {
    super.initState();
    ref.read(campusApiProvider).getMapPois().then((p) => setState(() => _pois = p));
  }

  void _showPoi(MapPoi poi) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poi.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(poi.description),
            const SizedBox(height: 8),
            Text('路径示意：从当前位置步行约 5 分钟（Mock）'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const center = LatLng(39.9042, 116.4074);

    return Scaffold(
      appBar: AppBar(title: const Text('校园地图')),
      body: _pois == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.campus.campus_life',
                ),
                MarkerLayer(
                  markers: _pois!
                      .map(
                        (p) => Marker(
                          point: LatLng(p.lat, p.lng),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showPoi(p),
                            child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}
