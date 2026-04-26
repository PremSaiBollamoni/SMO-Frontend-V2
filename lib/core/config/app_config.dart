/// Application configuration constants
const String baseUrl = 'http://192.168.29.139:8080';
const String appVersion = '1.0';
const String appName = 'SMO System';
const String appSubtitle = 'Sewing Machine Operations';

/// API Endpoints
class ApiEndpoints {
  // Auth
  static const String login = '/api/auth/login';
  static const String health = '/api/health';

  // HR
  static const String hrRoles = '/api/hr/roles';
  static const String hrEmployees = '/api/hr/employees';
  static const String hrEmployeeDetail = '/api/hr/employees'; // with /{id}
  static const String hrLogin = '/api/hr/login';
  static const String hrLoginUpdate = '/api/hr/login'; // with /{id}
}

/// Query Parameters
class QueryParams {
  static const String actorEmpId = 'actorEmpId';
}

/// Timeouts (in seconds)
class Timeouts {
  static const int connectionTimeout = 60;
  static const int receiveTimeout = 60;
  static const int sendTimeout = 60;
  static const int healthCheckTimeout = 45; // For Render cold start
}

/// Shared Preferences Keys
class PrefsKeys {
  static const String employeeName = 'EMPLOYEE_NAME';
  static const String role = 'ROLE';
  static const String empId = 'EMP_ID';
  static const String activities = 'ACTIVITIES';
  static const String darkMode = 'dark_mode';
}

/// Employee Statuses
class EmployeeStatuses {
  static const List<String> all = ['ACTIVE', 'RESIGNED', 'TERMINATED'];
  static const String active = 'ACTIVE';
  static const String resigned = 'RESIGNED';
  static const String terminated = 'TERMINATED';
}

/// Role Statuses
class RoleStatuses {
  static const List<String> all = ['ACTIVE', 'INACTIVE'];
  static const String active = 'ACTIVE';
  static const String inactive = 'INACTIVE';
}

/// User Roles
class UserRoles {
  static const String hr = 'HR';
  static const String admin = 'ADMIN';
  static const String operator = 'OPERATOR';
  static const String cutter = 'CUTTER';
  static const String stitcher = 'STITCHER';
  static const String ironing = 'IRONING';
  static const String packager = 'PACKAGER';
  static const String storeManager = 'STORE MANAGER';
  static const String purchaseManager = 'PURCHASE MANAGER';
  static const String qcEngineer = 'QC ENGINEER';
  static const String qualityControlEngineer = 'QUALITY CONTROL ENGINEER';
  static const String qualityControlManager = 'QUALITY CONTROL MANAGER';
  static const String qcManager = 'QC MANAGER';
  static const String supervisor = 'SUPERVISOR';
  static const String gm = 'GM';
  static const String processPlannerRole = 'PROCESS PLANNER';

  static const List<String> operatorRoles = [
    operator,
    cutter,
    stitcher,
    ironing,
    packager,
  ];

  static const List<String> qcRoles = [
    qcEngineer,
    qualityControlEngineer,
    qualityControlManager,
    qcManager,
  ];

  static const List<String> supervisorRoles = [supervisor];
}
