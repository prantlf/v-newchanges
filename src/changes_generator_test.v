module main

fn test_one_tagged_fix() {
	commits := [
		Commit{
			last: true
			tags: ['v1.0.1']
			vars: {
				'type':        ['fix']
				'short_hash':  ['b1535a3']
				'hash':        ['b1535a3ec24be7913f0005cdd617680c02086cdf']
				'date':        ['2023-03-05']
				'description': ['Replace ajv@6 with ajv-draft-04']
			}
		},
	]
	changes := generate_changes(commits, '1.0.0', '1.0.2', '2023-08-05', Opts{
		repo_url: 'https://github.com/test/test'
	})!
	assert changes == [
		'## [1.0.1](https://github.com/test/test/compare/v1.0.0...v1.0.1) (2023-03-05)',
		'',
		'### Bug Fixes',
		'',
		'* Replace ajv@6 with ajv-draft-04 ([b1535a3](https://github.com/test/test/commit/b1535a3ec24be7913f0005cdd617680c02086cdf))',
		'',
	]
}

fn test_one_new_fix() {
	commits := [
		Commit{
			last: true
			vars: {
				'type':        ['fix']
				'short_hash':  ['b1535a3']
				'hash':        ['b1535a3ec24be7913f0005cdd617680c02086cdf']
				'date':        ['2023-03-05']
				'description': ['Replace ajv@6 with ajv-draft-04']
			}
		},
	]
	changes := generate_changes(commits, '1.0.0', '1.0.1', '2023-08-05', Opts{
		repo_url: 'https://github.com/test/test'
	})!
	assert changes == [
		'## [1.0.1](https://github.com/test/test/compare/v1.0.0...v1.0.1) (2023-08-05)',
		'',
		'### Bug Fixes',
		'',
		'* Replace ajv@6 with ajv-draft-04 ([b1535a3](https://github.com/test/test/commit/b1535a3ec24be7913f0005cdd617680c02086cdf))',
		'',
	]
}

fn test_two_new_fixes() {
	commits := [
		Commit{
			last: true
			vars: {
				'type':        ['fix']
				'short_hash':  ['b1535a3']
				'hash':        ['b1535a3ec24be7913f0005cdd617680c02086cdf']
				'date':        ['2023-03-05']
				'description': ['Replace ajv@6 with ajv-draft-04']
			}
		},
		Commit{
			vars: {
				'type':        ['fix']
				'short_hash':  ['87205c2']
				'hash':        ['87205c2427a0ebe0d791a4189b2b2346506601b3']
				'date':        ['2023-03-04']
				'description': ['Upgrade dependencies and require Node.js 14']
			}
		},
	]
	changes := generate_changes(commits, '1.0.0', '1.0.1', '2023-08-05', Opts{
		repo_url: 'https://github.com/test/test'
	})!
	assert changes == [
		'## [1.0.1](https://github.com/test/test/compare/v1.0.0...v1.0.1) (2023-08-05)',
		'',
		'### Bug Fixes',
		'',
		'* Upgrade dependencies and require Node.js 14 ([87205c2](https://github.com/test/test/commit/87205c2427a0ebe0d791a4189b2b2346506601b3))',
		'* Replace ajv@6 with ajv-draft-04 ([b1535a3](https://github.com/test/test/commit/b1535a3ec24be7913f0005cdd617680c02086cdf))',
		'',
	]
}

fn test_two_versions() {
	commits := [
		Commit{
			last: true
			vars: {
				'type':        ['fix']
				'short_hash':  ['b1535a3']
				'hash':        ['b1535a3ec24be7913f0005cdd617680c02086cdf']
				'date':        ['2023-03-05']
				'description': ['Replace ajv@6 with ajv-draft-04']
			}
		},
		Commit{
			tags: ['v1.0.1']
			vars: {
				'type':        ['fix']
				'short_hash':  ['87205c2']
				'hash':        ['87205c2427a0ebe0d791a4189b2b2346506601b3']
				'date':        ['2023-03-04']
				'description': ['Upgrade dependencies and require Node.js 14']
			}
		},
	]
	changes := generate_changes(commits, '1.0.0', '1.0.2', '2023-08-05', Opts{
		repo_url: 'https://github.com/test/test'
	})!
	assert changes == [
		'## [1.0.2](https://github.com/test/test/compare/v1.0.1...v1.0.2) (2023-08-05)',
		'',
		'### Bug Fixes',
		'',
		'* Replace ajv@6 with ajv-draft-04 ([b1535a3](https://github.com/test/test/commit/b1535a3ec24be7913f0005cdd617680c02086cdf))',
		'',
		'## [1.0.1](https://github.com/test/test/compare/v1.0.0...v1.0.1) (2023-03-04)',
		'',
		'### Bug Fixes',
		'',
		'* Upgrade dependencies and require Node.js 14 ([87205c2](https://github.com/test/test/commit/87205c2427a0ebe0d791a4189b2b2346506601b3))',
		'',
	]
}

