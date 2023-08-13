module main

import os

const wd = os.getwd()

fn test_get_git_root() {
	root := get_git_root()!
	assert root == wd
}

// fn test_get_remote_url() {
// 	root := get_remote_url()!
// 	assert root == 'https://github.com/prantlf/v-newchanges'
// }

fn test_get_repo_url_ready() {
	url := get_repo_url('https://github.com/prantlf/v-newchanges')!
	assert url == 'https://github.com/prantlf/v-newchanges'
}

fn test_get_repo_url_ssh() {
	url := get_repo_url('git@github.com:prantlf/v-newchanges.git')!
	assert url == 'https://github.com/prantlf/v-newchanges'
}

fn test_get_repo_url_unrecognised() {
	get_repo_url('dummy') or {
		assert err.msg() == 'unrecognised git remote url: "dummy"'
		return
	}
	assert false
}

fn test_get_repo_url_unrecognised_2() {
	get_repo_url('git@github.com') or {
		assert err.msg() == 'unrecognised git remote url: "git@github.com"'
		return
	}
	assert false
}

// fn test_get_commits() {
// 	root := get_commits('', Opts{})!
// 	assert root == wd
// }
