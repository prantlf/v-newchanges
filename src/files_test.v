module main

import os

const wd = os.getwd()

fn test_find_file_none() {
	name := find_file(wd, [])
	assert name == none
}

fn test_find_file_missing() {
	name := find_file(wd, ['dummy'])
	assert name == none
}

fn test_find_file_existing() {
	name := find_file(wd, ['v.mod'])
	assert name? == 'v.mod'
}

fn test_find_file_existing_2() {
	name := find_file(wd, ['dummy', 'v.mod'])
	assert name? == 'v.mod'
}
