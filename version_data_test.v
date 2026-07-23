module main

fn test_has() {
	data := VersionData{}
	assert data.has('dummy') == false
	assert data.has('version') == true
}

fn test_get_one() {
	data := VersionData{
		version: '42'
	}
	assert data.get_one('dummy') == ''
	assert data.get_one('version') == '42'
}

fn test_get_more() {
	data := VersionData{
		version: '42'
	}
	assert data.get_more('dummy') == []
	assert data.get_more('version') == ['42']
}
