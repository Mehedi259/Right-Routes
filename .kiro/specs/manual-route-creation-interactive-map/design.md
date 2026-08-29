# Design Document: Manual Route Creation with Interactive Map

## Overview

This design document specifies the technical implementation for the Manual Route Creation with Interactive Map feature in the Right Routes Flutter application. This feature enables users to create transportation routes through multiple input methods: manual text entry, voice-to-text, and interactive map pin placement. The feature integrates with the existing OCR-based permit import workflow and provides comprehensive route creation, editing, and validation capabilities.

### Purpose

The Manual Route Creation feature provides an alternative to document-based route import, allowing users to:
- Manually enter route waypoints via text or voice
- Visually place and manage waypoints on an interactive map
- Edit and reorder waypoints
- Calculate route distances
- Save and navigate routes

### Scope

This design covers:
- UI components for route creation and editing
- State management using GetX
- MapLibre GL integration for interactive mapping
- Geocoding and reverse geocoding services
- Voice-to-text input integration
- Data validation and error handling
- Integration with existing navigation flows

This design does NOT cover:
- Backend API implementation for route persistence
- Turn-by-turn navigation logic (handled by existing drive route map screen)
- OCR processing (handled by existing import permit feature)

## Architecture

### High-Level Architecture

The feature follows the existing app architecture using GetX for state management and follows the MVVM pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                    Route Creator Screen                      │
│                  (ManualRouteCreator)                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ├─── Observes State ───┐
                     │                       │
┌────────────────────▼────────────────┐    │
│     Route Controller                 │    │
│  (ManualRouteController)             │    │
│  - Manages waypoints (RxList)        │◄───┘
│  - Handles geocoding                 │
│  - Calculates distances              │
│  - Validates data                    │
└────────┬────────────┬─────────┬──────┘
         │            │         │
         │            │         │
    ┌────▼───┐   ┌───▼────┐  ┌─▼──────────┐
    │Geocoding│   │Voice   │  │MapLibre GL │
    │Service  │   │Service │  │Controller  │
    └─────────┘   └────────┘  └────────────┘
```

### Component Responsibilities

**ManualRouteCreator (View)**
- Renders UI components (map, input fields, buttons, waypoint list)
- Handles user interactions
- Observes controller state using Obx widgets
- Displays loading states and error messages

**ManualRouteController (Controller)**
- Manages application state (waypoints, route name, loading states)
- Coordinates between services (geocoding, voice input, map)
- Implements business logic (validation, distance calculation)
- Provides data for navigation to other screens

**GeocodingService**
- Converts address text to coordinates (forward geocoding)
- Converts coordinates to address text (reverse geocoding)
- Implements rate limiting and error handling
- Uses Nominatim OpenStreetMap API

**VoiceInputService**
- Manages speech-to-text functionality
- Handles microphone permissions
- Provides real-time speech recognition feedback
- Uses speech_to_text package

**MapLibreController**
- Manages map display and interactions
- Handles pin placement and removal
- Renders route polylines
- Manages camera positioning

## Components and Interfaces

### 1. ManualRouteCreator (Screen Widget)

**File**: `lib/views/home/home_new_routes/manual_route_creator/manual_route_creator.dart`

**Responsibilities**:
- Main screen widget for manual route creation
- Renders all UI components
- Handles user interactions
- Observes controller state

**Key UI Components**:
- App logo header
- Route name text field
- Permit group label
- Permit directions multi-line text field with microphone button
- MapLibre GL map widget
- Map control buttons (Add Pin, Delete Pin, Clear All, Update)
- Waypoint list with edit/delete actions
- Action buttons (Save, Drive)

**Dependencies**:
- ManualRouteController (GetX controller)
- MapLibreMapController (map instance)
- VoiceInputService
- flutter_screenutil (responsive sizing)
- flutter_svg (icon rendering)

### 2. ManualRouteController (GetX Controller)

**File**: `lib/views/home/home_new_routes/manual_route_creator/manual_route_controller.dart`

**State Properties**:
```dart
class ManualRouteController extends GetxController {
  // Core route data
  RxString routeName = ''.obs;
  RxString permitType = 'Permit 1'.obs;
  RxString permitDirections = ''.obs;
  RxList<Waypoint> waypoints = <Waypoint>[].obs;
  
