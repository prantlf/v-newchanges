module main

fn test_has() {
	commit := Commit{
		vars: {
			'test': ['42']
		}
	}
	assert commit.vars.has('dummy') == false
	assert commit.vars.has('test') == true
}

fn test_get_one() {
	commit := Commit{
		vars: {
			'test': ['42']
		}
	}
	assert commit.vars.get_one('dummy') == ''
	assert commit.vars.get_one('test') == '42'
}

fn test_get_more() {
	commit := Commit{
		vars: {
			'test': ['42']
		}
	}
	assert commit.vars.get_more('dummy') == []
	assert commit.vars.get_more('test') == ['42']
}

// fn test_get_one_opt() {
// 	commit := Commit{
// 		vars: {
// 			'test': ['42']
// 		}
// 	}
// 	assert commit.vars.get_one('dummy') == none
// 	assert commit.vars.get_one('test') == ?'42'
// }

// fn test_get_more_opt() {
// 	commit := Commit{
// 		vars: {
// 			'test': ['42']
// 		}
// 	}
// 	assert commit.vars.get_more('dummy')? == none
// 	assert commit.vars.get_more('test') == ?['42']
// }

fn test_add_one() {
	mut vars := map[string][]string{}
	vars.add_one('test', '42')
	assert vars['test'] or {
		assert false
		return
	} == ['42']
	vars.add_one('test', '43')
	assert vars['test'] or {
		assert false
		return
	} == ['42', '43']
}

fn test_add_more() {
	mut vars := map[string][]string{}
	vars.add_more('test', ['42'])
	assert vars['test'] or {
		assert false
		return
	} == ['42']
	vars.add_more('test', ['43'])
	assert vars['test'] or {
		assert false
		return
	} == ['42', '43']
}
