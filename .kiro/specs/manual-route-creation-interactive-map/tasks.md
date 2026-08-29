# Implementation Plan: Manual Route Creation with Interactive Map

## Overview

This implementation plan breaks down the Manual Route Creation with Interactive Map feature into discrete coding tasks. The feature enables users to create transportation routes through text entry, voice-to-text, and interactive map pin placement using Flutter, GetX state management, and MapLibre GL.

The implementation follows an incremental approach: core data models → state management → UI components → services → integration → testing. Each task builds on previous work and includes validation through automated tests.

## Tasks

- [ ] 1. Set up project structure and core data models
  - Create directory structure: `lib/views/home/home_new_routes/manual_route_creator/` and `lib/views/home/home_new_routes/manual_route_creator/widgets/`
  - Create `lib/models/waypoint.dart` with Waypoint class including id, address, latitude, longitude, index properties
  - Implement `hasValidCoordinates` getter, `toJson()` and `fromJson()` methods
  - Create `lib/models/route_data.dart` with RouteData class for navigation data transfer
  - Create `lib/utils/distance_calculator.dart` with Haversine formula implementation
  - _Requirements: 1.6, 14.4, 20.2-20.7_

- [ ]* 1.1 Write unit tests for Waypoint model
  - Test JSON serialization and deserialization
  - Test hasValidCoordinates getter with various coordinate states
  - _Requirements: 1.6, 29.4_

- [ ]* 1.2 Write unit tests for distance calculation
  - Test Haversine formula with known coordinate pairs (NYC to LA, etc.)
  - Verify distance accuracy within acceptable margin (±50 miles)
  - Test edge cases: same location (0 miles), antipodal points
  - _Requirements: 14.4_

- [ ] 2. Implement ManualRouteController with core state management
  - Create `lib/views/home/home_new_routes/manual_route_creator/manual_route_controller.dart`
  - Extend GetxController with observable state properties: routeName (RxString), permitType (RxString), permitDirections (RxString), waypoints (RxList<Waypoint>), isAddPinMode (RxBool), isDeletePinMode (RxBool), isGeocodingLoading (RxBool), isVoiceListening (RxBool), isSaving (RxBool), totalMiles (RxDouble)
  - Implement onInit() and onClose() lifecycle methods
  - Implement addWaypoint(), deleteWaypoint(int index), clearAllWaypoints() methods
  - Implement calculateTotalMiles() using distance calculator utility
  - Implement enterAddPinMode(), enterDeletePinMode(), exitInteractionMode() methods
  - _Requirements: 1.6, 4.1-4.2, 5.1-5.2, 6.4-6.7, 14.2-14.6, 26.1-26.10_

- [ ]* 2.1 Write unit tests for ManualRouteController waypoint management
  - Test adding waypoints to empty list
  - Test deleting waypoints by index
  - Test clearing all waypoints
  - Test waypoint list state updates
  - _Requirements: 1.6, 4.6, 5.4-5.5, 6.4-6.5_

- [ ]* 2.2 Write unit tests for ManualRouteController distance calculation
  - Test calculateTotalMiles() with 2 waypoints
  - Test calculateTotalMiles() with multiple waypoints
  - Test calculateTotalMiles() with fewer than 2 waypoints (should return 0.0)
  - Verify totalMiles observable updates correctly
  - _Requirements: 14.2-14.7_

- [ ]* 2.3 Write unit tests for ManualRouteController interaction modes
  - Test enterAddPinMode() sets isAddPinMode to true
  - Test enterDeletePinMode() sets isDeletePinMode to true
  - Test exitInteractionMode() resets both mode flags
  - _Requirements: 4.1-4.2, 5.1-5.2_

