module main

fn test_no_commits() {
	commits, all_commit_count := parse_commits('', Opts{})!
	assert commits.len == 0
}

fn test_unclassified_commit() {
	commits, all_commit_count := parse_commits('1740851f1fc2edc5c626241e8a737523bcabf8d8
2010-03-13

Initial commit

----------==========----------',
		Opts{})!
	assert commits.len == 0
	assert all_commit_count == 1
}

fn test_significant_commit() {
	commits, all_commit_count := parse_commits('b1535a3ec24be7913f0005cdd617680c02086cdf
2023-03-05

fix: Replace ajv@6 with ajv-draft-04

Support JSON Schema draft 04 by a more modern package.

----------==========----------',
		Opts{})!
	assert commits.len == 1
	assert commits[0].tags.len == 0
	assert commits[0].vars.len == 5
	assert commits[0].vars.get_one('short_hash') == 'b1535a3'
	assert commits[0].vars.get_one('hash') == 'b1535a3ec24be7913f0005cdd617680c02086cdf'
	assert commits[0].vars.get_one('date') == '2023-03-05'
	assert commits[0].vars.get_one('type') == 'fix'
	assert commits[0].vars.get_one('description') == 'Replace ajv@6 with ajv-draft-04'
	assert all_commit_count == 1
}

fn test_commit_with_note() {
	commits, all_commit_count := parse_commits("0b9130ceae5f6f27cbe3e6d65207127862ffe584
2023-03-05

feat: Support JSON Schema drafts 2019-09 and 2020-12 and JSON Type Definition

Upgrade AJV to the latest version and retain the previous AJV@6
to be able to support JSON Schema draft 04.

BREAKING CHANGE: The default environment recognises only JSON Schema drafts 06 and 07 automatically. Not 04 any more. The environment for JSON Schema drafts 04 has to be selected explicitly.
Also, JSON Schema drafts 06 and 07 are handled by AJV@8 instead of AJV@6. It shouldn't make any difference, but the implementation is new and could perform a stricter validation.

----------==========----------",
		Opts{})!
	assert commits.len == 1
	assert commits[0].tags.len == 0
	assert commits[0].vars.len == 6
	assert commits[0].vars.get_one('short_hash') == '0b9130c'
	assert commits[0].vars.get_one('hash') == '0b9130ceae5f6f27cbe3e6d65207127862ffe584'
	assert commits[0].vars.get_one('date') == '2023-03-05'
	assert commits[0].vars.get_one('type') == 'feat'
	assert commits[0].vars.get_one('description') == 'Support JSON Schema drafts 2019-09 and 2020-12 and JSON Type Definition'
	assert commits[0].vars.get_one('BREAKING_CHANGE') == "The default environment recognises only JSON Schema drafts 06 and 07 automatically. Not 04 any more. The environment for JSON Schema drafts 04 has to be selected explicitly.
Also, JSON Schema drafts 06 and 07 are handled by AJV@8 instead of AJV@6. It shouldn't make any difference, but the implementation is new and could perform a stricter validation."
	assert all_commit_count == 1
}

fn test_commit_with_two_notes() {
	commits, all_commit_count := parse_commits("0b9130ceae5f6f27cbe3e6d65207127862ffe584
2023-03-05

feat: Support JSON Schema drafts 2019-09 and 2020-12 and JSON Type Definition

BREAKING CHANGE: The default environment recognises only JSON Schema drafts 06 and 07 automatically. Not 04 any more. The environment for JSON Schema drafts 04 has to be selected explicitly.
Also, JSON Schema drafts 06 and 07 are handled by AJV@8 instead of AJV@6. It shouldn't make any difference, but the implementation is new and could perform a stricter validation.

REMARKS: Upgrade AJV to the latest version and retain the previous AJV@6 to be able to support JSON Schema draft 04.

----------==========----------",
		Opts{})!
	assert commits.len == 1
	assert commits[0].tags.len == 0
	assert commits[0].vars.len == 7
	assert commits[0].vars.get_one('short_hash') == '0b9130c'
	assert commits[0].vars.get_one('hash') == '0b9130ceae5f6f27cbe3e6d65207127862ffe584'
	assert commits[0].vars.get_one('date') == '2023-03-05'
	assert commits[0].vars.get_one('type') == 'feat'
	assert commits[0].vars.get_one('description') == 'Support JSON Schema drafts 2019-09 and 2020-12 and JSON Type Definition'
	assert commits[0].vars.get_one('BREAKING_CHANGE') == "The default environment recognises only JSON Schema drafts 06 and 07 automatically. Not 04 any more. The environment for JSON Schema drafts 04 has to be selected explicitly.
Also, JSON Schema drafts 06 and 07 are handled by AJV@8 instead of AJV@6. It shouldn't make any difference, but the implementation is new and could perform a stricter validation."
	assert commits[0].vars.get_one('REMARKS') == 'Upgrade AJV to the latest version and retain the previous AJV@6 to be able to support JSON Schema draft 04.'
	assert all_commit_count == 1
}

