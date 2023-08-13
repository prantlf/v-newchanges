struct Commit {
	last bool
	tags []string
	vars map[string][]string
}

fn (mut m map[string][]string) add_one(name string, val string) {
	if name in m {
		m[name] << val
	} else {
		m[name] = [val]
	}
}

fn (mut m map[string][]string) add_more(name string, val []string) {
	if name in m {
		for it in val {
			m[name] << it
		}
	} else {
		m[name] = val
	}
}

fn (m map[string][]string) has(name string) bool {
	return name in m
}

fn (m map[string][]string) get_one(name string) string {
	val := m[name]
	return if val.len > 0 {
		val[0]
	} else {
		''
	}
}

fn (m map[string][]string) get_more(name string) []string {
	return m[name]
}

// fn (m map[string][]string) get_one_opt(name string) ?string {
// 	val := m[name]
// 	return if val.len > 0 {
// 		val[0]
// 	} else {
// 		none
// 	}
// }

// fn (m map[string][]string) get_more_opt(name string) ?[]string {
// 	return if name in m {
// 		m[name]
// 	} else {
// 		none
// 	}
// }
