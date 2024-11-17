import semver { Increment }
import time { now }
import prantlf.semvut { next_prerelease, next_release }

fn compute_next_version(commits []Commit, last_version string, opts &Opts) !(string, string) {
	d.log_str('compute the next version number')
	d.stop_ticking()
	last_commit := commits[0]
	if last_commit.last && last_commit.tags.len > 0 {
		tag_version := get_version(last_commit.tags[0], opts)
		if tag_version != last_version {
			d.start_ticking()
			d.log('the last commit contains the next version: "%s"', tag_version)
			return tag_version, last_commit.vars.get_one('date')
		}
	}

	mut next_version := ''
	for commit in commits {
		if commit.tags.len > 0 {
			next_version = commit.tags[0]
			break
		}
	}
	if next_version.len > 0 {
		next_version = get_version(next_version, opts)
		d.log('previous version read from a commit: "%s"', next_version)
	} else {
		next_version = last_version
		d.log('previous version read from the change log: "%s"', next_version)
	}

	mut increment_guess := ?Increment(none)
	for commit in commits {
		if commit.tags.len > 0 {
			break
		}

		typ := commit.vars.get_one('type')
		if typ.len == 0 {
			continue
		}

		if commit.vars.has('BREAKING CHANGE') {
			if d.is_enabled() {
				d.log_str('major: "${commit.vars.get_one('short_hash')}" "${commit.vars.get_one('description')}"')
			}
			increment_guess = Increment.major
			break
		}

		if typ.starts_with('fix') || typ.starts_with('perf') {
			if increment_guess == none {
				increment_guess = Increment.patch
				if d.is_enabled() {
					d.log_str('patch: "${commit.vars.get_one('short_hash')}" "${commit.vars.get_one('description')}"')
				}
			}
		} else if typ.starts_with('feat') {
			if increment_guess or { Increment.patch } == Increment.patch {
				increment_guess = Increment.minor
				if d.is_enabled() {
					d.log_str('minor: "${commit.vars.get_one('short_hash')}" "${commit.vars.get_one('description')}"')
				}
			}
			// } else if typ.starts_with('revert') {
			// TODO
		}
	}

	mut increment := increment_guess or {
		if !opts.assume_patch {
			d.start_ticking()
			d.log_str('no significat commit found')
			return '', ''
		}
		Increment.patch
	}

	if d.is_enabled() {
		if increment_guess == none {
			d.log_str('assume patch release from insignificant commits')
		} else {
			d.log_str('infer ${increment} release from significant commits')
		}
	}

	ver_num := semver.from(next_version)!
	if increment == Increment.major && ver_num.major == 0 && !opts.bump_major_0 {
		d.log_str('reduce the change severity to minor because of the major number 0')
		increment = Increment.minor
	}

	next_version = if opts.pre_release {
		next_prerelease(ver_num, opts.pre_id).str()
	} else {
		next_release(ver_num, increment).str()
	}

	d.start_ticking()
	d.log('the next version will be "%s"', next_version)
	next_date := now().ymmdd()
	return next_version, next_date
}

fn get_version(tag string, opts &Opts) string {
	len := opts.tag_prefix.len
	return if len > 0 {
		tag[len..]
	} else {
		tag
	}
}
