"use strict";
var page = require('webpage').create();
<% if ${useUrl} == "true" %>var url = '<%= url %>';<% end %>
<% if ${useUrl} == "false" %>var content = '<%= contentString %>';
var url = 'html2pdfy';
page.setContent(content, url);<% end %>
page.paperSize = {
	width : '<%= paperWidth %>',
	height : '<%= paperHeight %>',
	orientation : '<%= paperOrientation %>'
};
page.open(url);
page.onLoadFinished = function() {
	page.render('html2pdfy.pdf');
	phantom.exit();
}
