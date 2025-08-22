#!/usr/bin/env dart

import 'dart:io';

import 'package:flutter/foundation.dart';

/// Comprehensive test runner for the Flutter uploader app
class TestRunner {
  static const String testDirectory = 'test';
  static const String coverageDirectory = 'coverage';
  static const String coverageFile = 'coverage/lcov.info';
  static const double minimumCoverage = 80.0;

  final List<String> testFiles = [
    'models/user_model_test.dart',
    'models/employee_model_test.dart',
    'models/auth_token_model_test.dart',
    'models/upload_model_test.dart',
    'models/api_response_model_test.dart',
    'services/auth_service_test.dart',
    'services/user_service_test.dart',
    // Add more test files as they are created
  ];

  /// Run all unit tests
  Future<bool> runUnitTests() async {
    if (kDebugMode) {
      debugPrint('🧪 Running Unit Tests...');
    }

    final result = await Process.run('flutter', [
      'test',
      '--coverage',
      '--test-randomize-ordering-seed=random',
    ]);

    if (kDebugMode) {
      debugPrint('STDOUT: ${result.stdout}');
    }
    if (result.stderr.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('STDERR: ${result.stderr}');
      }
    }

    return result.exitCode == 0;
  }

  /// Run widget tests
  Future<bool> runWidgetTests() async {
    if (kDebugMode) {
      debugPrint('🎨 Running Widget Tests...');
    }

    final result = await Process.run('flutter', [
      'test',
      '--coverage',
      'test/widget_test.dart',
    ]);

    if (kDebugMode) {
      debugPrint('STDOUT: ${result.stdout}');
    }
    if (result.stderr.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('STDERR: ${result.stderr}');
      }
    }

    return result.exitCode == 0;
  }

  /// Run integration tests
  Future<bool> runIntegrationTests() async {
    if (kDebugMode) {
      debugPrint('🔗 Running Integration Tests...');
    }

    final result = await Process.run('flutter', [
      'test',
      'integration_test',
      '--coverage',
    ]);

    if (kDebugMode) {
      debugPrint('STDOUT: ${result.stdout}');
    }
    if (result.stderr.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('STDERR: ${result.stderr}');
      }
    }

    return result.exitCode == 0;
  }

  /// Generate coverage report
  Future<bool> generateCoverageReport() async {
    if (kDebugMode) {
      debugPrint('📊 Generating Coverage Report...');
    }

    // Create coverage directory if it doesn't exist
    final coverageDir = Directory(coverageDirectory);
    if (!coverageDir.existsSync()) {
      coverageDir.createSync(recursive: true);
    }

    // Generate HTML coverage report
    final result = await Process.run('genhtml', [
      coverageFile,
      '--output-directory=coverage/html',
    ]);

    if (result.exitCode != 0) {
      if (kDebugMode) {
        debugPrint('Failed to generate HTML coverage report: ${result.stderr}');
      }
      return false;
    }

    if (kDebugMode) {
      debugPrint('Coverage report generated in coverage/html/');
    }
    return true;
  }

  /// Analyze test coverage
  Future<Map<String, dynamic>> analyzeCoverage() async {
    final coverageFilePath = File(coverageFile);

    if (!coverageFilePath.existsSync()) {
      return {'error': 'Coverage file not found'};
    }

    final lines = coverageFilePath.readAsLinesSync();
    int totalLines = 0;
    int coveredLines = 0;

    for (final line in lines) {
      if (line.startsWith('DA:')) {
        final parts = line.split(',');
        if (parts.length >= 2) {
          totalLines++;
          final hits = int.tryParse(parts[1]) ?? 0;
          if (hits > 0) {
            coveredLines++;
          }
        }
      }
    }

    final coveragePercentage = totalLines > 0 ? (coveredLines / totalLines) * 100 : 0;

    return {
      'totalLines': totalLines,
      'coveredLines': coveredLines,
      'coveragePercentage': coveragePercentage,
      'meetsMinimum': coveragePercentage >= minimumCoverage,
    };
  }

  /// Run all tests
  Future<TestResults> runAllTests() async {
    final results = TestResults();

    if (kDebugMode) {
      debugPrint('🚀 Starting Comprehensive Test Suite');
    }
    if (kDebugMode) {
      debugPrint('=' * 50);
    }

    // Run unit tests
    results.unitTestsPassed = await runUnitTests();
    if (kDebugMode) {
      debugPrint('Unit Tests: ${results.unitTestsPassed ? '✅ PASSED' : '❌ FAILED'}');
    }

    // Run widget tests
    results.widgetTestsPassed = await runWidgetTests();
    if (kDebugMode) {
      debugPrint('Widget Tests: ${results.widgetTestsPassed ? '✅ PASSED' : '❌ FAILED'}');
    }

    // Run integration tests
    results.integrationTestsPassed = await runIntegrationTests();
    if (kDebugMode) {
      debugPrint('Integration Tests: ${results.integrationTestsPassed ? '✅ PASSED' : '❌ FAILED'}');
    }

    // Generate coverage report
    results.coverageGenerated = await generateCoverageReport();
    if (kDebugMode) {
      debugPrint('Coverage Report: ${results.coverageGenerated ? '✅ GENERATED' : '❌ FAILED'}');
    }

    // Analyze coverage
    results.coverageData = await analyzeCoverage();

    if (kDebugMode) {
      debugPrint('
📈 Test Results Summary:');
    }
    if (kDebugMode) {
      debugPrint('=' * 50);
    }

    if (results.coverageData.containsKey('coveragePercentage')) {
      final coverage = results.coverageData['coveragePercentage'];
      if (kDebugMode) {
        debugPrint('Code Coverage: ${coverage.toStringAsFixed(2)}%');
      }
      if (kDebugMode) {
        debugPrint('Minimum Required: $minimumCoverage%');
      }
      if (kDebugMode) {
        debugPrint('Coverage Status: ${results.coverageData['meetsMinimum'] ? '✅ MET' : '❌ NOT MET'}');
      }
    }

    results.allTestsPassed = results.unitTestsPassed &&
                          results.widgetTestsPassed &&
                          results.integrationTestsPassed;

    if (kDebugMode) {
      debugPrint('Overall Status: ${results.allTestsPassed ? '✅ ALL TESTS PASSED' : '❌ SOME TESTS FAILED'}');
    }

    return results;
  }

  /// Run tests for specific service
  Future<bool> runServiceTests(String serviceName) async {
    if (kDebugMode) {
      debugPrint('🔧 Running $serviceName Tests...');
    }

    final result = await Process.run('flutter', [
      'test',
      '--coverage',
      'test/services/${serviceName.toLowerCase()}_service_test.dart',
    ]);

    if (kDebugMode) {
      debugPrint('STDOUT: ${result.stdout}');
    }
    if (result.stderr.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('STDERR: ${result.stderr}');
      }
    }

    return result.exitCode == 0;
  }

  /// Run tests for specific model
  Future<bool> runModelTests(String modelName) async {
    if (kDebugMode) {
      debugPrint('📝 Running $modelName Model Tests...');
    }

    final result = await Process.run('flutter', [
      'test',
      '--coverage',
      'test/models/${modelName.toLowerCase()}_model_test.dart',
    ]);

    if (kDebugMode) {
      debugPrint('STDOUT: ${result.stdout}');
    }
    if (result.stderr.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('STDERR: ${result.stderr}');
      }
    }

    return result.exitCode == 0;
  }

  /// Clean test artifacts
  Future<void> cleanTestArtifacts() async {
    if (kDebugMode) {
      debugPrint('🧹 Cleaning test artifacts...');
    }

    final coverageDir = Directory(coverageDirectory);
    if (coverageDir.existsSync()) {
      coverageDir.deleteSync(recursive: true);
    }

    final testCoverageDir = Directory('.dart_tool/test_coverage');
    if (testCoverageDir.existsSync()) {
      testCoverageDir.deleteSync(recursive: true);
    }

    if (kDebugMode) {
      debugPrint('Test artifacts cleaned successfully');
    }
  }
}

