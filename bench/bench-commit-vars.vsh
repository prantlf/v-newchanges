#!/usr/bin/env -S v -prod run

import benchmark { start }

struct Commit {
	last bool
	tags []string
	vars map[string][]string
}

type Value = []string | string

struct Commit2 {
	last bool
	tags []string
	vars map[string]Value
}

fn (v Value) str() string {
	match v {
		string {
			return v
		}
		[]string {
			// return v.str()
			panic('string requested for an array value')
		}
	}
}

fn (m map[string][]string) get_value(name string) string {
	if val := m[name] {
		return val[0]
	} else {
		return ''
	}
}

fn (m map[string]Value) get_value(name string) string {
	val := m[name] or { return '' }
	match val {
		string {
			return val
		}
		[]string {
			return val[0]
		}
	}
}

fn (mut m map[string][]string) add_one(name string, val string) {
	if name in m {
		m[name] << val
	} else {
		m[name] = [val]
	}
}

fn (mut m map[string]Value) add_one(name string, val string) {
	if this_val := m[name] {
		match this_val {
			string {
				m[name] = Value([this_val.str(), val])
			}
			[]string {
				panic('multivalues not implemented yet')
				// mut arr := []string{}
				// arr = this_val
				// this_val.insert(0, val)
				// m[name] = this_val
			}
		}
	} else {
		m[name] = val
	}
}

const repeat_count = 1000

const commit_count = 100

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

mut commits := []Commit{}
mut commits2 := []Commit2{}

mut b := start()

for _ in 0 .. commit_count {
	mut vars := map[string][]string{}
	for name in names {
		vars.get_value(name)
		vars.add_one(name, 'testing value')
		vars.add_one(name, 'testing value')
		vars.get_value(name)
	}
	commits << Commit{
		vars: vars
	}
}
b.measure('commits with array')

for _ in 0 .. commit_count {
	mut vars := map[string]Value{}
	for name in names {
		vars.get_value(name)
		vars.add_one(name, 'testing value')
		vars.add_one(name, 'testing value')
		vars.get_value(name)
	}
	commits2 << Commit2{
		vars: vars
	}
}
b.measure('commits with value')
