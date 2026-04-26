import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

/// Service Discovery for SMO Backend
/// Automatically discovers SMO backend services on the local network
class ServiceDiscoveryService extends GetxService {
  static const String _cacheKey = 'smo_backend_url';
  static const String _serviceType = '_smo._tcp';
  static const int _discoveryTimeout = 10; // seconds
  static const int _networkScanTimeout = 5; // seconds per IP
  
  final Dio _dio = Dio();
  String? _cachedBackendUrl;
  
  /// Initialize service discovery
  @override
  Future<void> onInit() async {
    super.onInit();
    _dio.options.connectTimeout = const Duration(seconds: 3);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    await _loadCachedUrl();
  }

  /// Discover SMO backend service automatically
  /// Returns the base URL of the discovered backend
  Future<String?> discoverBackend() async {
    print('[ServiceDiscovery] Starting backend discovery...');
    
    // Step 1: Try cached URL first
    if (_cachedBackendUrl != null) {
      print('[ServiceDiscovery] Trying cached URL: $_cachedBackendUrl');
      if (await _validateBackend(_cachedBackendUrl!)) {
        print('[ServiceDiscovery] ✓ Cached backend is available');
        return _cachedBackendUrl;
      } else {
        print('[ServiceDiscovery] ✗ Cached backend is not available, clearing cache');
        _cachedBackendUrl = null;
        await _clearCachedUrl();
      }
    }
    
    // Step 2: Try localhost first (most common for development)
    print('[ServiceDiscovery] Trying localhost...');
    if (await _validateBackend('http://localhost:8080')) {
      await _cacheUrl('http://localhost:8080');
      return 'http://localhost:8080';
    }
    
    // Step 3: Try current machine IP
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            String testUrl = 'http://${addr.address}:8080';
            print('[ServiceDiscovery] Trying current machine IP: $testUrl');
            if (await _validateBackend(testUrl)) {
              await _cacheUrl(testUrl);
              return testUrl;
            }
          }
        }
      }
    } catch (e) {
      print('[ServiceDiscovery] Error checking machine IPs: $e');
    }
    
    // Step 4: Try mDNS discovery
    String? mdnsUrl = await _discoverViaMdns();
    if (mdnsUrl != null) {
      await _cacheUrl(mdnsUrl);
      return mdnsUrl;
    }
    
    // Step 5: Try network scanning as fallback
    String? scanUrl = await _discoverViaNetworkScan();
    if (scanUrl != null) {
      await _cacheUrl(scanUrl);
      return scanUrl;
    }
    
    print('[ServiceDiscovery] ✗ No SMO backend found on network');
    return null;
  }

  /// Discover backend using mDNS/Bonjour
  Future<String?> _discoverViaMdns() async {
    print('[ServiceDiscovery] Trying mDNS discovery...');
    
    try {
      final MDnsClient client = MDnsClient();
      await client.start();
      
      // Look for SMO service
      await for (final PtrResourceRecord ptr in client
          .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(_serviceType))
          .timeout(Duration(seconds: _discoveryTimeout))) {
        
        print('[ServiceDiscovery] Found mDNS service: ${ptr.domainName}');
        
        // Get service details
        await for (final SrvResourceRecord srv in client
            .lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))
            .timeout(Duration(seconds: 2))) {
          
          // Get IP address
          await for (final IPAddressResourceRecord ip in client
              .lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target))
              .timeout(Duration(seconds: 2))) {
            
            String backendUrl = 'http://${ip.address.address}:${srv.port}';
            print('[ServiceDiscovery] Testing mDNS backend: $backendUrl');
            
            if (await _validateBackend(backendUrl)) {
              print('[ServiceDiscovery] ✓ mDNS backend validated: $backendUrl');
              client.stop();
              return backendUrl;
            }
          }
        }
      }
      
      client.stop();
    } catch (e) {
      print('[ServiceDiscovery] mDNS discovery failed: $e');
    }
    
    return null;
  }

  /// Discover backend by scanning local network
  Future<String?> _discoverViaNetworkScan() async {
    print('[ServiceDiscovery] Trying network scan discovery...');
    
    try {
      // Get local IP ranges to scan
      List<String> ipRanges = await _getLocalIpRanges();
      
      for (String ipRange in ipRanges) {
        print('[ServiceDiscovery] Scanning IP range: $ipRange');
        
        List<Future<String?>> scanTasks = [];
        
        // Scan common ports and IPs in parallel (limit to 50 concurrent tasks)
        for (int i = 1; i <= 254; i++) {
          String ip = ipRange.replaceAll('x', i.toString());
          scanTasks.add(_testBackendUrl('http://$ip:8080'));
          
          // Limit concurrent tasks to avoid overwhelming the network
          if (scanTasks.length >= 50) {
            String? result = await _waitForFirstSuccess(scanTasks);
            if (result != null) {
              print('[ServiceDiscovery] ✓ Network scan found backend: $result');
              return result;
            }
            scanTasks.clear();
          }
        }
        
        // Wait for remaining tasks
        if (scanTasks.isNotEmpty) {
          String? result = await _waitForFirstSuccess(scanTasks);
          if (result != null) {
            print('[ServiceDiscovery] ✓ Network scan found backend: $result');
            return result;
          }
        }
      }
    } catch (e) {
      print('[ServiceDiscovery] Network scan failed: $e');
    }
    
    return null;
  }

  /// Get local IP ranges for scanning
  Future<List<String>> _getLocalIpRanges() async {
    List<String> ranges = [];
    
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            String ip = addr.address;
            print('[ServiceDiscovery] Found local IP: $ip');
            
            // Generate scan range based on subnet
            if (ip.startsWith('192.168.')) {
              String base = ip.substring(0, ip.lastIndexOf('.'));
              ranges.add('$base.x');
            } else if (ip.startsWith('10.')) {
              String base = ip.substring(0, ip.lastIndexOf('.'));
              ranges.add('$base.x');
            } else if (ip.startsWith('172.')) {
              String base = ip.substring(0, ip.lastIndexOf('.'));
              ranges.add('$base.x');
            } else {
              // For any other IP range, generate the subnet
              String base = ip.substring(0, ip.lastIndexOf('.'));
              ranges.add('$base.x');
            }
          }
        }
      }
    } catch (e) {
      print('[ServiceDiscovery] Failed to get IP ranges: $e');
    }
    
    // Fallback ranges if nothing found
    if (ranges.isEmpty) {
      ranges.addAll(['192.168.1.x', '192.168.0.x', '10.0.0.x', '10.89.193.x']);
    }
    
    // Remove duplicates
    ranges = ranges.toSet().toList();
    
    print('[ServiceDiscovery] IP ranges to scan: $ranges');
    return ranges;
  }

  /// Test if a URL hosts SMO backend
  Future<String?> _testBackendUrl(String url) async {
    try {
      final response = await _dio.get(
        '$url/api/discovery/ping',
        options: Options(
          sendTimeout: Duration(seconds: _networkScanTimeout),
          receiveTimeout: Duration(seconds: _networkScanTimeout),
        ),
      );
      
      if (response.statusCode == 200 && 
          response.data is Map &&
          response.data['service'] == 'SMO-Backend') {
        return url;
      }
    } catch (e) {
      // Ignore connection errors during scanning
    }
    
    return null;
  }

  /// Wait for first successful result from parallel tasks
  Future<String?> _waitForFirstSuccess(List<Future<String?>> tasks) async {
    Completer<String?> completer = Completer();
    int completedTasks = 0;
    
    for (var task in tasks) {
      task.then((result) {
        completedTasks++;
        if (result != null && !completer.isCompleted) {
          completer.complete(result);
        } else if (completedTasks == tasks.length && !completer.isCompleted) {
          completer.complete(null);
        }
      }).catchError((error) {
        completedTasks++;
        if (completedTasks == tasks.length && !completer.isCompleted) {
          completer.complete(null);
        }
      });
    }
    
    return completer.future;
  }

  /// Validate that a URL hosts a valid SMO backend
  Future<bool> _validateBackend(String url) async {
    try {
      // Test health endpoint
      final response = await _dio.get('$url/api/health');
      
      if (response.statusCode == 200 && 
          response.data is Map &&
          response.data['service'] == 'SMO-Backend' &&
          response.data['status'] == 'UP') {
        return true;
      }
    } catch (e) {
      print('[ServiceDiscovery] Backend validation failed for $url: $e');
    }
    
    return false;
  }

  /// Cache discovered backend URL
  Future<void> _cacheUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, url);
      _cachedBackendUrl = url;
      print('[ServiceDiscovery] Cached backend URL: $url');
    } catch (e) {
      print('[ServiceDiscovery] Failed to cache URL: $e');
    }
  }

  /// Load cached backend URL
  Future<void> _loadCachedUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedBackendUrl = prefs.getString(_cacheKey);
      if (_cachedBackendUrl != null) {
        print('[ServiceDiscovery] Loaded cached URL: $_cachedBackendUrl');
      }
    } catch (e) {
      print('[ServiceDiscovery] Failed to load cached URL: $e');
    }
  }

  /// Clear cached backend URL
  Future<void> _clearCachedUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      _cachedBackendUrl = null;
      print('[ServiceDiscovery] Cleared cached URL');
    } catch (e) {
      print('[ServiceDiscovery] Failed to clear cached URL: $e');
    }
  }

  /// Get current backend URL (cached or discovered)
  String? get currentBackendUrl => _cachedBackendUrl;

  /// Force refresh discovery (clears cache and rediscovers)
  Future<String?> refreshDiscovery() async {
    print('[ServiceDiscovery] Force refreshing discovery...');
    await _clearCachedUrl();
    return await discoverBackend();
  }
  
  /// Manual override for testing - set a specific backend URL
  Future<void> setManualBackendUrl(String url) async {
    print('[ServiceDiscovery] Setting manual backend URL: $url');
    await _cacheUrl(url);
  }
}