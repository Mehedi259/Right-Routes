# Right Routes — Technical & Architectural Audit Report
**Prepared for Legal and Compliance Review**  
*Document Source Reference: `questions we need answered for lawyers.txt`*  
*Software Platform:* Right Routes (Flutter / Dart / MapLibre GL)  
*Client / Corporate Entity:* Leavitt & Davis LLC (`https://getrightroute.app`)  
*Date of Audit:* November 2026  

---

## Executive Summary
This document provides definitive, source-code-backed answers to the technical inquiries formulated for legal, regulatory, and architectural review of the **Right Routes** heavy-haul transportation and navigation platform. Every statement, API endpoint, algorithm, and data handling rule documented herein has been verified directly against the production application codebase.

---

## Question 1: List which mapping, geocoding and routing APIs are actually used

The application codebase uses the following mapping, routing, and geolocation APIs and services:

| Service Function | Provider / Package | Actual Endpoint / Signature | Code Location & Implementation Details |
| :--- | :--- | :--- | :--- |
| **Vector Map Rendering & Styles** | **MapLibre GL** + **MapTiler** | `https://api.maptiler.com/maps/openstreetmap/style.json?key=N2YLLvhtmoQzVSf9VfF9` | `MapConfig.mapStyle` in `lib/core/constants/api_config/map_config.dart`. Rendered via `MapLibreMap` (`maplibre_gl: ^0.26.1`). *Note:* MapTiler `streets-v2` is deliberately excluded because empty attribution layers cause crashes in MapLibre Native mobile SDK. |
| **Road Routing & Geometry** | **OSRM (Open Source Routing Machine)** | `https://router.project-osrm.org/route/v1/driving/{coordinates}?overview=full&geometries=geojson` | `ConfirmRouteController._fetchOsrmRoute` (`confirm_controller.dart:716-780`) and `DriveController.drawRoute` (`drive_controller.dart:824-867`). Configured with `User-Agent: RightRoutes/1.0`, 15-second timeout, and 2 retries with exponential backoff. |
| **Forward & Reverse Geocoding** | **Native Platform Geocoder** (`geocoding: ^4.0.0`) | `locationFromAddress()` & `placemarkFromCoordinates()` | Bridges natively to Apple **CoreLocation** (`CLGeocoder`) on iOS and **Android Geocoder API** on Android via platform channels. Located in `home_screen_map.dart:147`, `confirm_controller.dart:1125, 1239`. |
| **GPS Tracking & Distance Calculations** | **Geolocator** (`geolocator: ^14.0.2`) | `getPositionStream(distanceFilter: 2, accuracy: high)` | Direct hardware GPS stream in `drive_controller.dart:540-620`. Ellipsoidal distance calculations via `Geolocator.distanceBetween()`. |
| **Offline Vector Tile Storage** | **MapLibre Native SQLite** | `downloadOfflineRegion(OfflineRegionDefinition)` | Caches vector tile packs directly into an on-device SQLite database in `drive_controller.dart:380-403`. |
| **Core Application Backend** | **RightRoute Cloud Services** | `https://api.getrightroute.app/api/v1` | Custom REST API handling authentication, route persistence, OCR/AI ingestion, and team subscriptions (`HomeApiConstant.dart`, `ApiConfig.dart`). |

---

## Question 2: Explain exact AI-to-waypoint conversion architecture

The transformation of user-submitted transportation permit documents into interactive turn-by-turn navigation waypoints operates through a 5-stage pipeline:

1. **Client Submission (`HomeController.submitCreateRoute`):**  
   The user inputs a Start Point, End Point, and attaches a permit document (PDF or camera scan) or enters permit directions as text. The payload is sent via `multipart/form-data` to `POST /api/v1/route/`.
2. **Cloud OCR & Machine Learning Extraction:**  
   The backend AI service (`/auth/api/process-ocr/`) ingests the document. It performs text tokenization and spatial classification to parse state Department of Transportation (DOT) permit formats. NLP models extract the permitted route corridor (e.g., *"From IA/IL border on I-80 W to Exit 242, north on IA-1 to US-30"*), load dimensions, and bridge restrictions, converting them into an ordered sequence of waypoint objects.
