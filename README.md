# 🎨 SMO - Smart Manufacturing Operations (Frontend)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-State%20Management-8B5CF6?style=for-the-badge&logo=flutter&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-3-757575?style=for-the-badge&logo=material-design&logoColor=white)

**Beautiful, responsive cross-platform application for intelligent manufacturing operations**

[Features](#-features) • [Screenshots](#-screenshots) • [Architecture](#-architecture) • [Getting Started](#-getting-started) • [Build](#-build)

</div>

---

## 📋 Overview

SMO Frontend is a modern, feature-rich Flutter application that provides an intuitive interface for managing garment manufacturing operations. Built with clean architecture principles and powered by GetX state management, it delivers a seamless experience across Windows, Android, iOS, and Web platforms.

### 🎯 Key Highlights

- **🎨 Modern UI/UX** - Material Design 3 with custom theming and smooth animations
- **📱 Cross-Platform** - Single codebase for Windows, Android, iOS, and Web
- **🔄 Real-time Updates** - Live workflow visualization and production tracking
- **📊 Interactive Graphs** - DAG-based workflow visualization with zoom and pan
- **🎭 Role-based Dashboards** - Customized interfaces for each user role
- **⚡ High Performance** - Optimized rendering and efficient state management
- **🌐 Offline Support** - Local caching for uninterrupted operations

---

## ✨ Features

### 🏗️ Core Modules

#### 1. **HR & Admin Dashboard**
- 👥 Employee management with CRUD operations
- 🎭 Role creation and assignment
- 📊 HR analytics and insights
- 🔐 Login credential management
- 📈 Employee performance tracking
- 🎨 Clean, intuitive interface with sidebar navigation

#### 2. **General Manager (GM) Module**
- ✅ Process plan approval workflow
- 📊 Pending approvals dashboard
- 🔍 Detailed process plan review
- 📈 Production insights and metrics
- 🎯 Strategic decision support
- 📉 Performance analytics

#### 3. **Process Planner Module**
- 🎨 Visual workflow designer
- 📋 Operation management (Create, Edit, Delete)
- 🔄 Routing and routing step configuration
- 📦 Product management
- 🎯 Process plan creation and cloning
- 📊 Interactive workflow graph visualization
  - Horizontal left-to-right layout
  - Parallel branch and merge point rendering
  - Node metrics and operation details
  - Zoom and pan capabilities
  - Color-coded operation types

#### 4. **Supervisor Module**
- 🏷️ QR code assignment to operators
- 📍 Work tracking and monitoring
- 🔄 Bin merging operations
- 👷 Operator performance insights
- 🔄 Work reassignment capabilities
- 📊 Floor-level analytics
- ⚡ Real-time status updates

#### 5. **Operator Module**
- 📋 Assigned tasks view
- ▶️ Start work interface
- ✅ Complete work tracking
- 📊 Personal performance metrics
- 🏷️ QR code scanning
- ⏱️ Time tracking

#### 6. **Store Management Module**
- 📦 Inventory management
- 📥 GRN (Goods Receipt Note) processing
- 📊 Stock level monitoring
- 🔄 Stock movement tracking
- 📋 Item management
- 🎯 Material issue tracking

#### 7. **Auto-Discovery & Service Configuration**
- 🔍 Automatic backend service discovery
- 🌐 mDNS/Bonjour support
- 📡 Network scanning fallback
- 🔄 Intelligent retry mechanism
- 💾 URL caching for offline access
- 🎯 Multi-network support (192.168.x.x, 10.x.x.x, 172.x.x.x)
- ⚡ Zero-configuration deployment
- 🔐 Secure service validation

#### 8. **Interactive Workflow Monitoring**
- 🖱️ Clickable workflow nodes for real-time insights
- 👥 Role-based access (GM strategic, Supervisor operational)
- 📊 Live production metrics (WIP, active jobs, completions)
- 🔄 Auto-refreshing node metrics dialog
- 📈 Strategic monitoring for bottleneck analysis
- 🏭 Floor-level monitoring for production tracking

#### 9. **Order Management System** ⭐ NEW
- 📋 Create and manage production orders
- 🎯 Link orders to products and process plans
- 📊 Real-time order progress tracking
- 🔗 Bin-to-order linkage for WIP tracking
- 📈 Strategic Monitor for GM oversight
- ✅ Order activation and status management
- 🏷️ Supervisor assigns bins to orders during QR assignment
- 📊 Progress calculation from linked bins and WIP data

#### 10. **Enhanced Workflow Progression** ⭐ NEW
- 🔄 Automatic routing progression through operations
- 📍 Current operation tracking in bin table
- ✅ Sequential operation validation
- 🎯 Last operation detection for workflow completion
- 📊 Bin status lifecycle management
- 🔗 WIP tracking with proper FK population
- ♻️ Bin reusability after merge (FREE status)

#### 11. **QR Event Audit Trail** ⭐ NEW
- 📝 Complete QR scanning event logging
- 🔍 Audit trail for compliance and debugging
- 📊 Event types: ASSIGNMENT, TRACKING, MERGE_SOURCE, MERGE_TARGET
- 🕒 Timestamp tracking for all QR operations
- 👤 Operator and supervisor tracking
- 📈 Historical event analysis capabilities

#### 12. **Toast Notifications** ⭐ NEW
- 📱 Mobile-friendly toast messages using fluttertoast
- ✅ Success notifications (green background)
- ℹ️ Info notifications (blue background)
- ❌ Error notifications (red background)
- ⏱️ 4-5 second display duration
- 📍 Center gravity for better visibility

---

## 🖼️ Screenshots

### Dashboard Views
```
┌─────────────────────────────────────────────────────────────┐
│  HR Dashboard    │  GM Dashboard    │  Process Planner      │
│  ┌─────────────┐ │  ┌─────────────┐ │  ┌─────────────┐     │
│  │ Employees   │ │  │ Pending     │ │  │ Workflow    │     │
│  │ Roles       │ │  │ Approvals   │ │  │ Graph       │     │
│  │ Analytics   │ │  │ Insights    │ │  │ Operations  │     │
│  └─────────────┘ │  └─────────────┘ │  └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Workflow Graph Visualization
```
CUTTING → PART_BIN_CREATION → ┬─ COLLAR_CUFF_LINE ──→ MERGE_COLLAR ─┐
                               ├─ POCKET_PLACKET_LINE → MERGE_POCKET ─┤
                               ├─ SLEEVE_LINE ────────→ MERGE_SLEEVE ─┤
                               └─ BODY_LINE ──────────→ MERGE_BODY ───┘
                                                                       ↓
                                                                  SIDE_SEAM
                                                                       ↓
                                                              BUTTON_HOLE → ...
```

---

## 🏛️ Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  Screens • Widgets • Controllers (GetX) • UI Components      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  Models • Business Logic • Use Cases • Entities              │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  Repositories • API Services • Data Sources • DTOs           │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                     External Services                        │
│  REST API • Local Storage • Device Features                  │
└─────────────────────────────────────────────────────────────┘
```

### State Management

**GetX Pattern:**
- **Controllers** - Business logic and state management
- **Reactive Variables** - `.obs` for reactive state
- **Dependency Injection** - `Get.put()` and `Get.find()`
- **Navigation** - `Get.to()` and `Get.back()`
- **Snackbars** - `Get.snackbar()` for user feedback

### Key Design Patterns

- **Repository Pattern** - Abstract data sources
- **MVVM Pattern** - Model-View-ViewModel architecture
- **Factory Pattern** - Widget and model creation
- **Singleton Pattern** - API clients and services
- **Observer Pattern** - Reactive state updates

---

## 🚀 Getting Started

### Prerequisites

```bash
Flutter SDK 3.0+
Dart SDK 3.0+
Android Studio / VS Code
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/PremSaiBollamoni/SMO-Frontend-V2.git
cd SMO-Frontend-V2
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**
```dart
// lib/core/config/app_config.dart
// API endpoint is now automatically discovered!
// The app will:
// 1. Try cached URL first
// 2. Try localhost (http://localhost:8080)
// 3. Try current machine IP
// 4. Try mDNS discovery
// 5. Fall back to network scanning

// For manual override (testing only):
final discoveryService = Get.find<ServiceDiscoveryService>();
await discoveryService.setManualBackendUrl('http://192.168.1.100:8080');
```

4. **Run the application**
```bash
# For Windows
flutter run -d windows

# For Android
flutter run -d android

# For Web
flutter run -d chrome

# For iOS
flutter run -d ios
```

---

## 🔧 Configuration

### Service Discovery

The app automatically discovers the SMO backend service on your local network. No manual configuration needed!

**Discovery Process:**
1. **Cached URL** - Checks previously discovered backend
2. **Localhost** - Tries `http://localhost:8080` (development)
3. **Current Machine IP** - Scans local network interfaces
4. **mDNS Discovery** - Uses Bonjour/mDNS for service discovery
5. **Network Scanning** - Scans local network ranges as fallback

**Supported Networks:**
- `192.168.x.x` (Class C private)
- `10.x.x.x` (Class A private)
- `172.x.x.x` (Class B private)
- Any other local network

**Manual Override (Testing):**
```dart
final discoveryService = Get.find<ServiceDiscoveryService>();
await discoveryService.setManualBackendUrl('http://192.168.1.100:8080');
```

**Force Refresh Discovery:**
```dart
final discoveryService = Get.find<ServiceDiscoveryService>();
final backendUrl = await discoveryService.refreshDiscovery();
```

### API Configuration

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration timeout = Duration(seconds: 30);
  static const bool enableLogging = true;
}
```

### Theme Configuration

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF2196F3),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF03A9F4),
    ),
    // ... custom theme configuration
  );
}
```

