# Requirements Document

## Introduction

This document specifies the requirements for the Manual Route Creation with Interactive Map feature for the Right Routes Flutter application. This feature enables users to create transportation routes manually through multiple input methods: text entry, voice-to-text, and interactive map pin placement. The feature integrates with the existing OCR-based permit import workflow and provides a comprehensive route creation and editing experience.

## Glossary

- **Route_Creator**: The screen and controller that manages manual route creation with interactive map
- **Map_Widget**: The MapLibre GL map component displaying the route and pins
- **Pin**: A visual marker on the map representing a waypoint location
- **Waypoint**: A location point along the route with address text and coordinates
- **Geocoding_Service**: The service that converts address text to latitude/longitude coordinates
- **Reverse_Geocoding_Service**: The service that converts latitude/longitude coordinates to address text
- **Voice_Input_Service**: The speech-to-text service that converts spoken words to text
- **Route_Data**: The complete route information including name, waypoints, coordinates, and metadata
- **Permit_Direction**: Text describing a route segment or waypoint location
- **Route_Polyline**: The visual line connecting waypoints on the map
- **Start_Pin**: The first waypoint pin (displayed in red)
- **End_Pin**: The last waypoint pin (displayed in green)
- **Middle_Pin**: Any waypoint pin between start and end (displayed in orange)
- **Total_Miles**: The calculated distance of the complete route in miles
- **Route_Controller**: The GetX controller managing route state and business logic
- **Navigation_Service**: The GetX routing service for screen transitions

## Requirements

### Requirement 1: Manual Permit Direction Entry

**User Story:** As a route planner, I want to manually type permit directions into a text field, so that I can create routes without importing documents.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a multi-line text input field for permit directions
2. WHEN a user types text into the permit direction field, THE Route_Creator SHALL update the field state in real-time
3. THE Route_Creator SHALL preserve entered text during screen lifecycle changes
4. THE Route_Creator SHALL support text editing operations including copy, paste, cut, and select
5. THE Route_Creator SHALL display the text field with white text on dark background matching app theme
6. WHEN the permit direction field contains text, THE Route_Controller SHALL store the text in observable state

### Requirement 2: Voice-to-Text Input for Permit Directions

**User Story:** As a route planner, I want to use voice input to enter permit directions, so that I can create routes hands-free while driving or multitasking.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a microphone button adjacent to the permit direction text field
2. WHEN a user taps the microphone button, THE Voice_Input_Service SHALL request microphone permission
3. IF microphone permission is granted, THEN THE Voice_Input_Service SHALL begin listening for speech
4. WHILE the Voice_Input_Service is listening, THE Route_Creator SHALL display a visual indicator showing active recording
5. WHEN the Voice_Input_Service recognizes speech, THE Route_Creator SHALL append the recognized text to the permit direction field
6. WHEN a user taps the microphone button while recording, THE Voice_Input_Service SHALL stop listening
7. IF microphone permission is denied, THEN THE Route_Creator SHALL display an error message explaining permission is required
8. IF the Voice_Input_Service encounters an error, THEN THE Route_Creator SHALL display a descriptive error message
9. THE Voice_Input_Service SHALL use the speech_to_text package for speech recognition
10. WHEN speech recognition completes, THE Route_Creator SHALL update the permit direction field with the final recognized text

### Requirement 3: Interactive Map Display

**User Story:** As a route planner, I want to see an interactive map showing my route, so that I can visualize the path and waypoint locations.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a Map_Widget using MapLibre GL
2. THE Map_Widget SHALL render with minimum height of 300 device-independent pixels
3. THE Map_Widget SHALL support standard map gestures including pan, zoom, and rotate
4. WHEN the Route_Creator initializes, THE Map_Widget SHALL center on the first waypoint if waypoints exist
5. IF no waypoints exist, THEN THE Map_Widget SHALL center on a default location (latitude 42.0, longitude -93.0)
6. THE Map_Widget SHALL use the map style configured in the app settings
7. THE Map_Widget SHALL display zoom controls for user interaction
8. THE Map_Widget SHALL render within the dark-themed UI container with navy blue background

