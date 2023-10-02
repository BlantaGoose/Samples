### IUCNから大量のデータをマニュアルでダウンロードした後、解凍・名前変更をしてくれるスクリプト
#!/bin/bash

start_time=`date "+%Y-%m-%d %H:%M:%S"`
echo $start_time >> output.txt

##プロジェクト名
path=falconparrots
##NCBIから一括ダウンロードすると、ncbi_dataset/data/ディレクトリに以下が出てくる
file=data_summary.tsv

##samplelistディレクトリ内にプロジェクトがない場合は作る
#mkdir ../samplelist/$path
#mv ../../../Downloads/ncbi_dataset/data ../samplelist/$path

##data_summary.tsvを見るとわかるが、一列目に学名、六列目にアクセッションがついている。
##各FASTA, GFFファイルはアクセッション番号のディレクトリ内にあるので、学名と紐付けしてディレクトリを学名に変える
tail -n +2 ../samplelist/$path/data/$file | cut -f 1,6 > ../samplelist/$path/ot.txt

##ot3.txtは紐付けが完了したテキストファイル。一行一種
##次は、ot3.txtの学名とアクセッションを分けておく

##awkコマンドでやってみよ。{}を打つ前後はシ　ン　グ　ルクオーテーションじゃないといけない
cat ../samplelist/$path/ot.txt | while read line
do
	Laten=$(echo $line | awk -v 'OFS=_' '{print $1,$2}')	##$lineはot3.txtの一行分。デフォルトでtabで区切るので、$1と$2をアンダーバー（OFS=_）に置換
	gen=$(echo ${Laten:0:2})
	species=$(echo $Laten | cut -d "_" -f 2)
	spe=$(echo ${species:0:3})
	Accession=$(echo $line | awk '{print $3}')

	mv ../samplelist/$path/data/$Accession/${Accession}_*_genomic.fna ../samplelist/$path/data/$Accession/${gen}.${spe}.fna
	mv ../samplelist/$path/data/$Accession/genomic.gff ../samplelist/$path/data/$Accession/${gen}.${spe}.gff
	mv ../samplelist/$path/data/$Accession/protein.faa ../samplelist/$path/data/$Accession/${gen}.${spe}.faa

	mv ../samplelist/$path/data/$Accession/${gen}.${spe}.fna ../data/FNA/$path/
	mv ../samplelist/$path/data/$Accession/${gen}.${spe}.faa ../data/FAA/$path/
	mv ../samplelist/$path/data/$Accession/${gen}.${spe}.gff ../data/GFF/$path/


done
