struct VersionData {
	prev_version string
	version      string
	date         string
}

fn (d &VersionData) has(name string) bool {
	return has_field(d, name)
}

fn (d &VersionData) get_one(name string) string {
	return get_one_field(d, name)
}

fn (d &VersionData) get_more(name string) []string {
	return get_more_field(d, name)
}
