import os { create }
import strings { repeat }
import prantlf.template { ReplacerOpts, parse_replacer_opt, parse_template }

fn generate_changes(commits []Commit, last_version string, next_version string, next_date string, opts &Opts) ![]string {
	d.log_str('generate new changes')
	d.stop_ticking()
	heading := repeat(`#`, opts.heading)

	mut repo_url := if opts.repo_url != '' {
		opts.repo_url
	} else {
		remote_url := get_remote_url()!
		get_repo_url(remote_url)!
	}
	repo_url = repo_url.replace('{', '\\{')

	prep_data := PrepData{
		heading:    heading
		repo_url:   repo_url
		tag_prefix: opts.tag_prefix
	}
	prep_opts := ReplacerOpts{
		vars: ['heading', 'repo_url', 'tag_prefix']
	}
	version_prep_tpl := parse_replacer_opt(opts.version_tpl, prep_opts)!
	version_source := version_prep_tpl.replace(prep_data)
	version_tpl := parse_template(version_source)!
	change_prep_tpl := parse_replacer_opt(opts.change_tpl, prep_opts)!
	change_source := change_prep_tpl.replace(prep_data)
	change_tpl := parse_template(change_source)!
	commit_prep_tpl := parse_replacer_opt(opts.commit_tpl, prep_opts)!
	commit_source := commit_prep_tpl.replace(prep_data)
	commit_tpl := parse_template(commit_source)!

	mut lines := []string{cap: commits.len + 1}
	mut changes := map[string][]string{}
	mut broken_changes := []string{}
	mut prev_version := last_version
	mut version_commit := -1
	mut needs_eoln := true

	mut i := commits.len
	for i >= 0 {
		i--
		mut this_version := ''
		mut this_date := ''
		if i >= 0 {
			commit := commits[i]

			typ := commit.vars.get_one('type')
			if typ != '' {
				broken := commit.vars.get_more('BREAKING CHANGE')
				if broken.len > 0 {
					changes.add_more('broken', broken)
					if typ !in opts.logged_types && typ !in broken_changes {
						broken_changes << typ
					}
				}

				if broken.len > 0 || typ in opts.logged_types {
					commit_line := commit_tpl.generate(commit.vars)
					if typ !in changes {
						changes[typ] = []string{}
					}
					changes[typ].prepend(commit_line)
				}
			}

			if commit.tags.len == 0 {
				continue
			}

			this_version = get_version(commit.tags[0], opts)
			this_date = commit.vars.get_one('date')
		} else if i + 1 != version_commit {
			this_version = next_version
			this_date = next_date
		} else {
			break
		}

		if broken := changes['broken'] {
			if needs_eoln {
				lines.prepend('')
				needs_eoln = false
			}

			for this_change in broken {
				lines.prepend(this_change)
				lines.prepend('')
			}

			title := opts.type_titles['BREAKING CHANGE'] or { 'BREAKING CHANGES' }
			change_data := ChangeData{
				title: title
			}
			change_line := change_tpl.generate(change_data)
			lines.prepend(change_line)
			lines.prepend('')
		}

		mut j := opts.logged_types.len + broken_changes.len
		for j > 0 {
			j--
			change := if j >= opts.logged_types.len {
				broken_changes[j - opts.logged_types.len]
			} else {
				opts.logged_types[j]
			}
			if this_changes := changes[change] {
				if needs_eoln {
					lines.prepend('')
					needs_eoln = false
				}

				for this_change in this_changes {
					lines.prepend(this_change)
				}

				lines.prepend('')
				title := opts.type_titles[change] or { change }
				heading_line := change_source.replace('{title}', title)
				lines.prepend(heading_line)
				lines.prepend('')
			}
		}

		if needs_eoln {
			lines.prepend('')
			needs_eoln = false
		}

		version_data := VersionData{
			prev_version: prev_version
			version:      this_version
			date:         this_date
		}
		version_line := version_tpl.generate(version_data)
		lines.prepend(version_line)

		changes.clear()
		broken_changes.clear()
		prev_version = this_version
		version_commit = i
		needs_eoln = true
	}

	d.start_ticking()
	d.log('generated %d lines', lines.len)
	return lines
}

fn append_changes(changes_file string, changes []string, last_change int, new_changes []string, opts &Opts) ! {
	d.log_str('appending the new changes to the log')
	dchanges_file := d.rwd(changes_file)
	d.log('writing "%s"', dchanges_file)
	mut handle := create(changes_file)!

	if last_change >= 0 {
		mut i := 0
		for i < last_change {
			handle.writeln(changes[i])!
			i++
		}
		for line in new_changes {
			handle.writeln(line)!
		}
		for i < changes.len {
			handle.writeln(changes[i])!
			i++
		}
	} else {
		if changes.len > 0 {
			for line in changes {
				handle.writeln(line)!
			}
		} else {
			handle.writeln(opts.prolog)!
			handle.writeln('')!
		}
		for line in new_changes {
			handle.writeln(line)!
		}
	}

	d.log('written %d lines', new_changes.len)
}