fn test_fix_with_breaking_change() {
	commits := [
		Commit{
			last: true
			vars: {
				'type':            ['fix']
				'short_hash':      ['87205c2']
				'hash':            ['87205c2427a0ebe0d791a4189b2b2346506601b3']
				'date':            ['2023-03-04']
				'description':     ['Upgrade dependencies and require Node.js 14']
				'BREAKING_CHANGE': ['* Dropped support for Node.js 12. The minimum supported version is Node.js 14.
* Solaris is not upported any more, because Node.js dropped support for it.']
			}
		},
	]
	changes := generate_changes(commits, '1.0.0', '1.0.1', '2023-08-05', Opts{
		repo_url: 'https://github.com/test/test'
	})!
	assert changes == [
		'## [1.0.1](https://github.com/test/test/compare/v1.0.0...v1.0.1) (2023-08-05)',
		'',
		'### Bug Fixes',
		'',
		'* Upgrade dependencies and require Node.js 14 ([87205c2](https://github.com/test/test/commit/87205c2427a0ebe0d791a4189b2b2346506601b3))',
		'',
		'### BREAKING CHANGES',
		'',
		'* Dropped support for Node.js 12. The minimum supported version is Node.js 14.
* Solaris is not upported any more, because Node.js dropped support for it.',
		'',
	]
}

fn test_fix_and_chore_with_breaking_change() {
	commits := [
		Commit{
			last: true
			vars: {
				'type':            ['fix']
				'short_hash':      ['87205c2']
				'hash':            ['87205c2427a0ebe0d791a4189b2b2346506601b3']
				'date':            ['2023-03-04']
				'description':     ['Upgrade dependencies and require Node.js 14']
				'BREAKING_CHANGE': ['* Dropped support for Node.js 12. The minimum supported version is Node.js 14.
* Solaris is not upported any more, because Node.js dropped support for it.']
			}
		},
		Commit{
			last: true
			vars: {
				'type':            ['chore']
				'short_hash':      ['4a8f2d9']
				'hash':            ['4a8f2d9c27428da32b95f607bf7952190636af9f']
				'date':            ['2019-12-22']
				'description':     ['Upgrade package dependencies']
				'BREAKING_CHANGE': ['* Dependencies (commander, at least) dropped support for Node.js 4. Node.js 6 should still work, but officially it is not supported either.
You should upgrade to the current or still supported Node.js LTS version.']
			}
		},
	]
	changes := generate_changes(commits, '1.0.0', '1.0.1', '2023-08-05', Opts{
		repo_url: 'https://github.com/test/test'
	})!
	assert changes == [
		'## [1.0.1](https://github.com/test/test/compare/v1.0.0...v1.0.1) (2023-08-05)',
		'',
		'### Bug Fixes',
		'',
		'* Upgrade dependencies and require Node.js 14 ([87205c2](https://github.com/test/test/commit/87205c2427a0ebe0d791a4189b2b2346506601b3))',
		'',
		'### Chores',
		'',
		'* Upgrade package dependencies ([4a8f2d9](https://github.com/test/test/commit/4a8f2d9c27428da32b95f607bf7952190636af9f))',
		'',
		'### BREAKING CHANGES',
		'',
		'* Dropped support for Node.js 12. The minimum supported version is Node.js 14.
* Solaris is not upported any more, because Node.js dropped support for it.',
		'',
		'* Dependencies (commander, at least) dropped support for Node.js 4. Node.js 6 should still work, but officially it is not supported either.
You should upgrade to the current or still supported Node.js LTS version.',
		'',
	]
}
