gm = require "gm"
gm("files/5160bd4c5a97fd6623000001.jpg").thumb(100, 100, "files/5160bd4c5a97fd6623000001.thumb.jpg", 90, (err, sout, serr, cmd) => 
	err)
