module main

fn test_get_changes() {
	lines := get_changes('CHANGELOG.md')!
	assert lines.len > 0
	assert lines[0] == '# Changes'
}

fn test_no_changes() {
	n, heading, last_version, last_date, last_product := analyse_changes([]string{}, Opts{})!
	assert n == -1
	assert heading == 0
	assert last_version == ''
	assert last_date == ''
	assert last_product == ''
}

fn test_just_title_change() {
	n, heading, last_version, last_date, last_product := analyse_changes(['# Changes'], Opts{})!
	assert n == -1
	assert heading == 0
	assert last_version == ''
	assert last_date == ''
	assert last_product == ''
}

fn test_first_change() {
	n, heading, last_version, last_date, last_product := analyse_changes([
		'# 1.0.1 (2011-05-21)',
	], Opts{})!
	assert n == 0
	assert heading == 1
	assert last_version == '1.0.1'
	assert last_date == '2011-05-21'
	assert last_product == ''
}

fn test_other_change() {
	n, heading, last_version, last_date, last_product := analyse_changes([
		'## [14.0.3](https://github.com/prantlf/jsonlint/compare/v14.0.2...v14.0.3) (2023-04-27)',
	], Opts{})!
	assert n == 0
	assert heading == 2
	assert last_version == '14.0.3'
	assert last_date == '2023-04-27'
	assert last_product == ''
}

fn test_whole_log() {
	n, heading, last_version, last_date, last_product := analyse_changes(['# Changes', '',
		'## [14.0.3](https://github.com/prantlf/jsonlint/compare/v14.0.2...v14.0.3) (2023-04-27)',
		'', '## 1.0.1 (2011-05-21)', ''], Opts{})!
	assert n == 2
	assert heading == 2
	assert last_version == '14.0.3'
	assert last_date == '2023-04-27'
	assert last_product == ''
}

fn test_first_product() {
	n, heading, last_version, last_date, last_product := analyse_changes([
		'# 26.1.0 (1.0.1) (2011-05-21)',
	], Opts{
		version_re: r'^\s*(?<heading>#+)\s+(?:(?<product>\d+\.\d+\.\d+) +\((?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)\)|(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)|(?:\[(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)\])).+\((?<date>[-\d]+)\)\s*$'
	})!
	assert n == 0
	assert heading == 1
	assert last_version == '1.0.1'
	assert last_date == '2011-05-21'
	assert last_product == '26.1.0'
}

fn test_other_product() {
	n, heading, last_version, last_date, last_product := analyse_changes([
		'## [26.1.5 (14.0.3)](https://github.com/prantlf/jsonlint/compare/v14.0.2...v14.0.3) (2023-04-27)',
	], Opts{
		version_re: r'^\s*(?<heading>#+)\s+(?:(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)|(?:\[(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)\])|(?:\[(?<product>\d+\.\d+\.\d+) +\((?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)\)\])|(?:\[(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)\])).+\((?<date>[-\d]+)\)\s*$'
	})!
	assert n == 0
	assert heading == 2
	assert last_version == '14.0.3'
	assert last_date == '2023-04-27'
	assert last_product == '26.1.5'
}
