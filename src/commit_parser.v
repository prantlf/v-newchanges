import strings { new_builder }
import prantlf.onig { NoMatch, RegEx, onig_compile }
import prantlf.strutil { avoid_space_within, is_whitespace, replace_u8 }

fn parse_commits(commit_log string, opts &Opts) !([]Commit, int) {
	d.log_str('parse recent commits')
	d.stop_ticking()
	lines := commit_log.split_into_lines()

	mut re_vertag := onig_compile('^${opts.tag_prefix}\\d+\\.\\d+\\.\\d+(?:-[.0-9A-Za-z-]+)?\$',
		onig.opt_none)!
	defer {
		re_vertag.free()
	}
	mut re_note := onig_compile(r'^\s*([ A-Z]+)\s*:\s*(.+)?$', onig.opt_none)!
	defer {
		re_note.free()
	}
	mut re_subject := compile_re(opts.subject_re)!
	defer {
		if !isnil(re_subject) {
			re_subject.free()
		}
	}
	mut re_body := compile_re(opts.body_re)!
	defer {
		if !isnil(re_body) {
			re_body.free()
		}
	}
	mut re_footer := compile_re(opts.footer_re)!
	defer {
		if !isnil(re_footer) {
			re_footer.free()
		}
	}

	mut commits := []Commit{}
	mut all_commit_count := 0
	line_count := lines.len
	for i := 0; i + 3 < line_count; {
		hash := lines[i]
		short_hash := hash[..7]
		date := lines[i + 1]
		tag_line := lines[i + 2]
		subject := lines[i + 3]
		tags, ignored := collect_tags(tag_line, re_vertag)!
		if d.is_enabled() {
			d.log_str('${short_hash} ${subject} (${date})')
			if tags.len > 0 {
				d.log_str('> matching tags: ${tags.join(', ')}')
			}
			if ignored.len > 0 {
				d.log_str('> ignored tags: ${ignored.join(', ')}')
			}
		}

		mut vars := map[string][]string{}

		from := i + 4
		mut j := from
		mut last_empty := 0
		mut note_name := ''
		// mut note_val := ''
		mut builder := new_builder(256)
		for ; j < line_count; j++ {
			line := lines[j]
			if line == opts.commit_sep {
				j++
				break
			}

			if is_whitespace(line) {
				last_empty = j
				if note_name.len > 0 {
					val := builder.str().trim_right(' \t\r\n')
					d.log('> collected "%s": "%s"', note_name, val)
					vars.add_one(note_name, val)
					note_name = ''
				}
			} else {
				d.log_str(line)
				if note_name.len > 0 {
					builder.writeln(line)
					// } else {
					// 	note_name, note_val = try_note(line)
					// 	builder.clear()
					// 	if note_val.len > 0 {
					// 		builder.writeln(note_val)
					// 	}
					// }
				} else {
					if m := re_note.match_str(line, onig.opt_none) {
						if name_g := m.group_by_index(1) {
							name_s, name_e := avoid_space_within(line, name_g.start, name_g.end)
							note_name = replace_u8(line[name_s..name_e], ` `, `_`)
							builder.clear()
							if start := m.group_text_by_index(line, 2) {
								if start.len > 0 {
									builder.writeln(start)
								}
							}
						}
					} else {
						if err !is NoMatch {
							return err
						}
					}
				}
			}
		}
		i = j
		if last_empty == 0 {
			last_empty = i
		}

		if !isnil(re_subject) {
			collect_vars(subject, mut re_subject, mut vars)!
		}

		if !isnil(re_body) {
			if isnil(re_subject) {
				collect_vars(subject, mut re_body, mut vars)!
			}
			j = from
			for ; j < last_empty; j++ {
				collect_vars(lines[j], mut re_body, mut vars)!
			}
		}

		if !isnil(re_footer) {
			j = if last_empty < i {
				last_empty
			} else {
				from
			}
			for ; j < i; j++ {
				collect_vars(lines[j], mut re_footer, mut vars)!
			}
		}

		if 'type' in vars || tags.len > 0 {
			unsafe {
				vars.add_one('short_hash', short_hash)
				vars.add_one('hash', hash)
				vars.add_one('date', date)
			}
			last := if all_commit_count == 0 {
				true
			} else {
				false
			}
			commits << Commit{
				last: last
				tags: tags
				vars: vars
			}
		} else {
			d.log_str('> commit type not detected')
		}
		all_commit_count++
	}

	d.start_ticking()
	d.log('collected "%d" entries', commits.len)
	return commits, all_commit_count
}

fn compile_re(str string) !&RegEx {
	if str.len > 0 {
		return onig_compile(str, onig.opt_none)!
	}
	return unsafe { nil }
}

fn collect_vars(line string, mut re RegEx, mut vars map[string][]string) ! {
	if m := re.match_str(line, onig.opt_none) {
		if m.names.len > 0 {
			for name, _ in m.names {
				if grps := m.groups_by_name(name) {
					mut vals := []string{}
					for grp in grps {
						start, end := avoid_space_within(line, grp.start, grp.end)
						val := line[start..end]
						if d.is_enabled() {
							vals << val
						}
						vars.add_one(name, val)
					}
					if d.is_enabled() {
						vals_str := vals.join('", "')
						d.log_str('> collected "${name}": "${vals_str}"')
						continue
					}
				}
				d.log('> ignored "%s"', name)
			}
		}
	} else {
		if err !is NoMatch {
			return err
		}
	}
}

fn collect_tags(line string, re &RegEx) !([]string, []string) {
	mut tags := []string{}
	mut ignored := []string{}
	mut start := 0
	for {
		start = line.index_after('tag: ', start)
		if start < 0 {
			break
		}
		start += 5
		end := line.index_after(',', start)
		tag := if end < 0 {
			line[start..]
		} else {
			line[start..end]
		}
		if re.matches(tag, onig.opt_none)! {
			tags << tag
		} else if d.is_enabled() {
			ignored << tag
		}
		if end < 0 {
			break
		}
		start = end + 1
	}
	return tags, ignored
}

// fn try_note(line string) (string, string) {
// 	from := skip_space(line)
// 	if from == line.len {
// 		return '', ''
// 	}

// 	for i in from .. line.len {
// 		c := line[i]
// 		if c == ` ` || (c >= `A` && c <= `Z`) {
// 			continue
// 		}
// 		if c == `:` {
// 			return line[from..i].trim_right(' '), line[i + 1..].trim_space()
// 		}
// 		break
// 	}
// 	return '', ''
// }
