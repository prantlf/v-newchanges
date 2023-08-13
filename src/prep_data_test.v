module main

fn test_has() {
	data := PrepData{}
	assert data.has('dummy') == false
	assert data.has('heading') == true
}

fn test_get_one() {
	data := PrepData{
		heading: '42'
	}
	assert data.get_one('dummy') == ''
	assert data.get_one('heading') == '42'
}

fn test_get_more() {
	data := PrepData{
		heading: '42'
	}
	assert data.get_more('dummy') == []
	assert data.get_more('heading') == ['42']
}