- [ ] 3. Implement GeocodingService for address and coordinate conversion
  - Create `lib/services/geocoding_service.dart`
  - Implement forward geocoding: geocodeAddress(String address) returning Future<Map<String, double>?>
  - Implement reverse geocoding: reverseGeocode(double latitude, double longitude) returning Future<String?>
  - Use Nominatim OpenStreetMap API with base URL https://nominatim.openstreetmap.org
  - Add User-Agent header "RightRoutes/1.0" to all requests
  - Implement rate limiting with 500ms delay between requests using _enforceRateLimit()
  - Add 10-second timeout for all requests
  - Return null on failure (timeout, no results, network error)
  - For reverse geocoding failures, return "Location at [lat], [lng]" format with 4 decimal places
  - _Requirements: 4.4-4.5, 10.4-10.7, 21.1-21.10, 22.1-22.8_

- [ ]* 3.1 Write integration tests for GeocodingService
  - Test geocodeAddress() with valid US address (e.g., "Des Moines, Iowa, USA")
  - Test geocodeAddress() with invalid address returns null
  - Test reverseGeocode() with valid coordinates returns address string
  - Test reverseGeocode() with ocean coordinates returns fallback format
  - Test rate limiting enforces 500ms delay between requests
  - Mock HTTP client for predictable test results
  - _Requirements: 21.1-21.10, 22.1-22.8_

- [ ] 4. Implement VoiceInputService for speech-to-text
  - Create `lib/services/voice_input_service.dart`
  - Use speech_to_text package for speech recognition
  - Implement initialize() method to set up speech recognition
  - Implement requestPermission() method using permission_handler package
  - Implement startListening() with onResult and onError callbacks
  - Implement stopListening() method
  - Add isListening and isAvailable getters
  - Handle permission denied scenarios with appropriate error messages
  - _Requirements: 2.2-2.10, 28.1-28.7_

- [ ]* 4.1 Write unit tests for VoiceInputService permission handling
  - Test requestPermission() when permission granted
  - Test requestPermission() when permission denied
  - Test requestPermission() when permission permanently denied
  - Mock permission_handler for predictable test results
  - _Requirements: 2.2-2.3, 2.7, 28.1-28.7_

- [ ] 5. Integrate GeocodingService into ManualRouteController
  - Add GeocodingService instance to ManualRouteController
  - Implement addWaypointFromMap(LatLng coordinates) method
  - Call reverseGeocode() when adding waypoint from map
  - Update isGeocodingLoading state during geocoding operations
  - Create waypoint with address from reverse geocoding or coordinate-based fallback
  - Implement updateWaypointText(int index, String newText) method
  - Call geocodeAddress() when waypoint text is updated
  - Update waypoint coordinates if geocoding succeeds
  - Display warning if geocoding fails but preserve original coordinates
  - _Requirements: 4.3-4.10, 10.1-10.10, 21.1-21.10, 22.1-22.8_

- [ ]* 5.1 Write unit tests for controller geocoding integration
  - Test addWaypointFromMap() calls reverseGeocode() with correct coordinates
  - Test addWaypointFromMap() creates waypoint with returned address
  - Test addWaypointFromMap() creates waypoint with fallback label when geocoding fails
  - Test updateWaypointText() calls geocodeAddress() with new text
  - Test updateWaypointText() updates coordinates when geocoding succeeds
  - Test updateWaypointText() preserves coordinates when geocoding fails
  - Mock GeocodingService for predictable test results
  - _Requirements: 4.3-4.10, 10.4-10.10_

- [ ] 6. Integrate VoiceInputService into ManualRouteController
  - Add VoiceInputService instance to ManualRouteController
  - Implement toggleVoiceInput() method
  - Request microphone permission on first use
  - Update isVoiceListening state when listening starts/stops
  - Append recognized text to permitDirections observable
  - Handle permission denied and recognition error scenarios
  - _Requirements: 2.1-2.10, 28.1-28.7_

- [ ]* 6.1 Write unit tests for controller voice input integration
  - Test toggleVoiceInput() requests permission on first use
  - Test toggleVoiceInput() starts listening when permission granted
  - Test toggleVoiceInput() stops listening when already listening
  - Test recognized text appends to permitDirections
  - Test error handling when permission denied
  - Mock VoiceInputService for predictable test results
  - _Requirements: 2.1-2.10_

