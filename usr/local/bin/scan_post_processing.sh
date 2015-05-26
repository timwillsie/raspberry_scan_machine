#!/bin/bash

root_path="/tmp"
result_path="${root_path}/result"
raw_path="raw"
pdf_path="pdf"

# change directory
cd ${root_path}
logger -t "scan_post_processing" "chdir to ${root_path}"

for dir in `ls -l ${raw_path} | egrep '^d' | awk '{print $9}'`
do
	cd ${raw_path}/${dir}

	logger -t "scan_post_processing" "chdir to ${raw_path}/${dir}"

	# keep filenames for pdfunite
	pdfunite_args=""

	# convert all scanned files to pdf and keep filename for pdf merging

	logger -t "scan_post_processing" "Looping through the page files"

	for file in *.pnm
	do

		logger -t "scan_post_processing" "Current: ${file}"

		file=`echo $file | sed 's/\.pnm//'`

		logger -t "scan_post_processing" "convert ${file}.pnm ${file}.pdf"

		convert ${file}.pnm ${file}.pdf

		pdfunite_args="${pdfunite_args} ${file}.pdf"
	done

	# ... and merge the single files to one file

	logger -t "scan_post_processing" "launching pdfunite ${pdfunite_args} ${pdf_filename}"

	pdf_filename=`echo $dir | sed 's/scan_//'`
	pdf_filename="${pdf_filename}.pdf"

	pdfunite ${pdfunite_args} ${pdf_filename}

	# OCR to pdf folder

	cd /usr/local/src/OCRmyPDF-1.1-stable/

	logger -t "scan_post_processing" "launching ./OCRmyPDF.sh -d -c -l deu ${root_path}/${raw_path}/${dir}/${pdf_filename} ${result_path}/${pdf_filename}"

	sudo ./OCRmyPDF.sh -d -c -l deu ${root_path}/${raw_path}/${dir}/${pdf_filename} ${result_path}/${pdf_filename}

	# delete the source files

	cd ${root_path}

	logger -t "scan_post_processing" "deleting source files rm -r ${raw_path}"

	rm -r ${raw_path}/${dir}
done
