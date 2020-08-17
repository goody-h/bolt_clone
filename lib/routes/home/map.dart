import 'package:bolt_clone/routes/home/home.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bolt_clone/blocs/trip_bloc/trip.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Map extends StatelessWidget {
  const Map({
    Key key,
    this.loadMap,
    this.onLoad,
    this.pin,
    this.marker,
    this.route,
    this.baseBottomInset,
  }) : super(key: key);

  final bool loadMap;
  final Function(GoogleMapController) onLoad;
  final SelectionPinController pin;
  final RouteController route;
  final MarkerController marker;
  final double baseBottomInset;

  // Initial location of the Map view
  final CameraPosition _initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0), zoom: 10);

  @override
  Widget build(BuildContext context) {
    if (!loadMap) {
      return SizedBox.shrink();
    }
    final state = BlocProvider.of<TripBloc>(context).state;
    final markers = marker.getMarkers(context, state);
    final polylines = route.getRoute();

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
      padding: EdgeInsets.only(bottom: baseBottomInset),
      markers: markers != null ? Set<Marker>.from(markers) : null,
      polylines: polylines != null ? Set<Polyline>.from(polylines) : null,
    );
  }
}
