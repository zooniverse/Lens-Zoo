
betatest_sw_fits.tgz:
	curl -o betatest_sw_fits.tgz 'http://member.ipmu.jp/anupreeta.more/betatest_sw_fits.tgz'

finalfiles: betatest_sw_fits.tgz
	gzip -dc betatest_sw_fits.tgz | tar xf -

finalimgs.tgz:
	curl -o finalimgs.tgz 'http://member.ipmu.jp/anupreeta.more/finalimgs.tgz'
	
finalimgs: finalimgs.tgz
	gzip -dc finalimgs.tgz | tar xf -

blindlimgs.tgz:
	curl -o blindlimgs.tgz 'http://member.ipmu.jp/anupreeta.more/blindlimgs.tgz'

blindlimgs: blindlimgs.tgz
	gzip -dc blindlimgs.tgz | tar xf -

lensfits.tgz:
	curl -o lensfits.tgz 'http://member.ipmu.jp/anupreeta.more/lensfits.tgz'

lensfits: lensfits.tgz
	gzip -dc lensfits.tgz | tar xf -

lensimgs.tgz:
	curl -o lensimgs.tgz 'http://member.ipmu.jp/anupreeta.more/lensimgs.tgz'

lensimgs: lensimgs.tgz
	gzip -dc lensimgs.tgz | tar xf -

# simlensonly.tgz:
# 	curl -o simlensonly.tgz 'http://member.ipmu.jp/anupreeta.more/simlensonly.tgz'
# 
# simlensonly: simlensonly.tgz
# 	gzip -dc simlensonly.tgz | tar xf -

arrange: finalimgs blindlimgs lensfits lensimgs finalfiles
	mkdir -vp subjects
	mkdir -vp subjects/standard
	mkdir -vp subjects/raw
	mkdir -vp subjects/thumbnail
	mv blindlimgs/*.png subjects/standard/
	mv blindlimgs/*.fits subjects/raw/
	mv finalimgs/*.png subjects/standard/
	mv lensfits/*.fits subjects/raw/
	mv lensimgs/*.png subjects/standard/
	mv lensimgs/lens_info lens_info
	mv finalfiles/*.fits subjects/raw

fpack: arrange
	fpack subjects/raw/*.fits
	rm subjects/raw/*.fits

remove:
	while read p; do \
	rm subjects/raw/$$p.fits; \
	done < dellst.txt
	