---

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^4.6.5
  
  # HTTP Client
  dio: ^5.3.2
  
  # Local Storage
  shared_preferences: ^2.2.0
  
  # Service Discovery
  multicast_dns: ^0.3.2+7
  
  # UI Components
  flutter_svg: ^2.0.7
  cached_network_image: ^3.2.3
  
  # QR Code
  qr_flutter: ^4.1.0
  mobile_scanner: ^3.4.1
  
  # Charts & Graphs
  fl_chart: ^0.63.0
  graphview: ^1.2.0
  syncfusion_flutter_charts: ^30.2.7
  
  # Utilities
  intl: ^0.18.1
  logger: ^2.0.1
```

---

## 🏗️ Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── config/                    # App configuration
│   │   └── app_config.dart
│   ├── network/                   # Network setup
│   │   └── dio_setup.dart
│   ├── theme/                     # App theming
│   │   └── app_theme.dart
│   └── utils/                     # Utility functions
│
├── features/                      # Feature modules
│   ├── hr/                        # HR Module
│   │   ├── data/
│   │   │   ├── api/              # API services
│   │   │   ├── models/           # Data models
│   │   │   └── repository/       # Repositories
│   │   ├── domain/
│   │   │   └── models/           # Domain models
│   │   └── presentation/
│   │       ├── controller/       # GetX controllers
│   │       ├── screens/          # Screen widgets
│   │       └── widgets/          # Reusable widgets
│   │
│   ├── gm/                        # GM Module
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── process_planner/           # Process Planner Module
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── workflow_graph/  # Graph visualization
│   │               ├── workflow_graph_builder.dart
│   │               ├── horizontal_workflow_graph.dart
│   │               ├── workflow_node.dart
│   │               └── engines/
│   │
│   ├── supervisor/                # Supervisor Module
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── operator/                  # Operator Module
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── store/                     # Store Module
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── login_screen.dart              # Login screen
├── main.dart                      # App entry point
└── models.dart                    # Shared models
```

