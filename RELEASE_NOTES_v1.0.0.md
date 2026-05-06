# SMO-V1 Production Release v1.0.0

**Release Date:** May 6, 2026  
**App Name:** SMO-V1  
**Version:** 1.0.0  
**Build:** Release APK (71.52 MB)

---

## 🎉 First Production Release

This is the first production-ready release of the Smart Manufacturing Operations (SMO) mobile application for garment manufacturing workflow management.

---

## ✨ Features

### 🔐 Authentication & Roles
- Multi-role login system (HR, GM, Supervisor, Process Planner, Operator)
- Role-based access control
- Secure authentication with backend

### 👔 HR & Admin Module
- Employee management (CRUD operations)
- Role creation and assignment
- Employee performance tracking
- Login credential management

### 📊 General Manager (GM) Module
- Process plan approval workflow
- Pending approvals dashboard
- Production insights and analytics
- **Strategic Monitor** with order-specific statistics
- Real-time WIP tracking per order
- Interactive workflow visualization

### 🎨 Process Planner Module
- Visual workflow designer
- Operation management
- Routing configuration
- Interactive workflow graph with zoom/pan
- Node metrics and real-time data

### 👷 Supervisor Module
- **QR Assignment** with order linkage
- Work tracking and monitoring
- Bin merging operations
- Operator performance insights
- Floor-level analytics

### 🏭 Production Features
- QR code-based tracking
- Bin lifecycle management
- Workflow progression automation
- WIP (Work in Progress) tracking
- Order-to-bin linkage
- Real-time operation tracking

### 🎨 Master Data Management
- Styles management
- GTG (Garment-to-Go) variants
- Buttons catalog
- Threads inventory
- Machines registry
- Labels management
- Full CRUD operations for all entities

### 🌐 Service Discovery
- Automatic backend detection
- Production server priority
- mDNS/Bonjour support
- Network scanning fallback
- Offline caching

---

## 🔧 Technical Specifications

### Backend Integration
- **Production URL:** `https://smobza.thegttech.com/smo`
- **Context Path:** `/smo`
- **API Version:** REST API v1.0
- **Authentication:** Token-based

### Platform Support
- **Android:** 5.0+ (API 21+)
- **Architecture:** ARM64, ARMv7
- **Size:** 71.52 MB

### Key Technologies
- **Framework:** Flutter 3.0+
- **State Management:** GetX
- **HTTP Client:** Dio
- **Service Discovery:** mDNS
- **UI:** Material Design 3

---

## 🚀 What's New in v1.0.0

### Strategic Monitor Enhancement
- ✅ Order-specific statistics
- ✅ Real-time WIP tracking per order
- ✅ Active bins count per order
- ✅ Today's operations per order
- ✅ Today's merges per order
- ✅ Active operators per order

### Order Management
- ✅ Order-to-bin linkage during QR assignment
- ✅ Order selection in Strategic Monitor
- ✅ Dynamic stats that change per order

### Production Workflow
- ✅ Automatic bin status progression
- ✅ Current operation tracking
- ✅ Workflow completion detection
- ✅ Bin reusability after merge

### Backend Integration
- ✅ Production server configuration
- ✅ Service discovery with production priority
- ✅ All 24 critical endpoints verified
- ✅ Order stats API integration

---

## 📦 Installation

### Requirements
- Android 5.0 or higher
- Internet connection for backend communication
- Camera permission (for QR scanning)

### Steps
1. Download `SMO-V1.apk` from this release
2. Enable "Install from unknown sources" in Android settings
3. Install the APK
4. Launch the app (appears as "SMO-V1")
5. Login with your credentials

### Test Credentials
- **GM:** empId: 1003
- **Supervisor:** empId: 1004
- **HR Admin:** empId: 1001

---

## 🧪 Testing Checklist

### ✅ Verified Features
- [x] Login as GM, Supervisor, HR
- [x] Master Data CRUD operations
- [x] Process Plans visualization
- [x] Strategic Monitor with order stats
- [x] QR Assignment with order linkage
- [x] Work tracking and progression
- [x] Bin merging
- [x] Service discovery and backend connection
- [x] All 24 backend endpoints working

### 📊 Production Endpoints Tested
- Health check
- Approved orders
- Order-specific statistics
- Master data management
- Supervisor operations
- Insights and analytics

---

## 🐛 Known Issues

None reported in production testing.

---

## 📝 Release Notes

### Backend Changes
- Updated OrderMonitorController to include bins with 'assigned' status
- Fixed StyleVariant model with missing fields
- Enhanced MergingService with dual field checking
- Improved TrackingService with bin status lifecycle
- Added mandatory button/thread validation in GTG creation

### Frontend Changes
- Updated base URL to production server with /smo context
- Enhanced Strategic Monitor with order-specific stats
- Improved service discovery with production priority
- Updated app name to SMO-V1
- Fixed all endpoint mappings

---

## 🔗 Links

- **Frontend Repository:** https://github.com/PremSaiBollamoni/SMO-Frontend-V2
- **Backend Repository:** https://github.com/PremSaiBollamoni/SMO
- **Production Server:** https://smobza.thegttech.com/smo
- **Documentation:** See README.md files in repositories

---

## 👥 Credits

**Developer:** Prem Sai Bollamoni  
**Team Leaders:** Dr. N.V.S Shankar, K.V. Kalyan  
**Organization:** CUTM

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

Special thanks to:
- Flutter team for the amazing framework
- GetX community for state management
- The open-source community
- All testers and contributors

---

## 📞 Support

For issues or questions:
- Email: premsaibollamoni@gmail.com
- GitHub Issues: https://github.com/PremSaiBollamoni/SMO-Frontend-V2/issues

---

**⭐ Star the repository if you find it helpful!**

Made with ❤️ for the garment manufacturing industry
