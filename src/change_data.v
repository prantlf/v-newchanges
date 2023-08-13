struct ChangeData {
	title string
}

fn (d &ChangeData) has(name string) bool {
	return has_field(d, name)
}

fn (d &ChangeData) get_one(name string) string {
	return get_one_field(d, name)
}

fn (d &ChangeData) get_more(name string) []string {
	return get_more_field(d, name)
}

fn has_field[T](data &T, name string) bool {
	$for field in T.fields {
		if field.name == name {
			return true
		}
	}
	return false
}

fn get_one_field[T](data &T, name string) string {
	$for field in T.fields {
		if field.name == name {
			$if field.is_array {
				val := data.$(field.name)
				return if val.len > 0 {
					val[0]
				} else {
					''
				}
			} $else $if field.typ is string {
				return data.$(field.name)
			}
		}
	}
	return ''
}

fn get_more_field[T](data &T, name string) []string {
	$for field in T.fields {
		if field.name == name {
			$if field.is_array {
				return data.$(field.name)
			} $else $if field.typ is string {
				return [data.$(field.name)]
			}
		}
	}
	return []
}
