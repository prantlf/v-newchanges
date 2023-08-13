module main

fn test_get_changes() {
	lines := get_changes('CHANGELOG.md')!
	assert lines.len > 0
	assert lines[0] == '# Changes'
}

fn test_no_changes() {
	n, heading, last_version := analyse_changes([]string{}, Opts{})!
	assert n == -1
	assert heading == 0
	assert last_version == ''
}

fn test_just_title_change() {
	n, heading, last_version := analyse_changes(['# Changes'], Opts{})!
	assert n == -1
	assert heading == 0
	assert last_version == ''
}

fn test_first_change() {
	n, heading, last_version := analyse_changes(['# 1.0.1 (2011-05-21)'], Opts{})!
	assert n == 0
	assert heading == 1
	assert last_version == '1.0.1'
}

fn test_other_change() {
	n, heading, last_version := analyse_changes([
		'## [14.0.3](https://github.com/prantlf/jsonlint/compare/v14.0.2...v14.0.3) (2023-04-27)',
	], Opts{})!
	assert n == 0
	assert heading == 2
	assert last_version == '14.0.3'
}

fn test_whole_log() {
	n, heading, last_version := analyse_changes(['# Changes', '',
		'## [14.0.3](https://github.com/prantlf/jsonlint/compare/v14.0.2...v14.0.3) (2023-04-27)',
		'', '## 1.0.1 (2011-05-21)', ''], Opts{})!
	assert n == 2
	assert heading == 2
	assert last_version == '14.0.3'
}
