makeTable() {
	cols=( `head -1 $fname | sed 's/"//g'` )
	columns=( `head -1 $fname | sed 's/,/ /g' | sed 's/"//g' | sed 's/key/_key/g'` )
	collen=${#columns[@]}
	id=${columns[0]}
	comma=""
	j=0
	if [[ $id = 'id' ]]; then
		columns[0]="${columns[0]} INT NOT NULL AUTO_INCREMENT"
		columns[$collen]=",PRIMARY KEY ($id)"
		j=1
		comma=","
	fi
	for (( ; j<$collen; j++ )); do 
		re=".+_id"
		if [[ ${columns[$j]} =~ $re ]]; then
			columns[$j]="${comma}${columns[$j]} INT"
		else
			columns[$j]="${comma}${columns[$j]} VARCHAR(2048) NOT NULL"
		fi
		comma=","
	done
	echo "DROP TABLE IF EXISTS $table;"
	echo "CREATE TABLE $table ( ${columns[@]}  );"
	echo "LOAD DATA LOCAL INFILE '$fname' INTO TABLE $table FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
}

cd data
fnames=( `ls *.csv` )
len=${#fnames[@]}
echo $len
echo "CREATE DATABASE IF NOT EXISTS omdb;" > omdb.sql
echo "USE omdb;" >> omdb.sql
for (( i=0; i<$len; i++ )); do
	fname=${fnames[$i]}
	table=`basename ${fname} .csv`
	echo $table
	if [ -s ${fname} ]; then
		makeTable >> omdb.sql
	fi
done

#mysql --defaults-extra-file=../local.cnf -v -u root omdb < omdb.sql
