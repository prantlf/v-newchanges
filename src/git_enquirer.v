import os { execute }
import prantlf.strutil { first_line }

// type Tags = map[string]string

fn get_git_root() !string {
	root := execute_git('git rev-parse --show-toplevel')!
	return root.trim_right('\r\n')
}

fn get_remote_url() !string {
	url := execute_git('git remote get-url origin')!
	return url.trim_right('\r\n')
}

fn get_repo_url(remote_url string) !string {
	repo_url := if remote_url.starts_with('git@') {
		colon := remote_url.index_u8(`:`)
		if colon > 0 {
			'https://${remote_url[4..colon]}/${remote_url[colon + 1..]}'
		} else {
			return error('unrecognised git remote url: "${remote_url}"')
		}
	} else if remote_url.starts_with('https:') {
		remote_url
	} else {
		return error('unrecognised git remote url: "${remote_url}"')
	}
	return if repo_url.ends_with('.git') {
		repo_url[..repo_url.len - 4]
	} else {
		repo_url
	}
}

fn get_commits(version string, opts &Opts) !string {
	mut cmd := 'git log --format="%H%n%as%n%D%n%B%n${opts.commit_sep}"'
	from := if opts.from.len > 0 {
		opts.from
	} else if version.len > 0 {
		'${opts.tag_prefix}${version}'
	} else {
		''
	}
	if from.len > 0 || opts.to.len > 0 {
		cmd += ' ${from}..${opts.to}'
	}
	if opts.path.len > 0 {
		cmd += ' -- "${opts.path}"'
	}
	return execute_git(cmd)!
}

// fn get_tags() !Tags {
// 	tag_log := execute_git('git show-ref --tags')!
// 	lines := tag_log.split_into_lines()
// 	mut tags := Tags(map[string]string{})
// 	for line in lines {
// 		sep := line.index_u8(` `)
// 		hash := line[..sep]
// 		tag := line[sep + 11..]
// 		tags[hash] = tag
// 	}
// 	d.log('received %d tags', tags.len)
// 	return tags
// }

fn execute_git(cmd string) !string {
	d.log('execute "%s"', cmd)
	res := execute(cmd)
	if res.exit_code != 0 {
		return error('git exited with ${res.exit_code}: ${first_line(res.output)}')
	}
	d.log('received %d bytes', res.output.len)
	return res.output
}