### Requirement 4: Pin Addition by Map Tap

**User Story:** As a route planner, I want to add waypoint pins by tapping on the map, so that I can visually select route locations.

#### Acceptance Criteria

1. WHEN a user taps the "Add Pin" button, THE Route_Controller SHALL enter pin-addition mode
2. WHILE in pin-addition mode, THE Route_Creator SHALL display a visual indicator showing the mode is active
3. WHEN a user taps a location on the Map_Widget while in pin-addition mode, THE Route_Controller SHALL create a new Pin at the tapped coordinates
4. WHEN a Pin is created, THE Reverse_Geocoding_Service SHALL convert the coordinates to an address
5. WHEN the Reverse_Geocoding_Service returns an address, THE Route_Controller SHALL create a Waypoint with the address and coordinates
6. THE Route_Controller SHALL add the new Waypoint to the waypoints list
7. THE Map_Widget SHALL display the new Pin at the tapped location
8. WHEN a Pin is added, THE Route_Controller SHALL exit pin-addition mode
9. THE Route_Creator SHALL display the "Add Pin" button with orange background color
10. WHEN reverse geocoding fails, THE Route_Controller SHALL create a Waypoint with coordinates-based label (e.g., "Location at 42.5, -93.2")

### Requirement 5: Pin Deletion by Tap

**User Story:** As a route planner, I want to delete waypoint pins by tapping on them, so that I can remove incorrect or unwanted locations.

#### Acceptance Criteria

1. WHEN a user taps the "Delete Pin" button, THE Route_Controller SHALL enter pin-deletion mode
2. WHILE in pin-deletion mode, THE Route_Creator SHALL display a visual indicator showing the mode is active
3. WHEN a user taps a Pin on the Map_Widget while in pin-deletion mode, THE Route_Controller SHALL identify the tapped Pin
4. WHEN a Pin is identified, THE Route_Controller SHALL remove the corresponding Waypoint from the waypoints list
5. THE Map_Widget SHALL remove the Pin from the map display
6. THE Route_Controller SHALL recalculate the Route_Polyline after Pin removal
7. WHEN a Pin is deleted, THE Route_Controller SHALL exit pin-deletion mode
8. THE Route_Creator SHALL display the "Delete Pin" button with orange background color
9. IF only one Waypoint remains, THEN THE Route_Controller SHALL allow deletion (route can have zero waypoints)

### Requirement 6: Clear All Pins Functionality

**User Story:** As a route planner, I want to clear all pins at once, so that I can start over without deleting pins individually.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a "Clear All" button
2. WHEN a user taps the "Clear All" button, THE Route_Creator SHALL display a confirmation dialog
3. THE confirmation dialog SHALL ask "Are you sure you want to clear all pins?"
4. WHEN a user confirms in the dialog, THE Route_Controller SHALL remove all Waypoints from the waypoints list
5. THE Map_Widget SHALL remove all Pins from the map display
6. THE Route_Controller SHALL clear the Route_Polyline
7. THE Route_Controller SHALL reset the Total_Miles to zero
8. WHEN a user cancels in the dialog, THE Route_Controller SHALL preserve all existing Waypoints
9. THE Route_Creator SHALL display the "Clear All" button with orange background color

### Requirement 7: Route Polyline Display

**User Story:** As a route planner, I want to see a line connecting my waypoints on the map, so that I can visualize the complete route path.

#### Acceptance Criteria

1. WHEN the Route_Controller has two or more Waypoints, THE Map_Widget SHALL display a Route_Polyline connecting the Waypoints in order
2. THE Route_Polyline SHALL connect Waypoints in the sequence they appear in the waypoints list
3. THE Route_Polyline SHALL use a visually distinct color (blue or orange) with minimum 3-pixel width
4. WHEN a Waypoint is added, THE Route_Controller SHALL update the Route_Polyline to include the new Waypoint
5. WHEN a Waypoint is removed, THE Route_Controller SHALL update the Route_Polyline to exclude the removed Waypoint
6. WHEN Waypoints are reordered, THE Route_Controller SHALL update the Route_Polyline to reflect the new order
7. IF fewer than two Waypoints exist, THEN THE Map_Widget SHALL not display a Route_Polyline
8. THE Route_Polyline SHALL render above the map tiles but below the Pins