  // Map interaction state
  RxBool isAddPinMode = false.obs;
  RxBool isDeletePinMode = false.obs;
  
  // Loading states
  RxBool isGeocodingLoading = false.obs;
  RxBool isVoiceListening = false.obs;
  RxBool isSaving = false.obs;
  
  // Calculated values
  RxDouble totalMiles = 0.0.obs;
  
  // Map controller
  MaplibreMapController? mapController;
  
  // Services
  final GeocodingService _geocodingService = GeocodingService();
  final VoiceInputService _voiceInputService = VoiceInputService();
}
```

**Key Methods**:
- `onInit()`: Initialize controller
- `onClose()`: Cleanup resources
- `addWaypointFromMap(LatLng coordinates)`: Add waypoint from map tap
- `addWaypointFromText(String address)`: Add waypoint from text input
- `deleteWaypoint(int index)`: Remove waypoint
- `updateWaypointText(int index, String newText)`: Edit waypoint address
- `reorderWaypoints(int oldIndex, int newIndex)`: Change waypoint sequence
- `clearAllWaypoints()`: Remove all waypoints
- `calculateTotalMiles()`: Compute route distance
- `updateRoutePolyline()`: Refresh map polyline
- `validateForSave()`: Check if route can be saved
- `validateForDrive()`: Check if route can be driven
- `saveRoute()`: Persist route to backend
- `startDriving()`: Navigate to drive screen
- `toggleVoiceInput()`: Start/stop voice recognition
- `enterAddPinMode()`: Enable pin addition mode
- `enterDeletePinMode()`: Enable pin deletion mode
- `exitInteractionMode()`: Exit pin interaction modes

### 3. Waypoint Data Model

**File**: `lib/models/waypoint.dart`

```dart
class Waypoint {
  final String id;
  String address;
  double? latitude;
  double? longitude;
  int index;
  
  Waypoint({
    required this.id,
    required this.address,
    this.latitude,
    this.longitude,
    required this.index,
  });
  
  bool get hasValidCoordinates => latitude != null && longitude != null;
  
  Map<String, dynamic> toJson() => {
    'location': address,
    'lat': latitude,
    'lng': longitude,
    'index': index,
  };
  
  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
    id: json['id'] ?? '',
    address: json['location'] ?? '',
    latitude: json['lat']?.toDouble(),
    longitude: json['lng']?.toDouble(),
    index: json['index'] ?? 0,
  );
}
```

### 4. GeocodingService

**File**: `lib/services/geocoding_service.dart`

**Responsibilities**:
- Forward geocoding (address → coordinates)
- Reverse geocoding (coordinates → address)
- Rate limiting
- Error handling

**Interface**:
```dart
class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const Duration _requestDelay = Duration(milliseconds: 500);
  DateTime? _lastRequestTime;
  
  Future<Map<String, double>?> geocodeAddress(String address);
  Future<String?> reverseGeocode(double latitude, double longitude);
  
  Future<void> _enforceRateLimit();
  String _buildForwardGeocodeUrl(String address);
  String _buildReverseGeocodeUrl(double lat, double lng);
}
```

**Geocoding Strategy**:
1. Clean input address (remove action verbs, parentheticals)
2. Add US country code filter
3. Parse response and extract lat/lng
4. Return null on failure (timeout, no results)
5. Implement 500ms delay between requests

**Reverse Geocoding Strategy**:
1. Send lat/lng to Nominatim reverse endpoint
2. Extract display_name from response
3. Return formatted address string
4. On failure, return "Location at [lat], [lng]"

### 5. VoiceInputService

**File**: `lib/services/voice_input_service.dart`

**Responsibilities**:
- Manage speech recognition
- Handle microphone permissions
- Provide recognition status callbacks
- Convert speech to text

**Interface**:
```dart
class VoiceInputService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  
  Future<bool> initialize();
  Future<bool> requestPermission();
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  });
  Future<void> stopListening();
  bool get isListening => _speechToText.isListening;
  bool get isAvailable => _isInitialized;
}
```

**Permission Handling**:
1. Check if permission already granted
2. Request permission if not granted
3. Show rationale dialog if denied
4. Offer to open settings if permanently denied

### 6. MapWidget Component

**File**: `lib/views/home/home_new_routes/manual_route_creator/widgets/map_widget.dart`

**Responsibilities**:
- Render MapLibre GL map
- Handle map gestures
- Display pins and polylines
- Manage camera positioning

**Configuration**:
```dart
class MapWidget extends StatefulWidget {
  final ManualRouteController controller;
  final Function(LatLng) onMapTap;
  
