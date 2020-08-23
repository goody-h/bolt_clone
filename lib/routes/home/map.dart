import 'package:bolt_clone/routes/home/home.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class MapData {
  MapData({this.mapTag, this.bottomPadding, this.secondaryPadding});
  String mapTag;
  double bottomPadding;
  double secondaryPadding;
}

class Map extends StatelessWidget {
  const Map({
    Key key,
    this.controller,
    this.loadMap,
    this.onLoad,
    this.pin,
    this.marker,
    this.route,
  }) : super(key: key);

  final Completer<bool> loadMap;
  final Function(GoogleMapController) onLoad;
  final SelectionPinController pin;
  final RouteController route;
  final MarkerController marker;
  final MapDataController controller;

  // Initial location of the Map view
  final CameraPosition _initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0), zoom: 10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MapData>(
      stream: controller.stream,
      initialData: controller.data,
      builder: (context, snap) {
        if (!loadMap.isCompleted) {
          return SizedBox.shrink();
        }

        print("map padding bottom ${controller.data.bottomPadding}");

        return BlocBuilder<TripBloc, TripState>(
          builder: (context, state) {
            final markers = marker.getMarkers(context, state);
            final polylines = route.getRoute(state);
            if (BlocProvider.of<TripBloc>(context).stateId == state.stateId) {
              pin.positionMap(state);
            }
            return GoogleMap(
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: onLoad,
              onCameraMove: (CameraPosition position) {
                pin.movePinPosition(position.target);
              },
              onCameraIdle: () {
                pin.updatePinPosition(context);
              },
              padding: EdgeInsets.only(bottom: controller.data.bottomPadding),
              markers: markers != null ? Set<Marker>.from(markers) : null,
              polylines:
                  polylines != null ? Set<Polyline>.from(polylines) : null,
            );
          },
        );
      },
    );
  }
}