---

## 🎨 UI Components

### Custom Widgets

- **WorkflowGraphBuilder** - Interactive DAG visualization
- **HorizontalWorkflowGraph** - Left-to-right workflow renderer
- **WorkflowNode** - Customizable operation node with click support
- **NodeMetricsDialog** - Real-time production metrics popup
- **TrayQuantityStepper** - Quantity input with validation
- **DashboardCard** - Reusable metric card
- **CustomSidebar** - Role-based navigation
- **CustomTopBar** - Consistent app bar

### Interactive Features

- **Clickable Workflow Nodes** - Tap nodes for real-time metrics
- **Role-based Access** - GM strategic view, Supervisor operational view
- **Auto-refresh Metrics** - Live data updates every 30 seconds
- **Zoom & Pan Support** - Interactive graph navigation
- **Tooltip Support** - Operation descriptions on hover

### Color Palette

```dart
Primary:     #2196F3  // Blue
Secondary:   #03A9F4  // Light Blue
Success:     #4CAF50  // Green
Warning:     #FF9800  // Orange
Error:       #F44336  // Red
Background:  #FAFAFA  // Light Gray
Surface:     #FFFFFF  // White
```

---

## 🔨 Build & Release

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

### Build Configurations

```bash
# Development
flutter run --debug

# Profile (Performance testing)
flutter run --profile

# Release
flutter run --release
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/hr/hr_controller_test.dart

# Integration tests
flutter test integration_test/
```

## 🔍 Troubleshooting

### Service Discovery Issues

**Problem:** App can't find backend service
- **Solution 1:** Ensure backend is running on the same network
- **Solution 2:** Check firewall settings (port 8080 must be accessible)
- **Solution 3:** Verify both devices are on the same WiFi network
- **Solution 4:** Manually set backend URL for testing

**Problem:** "Cannot connect to server" error
- **Solution 1:** Check backend health: `http://backend-ip:8080/api/health`
- **Solution 2:** Verify network connectivity
- **Solution 3:** Check if backend is running on port 8080
- **Solution 4:** Try manual URL configuration

**Problem:** Discovery takes too long
- **Solution 1:** Cached URL will be used on next launch
- **Solution 2:** Reduce network scan timeout in `service_discovery.dart`
- **Solution 3:** Use manual URL configuration for faster startup

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| 🪟 Windows | ✅ Supported | Primary development platform |
| 🤖 Android | ✅ Supported | Android 5.0+ (API 21+) |
| 🍎 iOS | ✅ Supported | iOS 11.0+ |
| 🌐 Web | ✅ Supported | Modern browsers |
| 🐧 Linux | 🚧 Experimental | Community support |
| 🍎 macOS | 🚧 Experimental | Community support |

---

## 🎯 Performance Optimization

- **Lazy Loading** - Load data on demand
- **Image Caching** - Cached network images
- **List Virtualization** - Efficient list rendering
- **State Management** - Minimal rebuilds with GetX
- **Code Splitting** - Feature-based modules
- **Asset Optimization** - Compressed images and fonts

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write widget tests for new features
- Keep widgets focused and reusable

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

**Prem Sai Bollamoni**
- GitHub: [@PremSaiBollamoni](https://github.com/PremSaiBollamoni)
- LinkedIn: [Prem Sai Bollamoni](https://linkedin.com/in/premsaibollamoni)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX community for excellent state management
- Material Design team for design guidelines
- Open-source contributors for inspiration

---

## 📞 Support

For support, email premsaibollamoni@gmail.com or open an issue in the repository.

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

Made with ❤️ and Flutter for the garment manufacturing industry

</div>