  @override
  Widget build(BuildContext context) {
    return MaplibreMap(
      styleString: 'mapbox://styles/mapbox/dark-v10',
      initialCameraPosition: CameraPosition(
        target: LatLng(42.0, -93.0),
        zoom: 6.0,
      ),
      onMapCreated: _onMapCreated,
      onMapClick: _onMapClick,
      onStyleLoadedCallback: _onStyleLoaded,
      myLocationEnabled: false,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      minMaxZoomPreference: MinMaxZoomPreference(3.0, 18.0),
    );
  }
}
```

**Pin Rendering**:
- Start pin: Red color (#FF0000)
- Middle pins: Orange color (#F58842)
- End pin: Green color (#00FF00)
- Use existing Map-Pin-orange.svg asset as base
- Apply color filters for different pin types

**Polyline Rendering**:
- Color: Blue (#4260F5) or Orange (#F58842)
- Width: 4 pixels
- Connect waypoints in sequence order
- Update when waypoints change

### 7. WaypointListWidget Component

**File**: `lib/views/home/home_new_routes/manual_route_creator/widgets/waypoint_list_widget.dart`

**Responsibilities**:
- Display scrollable list of waypoints
- Provide edit and delete actions
- Support drag-to-reorder (optional)
- Show empty state message

**List Item Structure**:
```dart
class WaypointListItem extends StatelessWidget {
  final Waypoint waypoint;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onDragStart;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFF1A2332), width: 3)),
      ),
      child: ListTile(
        leading: _buildPinIcon(),
        title: Text(waypoint.address),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: Icon(Icons.close), onPressed: onDelete),
            if (onDragStart != null)
              IconButton(icon: Icon(Icons.drag_handle), onPressed: onDragStart),
          ],
        ),
      ),
    );
  }
}
```

## Data Models

### RouteData (for navigation)

```dart
class RouteData {
  final String routeName;
  final String permitType;
  final List<String> routeSegments;
  final String startLocation;
  final String endLocation;
  final List<Map<String, dynamic>> routeWithCoordinates;
  final List<Map<String, dynamic>>? routeSteps;
  
  RouteData({
    required this.routeName,
    required this.permitType,
    required this.routeSegments,
    required this.startLocation,
    required this.endLocation,
    required this.routeWithCoordinates,
    this.routeSteps,
  });
  
  Map<String, dynamic> toJson() => {
    'routeName': routeName,
    'permitType': permitType,
    'routeSegments': routeSegments,
    'startLocation': startLocation,
    'endLocation': endLocation,
    'routeWithCoordinates': routeWithCoordinates,
    'routeSteps': routeSteps,
  };
}
```

### Distance Calculation

**Haversine Formula Implementation**:
```dart
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 3958.8; // miles
  
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  
  double a = sin(dLat / 2) * sin(dLat / 2) +
             cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
             sin(dLon / 2) * sin(dLon / 2);
  
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  
  return earthRadius * c;
}

double _toRadians(double degrees) => degrees * pi / 180;
```

## Error Handling

### Error Categories

**1. Network Errors**
- Geocoding API timeout (10 seconds)
- Geocoding API unavailable
- Backend API errors during save

**Error Handling Strategy**:
- Display user-friendly error messages
- Log detailed errors to console
- Provide retry options
- Graceful degradation (allow coordinate-based labels)

**2. Permission Errors**
- Microphone permission denied
- Microphone permission permanently denied

**Error Handling Strategy**:
- Show permission rationale dialog
- Offer to open app settings
- Disable voice input button if permission denied

**3. Validation Errors**
- Empty route name
- No waypoints for save
- Fewer than 2 waypoints for drive
- Invalid waypoint data

**Error Handling Strategy**:
- Display specific validation messages
- Highlight invalid fields
- Prevent action until validation passes

**4. Geocoding Errors**
- Address not found
- Ambiguous address
- Invalid coordinates

**Error Handling Strategy**:
- Allow manual coordinate entry
- Provide coordinate-based fallback labels
- Show warning but allow continuation

### Error Message Display

**Snackbar Configuration**:
```dart
void showError(String message) {
  Get.snackbar(
    'Error',
    message,
    backgroundColor: AppColors.orange,
    colorText: Colors.white,
    duration: Duration(seconds: 3),
    snackPosition: SnackPosition.BOTTOM,
  );
}

