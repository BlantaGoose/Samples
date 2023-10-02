##scraping.shが終わったあと
##Transfer script
#!/bin/bash

path=telluraves

while read line
do
	name=$(echo $line | cut -d "," -f 1)
	accession=$(echo $line | cut -d "," -f 2)
	gen=$(echo ${name:0:2})
	species=$(echo $name | cut -d "_" -f 2)
	spe=$(echo ${species:0:3})


	##全部Parus_major/にfaaもgffも色々保存してしまった。LSI抽出用のディレクトリ/samples/data/FNA, FAA, GFFにぶち込みたい
	mv ../samplelist/$path/data/${name}/${gen}.${spe}.fna ../data/FNA/$path/
	mv ../samplelist/$path/data/${name}/${gen}.${spe}.faa ../data/FAA/$path/
	mv ../samplelist/$path/data/${name}/${gen}.${spe}.gff ../data/GFF/$path/

done < ../samplelist/$path/Sansyou.csv