- [ ] 7. Implement validation logic in ManualRouteController
  - Implement validateForSave() method checking: route name not empty (trimmed), at least one waypoint exists, each waypoint has valid coordinates or address
  - Implement validateForDrive() method checking: at least two waypoints exist, each waypoint has valid coordinates
  - Return validation result as boolean
  - Store validation error messages for UI display
  - _Requirements: 17.2-17.5, 18.2-18.4, 29.1-29.8_

- [ ]* 7.1 Write unit tests for validation logic
  - Test validateForSave() fails when route name is empty
  - Test validateForSave() fails when route name is whitespace only
  - Test validateForSave() fails when no waypoints exist
  - Test validateForSave() succeeds with valid route name and waypoints
  - Test validateForDrive() fails with fewer than 2 waypoints
  - Test validateForDrive() fails when waypoints lack coordinates
  - Test validateForDrive() succeeds with 2+ waypoints with valid coordinates
  - _Requirements: 17.2-17.5, 18.2-18.4, 29.1-29.8_

- [ ] 8. Implement MapWidget component with MapLibre GL
  - Create `lib/views/home/home_new_routes/manual_route_creator/widgets/map_widget.dart`
  - Use MaplibreMap widget with dark style (mapbox://styles/mapbox/dark-v10)
  - Set initial camera position to LatLng(42.0, -93.0) with zoom 6.0
  - Implement onMapCreated callback to store MaplibreMapController reference
  - Implement onMapClick callback to handle map tap events
  - Implement onStyleLoadedCallback for post-initialization setup
  - Enable map gestures: pan, zoom, rotate, tilt, scroll
  - Set minMaxZoomPreference to MinMaxZoomPreference(3.0, 18.0)
  - Set minimum height to 300 device-independent pixels
  - _Requirements: 3.1-3.8, 27.1-27.10_

- [ ] 9. Implement pin rendering in MapWidget
  - Add method to add symbol (pin) to map using mapController.addSymbol()
  - Use Map-Pin-orange.svg asset as base icon
  - Implement pin color differentiation: red for start pin (#FF0000), orange for middle pins (#F58842), green for end pin (#00FF00)
  - Apply color filters based on waypoint position in list
  - Store symbol references for later removal
  - Add method to remove symbol using mapController.removeSymbol()
  - Update pin colors when waypoints are reordered
  - _Requirements: 4.7, 5.5, 8.1-8.8_

- [ ] 10. Implement polyline rendering in MapWidget
  - Add method to draw polyline connecting waypoints using mapController.addLine()
  - Use blue (#4260F5) or orange (#F58842) color with 4-pixel width
  - Connect waypoints in sequence order from waypoints list
  - Only render polyline when 2 or more waypoints exist
  - Store line reference for later removal
  - Add method to update polyline when waypoints change
  - Remove old polyline before adding new one
  - Ensure polyline renders above map tiles but below pins
  - _Requirements: 7.1-7.8_

- [ ] 11. Implement map interaction modes in MapWidget
  - Accept controller reference as parameter
  - In onMapClick callback, check controller.isAddPinMode
  - If in add pin mode, call controller.addWaypointFromMap(tappedLatLng)
  - Check controller.isDeletePinMode in onMapClick
  - If in delete pin mode, identify tapped pin and call controller.deleteWaypoint(index)
  - Implement camera animation to show all waypoints using animateCamera()
  - Calculate bounds from waypoint coordinates
  - _Requirements: 4.1-4.10, 5.1-5.9_

- [ ]* 11.1 Write widget tests for MapWidget
  - Test MapWidget renders with correct initial camera position
  - Test map gestures are enabled (pan, zoom, rotate)
  - Test onMapCreated callback stores controller reference
  - Mock MaplibreMapController for testing
  - _Requirements: 3.1-3.8_

- [ ] 12. Implement WaypointListWidget component
  - Create `lib/views/home/home_new_routes/manual_route_creator/widgets/waypoint_list_widget.dart`
  - Accept controller reference and waypoints list as parameters
  - Use Obx to observe waypoints list changes
  - Render scrollable ListView of waypoint items
  - Display "No waypoints added yet" message when list is empty
  - Use white text on dark background matching app theme
  - Add left border accent (3-pixel width, color #1A2332)
  - _Requirements: 9.1-9.9_

- [ ] 13. Implement WaypointListItem component
  - Create `lib/views/home/home_new_routes/manual_route_creator/widgets/waypoint_list_item.dart`
  - Accept waypoint, onEdit, onDelete callbacks as parameters
  - Display waypoint address text in ListTile title
  - Add edit icon button (Icons.edit) in trailing section
  - Add delete icon button (Icons.close) in trailing section
  - Use white text on dark background
  - Add left border accent matching design
  - Display pin icon in leading section with color based on position (red/orange/green)
  - _Requirements: 9.2-9.9, 11.1-11.7_

- [ ]* 13.1 Write widget tests for WaypointListWidget and WaypointListItem
  - Test empty state message displays when no waypoints
  - Test waypoint list items render for each waypoint
  - Test edit button tap triggers onEdit callback
  - Test delete button tap triggers onDelete callback
  - Test waypoint address text displays correctly
  - _Requirements: 9.1-9.9, 11.1-11.7_

- [ ] 14. Implement waypoint editing functionality
  - In ManualRouteController, implement updateWaypointText(int index, String newText)
  - Show editable text field when edit button tapped
  - Pre-fill text field with current waypoint address
  - On confirm, call geocodeAddress() with new text
  - If geocoding succeeds, update waypoint coordinates and address
  - If geocoding fails, preserve original coordinates and show warning
  - Update map pin position if coordinates changed
  - Update polyline after coordinate changes
  - _Requirements: 10.1-10.10_

- [ ] 15. Implement waypoint deletion functionality
  - In WaypointListItem, wire delete button to controller.deleteWaypoint(index)
  - In ManualRouteController.deleteWaypoint(), remove waypoint from list
  - Remove corresponding pin from map
  - Recalculate polyline after removal
  - Update pin colors if first or last waypoint was removed
  - Allow deletion even if only one waypoint remains
  - No confirmation dialog required for list deletion
  - _Requirements: 11.1-11.7_

- [ ] 16. Implement VoiceInputButton component
  - Create `lib/views/home/home_new_routes/manual_route_creator/widgets/voice_input_button.dart`
  - Display microphone icon button adjacent to permit directions field
  - Use Mic-white.svg asset from assets/icons/
  - Show recording indicator when isVoiceListening is true (pulsing animation or color change)
  - Wire tap event to controller.toggleVoiceInput()
  - Display error message if permission denied
  - _Requirements: 2.1-2.10_

- [ ]* 16.1 Write widget tests for VoiceInputButton
  - Test microphone button renders correctly
  - Test button tap triggers toggleVoiceInput()
  - Test recording indicator displays when listening
  - Test error message displays when permission denied
  - _Requirements: 2.1-2.10_

- [ ] 17. Implement ManualRouteCreator main screen layout
  - Create `lib/views/home/home_new_routes/manual_route_creator/manual_route_creator.dart`
  - Use Scaffold with navy blue background and map pattern from ImageManager.mapBackground
  - Add SafeArea wrapper
  - Display app logo at top using ImageManager.splashScreenLogo
  - Add route name text field with white text, dark background, label "Route Name", max length 100
  - Add permit group label displaying controller.permitType
  - Add permit directions multi-line text field with white text, dark background
  - Add VoiceInputButton adjacent to permit directions field
  - Add MapWidget with minimum height 300.h
  - Add map control buttons row: Add Pin, Delete Pin, Clear All, Update
  - Add WaypointListWidget below map
  - Add action buttons at bottom: Save (green), Drive (orange)
  - Use flutter_screenutil for responsive sizing (.sp, .w, .h units)
  - _Requirements: 1.1-1.5, 2.1, 3.1-3.8, 13.1-13.7, 25.1-25.9_

- [ ] 18. Implement map control button actions
  - Wire "Add Pin" button to controller.enterAddPinMode()
  - Display visual indicator when isAddPinMode is true (button highlight or text change)
  - Wire "Delete Pin" button to controller.enterDeletePinMode()
  - Display visual indicator when isDeletePinMode is true
  - Wire "Clear All" button to show confirmation dialog
  - Confirmation dialog asks "Are you sure you want to clear all pins?"
  - On confirm, call controller.clearAllWaypoints()
  - On cancel, preserve waypoints
  - Wire "Update" button to refresh map display and recalculate distances
  - Style all buttons with orange background (AppColors.orange), white text, rounded corners 5.r
  - _Requirements: 4.1-4.10, 5.1-5.9, 6.1-6.9, 16.1-16.8_

- [ ]* 18.1 Write widget tests for map control buttons
  - Test "Add Pin" button enters add pin mode
  - Test "Delete Pin" button enters delete pin mode
  - Test "Clear All" button shows confirmation dialog
  - Test confirmation dialog "Yes" clears all waypoints
  - Test confirmation dialog "No" preserves waypoints
  - Test "Update" button triggers map refresh
  - _Requirements: 4.1-4.10, 5.1-5.9, 6.1-6.9, 16.1-16.8_

- [ ] 19. Implement total miles display
  - Add "Total Miles" label and value display in ManualRouteCreator
  - Use Obx to observe controller.totalMiles
  - Display value with one decimal place (e.g., "45.3 miles")
  - Use white text matching app theme
  - Position near map or waypoint list
  - Update automatically when waypoints change
  - _Requirements: 14.1-14.8_

- [ ] 20. Implement Save route functionality
  - Wire "Save" button to controller.saveRoute()
  - In saveRoute(), call validateForSave()
  - If validation fails, display error message with specific failure reason (empty name, no waypoints)
  - If validation succeeds, create RouteData object with: routeName, permitType, routeSegments (waypoint addresses), startLocation (first waypoint), endLocation (last waypoint), routeWithCoordinates (waypoint JSON)
  - Navigate to edit_confirm_start_your_route screen using Get.toNamed()
  - Pass RouteData as arguments using toJson()
  - Display success message before navigation
  - Style Save button with green background, white text, rounded corners 5.r
  - _Requirements: 17.1-17.10, 20.1-20.9_

- [ ] 21. Implement Drive route functionality
  - Wire "Drive" button to controller.startDriving()
  - In startDriving(), call validateForDrive()
  - If validation fails, display error message explaining requirements (need 2+ waypoints)
  - If validation succeeds, create RouteData object with waypoints and coordinates
  - Navigate to drive route map screen using Get.toNamed()
  - Pass RouteData as arguments
  - Style Drive button with orange background (AppColors.orange), white text, rounded corners 5.r
  - Position at bottom of action buttons section
  - _Requirements: 18.1-18.8_

- [ ]* 21.1 Write widget tests for Save and Drive buttons
  - Test Save button displays validation error when route name empty
  - Test Save button displays validation error when no waypoints
  - Test Save button navigates to confirmation screen with valid data
  - Test Drive button displays validation error with fewer than 2 waypoints
  - Test Drive button navigates to drive screen with valid data
  - Mock navigation for testing
  - _Requirements: 17.1-17.10, 18.1-18.8_

- [ ] 22. Implement loading states and error handling
  - Display circular progress spinner when isGeocodingLoading is true
  - Display recording indicator when isVoiceListening is true
  - Display loading spinner when isSaving is true
  - Use white color for loading indicators
  - Display error messages with orange or red background for visibility
  - Show specific error messages for: network failures, geocoding failures, permission denials, validation failures
  - Use Get.snackbar() for error and success messages
  - Position snackbars at bottom of screen
  - Log all errors to debug console
  - _Requirements: 23.1-23.9_

- [ ]* 22.1 Write widget tests for loading states
  - Test loading spinner displays when isGeocodingLoading is true
  - Test recording indicator displays when isVoiceListening is true
  - Test loading spinner displays when isSaving is true
  - Test error snackbar displays with correct styling
  - _Requirements: 23.1-23.9_

- [ ] 23. Register route in navigation system
  - Add manualRouteCreator route constant to `lib/core/routes/all_routes.dart`
  - Add GetPage entry mapping route to ManualRouteCreator screen
  - Follow existing GetX routing patterns
  - _Requirements: 19.3-19.4_

- [ ] 24. Integrate with import_your_permit screen
  - Add navigation option in `lib/views/home/home_new_routes/CreateRouteAllFile/import_your_permit.dart`
  - Wire navigation to Get.toNamed(AppRoutes.manualRouteCreator)
  - Initialize controller with empty state on navigation
  - Ensure back navigation returns to import_your_permit
  - _Requirements: 19.1-19.6_

- [ ] 25. Implement accessibility features
  - Add semantic labels to all interactive buttons (Add Pin, Delete Pin, Clear All, Update, Save, Drive)
  - Add semantic label to MapWidget: "Interactive route map"
  - Add semantic labels to waypoint list items: "Waypoint [index]: [address]"
  - Add semantic labels to text fields describing their purpose
  - Add semantic labels to loading indicators describing loading state
  - Ensure minimum touch target size of 44x44 points for all interactive elements
  - Verify color contrast meets WCAG AA standards (white on dark: 21:1 ratio)
  - Test with system text scaling up to 200% using .sp units
  - _Requirements: 30.1-30.8_

- [ ]* 25.1 Write accessibility tests
  - Test all buttons have semantic labels
  - Test MapWidget has semantic label
  - Test waypoint list items have semantic labels
  - Test text fields have semantic labels
  - Test touch targets meet minimum size requirements
  - Use Flutter's accessibility testing tools
  - _Requirements: 30.1-30.8_

- [ ] 26. Implement waypoint reordering (optional enhancement)
  - Add drag handle icon (Icons.drag_handle) to WaypointListItem trailing section
  - Implement ReorderableListView for waypoint list
  - Implement onReorder callback in controller
  - Update waypoints list order when dragged
  - Update pin colors after reordering (start/middle/end)
  - Update polyline to reflect new sequence
  - Display visual feedback during drag operation
  - _Requirements: 12.1-12.7_

- [ ]* 26.1 Write widget tests for waypoint reordering
  - Test drag handle displays on waypoint items
  - Test reordering updates waypoints list
  - Test pin colors update after reordering
  - Test polyline updates after reordering
  - _Requirements: 12.1-12.7_

- [ ] 27. Final integration testing and polish
  - Test complete flow: open screen → add waypoints via map → edit waypoint → delete waypoint → save route → navigate to confirmation
  - Test complete flow: open screen → add waypoints via text → use voice input → drive route → navigate to drive screen
  - Verify geocoding works for various US addresses
  - Verify reverse geocoding works for map taps
  - Test voice recognition accuracy with sample phrases
  - Test map performance with 2, 10, and 50 waypoints
  - Verify responsive layout on different screen sizes (small phone, large phone, tablet)
  - Test map gestures (pan, zoom, rotate) work smoothly
  - Verify pin colors display correctly (red start, orange middle, green end)
  - Verify polyline renders and updates correctly
  - Test error scenarios: network failure, permission denial, invalid addresses
  - Verify all loading indicators appear and disappear correctly
  - Test navigation integration with confirmation and drive screens
  - Verify data passed to other screens matches expected format
  - _Requirements: All requirements_

- [ ] 28. Checkpoint - Ensure all tests pass
  - Run all unit tests and verify they pass
  - Run all widget tests and verify they pass
  - Run all integration tests and verify they pass
  - Fix any failing tests
  - Ensure code coverage is adequate for business logic
  - Ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- The implementation uses Dart/Flutter with GetX state management
- MapLibre GL is used for interactive mapping (version 0.25.0)
- Geocoding uses Nominatim OpenStreetMap API
- Voice input uses speech_to_text package
- All UI components follow the existing app theme (navy blue background, orange accents, white text)
- Responsive sizing uses flutter_screenutil (.sp, .w, .h units)
- Testing strategy focuses on unit tests for business logic, widget tests for UI components, and integration tests for services
- Property-based testing is NOT used because this feature is UI-heavy with external service dependencies
- Checkpoints ensure incremental validation throughout implementation