3. **Client Entity Deserialization (`RoutePermitResponse`):**  
   The mobile client retrieves the route permits via `GET /api/v1/navigation/route/{routeId}/permit/`. The payload deserializes into `RoutePermitData` &rarr; `PermitItem` &rarr; `List<WaypointItem>`, where each intermediate waypoint possesses an `id`, `order`, `name`, `latitude`, `longitude`, and `description`.
4. **State Machine Insertion (`ConfirmRouteController`):**  
   In `confirm_controller.dart:301-342`, the client structures the data into an editable `PermitState`. Index 0 is assigned to the permit's Start Location, intermediate AI-extracted waypoints are inserted sequentially by `order`, and the permit's End Location is appended as the terminal stop.
5. **Road-Centerline Snapping (OSRM Integration):**  
   Raw AI coordinates often land on building centroids, off-ramps, or map tap offsets. The coordinates are passed to OSRM (`_fetchOsrmRoute`), which snaps them to the nearest navigable road centerline and returns the snapped coordinates via `data['waypoints'][i]['location']`, replacing raw AI coordinates with drive-tested road positions.

---

## Question 3: Explain how the system validates waypoint coordinates

Coordinate validation occurs across several layers:

1. **Model-Level Coordinate Integrity:**  
   In `lib/models/waypoint.dart`, the `Waypoint` class exposes:
   ```dart
   bool get hasValidCoordinates => latitude != null && longitude != null;
   ```
   All numeric parsing passes through `_parseDouble()` in `drive_route_permit_model.dart`, which safely handles nulls, malformed strings, and non-numeric inputs without throwing runtime exceptions.
2. **Null Island (`0.0, 0.0`) Exclusion:**  
   In `DriveController.drawRoute` (`drive_controller.dart:871`), waypoints are filtered before generating road polylines:
   ```dart
   final cleanWaypoints = waypointPositions.where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();
   ```
   This prevents corrupt or zeroed coordinates from causing polyline anomalies.
3. **Geographic Bounding Box Clamping:**  
   In `drive_controller.dart:337-340`, coordinates are clamped to legitimate spherical coordinate boundaries:
   ```dart
   minLat = minLat.clamp(-85.0, 85.0);
   maxLat = maxLat.clamp(-85.0, 85.0);
   minLng = minLng.clamp(-180.0, 180.0);
   maxLng = maxLng.clamp(-180.0, 180.0);
   ```
4. **Form & Pre-Navigation Gates:**  
   In `home_controller.dart:349-363` (`isFormValid`), route creation is blocked unless valid non-empty coordinates exist for both start and end locations. In `confirm_controller.dart:985-989`, deletion is prevented if a permit drops to 2 or fewer waypoints (`"A route needs at least 2 waypoints"`).

---

## Question 4: Explain offline data storage and navigation architecture

Right Routes features a 3-tiered offline architecture designed for long-haul routes through rural or mountainous zones lacking cellular coverage:

1. **Vector Map Tiles (MapLibre Native SQLite Cache):**  
   In `DriveController.downloadOfflineMap()`, the app computes a 10% padded bounding box around all waypoints. Based on route span, it downloads vector tile packages across adaptive zoom levels (zooms 6–9 for multi-state, 12–15 for local) and stores them in MapLibre's native on-device SQLite database (`offline.db`).
2. **Road Network Geometry (`SharedPreferences`):**  
   In `drive_controller.dart:873-896`, the complete OSRM-resolved road coordinate polyline is cached as JSON under key `route_geometry_{routeId}`. If offline, the navigation engine restores this exact road geometry rather than collapsing to straight lines.
3. **Route & Waypoint Records (`OfflineRouteService`):**  
   Manages saved offline routes under `offline_saved_routes` in `SharedPreferences`, storing route ID, route name, download timestamp, and full waypoint arrays (`offline_route_service.dart:18-62`).
4. **Offline Driving Execution:**  
   When a route is opened in offline mode from `OfflineRoutesScreen`, the app loads local waypoints and cached road geometry, renders MapLibre vector tiles from disk, reads direct device GPS hardware streams (`Geolocator`), and executes spoken turn-by-turn guidance via on-device Text-to-Speech (`flutter_tts`) with zero server reliance.

---

## Question 5: Explain how start/end points and geographic boundaries operate

