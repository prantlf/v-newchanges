module main

import time { now }

const now_date = now().ymmdd()

fn test_last_version_differs() {
	commits := [
		Commit{
			last: true
			tags: ['v1.0.1']
			vars: {
				'date': ['2023-07-18']
			}
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{})!
	assert next_version == '1.0.1'
	assert next_date == '2023-07-18'
}

fn test_last_version_same() {
	commits := [
		Commit{
			tags: ['v1.0.0']
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{})!
	assert next_version == ''
	assert next_date == ''
}

fn test_last_version_same_asume() {
	commits := [
		Commit{
			tags: ['v1.0.0']
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{
		assume_patch: true
	})!
	assert next_version == '1.0.1'
	assert next_date == now_date
}

fn test_no_last_version() {
	commits := [
		Commit{},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{})!
	assert next_version == ''
	assert next_date == ''
}

fn test_no_last_version_assume() {
	commits := [
		Commit{},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{
		assume_patch: true
	})!
	assert next_version == '1.0.1'
	assert next_date == now_date
}

fn test_patch() {
	commits := [
		Commit{
			vars: {
				'short_hash':  ['0000000']
				'type':        ['fix']
				'description': ['patch']
			}
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{})!
	assert next_version == '1.0.1'
	assert next_date == now_date
}

fn test_minor() {
	commits := [
		Commit{
			vars: {
				'short_hash':  ['0000000']
				'type':        ['feat']
				'description': ['minor']
			}
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{})!
	assert next_version == '1.1.0'
	assert next_date == now_date
}

fn test_major() {
	commits := [
		Commit{
			vars: {
				'short_hash':      ['0000000']
				'type':            ['chore']
				'description':     ['major']
				'BREAKING_CHANGE': ['break']
			}
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{})!
	assert next_version == '2.0.0'
	assert next_date == now_date
}

fn test_minor_2() {
	commits := [
		Commit{
			vars: {
				'short_hash':  ['0000000']
				'type':        ['fix']
				'description': ['patch']
			}
		},
		Commit{
			vars: {
				'short_hash':  ['0000001']
				'type':        ['feat']
				'description': ['minor']
			}
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{})!
	assert next_version == '1.1.0'
	assert next_date == now_date
}

fn test_from_commit() {
	commits := [
		Commit{
			tags: ['v2.0.0']
			vars: {
				'short_hash':  ['0000000']
				'type':        ['perf']
				'description': ['patch']
			}
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{})!
	assert next_version == ''
	assert next_date == ''
}

fn test_from_commit_assume() {
	commits := [
		Commit{
			tags: ['v2.0.0']
			vars: {
				'short_hash':  ['0000000']
				'type':        ['perf']
				'description': ['patch']
			}
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{
		assume_patch: true
	})!
	assert next_version == '2.0.1'
	assert next_date == now_date
}

fn test_from_commit_2() {
	commits := [
		Commit{
			tags: ['v2.0.0']
			vars: {
				'short_hash': ['0000000']
			}
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{})!
	assert next_version == ''
	assert next_date == ''
}

fn test_from_commit_2_assume() {
	commits := [
		Commit{
			tags: ['v2.0.0']
			vars: {
				'short_hash': ['0000000']
			}
		},
	]
	next_version, next_date := compute_next_version(commits, '1.0.0', Opts{
		assume_patch: true
	})!
	assert next_version == '2.0.1'
	assert next_date == now_date
}
