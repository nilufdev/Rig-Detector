# <pre> Rig Detector </pre>
<pre>Why fix roads, when we can mine them!</pre>

## <pre> Table of Contents </pre>

1. [Problem Statement](#-1-problem-statement-)  
2. [Inspiration](#-2-inspiration-)  
3. [How It Works](#-3-how-it-works-)  
4. [Features](#-4-features-)  
5. [Architecture](#-5-architecture-)  
6. [Tech Stack](#-6-tech-stack-)  
7. [Setup](#-7-setup-)  
8. [Folder Structure](#-8-folder-structure-)  
9. [Code Snippets](#-9-code-snippets-)  
10. [Screenshots / Demo](#-10-screenshots--demo-)  
11. [Future Todo](#-11-future-todo-)  
12. [Team](#-12-team-)  

## <pre> 1. Problem Statement </pre>

In places like Kerala, road potholes are a part of daily life. Rig Detector humorously treats potholes as crypto mining rigs. It detects sudden bumps when you're driving, records their location, and displays them on a live dashboard. This mocks the state of infrastructure while showcasing real-time motion data processing.

## <pre> 2. Inspiration </pre>

```-``` The iconic pothole-ridden roads of Kerala  
```-``` Frustration with poor infrastructure  
```-``` Gamifying sensor data from accelerometers  
```-``` Turning a daily annoyance into a useless (yet cool) data visualization

## <pre> 3. How It Works </pre>

1. User activates "Drive Mode" in the Flutter mobile app  
2. App listens to phone accelerometer in real-time  
3. If a shake exceeds the threshold → logs time, date, and GPS coordinates  
4. Data is sent to Firebase Firestore (free tier)  
5. Flutter Web dashboard running on `localhost`:
   - Pins locations on map (red markers)
   - Displays a leaderboard-style tile feed of events
   - Tiles animate to top when new events arrive  
6. The mobile app displays live phone movement and a tile saying "Rig Detected!"

## <pre> 4. Features </pre>

```-``` Drive Mode toggle  
```-``` Real-time shake detection with motion threshold  
```-``` Firebase Firestore integration  
```-``` Live Flutter Web dashboard  
```-``` Animated tile feed of detected events  
```-``` Displays live accelerometer movement on phone  
```-``` Red pins on dashboard map for every detected pothole

## <pre> 5. Architecture </pre>

```plaintext
[Mobile App]
 └─ Accelerometer + Geolocator
     └─ Firebase Firestore
         └─ [Web Dashboard]
             ├─ Map Pins
             └─ Animated Tile Feed
```
## <pre> 6. Tech Stack </pre>

<pre>
| Layer          |        Technology              |
|----------------|--------------------------------|
| App Frontend   | Flutter, Provider              |
| Motion Sensors | Accelerometer from sensors     |
| Maps & Location| geolocator, Google Maps API    |
| Backend        | Firebase Firestore (NoSQL DB)  |
| Web Dashboard  | Flutter Web, flutter_animate   |
</pre>

## <pre> 7. Setup </pre>

### <pre> Clone Repo </pre>

```bash
git clone https://github.com/your-username/rig-detector.git
cd rig-detector
flutter pub get
```

### <pre> Run Mobile App </pre>

```bash
flutter run -d android
```

### <pre> Run Web Dashboard </pre>

```bash
cd lib/web_dashboard
flutter run -d chrome
```

### <pre> Firebase Setup </pre>

```-``` Create a Firebase project  
```-``` Enable Firestore  
```-``` Add `google-services.json` for Android  
```-``` Add Firebase config to `index.html` for web

## <pre> 8. Folder Structure </pre>

```bash
lib/
├── main.dart
├── core/
│   └── services/
│       ├── shake_detector_service.dart
│       ├── firebase_service.dart
│       └── location_service.dart
├── models/
│   └── shake_event.dart
├── ui/
│   ├── mobile/
│   └── web_dashboard/
│       ├── dashboard_screen.dart
│       └── widgets/
│           └── shake_tile.dart
```

## <pre> 9. Code Snippets </pre>

### <pre> ShakeDetectorService </pre>

```dart
class ShakeDetectorService {
  final double threshold;
  final void Function(double) onShake;

  ShakeDetectorService({required this.threshold, required this.onShake});

  void start() {
    accelerometerEvents.listen((event) {
      double total = event.x.abs() + event.y.abs() + event.z.abs();
      if (total > threshold) {
        onShake(total);
      }
    });
  }
}
```

### <pre> FirebaseService </pre>

```dart
class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> logEvent(ShakeEvent event) async {
    await _db.collection('shakeEvents').add(event.toJson());
  }

  Stream<List<ShakeEvent>> getEventsStream() {
    return _db.collection('shakeEvents').orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) =>
        snapshot.docs.map((doc) => ShakeEvent.fromJson(doc.data())).toList());
  }
}
```

### <pre> ShakeEvent Model </pre>

```dart
class ShakeEvent {
  final double intensity;
  final GeoPoint location;
  final DateTime timestamp;

  ShakeEvent({
    required this.intensity,
    required this.location,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'intensity': intensity,
    'location': location,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ShakeEvent.fromJson(Map<String, dynamic> json) => ShakeEvent(
    intensity: json['intensity'],
    location: json['location'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
```

### <pre> ShakeEventTile </pre>

```dart
class ShakeEventTile extends StatelessWidget {
  final ShakeEvent event;

  const ShakeEventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [FadeEffect(duration: Duration(milliseconds: 500))],
      child: Card(
        child: ListTile(
          title: Text('Rig Detected!'),
          subtitle: Text('${event.timestamp}'),
          trailing: Text('${event.intensity.toStringAsFixed(2)} G'),
        ),
      ),
    );
  }
}
```

## <pre> 10. Screenshots / Demo </pre>

<pre>
|   Mobile App  |    Web Dashboard    |
|---------------|---------------------|
| Drive mode    | Map with pins       |
| Live Location | Animated shake tile |
| Stop button   | Realtime refresh    |
</pre>

## <pre> 11. Future Todo </pre>

```-``` Add shake severity grading  
```-``` Visualize heatmaps of high-bump areas  
```-``` Background tracking permission  
```-``` Host web dashboard

## <pre> 12. Team </pre>

<pre>

| Name     | Role                        |
|----------|-----------------------------|
| Nihal    | Mobile + Web + Firebase Dev |
| Naveen   | Documentation + Design      |
| Naveen   | Testing                     |

THEJUS ENGINEERING COLLEGE
TJE23CS059 - NAVEEN
TJE23CS060 - NIHAL

</pre>