### Requirement 8: Pin Visual Differentiation

**User Story:** As a route planner, I want start, middle, and end pins to have different colors, so that I can easily identify the route direction and structure.

#### Acceptance Criteria

1. THE Map_Widget SHALL display the Start_Pin with red color
2. THE Map_Widget SHALL display all Middle_Pins with orange color
3. THE Map_Widget SHALL display the End_Pin with green color
4. WHEN the waypoints list has exactly one Waypoint, THE Map_Widget SHALL display it as a Start_Pin (red)
5. WHEN the waypoints list has exactly two Waypoints, THE Map_Widget SHALL display the first as Start_Pin (red) and second as End_Pin (green)
6. WHEN the waypoints list has three or more Waypoints, THE Map_Widget SHALL display first as Start_Pin (red), last as End_Pin (green), and all others as Middle_Pins (orange)
7. WHEN Waypoints are reordered, THE Map_Widget SHALL update Pin colors to reflect the new positions
8. THE Map_Widget SHALL use the existing pin icon assets (Map-Pin-orange.svg, Map-Pin-orange.png)

### Requirement 9: Waypoint List Display

**User Story:** As a route planner, I want to see a list of all waypoints below the map, so that I can review and manage the route sequence.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a scrollable waypoint list below the Map_Widget
2. THE waypoint list SHALL display each Waypoint as a separate list item
3. EACH waypoint list item SHALL display the waypoint address text
4. EACH waypoint list item SHALL display an edit icon button
5. EACH waypoint list item SHALL display a delete (X) button
6. THE waypoint list SHALL display Waypoints in the order they appear in the waypoints list
7. WHEN the waypoints list is empty, THE Route_Creator SHALL display a message "No waypoints added yet"
8. THE waypoint list SHALL use white text on dark background matching app theme
9. THE waypoint list SHALL display with left border accent matching app design patterns

### Requirement 10: Waypoint Text Editing

**User Story:** As a route planner, I want to edit waypoint text directly, so that I can correct addresses or add custom labels.

#### Acceptance Criteria

1. WHEN a user taps the edit icon on a waypoint list item, THE Route_Creator SHALL display an editable text field for that Waypoint
2. THE editable text field SHALL be pre-filled with the current waypoint address text
3. WHEN a user modifies the text and confirms, THE Route_Controller SHALL update the Waypoint address text
4. WHEN waypoint text is updated, THE Geocoding_Service SHALL attempt to geocode the new address
5. IF geocoding succeeds, THEN THE Route_Controller SHALL update the Waypoint coordinates
6. IF geocoding succeeds, THEN THE Map_Widget SHALL move the corresponding Pin to the new coordinates
7. IF geocoding fails, THEN THE Route_Controller SHALL preserve the original coordinates
8. IF geocoding fails, THEN THE Route_Creator SHALL display a warning message
9. WHEN a user cancels editing, THE Route_Controller SHALL preserve the original waypoint text
10. THE Route_Controller SHALL update the Route_Polyline after successful coordinate changes

### Requirement 11: Waypoint Deletion from List

**User Story:** As a route planner, I want to delete waypoints from the list, so that I can remove locations without using the map interface.

#### Acceptance Criteria

1. WHEN a user taps the delete (X) button on a waypoint list item, THE Route_Controller SHALL remove the corresponding Waypoint from the waypoints list
2. THE Map_Widget SHALL remove the corresponding Pin from the map display
3. THE Route_Controller SHALL recalculate the Route_Polyline after Waypoint removal
4. THE Route_Creator SHALL update the waypoint list display to reflect the removal
5. THE Route_Controller SHALL update Pin colors if the removed Waypoint was first or last
6. IF only one Waypoint remains, THEN THE Route_Controller SHALL allow deletion
7. THE deletion SHALL occur immediately without confirmation dialog

### Requirement 12: Waypoint Reordering (Optional Enhancement)

**User Story:** As a route planner, I want to reorder waypoints by dragging, so that I can adjust the route sequence without deleting and re-adding waypoints.

