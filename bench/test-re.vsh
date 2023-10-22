#!/usr/bin/env -S v run

import prantlf.onig { onig_compile }

mut pat := r'^\s*(?<heading>#+)\s+(?:(?<version>\d+\.\d+\.\d+)|(?:\[(?<version>\d+\.\d+\.\d+)\])).+\((?<date>[-\d]+)\)\s*$'
mut re := onig_compile(pat, onig.opt_none)!

mut line := '# [23.4.0](https://gitlab.otxlab.net/smartui/nucleus/compare/23.2.0...23.4.0) (2023-06-09)'
if m := re.match_str(line, onig.opt_none) {
	println(m)
} else {
	eprintln(err)
}

pat = r'^\s*(?<description>.+)\s*\((?<type>[^ ]+)(?:\s*,\s*(?<issue>[^ ]+))?(?:\s*,\s*(?<issue>[^ ]+))?\)\s*$'
re = onig_compile(pat, onig.opt_none)!

line = 'Do not stringify binary POST payloads (fix, SVF-5198)'
if m := re.match_str(line, onig.opt_none) {
	println(m)
} else {
	eprintln(err)
}