void showSuccess(String message) {
  Get.snackbar(
    'Success',
    message,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    duration: Duration(seconds: 2),
    snackPosition: SnackPosition.BOTTOM,
  );
}
```

## Testing Strategy

### Testing Approach

This feature is **NOT suitable for property-based testing** because:
1. **UI Rendering**: The feature is primarily UI-focused (map display, buttons, lists, text fields)
2. **External Services**: Heavy reliance on external APIs (Nominatim geocoding, speech recognition)
3. **State Management**: Testing focuses on state transitions and UI updates, not pure functions
4. **User Interactions**: Testing requires simulating user gestures (taps, drags, voice input)

Instead, the testing strategy will use:
- **Widget tests** for UI components
- **Unit tests** for business logic (distance calculation, validation)
- **Integration tests** for service interactions
- **Mock-based tests** for external dependencies

### Unit Tests

**File**: `test/unit/manual_route_controller_test.dart`

**Test Cases**:
1. **Distance Calculation**
   - Test Haversine formula with known coordinates
   - Verify distance accuracy within acceptable margin
   - Test edge cases (same location, antipodal points)

2. **Validation Logic**
   - Test save validation (route name, waypoint count)
   - Test drive validation (minimum 2 waypoints)
   - Test waypoint data validation

3. **Waypoint Management**
   - Test adding waypoints
   - Test removing waypoints
   - Test reordering waypoints
   - Test clearing all waypoints

4. **State Updates**
   - Test route name updates
   - Test permit type updates
   - Test loading state transitions

**Example Test**:
```dart
test('calculateDistance returns correct value for known coordinates', () {
  final controller = ManualRouteController();
  
  // New York to Los Angeles (approx 2451 miles)
  double distance = controller.calculateDistance(
    40.7128, -74.0060,  // NYC
    34.0522, -118.2437  // LA
  );
  
  expect(distance, closeTo(2451, 50)); // Within 50 miles
});

test('validateForSave fails when route name is empty', () {
  final controller = ManualRouteController();
  controller.routeName.value = '';
  controller.waypoints.add(Waypoint(
    id: '1',
    address: 'Test Location',
    latitude: 42.0,
    longitude: -93.0,
    index: 0,
  ));
  
  expect(controller.validateForSave(), isFalse);
});
```

### Widget Tests

**File**: `test/widget/manual_route_creator_test.dart`

**Test Cases**:
1. **UI Rendering**
   - Verify all UI components render correctly
   - Test responsive sizing with different screen sizes
   - Verify theme consistency (colors, fonts)

2. **User Interactions**
   - Test button taps (Add Pin, Delete Pin, Clear All, Save, Drive)
   - Test text input (route name, permit directions)
   - Test waypoint list interactions (edit, delete)

3. **State-Driven UI Updates**
   - Test loading indicators appear during operations
   - Test waypoint list updates when waypoints change
   - Test total miles display updates

**Example Test**:
```dart
testWidgets('displays empty state message when no waypoints', (tester) async {
  await tester.pumpWidget(
    GetMaterialApp(
      home: ManualRouteCreator(),
    ),
  );
  
  expect(find.text('No waypoints added yet'), findsOneWidget);
});

testWidgets('Add Pin button enters pin addition mode', (tester) async {
  await tester.pumpWidget(
    GetMaterialApp(
      home: ManualRouteCreator(),
    ),
  );
  
  await tester.tap(find.text('Add Pin'));
  await tester.pump();
  
  final controller = Get.find<ManualRouteController>();
  expect(controller.isAddPinMode.value, isTrue);
});
```

### Integration Tests

**File**: `test/integration/geocoding_service_test.dart`

**Test Cases**:
1. **Geocoding Service**
   - Test forward geocoding with valid address
   - Test forward geocoding with invalid address
   - Test reverse geocoding with valid coordinates
   - Test rate limiting behavior
   - Test timeout handling

2. **Voice Input Service**
   - Test permission request flow
   - Test speech recognition initialization
   - Test start/stop listening

**Example Test**:
```dart
test('geocodeAddress returns coordinates for valid address', () async {
  final service = GeocodingService();
  
  final result = await service.geocodeAddress('Des Moines, Iowa, USA');
  
  expect(result, isNotNull);
  expect(result!['lat'], closeTo(41.6, 0.5));
  expect(result['lng'], closeTo(-93.6, 0.5));
});

