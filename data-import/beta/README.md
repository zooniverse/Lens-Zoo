
### Data Preparation

Running the `Makefile`.  This will

  * download all files
  * arrange them into appropriate directories (e.g. `subjects/standard/file.png`)
  * compress FITS using `fpack`
  * create thumbnails
  * upload to S3

    make go
    make remove # Removes some unneeded files
    make thumbnails # Generates thumbnails
    make toS3 # Upload all subjects (standard, thumbnails, raw) to S3

#### lensimgs.tgz
Sample of simulated lenses.  Inside the directory is `lens_info` containing metadata about the simulations (e.g. id, x, y, type)

#### blindlimgs.tgz
8 PNGS and associated FITS containing real lenses

#### finalimgs.tgz
There are no simulated lenses in this sample.  Are all blanks?  Are there some real lenses in this sample?

#### lensfits.tgz
FITS files containing simulated lenses

#### simlensonly.tgz
Contains images of only the simluated lense.  These images are not meant to go online.

#### dellist.txt
Images to delete.