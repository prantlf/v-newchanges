#!/usr/bin/env -S v -prod run

import benchmark { start }

fn (mut m map[string][]string) add_more1(name string, val []string) {
	if name in m {
		for it in val {
			m[name] << it
		}
	} else {
		m[name] = val.clone()
	}
}

fn (mut m map[string][]string) add_more2(name string, val []string) {
	if name in m {
		mut arr := m[name]
		for it in val {
			arr << it
		}
		m[name] = arr
	} else {
		m[name] = val.clone()
	}
}

const repeat_count = 100000

const names = [
	'hash',
	'short_hash',
	'type',
	'description',
	'issue',
	'pull_request',
	'BREAKING_CHANGE',
	'REMARKS',
	'NOTE',
]

mut b := start()

for _ in 0 .. repeat_count {
	mut m := map[string][]string{}
	for name in names {
		m.add_more1(name, ['42'])
		m.add_more1('names', [name])
	}
}
b.measure('add to array in map directly')

for _ in 0 .. repeat_count {
	mut m := map[string][]string{}
	for name in names {
		m.add_more2(name, ['42'])
		m.add_more2('names', [name])
	}
}
b.measure('add to array in map indirectly')