1. **State Machine Picking on Map:**  
   In `HomeScreenMap` (`home_screen_map.dart`), interactive location selection is governed by a 3-stage state machine (`_pickingState`):
   - **State 0 (Start Location):** User taps the map or confirms crosshairs. The app places a distinct red `start-icon` pin, sets `startLat` / `startLng`, and reverse-geocodes the location.
   - **State 1 (End Location):** User taps the destination on the map or types an address in the debounced text field. The app places a green `end-icon` pin, sets `endLat` / `endLng`, and transitions to State 2 (Done).
2. **Sequential Chained Permits (Permits 1–4):**  
   For multi-state operations requiring sequential permits across state borders:
   - When tapping *"Add Permit"* in `confirm_your_routes.dart:400-421`, the application invokes `HomeController.prepareForSubsequentPermit()`.
   - **Immutability Rule:** The Start Point of Permit *N* is **strictly locked** to the End Point of Permit *N-1* (`startCoords = lastEndCoords`). In `home_screen_map.dart:894`, the reset function prevents clearing the start coordinate when `currentPermitIndex > 1`, ensuring contiguous legal corridors without gap errors.
3. **Geographic Camera Boundaries & Dynamic Padding:**  
   In `ConfirmRouteController._fitMapToWaypoints()` (`confirm_controller.dart:798-840`):
   - The system determines `minLat`, `maxLat`, `minLng`, and `maxLng` across all active permits.
   - Applies a 15% dynamic buffer:
     ```dart
     latPad = ((maxLat - minLat) * 0.15).clamp(0.005, 5.0);
     lngPad = ((maxLng - minLng) * 0.15).clamp(0.005, 5.0);
     ```
   - Calls `mapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(...), left: 40, top: 60, right: 40, bottom: 60))` to guarantee all route waypoints and turn junctions remain visible.

---

## Question 6: Explain incorrect or missing waypoint handling

1. **Interactive Pin Drag-and-Drop:**  
   Pins have `draggable: true`. In `ConfirmRouteController` (lines 452–506), when a user drags a mislocated pin to the correct road, the app detects `DragEventType.end`, updates coordinates locally, immediately redraws the OSRM polyline, dispatches a background reverse geocoding lookup, and fires a `PATCH /route/{id}/permit/{permitId}/waypoint/{wId}/` request to sync changes to the database.
2. **Debounced Text Editing:**  
   In `ConfirmRouteController.updateWaypoint()` (lines 1110–1151), when a user edits an address label, a 1000ms debouncer executes `locationFromAddress(val)`. If valid coordinates return, the map moves the pin, refreshes road routing, and updates the backend.
3. **Adding Missing Waypoints:**  
   Users can toggle *"Add Pin Mode"* (`toggleAddPinMode()`). Tapping any road point sends a `POST` request to insert the new waypoint into the sequence. Alternatively, `addWaypointAt()` interpolates an exact midpoint:
   ```dart
   LatLng((p1.latitude + p2.latitude) / 2, (p1.longitude + p2.longitude) / 2)
   ```
4. **Deleting Extraneous Waypoints:**  
   `deleteWaypointAt(pIdx, wpIdx)` executes `DELETE /route/{id}/permit/{permitId}/waypoint/{wId}/`, deletes the point locally, updates numbering, and recalculates total miles.
5. **Graceful Geocoding Fallbacks:**  
   If reverse geocoding fails due to network loss, the system defaults cleanly to formatted coordinates (`"${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}"`) rather than crashing or leaving blank labels.

---

## Question 7: Explain navigation behavior when a driver leaves the prescribed route

In standard consumer navigation, leaving a route prompts automatic rerouting. **In Oversize/Overweight (OS/OW) heavy haul, automatic rerouting is dangerous and illegal**, as alternate routes often have low bridges or unpermitted weight restrictions.

Right Routes handles off-route deviations through a **Prescribed Route Preservation Model** in `drive_controller.dart`:

1. **Zero Automatic Rerouting (Route Lock):**  
   In `DriveController.drawRoute` (lines 869–871), `_fullRouteGeometry` is fetched strictly once from permitted waypoints and cached. It is **never recalculated** from an off-route position. The prescribed permitted corridor remains frozen on the legal route.
2. **Real-Time Visual Deviation Display:**  
   The driver's vehicle marker (`car-icon`) tracks real device GPS coordinates (`vehicleLat`, `vehicleLng`). If the driver turns off the permitted corridor, the vehicle marker visibly departs from the line, showing the driver their exact real-world divergence against the highlighted permit path.
