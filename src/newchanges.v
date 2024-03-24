import time { now }
import os { exists, join_path_single, write_file }
import semver
import prantlf.cli { Cli, run }
import prantlf.debug { rwd }
import prantlf.osutil { exist_in }

const version = '0.4.0'

const usage = 'Updates the changelog file using git log messages.

Usage: newchanges [options] [commands]

Commands:
  init                      generate a config file with defaults

Options:
  -c|--config <name>        file name or path of the config file
  -l|--log <file>           file to read from and write to (default: to find)
  -t|--tag-prefix <prefix>  expect git tags prefixed (default: "v")
  -h|--heading <level>      level of the log entry headings (default: 2)
	-l|--logged-types <types> change types to include in the log
  -f|--from <hash>          start at a specific commit (default: last change)
  -t|--to <hash>            end at a specific commit (default: HEAD)
  -u|--try-unshallow        try fetch missing commits and tags if not found
  -p|--path <path>          consider only specific path (default: git root)
  -r|--repo-url <url>       URL of the git repository (default: from git)
  -o|--override-version <v> set the new version to the specified value
  -e|--write-changes <file> write the new changes to the specified file
  -w|--write-version <file> write the version numnber to the specified file
  -a|--assume-patch         assume a patch release for insignificant commits
  -0|--bump-major-0         bump the major version also if it is 0
  --pre-release             bump the existing pre-release number
  --pre-id <id>             first pre-release identifier (default: "next")
  -d|--dry-run              print the new changes on the console only
  -N|--no-failure           do not fail if the change log was not updated
  -i|--print-last           print changes for the last version on the console
  -q|--quiet                omit the summary note on the standard output
  -v|--verbose              print the new changes on the console too
  -V|--version              print the version of the executable and exits
  -h|--help                 print the usage information and exits

Default change types to include in the log: "feat", "fix", "perf". If
the commit message includes the note "BREAKING CHANGE", it will be
included in the log regardless of its type.

Examples:
  $ newchanges -f v0.1.0 -t v0.2.0
  $ newchanges -d'

struct Opts {
	quiet            bool
	verbose          bool
	log              string
	tag_prefix       string = 'v'            @[json: 'tag-prefix']
	from             string
	to               string
	try_unshallow    bool              @[json: 'try-unshallow']
	path             string
	repo_url         string            @[json: 'repo-url']
	override_version string            @[json: 'override-version']
	write_changes    string            @[json: 'write-changes']
	write_version    string            @[json: 'write-version']
	assume_patch     bool              @[json: 'assume-patch']
	bump_major_0     bool              @[json: 'bump-major-0']
	pre_release      bool              @[json: 'pre-release']
	pre_id           string = 'next'            @[json: 'pre-id']
	dry_run          bool              @[json: 'dry-run']
	failure          bool = true              @[json: 'failure']
	print_last       bool              @[json: 'print-last']
	commit_sep       string = '----------==========----------'            @[json: 'commit-sep']
	subject_re       string = r'^\s*(?<type>[^: ]+)\s*:\s*(?<description>.+)$'            @[json: 'subject-re']
	body_re          string            @[json: 'body-re']
	footer_re        string            @[json: 'footer-re']
	version_re       string = r'^\s*(?<heading>#+)\s+(?:(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)|(?:\[(?<version>\d+\.\d+\.\d+(?:-[.0-9A-Za-z-]+)?)\])).+\((?<date>[-\d]+)\)\s*$'            @[json: 'version-re']
	prolog           string = '# Changes'
	version_tpl      string = '{heading} [{version}]({repo_url}/compare/{tag_prefix}{prev_version}...{tag_prefix}{version}) ({date})'            @[json: 'version-tpl']
	change_tpl       string  = '#{heading} {title}'            @[json: 'change-tpl']
	commit_tpl       string  = '* {description} ([{short_hash}]({repo_url}/commit/{hash}))'            @[json: 'commit-tpl']
	logged_types     []string = ['feat', 'fix', 'perf']          @[json: 'logged-types'; split]
	type_titles      map[string]string = {
		'feat':            'Features'
		'fix':             'Bug Fixes'
		'perf':            'Performance Improvements'
		'chore':           'Chores'
		'BREAKING_CHANGE': 'BREAKING CHANGES'
	} @[json: 'type-titles']
mut:
	heading int = 2
}

fn main() {
	run(Cli{
		usage: usage
		version: version
		cfg_opt: 'c'
		cfg_gen_arg: 'init'
		cfg_file: '.newchanges'
	}, body)
}