test('reverseGeocode returns address for valid coordinates', () async {
  final service = GeocodingService();
  
  final result = await service.reverseGeocode(41.5868, -93.6250);
  
  expect(result, isNotNull);
  expect(result, contains('Iowa'));
});
```

### Mock-Based Tests

**File**: `test/mocks/mock_geocoding_service.dart`

**Purpose**: Mock external services for controller testing

```dart
class MockGeocodingService extends Mock implements GeocodingService {}
class MockVoiceInputService extends Mock implements VoiceInputService {}
class MockMaplibreMapController extends Mock implements MaplibreMapController {}

test('addWaypointFromMap calls reverse geocoding', () async {
  final mockGeocoding = MockGeocodingService();
  final controller = ManualRouteController(geocodingService: mockGeocoding);
  
  when(mockGeocoding.reverseGeocode(any, any))
      .thenAnswer((_) async => 'Test Address');
  
  await controller.addWaypointFromMap(LatLng(42.0, -93.0));
  
  verify(mockGeocoding.reverseGeocode(42.0, -93.0)).called(1);
  expect(controller.waypoints.length, 1);
  expect(controller.waypoints.first.address, 'Test Address');
});
```

### Manual Testing Checklist

**Functional Testing**:
- [ ] Add waypoints via map tap
- [ ] Add waypoints via text input
- [ ] Add waypoints via voice input
- [ ] Edit waypoint addresses
- [ ] Delete individual waypoints
- [ ] Clear all waypoints
- [ ] Reorder waypoints (if implemented)
- [ ] Save route with valid data
- [ ] Attempt save with invalid data (verify validation)
- [ ] Start driving with valid route
- [ ] Verify route appears correctly on drive screen

**UI/UX Testing**:
- [ ] Verify responsive layout on different screen sizes
- [ ] Test map gestures (pan, zoom, rotate)
- [ ] Verify pin colors (red start, orange middle, green end)
- [ ] Verify polyline renders correctly
- [ ] Test voice input button states
- [ ] Verify loading indicators appear during operations
- [ ] Test error message display

**Integration Testing**:
- [ ] Verify geocoding works for various addresses
- [ ] Test reverse geocoding for map taps
- [ ] Verify voice recognition accuracy
- [ ] Test navigation to confirmation screen
- [ ] Verify data passed to drive screen

**Performance Testing**:
- [ ] Test with 2 waypoints
- [ ] Test with 10 waypoints
- [ ] Test with 50 waypoints
- [ ] Verify map performance with many pins
- [ ] Test geocoding rate limiting

## Implementation Notes

### Dependencies

**Required Packages** (already in pubspec.yaml):
- `get: ^4.7.2` - State management and navigation
- `flutter_screenutil: ^5.9.3` - Responsive sizing
- `flutter_svg: ^2.2.3` - SVG icon rendering
- `maplibre_gl: ^0.25.0` - Map display
- `speech_to_text: ^7.3.0` - Voice input
- `permission_handler: ^11.3.0` - Permission management
- `http: ^1.6.0` - Network requests
- `geolocator: ^11.0.0` - Location utilities

### File Structure

```
lib/
├── views/
│   └── home/
│       └── home_new_routes/
│           └── manual_route_creator/
│               ├── manual_route_creator.dart
│               ├── manual_route_controller.dart
│               └── widgets/
│                   ├── map_widget.dart
│                   ├── waypoint_list_widget.dart
│                   ├── waypoint_list_item.dart
│                   └── voice_input_button.dart
├── services/
│   ├── geocoding_service.dart
│   └── voice_input_service.dart
├── models/
│   ├── waypoint.dart
│   └── route_data.dart
└── utils/
    └── distance_calculator.dart
