import os { exists, join_path_single }

fn find_file(dir string, names []string) ?string {
	if d.is_enabled() {
		names_str := names.join('"", "')
		d.log_str('looking for names "${names_str}" in "${dir}"')
	}

	for name in names {
		mut file := join_path_single(dir, name)
		mut ddir := d.rwd(dir)
		d.log('checking if "%s" exists in "%s"', name, ddir)
		if exists(file) {
			d.log('"%s" found in "%s"', name, ddir)
			return name
		}
	}

	d.log_str('none of the names found')
	return none
}
