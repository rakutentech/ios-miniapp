# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 500

xcov.report(
  workspace: 'MiniApp.xcworkspace',
  scheme: 'MiniApp_Tests',
  xccov_file_direct_path: ENV['BITRISE_XCRESULT_PATH'],
  source_directory: 'MiniApp',
  json_report: true,
  include_targets: 'MiniApp.framework',
  include_test_targets: false,
  minimum_coverage_percentage: 70.0
)