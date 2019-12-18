cd data
curl https://www.omdb.org/content/Help:DataDownload > a.jnk
egrep -o '".*.bz2"' a.jnk | sed 's/"//g' > b.jnk
urls=( `cat b.jnk` )
fnames=( `cut -d'/' -f 5 b.jnk` )
len=${#urls[@]}
echo $len
for (( i=0; i<$len; i++ )); do
	fname=`basename ${fnames[$i]} .bz2`
	table=`basename ${fname} .csv`
	echo $table
	curl ${urls[$i]} > ${fnames[$i]}
	gunzip -f ${fnames[$i]}
done
