
#
#	Download and decompress data
#

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

simlens_extra.tgz:
	curl -o simlens_extra.tgz 'http://member.ipmu.jp/anupreeta.more/simlens_extra.tgz'

simlens_extra: simlens_extra.tgz
	gzip -dc simlens_extra.tgz | tar xf -

blind_extra.tgz:
	curl -o blind_extra.tgz 'http://member.ipmu.jp/anupreeta.more/blind_extra.tgz'

blind_extra: blind_extra.tgz
	gzip -dc blind_extra.tgz | tar xf -

# simlensonly.tgz:
# 	curl -o simlensonly.tgz 'http://member.ipmu.jp/anupreeta.more/simlensonly.tgz'
# 
# simlensonly: simlensonly.tgz
# 	gzip -dc simlensonly.tgz | tar xf -

go: finalimgs blindlimgs lensfits lensimgs finalfiles simlens_extra blind_extra
	mkdir -vp subjects
	mkdir -vp subjects/standard
	mkdir -vp subjects/raw
	mkdir -vp subjects/thumbnail
	mv blindlimgs/*.png subjects/standard/
	mv blindlimgs/*.fits subjects/raw/
	mv finalimgs/*.png subjects/standard/
	mv lensimgs/*.png subjects/standard/
	mv lensimgs/lens_info lens_info
	mv finalfiles/*.fits subjects/raw
	mv simlens_extra/png/CFHTLS_082_0098_gri.png subjects/standard
	mv simlens_extra/fits/*.fits subjects/raw
	mv blind_extra/png/CFHTLS_082_0500_gri.png subjects/standard
	mv blind_extra/fits/*.fits subjects/raw
	fpack subjects/raw/*.fits
	rm subjects/raw/*.fits
	mv lensfits/*.fz subjects/raw/

remove:
	while read p; do \
	rm subjects/raw/$$p.fits.fz; \
	done < dellst.txt
	python pluck.py
	
thumbnails:
	for f in subjects/standard/*.png ; do \
		filename=$$(basename "$$f"); \
		convert $${f} -resize 40% subjects/thumbnail/$${filename}; \
	done
	
toS3:
	s3cmd put --acl-public subjects/standard/* s3://spacewarps.org/subjects/standard/
	s3cmd put --acl-public subjects/thumbnail/* s3://spacewarps.org/subjects/thumbnail/
	s3cmd put --acl-public subjects/raw/* s3://spacewarps.org/subjects/raw/
	