/// Test results data class
class TestResults {
  bool unitTestsPassed = false;
  bool widgetTestsPassed = false;
  bool integrationTestsPassed = false;
  bool coverageGenerated = false;
  Map<String, dynamic> coverageData = {};
  bool allTestsPassed = false;

  Map<String, dynamic> toJson() {
    return {
      'unitTestsPassed': unitTestsPassed,
      'widgetTestsPassed': widgetTestsPassed,
      'integrationTestsPassed': integrationTestsPassed,
      'coverageGenerated': coverageGenerated,
      'coverageData': coverageData,
      'allTestsPassed': allTestsPassed,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

void main(List<String> arguments) async {
  final runner = TestRunner();

  if (arguments.isEmpty) {
    // Run all tests
    final results = await runner.runAllTests();
    exit(results.allTestsPassed ? 0 : 1);
  } else {
    final command = arguments[0];

    switch (command) {
      case 'unit':
        final success = await runner.runUnitTests();
        exit(success ? 0 : 1);

      case 'widget':
        final success = await runner.runWidgetTests();
        exit(success ? 0 : 1);

      case 'integration':
        final success = await runner.runIntegrationTests();
        exit(success ? 0 : 1);

      case 'coverage':
        final success = await runner.generateCoverageReport();
        exit(success ? 0 : 1);

      case 'clean':
        await runner.cleanTestArtifacts();
        exit(0);

      case 'service':
        if (arguments.length < 2) {
          if (kDebugMode) {
            debugPrint('Usage: dart test_runner.dart service <ServiceName>');
          }
          exit(1);
        }
        final success = await runner.runServiceTests(arguments[1]);
        exit(success ? 0 : 1);

      case 'model':
        if (arguments.length < 2) {
          if (kDebugMode) {
            debugPrint('Usage: dart test_runner.dart model <ModelName>');
          }
          exit(1);
        }
        final success = await runner.runModelTests(arguments[1]);
        exit(success ? 0 : 1);

      default:
        if (kDebugMode) {
          debugPrint('Usage: dart test_runner.dart [unit|widget|integration|coverage|clean|service|model]');
        }
        exit(1);
    }
  }
}