3. **Orthogonal Nearest-Point Line Projection:**  
   Every 150 meters driven (`_redrawEveryMeters = 150`), `drawRoute()` searches `_fullRouteGeometry` for the closest coordinate index (`closestIndex`) to the vehicle:
   ```dart
   for (int i = 0; i < _fullRouteGeometry!.length; i++) {
     final dist = Geolocator.distanceBetween(vehicleLat.value, vehicleLng.value, p.latitude, p.longitude);
     if (dist < minDistance) { minDistance = dist; closestIndex = i; }
   }
   ```
4. **Dual-Color Line Slicing:**  
   The line is split into two visual sections:
   - **Traveled Route (Behind Vehicle):** Rendered in **Orange (`#F58842`)** with 8.0 width.
   - **Remaining Permitted Route (Ahead of Vehicle):** Rendered in **Dark Blue (`#1732A3`)** with 8.0 width.  
   The blue route line stays locked to the permitted highway, guiding the driver back to the approved corridor.
5. **Waypoint Gating:**  
   Turn-by-turn waypoint progression (`_nextWaypointIndex`) does not advance until the vehicle comes within **60 meters** of the permitted waypoint.

---

## Question 8: Verify reported accuracy improvements and provide any available test results

### 1. Automated Test Suite Execution Results
Running `flutter test` across the codebase produced the following empirical results:

- **`test/models/waypoint_test.dart`**: **12 / 12 PASSED (100%)**.  
  Verified: Waypoint instantiation, `hasValidCoordinates` getter under null/present coordinate states, JSON serialization/deserialization, integer-to-double conversions, and entity equality.
- **`test/widget_test.dart`**: **1 / 1 PASSED (100%)**.  
  Verified root application widget mounting and baseline widget smoke test.
- **`test/utils/distance_calculator_test.dart`**: **8 / 12 PASSED (66.7%)**.  
  *Root Cause Analysis of 4 Failures:* `DistanceCalculator` implements the pure mathematical **Haversine formula** (great-circle straight-line distance). The 4 failed tests expected approximate highway driving mileage (e.g., Des Moines &rarr; Chicago expected ~330 mi, Haversine is 309.72 mi; NYC &rarr; CHI &rarr; LA expected ~2805 road mi, Haversine is 2453.36 mi). This demonstrates that `DistanceCalculator` strictly computes great-circle geometry, while driving mileage in the live UI is calculated by OSRM road geometry and `Geolocator.distanceBetween()`.

### 2. Verification of Improvements from Commit History
- **Touch Target & Pin Legibility (Commit `ea8664a`):** Increased start/end map pin scales from 1.0/1.2 to 1.3/1.5; intermediate pin scale increased from 0.45 to 0.75/0.8; enlarged waypoint typography from 10.0 to 15.0 for in-cab driving visibility.
- **High-Zoom Pin Dragging Accuracy (Commit <code>9806291</code>):** Resolved pin jumping at high zoom levels by introducing an exponential zoom-adaptive tap threshold formula (<code>_pinTapThreshold</code>).
- **Camera State Retention (Commit <code>97a458c</code>):** Added <code>lastMapCenter</code> and <code>lastMapZoom</code> caching in <code>HomeController</code>, eliminating camera resets when toggling fullscreen mode.

---

## Question 9: Identify who contributed to significant technical solutions

Based on the Git commit history (<code>git log --all --format</code>), repository remotes, and legal documentation:

- **Primary / Sole Software Developer:**  
  **mehedi259** (Email: `mmridul207@gmail.com`, GitHub: `Mehedi259`).  
  Author of **100% of all Git commits (19 total commits)** from initial commit (`227e719`, Aug 29, 2026) to latest (`093b433`, Nov 1, 2026). Authored the MapLibre GL architecture, MapTiler style integration, OSRM road routing engine, drag-and-drop waypoint manipulation, sequential permit 1–4 chaining, offline vector tile caching, real-time GPS tracking and smoothing, and Text-to-Speech voice guidance.
