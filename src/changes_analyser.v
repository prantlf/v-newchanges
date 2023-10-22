import os { read_lines }
import prantlf.debug { new_debug }
import prantlf.onig { NoMatch, onig_compile }

const d = new_debug('newchanges')

fn get_changes(changes_file string) ![]string {
	d.log_str('get previous changes')
	dchanges_file := d.rwd(changes_file)
	d.log('reading "%s"', dchanges_file)
	changes := read_lines(changes_file)!
	d.log('received %d lines', changes.len)
	return changes
}

fn analyse_changes(changes []string, opts &Opts) !(int, int, string, string) {
	d.log_str('analyse previous changes')
	d.stop_ticking()
	mut re_version := onig_compile(opts.version_re, onig.opt_none)!
	defer {
		re_version.free()
	}

	for i in 0 .. changes.len {
		line := changes[i]
		d.log('%d: "%s"', i, line)
		if m := re_version.match_str(line, onig.opt_none) {
			heading := if heading_g := m.group_by_name('heading') {
				heading_g.end - heading_g.start
			} else {
				0
			}
			last_version := m.group_text_by_name(line, 'version') or { '' }
			date := m.group_text_by_name(line, 'date') or { '' }
			d.start_ticking()
			d.log('> version "%s" (%s) found (heading %d)', last_version, date, heading)
			return i, heading, last_version, date
		} else {
			if err !is NoMatch {
				return err
			}
		}
	}

	d.start_ticking()
	d.log_str('> no version found')
	return -1, 0, '', ''
}

fn get_last_changes(changes []string, opts &Opts) !(int, int, string) {
	d.log_str('get last changes')
	d.stop_ticking()
	mut re_version := onig_compile(opts.version_re, onig.opt_none)!
	defer {
		re_version.free()
	}

	mut first_line := -1
	mut last_line := -1
	mut last_version := ''
	for i in 0 .. changes.len {
		line := changes[i]
		d.log('%d: "%s"', i, line)
		if line.len == 0 {
			continue
		}
		if m := re_version.match_str(line, onig.opt_none) {
			ver := m.group_text_by_name(line, 'version') or { '' }
			d.log('> version "%s" found', ver)
			if first_line >= 0 {
				break
			} else {
				first_line = i
				last_version = ver
			}
		} else {
			if err !is NoMatch {
				return err
			}
		}
		last_line = i
	}

	if first_line >= 0 {
		d.start_ticking()
		d.log_str('> last log from line ${first_line} to line ${last_line} inclusive')
		return first_line, last_line + 1, last_version
	}

	d.start_ticking()
	d.log_str('> no version found')
	return -1, 0, ''
}