fn body(mut opts Opts, _args []string) ! {
	mut changes_dir := ''
	mut changes_file := ''
	mut changes := []string{}
	mut last_change := -1
	mut last_version := ''
	mut last_date := ''
	changes_file_found := if opts.log.len > 0 {
		changes_file = opts.log
		exists(opts.log)
	} else {
		changes_dir = get_git_root()!
		if changes_dir.len > 0 {
			if changes_name := exist_in(['CHANGELOG.md', 'CHANGES.md'], changes_dir) {
				changes_file = join_path_single(changes_dir, changes_name)
				true
			} else {
				false
			}
		} else {
			false
		}
	}

	if opts.print_last {
		if changes_file_found {
			changes = get_changes(changes_file)!
			first_line, last_line, last_ver := get_last_changes(changes, opts)!
			if first_line < 0 {
				msg := 'no last changes found'
				if !opts.failure {
					println(msg)
					return
				}
				return error(msg)
			}
			contents := if opts.verbose || opts.write_changes.len > 0 {
				changes[first_line..last_line].join('\n')
			} else {
				''
			}
			if opts.verbose {
				print(contents)
			}
			if !opts.quiet {
				if opts.verbose {
					println('\n')
				}
				println('version ${last_ver} and ${last_line - first_line} lines printed')
			}
			if opts.write_changes.len > 0 {
				write_file(opts.write_changes, contents)!
			}
			if opts.write_version.len > 0 {
				write_file(opts.write_version, last_ver)!
			}
			return
		} else {
			return error('change log not found')
		}
	}

	if changes_file_found {
		changes = get_changes(changes_file)!
		mut heading := 0
		last_change, heading, last_version, last_date = analyse_changes(changes, opts)!
		if heading > 0 && heading != opts.heading {
			opts.heading = heading
		}
	}

	commit_log := get_commits(last_version, last_date, opts)!
	mut commits, all_commit_count := parse_commits(commit_log, opts)!
	if commits.len == 0 {
		loc := get_location(last_version, last_date, opts)
		mut msg := if all_commit_count > 0 {
			commit_pl := if all_commit_count > 1 {
				's'
			} else {
				''
			}
			'classified commits from ${all_commit_count} commit${commit_pl}'
		} else {
			'commits'
		}
		msg = 'no ${msg} found ${loc}'
		if !opts.failure {
			println(msg)
			return
		}
		return error(msg)
	}

	next_version, next_date := if opts.override_version.len > 0 {
		semver.from(opts.override_version)!
		date := now().ymmdd()
		opts.override_version, date
	} else {
		ver, date := compute_next_version(commits, last_version, opts)!
		if ver.len == 0 {
			loc := get_location(last_version, last_date, opts)
			commit_pl := if commits.len > 1 {
				's'
			} else {
				''
			}
			msg := 'no significant commits from ${commits.len} classified commit${commit_pl} from ${all_commit_count} total found ${loc}'
			if !opts.failure {
				println(msg)
				return
			}
			return error(msg)
		}
		ver, date
	}

	new_changes := generate_changes(commits, last_version, next_version, next_date, opts)!
	mut prefix := ''
	mut suffix := ''
	mut contents := ''
	if (changes_file.len == 0 && changes_dir.len == 0) || opts.dry_run {
		contents = new_changes.join('\n')
		print(contents)
		if !opts.quiet {
			prefix = '\n'
			suffix = 'printed'
		}
	} else {
		if opts.verbose {
			contents = new_changes.join('\n')
			print(contents)
			if !opts.quiet {
				prefix = '\n'
			}
		}
		if changes_file.len == 0 {
			changes_file = join_path_single(changes_dir, 'CHANGELOG.md')
		}
		if !opts.quiet {
			mut dchanges_file := rwd(changes_file)
			if dchanges_file.starts_with('./') || dchanges_file.starts_with('.\\') {
				dchanges_file = dchanges_file[2..]
			}
			suffix = 'written to "${dchanges_file}"'
		}
		append_changes(changes_file, changes, last_change, new_changes, opts)!
	}
	if !opts.quiet {
		loc := get_location(last_version, last_date, opts)
		commit_pl := if commits.len > 1 {
			's'
		} else {
			''
		}
		println('${prefix}discovered ${commits.len} classified commit${commit_pl} from ${all_commit_count} total ${loc}')
		println('version ${next_version} (${next_date}) and ${new_changes.len} lines ${suffix}')
	}
	if opts.write_changes.len > 0 {
		if contents.len == 0 {
			contents = new_changes.join('\n')
		}
		write_file(opts.write_changes, contents)!
	}
	if opts.write_version.len > 0 {
		write_file(opts.write_version, next_version)!
	}
}

fn get_location(last_version string, last_date string, opts &Opts) string {
	from := if opts.from.len > 0 {
		opts.from
	} else if last_version.len > 0 {
		'${opts.tag_prefix}${last_version} (${last_date})'
	} else {
		'the beginning'
	}
	to := if opts.to.len > 0 {
		' until ${opts.to}'
	} else {
		''
	}
	at := if opts.path.len > 0 {
		' at "${opts.path}"'
	} else {
		''
	}
	return 'since ${from}${to}${at}'
}
