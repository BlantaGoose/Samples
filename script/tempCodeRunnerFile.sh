##NewAccession.Rで作成した生物種とNCBIアクセッションを参照して、スクレイピング
#!/bin/bash

start_time=`date "+%Y-%m-%d %H:%M:%S"`
echo $start_time >> output.txt


##初期化
rm col*
rm index.html*
rm html*
rm -r ftp.ncbi.nlm.nih.gov

##プロジェクト名を入れろ！！！
path="otameshi"
##Accession.Rで作ったcsvファイルを入れろ！！
csv="allbirdsGenbank.csv"

##まず、NCBIのIndexから興味ある生物種がずらっと並ぶディレクトリ(vertebrate_other)までのindex.htmlをダウンロード
wget -w 1 -nc ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/vertebrate_other/ -P ../samplelist/${path}/	#index.htmlの作成

##次に、Rで作成した興味ある種とそのアクセッションが入ったデータフレームから読み取り
mkdir ../samplelist/${path}/html_box	#興味ある種index.htmlの保管庫
mkdir ../samplelist/${path}/data
while read line
do
	##まず、UrbanGenBankから一列目と2列目を抽出し、URLを作成する。
	Latenname=$(echo ${line}|cut -d , -f 1|sed "s/ /_/"|sed 's/"//g')	#変数設定をshellでやるときは、イコール前後にスペースを入れてはいけない。
	echo $Latenname >> ../samplelist/${path}/data/species.txt		#種名の保存
	echo ${line} | cut -d , -f 2 | sed 's/"//g' >> ../samplelist/${path}/accession_interested.txt	#順番ヨシ

	##次に、種それぞれのhtmlファイルを取ってくる
	wget -w 1 ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/vertebrate_other/$Latenname/all_assembly_versions/	-P ../samplelist/${path}/html_box/	#種それぞれのhtmlファイル

done < ../samplelist/${path}/${csv}

##複数の.html.\d+ファイルに含まれる、"Assembly accession_assembly name"を取り出す。これでダウンロードできるはず
ls ../samplelist/$path/html_box | sort -t . -k 3 -n > ../samplelist/$path/html_junban.txt	#そのままhtml_box内のファイルを読み込むと、1,10,11,...,18,2,3,4,となる

##興味ある種のhtmlファイルの中身を、html_matomeにまとめる
while read line
do
	cat ../samplelist/$path/html_box/$line >> ../samplelist/$path/html_matome.txt
done < ../samplelist/$path/html_junban.txt

#matomeからアクセッションの情報を抽出し、all.txtに入れる
cat ../samplelist/$path/html_matome.txt | grep -e '<a href="ftp://ftp.ncbi.nlm.nih.gov:21/genomes/genbank/vertebrate_other/'|sed -e 's/<[^>]*>//g' > ../samplelist/$path/accession_all.txt
##これで、accession_all.txtに、アクセッション番号とアクセッションの名前が入った。


##次は、all.txtからReference genomeだけ取り出す
cat ../samplelist/$path/accession_all.txt | grep -f ../samplelist/$path/accession_interested.txt ../samplelist/$path/accession_all.txt > ../samplelist/$path/col2_proto.txt
rev ../samplelist/$path/col2_proto.txt | cut -f 1 -d "/"| rev > ../samplelist/$path/col2.txt


##col1（興味ある種の学名入りtxtファイル）とcol2（興味ある種のリファレンスアクセッション入りtxtファイル）を横方向に結合
paste -d , ../samplelist/$path/data/species.txt ../samplelist/$path/col2.txt > ../samplelist/$path/Sansyou.csv


##いよいよ、配列情報をダウンロード
while read line
do
	name=$(echo $line | cut -d "," -f 1)
	accession=$(echo $line | cut -d "," -f 2)
	mkdir ../samplelist/$path/data/${name}

##ダウンロードしたいファイルの拡張子を-Aの後ろに指定
	wget -r -nd -w 1 -P ../samplelist/$path/data/$name/ ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/vertebrate_other/$name/all_assembly_versions/$accession/${accession}_cds_from_genomic.fna.gz

##BUSCO用のprotein.faa
	wget -r -nd -w 1 -P ../samplelist/$path/data/$name/ ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/vertebrate_other/$name/all_assembly_versions/$accession/${accession}_protein.faa.gz

##accessionディレクトリ内のファイル、ディレクトリ全てをダウンロードする場合
##	wget -r -w 1 ftp://ftp.ncbi.nlm.nih.gov/genomes/genbank/vertebrate_other/$name/all_assembly_versions/$accession/

##解凍も忘れずに
	gunzip ../samplelist/$path/data/${name}/${accession}_cds_from_genomic.fna.gz
	gunzip ../samplelist/$path/data/${name}/${accession}_protein.faa.gz

	gen=$(echo ${name:0:1})			#一文字の属名
	species=$(echo $name | cut -d "_" -f 2)
	spe=$(echo ${species:0:3})		#三文字の種小名

	mv ../samplelist/$path/data/${name}/${accession}_cds_from_genomic.fna ../samplelist/$path/data/${name}/${gen}.${spe}.fna
	cp ../samplelist/$path/data/${name}/${gen}.${spe}.fna ../../transport/

	mv ../samplelist/$path/data/${name}/${accession}_protein.faa ../samplelist/$path/data/${name}/${gen}.${spe}.faa
	cp ../samplelist/$path/data/${name}/${gen}.${spe}.faa ../../transport/



done < ../samplelist/$path/Sansyou.csv

end_time=`date "+%Y-%m-%d %H:%M:%S"`
echo $end_time >> ../samplelist/$path/output.txt
