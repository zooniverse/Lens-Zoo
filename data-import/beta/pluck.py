
# Stupid script to remove the unused FITS files

import os
from os.path import join

BANDS = ['u', 'g', 'r', 'i', 'z']


def pluck():
  
  png_dir = join('.', 'subjects', 'standard')
  raw_dir = join('.', 'subjects', 'raw')
  
  pngs = os.listdir(png_dir)
  raws = os.listdir(raw_dir)
  for png in pngs:
    basename = png.split('_gri.png')[0]
    for band in BANDS:
      raw_name = "%s_%s.fits.fz" % (basename, band)
      raws.remove(raw_name)
  
  # Now delete the left over FITS files
  for raw in raws:
    path = join(raw_dir, raw)
    print path
    os.remove(path)
  
if __name__ == '__main__':
  pluck()
  