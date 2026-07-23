struct PrepData {
	heading    string
	repo_url   string
	tag_prefix string
}

fn (d &PrepData) has(name string) bool {
	return has_field(d, name)
}

fn (d &PrepData) get_one(name string) string {
	return get_one_field(d, name)
}

fn (d &PrepData) get_more(name string) []string {
	return get_more_field(d, name)
}
