module main

fn test_has() {
	data := ChangeData{}
	assert data.has('dummy') == false
	assert data.has('title') == true
}

fn test_get_one() {
	data := ChangeData{
		title: '42'
	}
	assert data.get_one('dummy') == ''
	assert data.get_one('title') == '42'
}

fn test_get_more() {
	data := ChangeData{
		title: '42'
	}
	assert data.get_more('dummy') == []
	assert data.get_more('title') == ['42']
}