#### Acceptance Criteria

1. EACH waypoint list item SHALL display a drag handle icon
2. WHEN a user long-presses a drag handle, THE Route_Creator SHALL enable drag mode for that waypoint
3. WHILE in drag mode, THE Route_Creator SHALL display visual feedback showing the waypoint is being dragged
4. WHEN a user drags a waypoint to a new position, THE Route_Controller SHALL reorder the waypoints list
5. WHEN waypoints are reordered, THE Map_Widget SHALL update Pin colors to reflect new start/middle/end positions
6. WHEN waypoints are reordered, THE Route_Controller SHALL update the Route_Polyline to reflect the new sequence
7. THE drag handle SHALL use a standard icon (e.g., three horizontal lines)

### Requirement 13: Route Name Input

**User Story:** As a route planner, I want to enter a name for my route, so that I can identify it later in my route history.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a text input field for route name at the top of the screen
2. THE route name field SHALL be labeled "Route Name" or similar
3. WHEN a user types text into the route name field, THE Route_Controller SHALL update the route name state
4. THE Route_Controller SHALL preserve the route name during screen lifecycle changes
5. THE route name field SHALL support text editing operations including copy, paste, cut, and select
6. THE route name field SHALL use white text on dark background matching app theme
7. THE route name field SHALL have a maximum length of 100 characters

### Requirement 14: Total Miles Calculation

**User Story:** As a route planner, I want to see the total route distance in miles, so that I can estimate travel time and fuel costs.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a "Total Miles" label and value
2. WHEN the Route_Controller has two or more Waypoints with valid coordinates, THE Route_Controller SHALL calculate the Total_Miles
3. THE Total_Miles calculation SHALL sum the straight-line distances between consecutive Waypoints
4. THE Route_Controller SHALL use the Haversine formula for distance calculation between coordinates
5. THE Route_Controller SHALL display Total_Miles with one decimal place precision (e.g., "45.3 miles")
6. WHEN Waypoints are added, removed, or reordered, THE Route_Controller SHALL recalculate Total_Miles
7. IF fewer than two Waypoints exist, THEN THE Route_Creator SHALL display Total_Miles as "0.0 miles"
8. THE Total_Miles display SHALL use white text matching app theme

### Requirement 15: Permit Grouping Display

**User Story:** As a route planner, I want to see which permit group my route belongs to, so that I can organize routes by permit.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a permit group label (e.g., "Permit 1")
2. THE permit group label SHALL be configurable through Route_Data
3. THE permit group label SHALL use white text on dark background matching app theme
4. THE permit group label SHALL display near the route name field
5. IF no permit group is specified, THEN THE Route_Creator SHALL display a default label "Permit 1"

### Requirement 16: Update Route Functionality

**User Story:** As a route planner, I want to update the route after making changes, so that I can refresh the map display and recalculate distances.

#### Acceptance Criteria

1. THE Route_Creator SHALL display an "Update" button with green background color
2. WHEN a user taps the "Update" button, THE Route_Controller SHALL recalculate the Route_Polyline
3. WHEN a user taps the "Update" button, THE Route_Controller SHALL recalculate Total_Miles
4. WHEN a user taps the "Update" button, THE Map_Widget SHALL refresh the Pin displays
5. WHEN a user taps the "Update" button, THE Map_Widget SHALL adjust the camera to show all Waypoints
6. IF any Waypoint has invalid coordinates, THEN THE Route_Controller SHALL attempt to re-geocode the address
7. WHEN update completes successfully, THE Route_Creator SHALL display a success message
8. IF update encounters errors, THEN THE Route_Creator SHALL display an error message with details

### Requirement 17: Save Route Functionality

