import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/components/app_radio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/components/app_back_button.dart';
import '../../../core/services/location_service.dart';

class NewAddressPage extends StatefulWidget {
  const NewAddressPage({super.key});

  @override
  State<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewAddressPage> {
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  bool _isDetectingLocation = false;

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _isDetectingLocation = true;
    });

    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to get location. Please enable location services.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          _addressLine1Controller.text = '${place.street ?? ''} ${place.subLocality ?? ''}'.trim();
          _addressLine2Controller.text = place.locality ?? '';
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _zipCodeController.text = place.postalCode ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location detected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error detecting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isDetectingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'New Address',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(AppDefaults.padding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding * 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* <---- Detect Location Button -----> */
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isDetectingLocation ? null : _detectLocation,
                  icon: _isDetectingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(_isDetectingLocation ? 'Detecting...' : 'Detect My Location'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <----  Full Name -----> */
              const Text("Full Name"),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Phone Number -----> */
              const Text("Phone Number"),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Address Line 1 -----> */
              const Text("Address Line 1"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressLine1Controller,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Address Line 2 -----> */
              const Text("Address Line 2"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressLine2Controller,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- City -----> */
              const Text("City"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- State and Zip Code -----> */
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("State"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stateController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDefaults.padding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Zip Code"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _zipCodeController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDefaults.padding),
                child: Row(
                  children: [
                    AppRadio(isActive: true),
                    SizedBox(width: AppDefaults.padding),
                    Text('Make Default Shipping Address'),
                  ],
                ),
              ),
              const SizedBox(height: AppDefaults.padding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Save Adress'),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