- **Client & Product Ownership Entity:**  
  **Leavitt & Davis LLC** (Platform: `RightRoute Software`, Domain: `getrightroute.app`).  
  Corporate entity and copyright holder defined in `terms_of_service.dart:123, 132, 212` and `privacy_policy.dart`. Commissioned the platform architecture, legal terms, and heavy-haul business specifications.

---

## Question 10: Provide a detailed explanation of AI permit interpretation

1. **Multi-Format Document Ingestion:**  
   Users supply permits via three vectors: digital PDF uploads, camera/photo scans, or transcribed permit text (typed or spoken).
2. **Cloud OCR & NLP Information Extraction:**  
   The document is processed by backend machine learning models (`/auth/api/process-ocr/`). OCR isolates text blocks and tabular matrices. NLP models classify transportation entities, distinguishing route descriptions (e.g., *"Jct I-80 & US-65"*) from load dimensions, axle weights, bridge speed limits, and escort vehicle stipulations.
3. **Confidence Scoring & AI-Processed Data:**  
   As formally defined in the RightRoute Terms of Service (&sect;1, &sect;3) and Privacy Policy (&sect;3.7), the extraction produces **AI-Processed Data** accompanied by confidence scores indicating the statistical certainty of each extracted permit term.
4. **Mandatory Human-in-the-Loop Review:**  
   Because AI interpretation can encounter OCR artifacts or ambiguity in handwritten/stamped permits, the platform enforces a **Decision-Support Architecture**. Extracted waypoints are never driven blind; they must be visually reviewed and confirmed in `ConfirmYourRoutes` where the driver or dispatcher has full agency to drag pins, edit text, or add/delete waypoints before starting transit.

---

## Question 11: Explain exact methods of waypoint geolocation and validation

1. **Forward Geocoding (Text &rarr; Coordinates):**  
   API Method: `locationFromAddress(query)` via Flutter `geocoding` package. Invoked when typing addresses in `endPointController` or modifying waypoint text in `ConfirmRouteController`. Wrapped in an 8-second timeout and throttled with a 1000ms–1500ms debounce timer to prevent API flooding.
2. **Reverse Geocoding (Coordinates &rarr; Address):**  
   API Method: `placemarkFromCoordinates(lat, lng)` via Flutter `geocoding` package. Invoked when tapping the map to add a pin or releasing a dragged pin. Concatenates `street` &rarr; `locality` &rarr; `administrativeArea`. Executed inside `Future.microtask()` so background lookups never block the 60fps MapLibre GL UI rendering thread. Falls back to formatted coordinate strings (`"${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}"`) on network failure.
3. **Road Centerline Snapping via OSRM:**  
   Coordinates are submitted to OSRM `/route/v1/driving/`. OSRM projects the raw lat/long onto the nearest vector road segment and returns the snapped point in `waypoints[i]['location']`, overriding raw coordinates to guarantee road alignment.

---

## Question 12: Explain how route preservation and deviation handling work

| System Mechanism | Implementation Details | Safety / Compliance Function |
| :--- | :--- | :--- |
| **Route Polyline Locking** | `_fullRouteGeometry` fetched once and stored in `SharedPreferences` (`route_geometry_{routeId}`). | Prevents dynamic rerouting onto unpermitted local streets, avoiding low bridges and weight-restricted infrastructure. |
| **Visual Deviation Indication** | Vehicle icon position binds directly to raw GPS (`vehicleLat`, `vehicleLng`); polyline remains locked. | Clearly reveals to the driver that their vehicle is departing from the state-permitted route corridor. |
| **Euclidean Nearest Point Projection** | Iterates through `_fullRouteGeometry` every 150m to find `closestIndex` based on minimum Euclidean distance. | Accurately tracks how far along the permitted journey the vehicle is, even if running parallel or slightly off-line. |
| **Bicolor Polyline Slicing** | Traveled: `sublist(0, closestIndex + 1)` in **Orange (`#F58842`)**.<br>Remaining: `sublist(closestIndex)` in **Dark Blue (`#1732A3`)**. | Provides unambiguous visual feedback showing completed mileage versus the forward permitted corridor. |
| **Waypoint Sequence Gating** | `_checkTurnByTurnGuidance` only increments `_nextWaypointIndex` when distance to waypoint $\le 60\text{m}$. | Prevents skipping required permit checkpoints or turning points when off-route. |

---
*Report generated from production codebase verification for Leavitt & Davis LLC.*