**User Story:** As a route planner, I want to save my created route, so that I can use it for navigation or reference later.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a "Save" button with green background color
2. WHEN a user taps the "Save" button, THE Route_Controller SHALL validate the Route_Data
3. THE Route_Controller SHALL require at least one Waypoint for save validation
4. THE Route_Controller SHALL require a non-empty route name for save validation
5. IF validation fails, THEN THE Route_Creator SHALL display an error message explaining the missing requirements
6. IF validation succeeds, THEN THE Route_Controller SHALL serialize the Route_Data
7. THE Route_Controller SHALL send the Route_Data to the backend API for persistence
8. WHEN save completes successfully, THE Route_Creator SHALL display a success message
9. WHEN save completes successfully, THE Navigation_Service SHALL navigate to the route confirmation screen
10. IF save fails, THEN THE Route_Creator SHALL display an error message and preserve the Route_Data for retry

### Requirement 18: Drive Route Functionality

**User Story:** As a route planner, I want to start driving my route immediately, so that I can begin navigation without additional steps.

#### Acceptance Criteria

1. THE Route_Creator SHALL display a "Drive" button with orange background color
2. WHEN a user taps the "Drive" button, THE Route_Controller SHALL validate the Route_Data
3. THE Route_Controller SHALL require at least two Waypoints for drive validation
4. IF validation fails, THEN THE Route_Creator SHALL display an error message explaining the requirements
5. IF validation succeeds, THEN THE Navigation_Service SHALL navigate to the drive route map screen
6. THE Route_Controller SHALL pass the Route_Data to the drive route map screen
7. THE drive route map screen SHALL receive waypoints with coordinates for navigation
8. THE "Drive" button SHALL be positioned at the bottom of the action buttons section

### Requirement 19: Integration with Existing Import Flow

**User Story:** As a route planner, I want to access manual route creation from the import permit screen, so that I can switch between import and manual entry methods.

#### Acceptance Criteria

1. THE import_your_permit screen SHALL display a navigation option to the Route_Creator
2. WHEN a user navigates from import_your_permit to Route_Creator, THE Route_Controller SHALL initialize with empty state
3. THE Route_Creator SHALL be accessible via the AppRoutes navigation system
4. THE Route_Creator SHALL follow the existing GetX routing patterns
5. THE Route_Creator SHALL use the CustomNavbar for bottom navigation
6. WHEN a user navigates back from Route_Creator, THE Navigation_Service SHALL return to the previous screen

### Requirement 20: Integration with Route Confirmation Screen

**User Story:** As a route planner, I want my manually created route to flow into the confirmation screen, so that I can review and finalize it before driving.

#### Acceptance Criteria

1. WHEN the Route_Creator navigates to edit_confirm_start_your_route, THE Route_Controller SHALL pass Route_Data as navigation arguments
2. THE Route_Data SHALL include routeSegments (list of waypoint addresses)
3. THE Route_Data SHALL include startLocation (first waypoint address)
4. THE Route_Data SHALL include endLocation (last waypoint address)
5. THE Route_Data SHALL include routeWithCoordinates (list of waypoints with lat/lng)
6. THE Route_Data SHALL include routeSteps (structured step data if available)
7. THE Route_Data SHALL include permitType (permit group label)
8. THE edit_confirm_start_your_route screen SHALL accept and display the Route_Data
9. THE Route_Data format SHALL match the format used by import_your_permit for consistency

### Requirement 21: Geocoding Service Integration

**User Story:** As a route planner, I want addresses to be automatically converted to map coordinates, so that waypoints display correctly on the map.

#### Acceptance Criteria

1. THE Geocoding_Service SHALL use the Nominatim OpenStreetMap API for address-to-coordinate conversion
2. WHEN the Geocoding_Service receives an address string, THE Geocoding_Service SHALL send a request to the Nominatim API
3. THE Geocoding_Service SHALL include "User-Agent: RightRoutes/1.0" header in requests
4. THE Geocoding_Service SHALL limit requests to US locations using countrycodes parameter
5. WHEN the Nominatim API returns results, THE Geocoding_Service SHALL extract latitude and longitude
6. THE Geocoding_Service SHALL return coordinates as a map with "lat" and "lng" keys
7. IF the Nominatim API returns no results, THEN THE Geocoding_Service SHALL return null
8. IF the Nominatim API request times out after 10 seconds, THEN THE Geocoding_Service SHALL return null
9. THE Geocoding_Service SHALL implement rate limiting with 500ms delay between requests
10. THE Geocoding_Service SHALL follow the existing geocoding patterns from import_your_permit