fn test_simple_release_commit() {
	commits, all_commit_count := parse_commits('a3de000313453b9012511b3252ed43085dbdfb96
2023-03-05
tag: v13.0.0
13.0.0

----------==========----------',
		Opts{})!
	assert commits.len == 1
	assert commits[0].tags == ['v13.0.0']
	assert commits[0].vars.len == 3
	assert commits[0].vars.get_one('short_hash') == 'a3de000'
	assert commits[0].vars.get_one('hash') == 'a3de000313453b9012511b3252ed43085dbdfb96'
	assert commits[0].vars.get_one('date') == '2023-03-05'
	assert all_commit_count == 1
}

fn test_complex_release_commit() {
	commits, all_commit_count := parse_commits("a3de000313453b9012511b3252ed43085dbdfb96
2023-03-05
tag: v13.0.0
chore(release): 13.0.0 [skip ci]

# [13.0.0](https://github.com/prantlf/jsonlint/compare/v12.0.0...v13.0.0) (2023-03-05)

### Features

* Support JSON Schema drafts 2019-09 and 2020-12 and JSON Type Definition ([0b9130c](https://github.com/prantlf/jsonlint/commit/0b9130ceae5f6f27cbe3e6d65207127862ffe584))

### BREAKING CHANGES

* The default environment recognises only JSON Schema drafts 06 and 07 automatically. Not 04 any more. The environment for JSON Schema drafts 04 has to be selected explicitly. Also, JSON Schema drafts 06 and 07 are handled by AJV@8 instead of AJV@6. It shouldn't make any difference, but the implementation is new and could perform a stricter validation.

----------==========----------",
		Opts{})!
	assert commits.len == 1
	assert commits[0].tags == ['v13.0.0']
	assert commits[0].vars.len == 5
	assert commits[0].vars.get_one('short_hash') == 'a3de000'
	assert commits[0].vars.get_one('hash') == 'a3de000313453b9012511b3252ed43085dbdfb96'
	assert commits[0].vars.get_one('date') == '2023-03-05'
	assert commits[0].vars.get_one('type') == 'chore(release)'
	assert commits[0].vars.get_one('description') == '13.0.0 [skip ci]'
	assert all_commit_count == 1
}

fn test_head_release_commit() {
	commits, all_commit_count := parse_commits('ffc5c32d2811c00b8f237592467fcc898f035c9f
2023-04-27
HEAD -> master, tag: v14.0.3, tag: v-next, origin/master, origin/HEAD
chore(release): 14.0.3 [skip ci]

## [14.0.3](https://github.com/prantlf/jsonlint/compare/v14.0.2...v14.0.3) (2023-04-27)

### Bug Fixes

* Ensure error location by custom parsing ([9757213](https://github.com/prantlf/jsonlint/commit/9757213eda5de9684099024d0c4f59e4d4f59c97))
* Upgrade dependencies ([30f611a](https://github.com/prantlf/jsonlint/commit/30f611a1fc24a9003929a1f399d1694de65401ed))

----------==========----------',
		Opts{})!
	assert commits.len == 1
	assert commits[0].tags == ['v14.0.3']
	assert commits[0].vars.len == 5
	assert commits[0].vars.get_one('short_hash') == 'ffc5c32'
	assert commits[0].vars.get_one('hash') == 'ffc5c32d2811c00b8f237592467fcc898f035c9f'
	assert commits[0].vars.get_one('date') == '2023-04-27'
	assert commits[0].vars.get_one('type') == 'chore(release)'
	assert commits[0].vars.get_one('description') == '14.0.3 [skip ci]'
	assert all_commit_count == 1
}

fn test_custom_description_1() {
	commits, all_commit_count := parse_commits('b1535a3ec24be7913f0005cdd617680c02086cdf
2023-03-05

Replace ajv@6 with ajv-draft-04 (fix)

----------==========----------',
		Opts{
		subject_re: r'^\s*(?<description>.+)\s*\((?<type>[^ ]+)\)\s*$'
	})!
	assert commits.len == 1
	assert commits[0].tags.len == 0
	assert commits[0].vars.len == 5
	assert commits[0].vars.get_one('short_hash') == 'b1535a3'
	assert commits[0].vars.get_one('hash') == 'b1535a3ec24be7913f0005cdd617680c02086cdf'
	assert commits[0].vars.get_one('date') == '2023-03-05'
	assert commits[0].vars.get_one('type') == 'fix'
	assert commits[0].vars.get_one('description') == 'Replace ajv@6 with ajv-draft-04'
	assert all_commit_count == 1
}

fn test_custom_description_2() {
	commits, all_commit_count := parse_commits('b1535a3ec24be7913f0005cdd617680c02086cdf
2023-03-05

Replace ajv@6 with ajv-draft-04 (fix, #87, #101)

----------==========----------',
		Opts{
		subject_re: r'^\s*(?<description>.+)\s*\((?<type>[^ ]+)(?:\s*,\s*#(?<issue>[^ ]+))?(?:\s*,\s*#(?<issue>[^ ]+))?\)\s*$'
	})!
	assert commits.len == 1
	assert commits[0].tags.len == 0
	assert commits[0].vars.len == 6
	assert commits[0].vars.get_one('short_hash') == 'b1535a3'
	assert commits[0].vars.get_one('hash') == 'b1535a3ec24be7913f0005cdd617680c02086cdf'
	assert commits[0].vars.get_one('date') == '2023-03-05'
	assert commits[0].vars.get_one('type') == 'fix'
	assert commits[0].vars.get_more('issue') == ['87', '101']
	assert commits[0].vars.get_one('description') == 'Replace ajv@6 with ajv-draft-04'
	assert all_commit_count == 1
}

fn test_custom_footer() {
	commits, all_commit_count := parse_commits('b1535a3ec24be7913f0005cdd617680c02086cdf
2023-03-05

Replace ajv@6 with ajv-draft-04

Type: fix
Fixes #87 #95
Fixes #101
----------==========----------',
		Opts{
		subject_re: r'^\s*(?<description>.+)$'
		footer_re:  r'^(?:Type:\s*(?<type>[^ ]+))|(?:Fixes\s*#(?<issue>[^ ]+)(?:\s*#(?<issue>[^ ]+))?)\s*$'
	})!
	assert commits.len == 1
	assert commits[0].tags.len == 0
	assert commits[0].vars.len == 6
	assert commits[0].vars.get_one('short_hash') == 'b1535a3'
	assert commits[0].vars.get_one('hash') == 'b1535a3ec24be7913f0005cdd617680c02086cdf'
	assert commits[0].vars.get_one('date') == '2023-03-05'
	assert commits[0].vars.get_one('type') == 'fix'
	assert commits[0].vars.get_more('issue') == ['87', '95', '101']
	assert commits[0].vars.get_one('description') == 'Replace ajv@6 with ajv-draft-04'
	assert all_commit_count == 1
}

fn test_mapped_type() {
	commits, all_commit_count := parse_commits('b1535a3ec24be7913f0005cdd617680c02086cdf
2023-03-05

defect: Replace ajv@6 with ajv-draft-04

Support JSON Schema draft 04 by a more modern package.

----------==========----------',
		Opts{
		type_mapping: {
			'defect': 'fix'
		}
	})!
	assert commits.len == 1
	assert commits[0].tags.len == 0
	assert commits[0].vars.len == 5
	assert commits[0].vars.get_one('short_hash') == 'b1535a3'
	assert commits[0].vars.get_one('hash') == 'b1535a3ec24be7913f0005cdd617680c02086cdf'
	assert commits[0].vars.get_one('date') == '2023-03-05'
	assert commits[0].vars.get_one('type') == 'fix'
	assert commits[0].vars.get_one('description') == 'Replace ajv@6 with ajv-draft-04'
	assert all_commit_count == 1
}
