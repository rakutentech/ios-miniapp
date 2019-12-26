# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

xcov.report(
  workspace: 'MiniApp.xcworkspace',
  scheme: 'MiniApp_Tests',
  output_directory: './artifacts/unit-tests/coverage',
  source_directory: 'MiniApp',
  json_report: true,
  include_targets: 'MiniApp.framework',
  include_test_targets: false,
  minimum_coverage_percentage: 50.0