### Requirement 22: Reverse Geocoding Service Integration

**User Story:** As a route planner, I want map coordinates to be automatically converted to addresses, so that I can see readable location names for pins I add.

#### Acceptance Criteria

1. THE Reverse_Geocoding_Service SHALL use the Nominatim OpenStreetMap API for coordinate-to-address conversion
2. WHEN the Reverse_Geocoding_Service receives latitude and longitude, THE Reverse_Geocoding_Service SHALL send a reverse geocoding request
3. THE Reverse_Geocoding_Service SHALL include "User-Agent: RightRoutes/1.0" header in requests
4. WHEN the Nominatim API returns results, THE Reverse_Geocoding_Service SHALL extract the display_name or formatted address
5. THE Reverse_Geocoding_Service SHALL return the address as a string
6. IF the Nominatim API returns no results, THEN THE Reverse_Geocoding_Service SHALL return a coordinate-based label
7. IF the Nominatim API request times out after 10 seconds, THEN THE Reverse_Geocoding_Service SHALL return a coordinate-based label
8. THE coordinate-based label SHALL format as "Location at [latitude], [longitude]" with 4 decimal places

### Requirement 23: Error Handling and Loading States

**User Story:** As a route planner, I want to see clear feedback when operations are in progress or fail, so that I understand the app state and can take corrective action.

#### Acceptance Criteria

1. WHILE the Geocoding_Service is processing, THE Route_Creator SHALL display a loading indicator
2. WHILE the Reverse_Geocoding_Service is processing, THE Route_Creator SHALL display a loading indicator
3. WHILE the Voice_Input_Service is listening, THE Route_Creator SHALL display a recording indicator
4. WHEN any service operation fails, THE Route_Creator SHALL display an error message with the failure reason
5. THE error messages SHALL use orange or red background colors for visibility
6. THE loading indicators SHALL use circular progress spinners with white color
7. WHEN a network request fails, THE error message SHALL indicate network connectivity issues
8. WHEN geocoding fails for a waypoint, THE Route_Creator SHALL allow the user to retry or manually enter coordinates
9. THE Route_Controller SHALL log all errors to the debug console for troubleshooting

### Requirement 24: Responsive UI Layout

**User Story:** As a route planner, I want the interface to adapt to different screen sizes, so that I can use the app on various devices.

#### Acceptance Criteria

1. THE Route_Creator SHALL use flutter_screenutil for responsive sizing
2. ALL text sizes SHALL scale proportionally using .sp units
3. ALL spacing and padding SHALL scale proportionally using .w and .h units
4. THE Map_Widget SHALL occupy available vertical space between header and waypoint list
5. THE waypoint list SHALL be scrollable when content exceeds available space
6. THE Route_Creator SHALL use SafeArea to avoid system UI overlaps
7. THE Route_Creator SHALL support both portrait and landscape orientations
8. THE button sizes SHALL remain tappable (minimum 44x44 points) across screen sizes

### Requirement 25: App Theme Consistency

**User Story:** As a route planner, I want the manual route creation screen to match the app's visual design, so that the experience feels cohesive.

#### Acceptance Criteria

1. THE Route_Creator SHALL use the navy blue background with subtle pattern from ImageManager.mapBackground
2. THE Route_Creator SHALL use AppColors.orange for primary action buttons
3. THE Route_Creator SHALL use green color for save and update buttons
4. THE Route_Creator SHALL use white text on dark backgrounds throughout
5. THE Route_Creator SHALL use League Gothic font for headers at 32.sp size
6. THE Route_Creator SHALL use Lato font for body text at 18.sp size
7. THE Route_Creator SHALL use rounded corners (5.r to 8.r) for buttons and containers
8. THE Route_Creator SHALL display the app logo at the top using ImageManager.splashScreenLogo
9. THE Route_Creator SHALL use the CustomNavbar at the bottom for consistent navigation

### Requirement 26: State Management with GetX

**User Story:** As a developer, I want the route creation feature to use GetX for state management, so that it follows the existing app architecture.

#### Acceptance Criteria