```

### Route Registration

**Add to `lib/core/routes/all_routes.dart`**:
```dart
static const String manualRouteCreator = "/ManualRouteCreator";

GetPage(name: manualRouteCreator, page: () => ManualRouteCreator()),
```

### Navigation Integration

**From import_your_permit.dart**:
```dart
GestureDetector(
  onTap: () => Get.toNamed(AppRoutes.manualRouteCreator),
  child: Text('Create Route Manually'),
)
```

**To edit_confirm_start_your_route.dart**:
```dart
void saveRoute() async {
  if (!validateForSave()) return;
  
  final routeData = RouteData(
    routeName: routeName.value,
    permitType: permitType.value,
    routeSegments: waypoints.map((w) => w.address).toList(),
    startLocation: waypoints.first.address,
    endLocation: waypoints.last.address,
    routeWithCoordinates: waypoints.map((w) => w.toJson()).toList(),
  );
  
  Get.toNamed(
    AppRoutes.editConfirmStartYourRoute,
    arguments: routeData.toJson(),
  );
}
```

### Styling Constants

**Colors** (from AppColors):
- Primary action: `AppColors.orange` (#F58842)
- Success: `Colors.green`
- Error: `AppColors.orange` or `Colors.red`
- Background: Navy blue with map pattern
- Text: White on dark backgrounds

**Typography**:
- Headers: League Gothic, 32.sp
- Body: Lato, 18.sp
- Buttons: Lato, 15.sp, bold

**Spacing**:
- Button height: 30.h
- Button width: 80.w (small), 120.w (medium)
- Border radius: 5.r to 8.r
- Padding: 19.w horizontal, 20.h vertical

### Accessibility Considerations

**Semantic Labels**:
- All buttons: Descriptive labels for screen readers
- Map widget: "Interactive route map"
- Waypoint list items: "Waypoint [index]: [address]"
- Text fields: Clear purpose labels

**Touch Targets**:
- Minimum 44x44 points for all interactive elements
- Adequate spacing between buttons

**Color Contrast**:
- White text on dark backgrounds: 21:1 ratio (exceeds WCAG AAA)
- Orange buttons: Verify 4.5:1 contrast with white text

**Text Scaling**:
- Use .sp units for all text sizes
- Test with system text scaling up to 200%
- Ensure no text truncation at large sizes

## Future Enhancements

### Phase 2 Features

1. **Offline Support**
   - Cache geocoding results
   - Store routes locally
   - Sync when online

2. **Route Optimization**
   - Suggest optimal waypoint order
   - Calculate actual road distances (not straight-line)
   - Integrate with routing APIs

3. **Advanced Map Features**
   - Traffic overlay
   - Satellite view
   - Street view integration
   - Custom map styles

4. **Collaboration**
   - Share routes with team members
   - Real-time collaborative editing
   - Route templates

5. **Analytics**
   - Track route creation patterns
   - Identify common waypoints
   - Usage statistics

### Technical Debt Considerations

1. **Geocoding Rate Limiting**
   - Current: 500ms delay between requests
   - Future: Implement exponential backoff
   - Consider caching geocoding results

2. **Map Performance**
   - Current: All pins rendered simultaneously
   - Future: Implement clustering for many waypoints
   - Consider viewport-based rendering

3. **State Persistence**
   - Current: State lost on app restart
   - Future: Persist draft routes to local storage
   - Implement auto-save functionality

4. **Error Recovery**
   - Current: Basic error messages
   - Future: Implement retry mechanisms
   - Add offline queue for failed operations

## Conclusion

This design provides a comprehensive implementation plan for the Manual Route Creation with Interactive Map feature. The architecture follows existing app patterns using GetX for state management, integrates with MapLibre GL for mapping, and provides multiple input methods (text, voice, map interaction) for route creation.

The feature is designed to be maintainable, testable, and extensible, with clear separation of concerns between UI, business logic, and services. The testing strategy focuses on unit tests for business logic, widget tests for UI components, and integration tests for service interactions, which is appropriate for this UI-heavy feature with external service dependencies.

Implementation should proceed in phases:
1. Core UI and state management
2. Geocoding integration
3. Voice input integration
4. Map interactions and polyline rendering
5. Validation and error handling
6. Navigation integration
7. Testing and refinement