1. THE Route_Controller SHALL extend GetxController
2. THE Route_Controller SHALL use RxList for the waypoints list
3. THE Route_Controller SHALL use RxString for route name and permit type
4. THE Route_Controller SHALL use RxBool for loading states
5. THE Route_Controller SHALL use RxDouble for Total_Miles
6. THE Route_Creator SHALL use Obx widgets to reactively update UI when state changes
7. THE Route_Controller SHALL be registered using Get.put() in the Route_Creator build method
8. THE Route_Controller SHALL implement onInit() for initialization logic
9. THE Route_Controller SHALL implement onClose() for cleanup logic
10. THE Route_Controller SHALL follow the controller patterns from ImportYourPermitController

### Requirement 27: MapLibre GL Integration

**User Story:** As a developer, I want the map to use MapLibre GL, so that it matches the existing map implementation in the app.

#### Acceptance Criteria

1. THE Map_Widget SHALL use the maplibre_gl package version 0.25.0
2. THE Map_Widget SHALL initialize with MaplibreMap widget
3. THE Map_Widget SHALL configure onMapCreated callback to store the MaplibreMapController
4. THE Map_Widget SHALL configure onStyleLoadedCallback for post-initialization setup
5. THE Map_Widget SHALL use the map style URL from app configuration
6. THE Map_Widget SHALL add symbols (pins) using the MaplibreMapController.addSymbol method
7. THE Map_Widget SHALL add lines (polyline) using the MaplibreMapController.addLine method
8. THE Map_Widget SHALL handle map tap events using onMapClick callback
9. THE Map_Widget SHALL update camera position using MaplibreMapController.animateCamera
10. THE Map_Widget SHALL remove symbols using MaplibreMapController.removeSymbol method

### Requirement 28: Permission Handling

**User Story:** As a route planner, I want the app to request necessary permissions gracefully, so that I understand why permissions are needed and can grant them.

#### Acceptance Criteria

1. WHEN the Voice_Input_Service is first used, THE Route_Creator SHALL request microphone permission
2. THE permission request SHALL include a rationale explaining why microphone access is needed
3. IF permission is denied, THEN THE Route_Creator SHALL display a message explaining the limitation
4. IF permission is permanently denied, THEN THE Route_Creator SHALL offer to open app settings
5. THE Route_Creator SHALL use the permission_handler package for permission requests
6. THE Route_Creator SHALL check permission status before attempting to use the Voice_Input_Service
7. THE permission handling SHALL follow the patterns from import_your_photo_permit

### Requirement 29: Data Validation

**User Story:** As a route planner, I want the app to validate my route data before saving, so that I don't create incomplete or invalid routes.

#### Acceptance Criteria

1. WHEN a user attempts to save, THE Route_Controller SHALL validate that route name is not empty
2. WHEN a user attempts to save, THE Route_Controller SHALL validate that at least one Waypoint exists
3. WHEN a user attempts to drive, THE Route_Controller SHALL validate that at least two Waypoints exist
4. THE Route_Controller SHALL validate that each Waypoint has either valid coordinates or address text
5. IF validation fails, THEN THE Route_Creator SHALL display a specific error message for each validation failure
6. THE validation error messages SHALL use orange background color
7. THE validation SHALL occur before any network requests are made
8. THE Route_Controller SHALL trim whitespace from route name before validation

### Requirement 30: Accessibility Support

**User Story:** As a route planner with accessibility needs, I want the interface to support screen readers and large text, so that I can use the app effectively.

#### Acceptance Criteria

1. ALL interactive buttons SHALL have semantic labels for screen readers
2. THE Map_Widget SHALL have a semantic label describing its purpose
3. THE waypoint list items SHALL have semantic labels including the waypoint address
4. THE text input fields SHALL have semantic labels describing their purpose
5. THE Route_Creator SHALL support dynamic text scaling up to 200%
6. THE color contrast between text and backgrounds SHALL meet WCAG AA standards (4.5:1 for normal text)
7. THE interactive elements SHALL have minimum touch target size of 44x44 points
8. THE loading indicators SHALL have semantic labels describing the loading state
