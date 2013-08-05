#!/bin/sh
##HMSET key field value [field value ...]

cat ./db/data.csv | awk -F "|" "BEGIN {x=1} {print \"HMSET\", \$1, \"provide\", \$2, \"location\", \$3 ; x++ }" | redis-cli > /dev/null 


echo 'import mobile data finished.'
echo 'try it now: '
echo '  $ redis-cli HGET 1300002 location'
echo '  "安徽巢湖"'

cat ./db/id.csv | awk -F "|" "BEGIN {y=1} {print \"HMSET\", \$1, \"location\", \$2 ; y++ }" | redis-cli > /dev/null 


echo 'import idcard data finished.'
echo 'try it now: '
echo '  $ redis-cli HGET 610103 location'
echo '  "陕西省西安市碑林区"'

cat ./db/cities.csv | awk -F "|" "BEGIN {y=1} {print \"HMSET\", \$1, \"code\", \$2 ; y++ }" | redis-cli > /dev/null 


echo 'import cities data finished.'
echo 'try it now: '
echo '  $ redis-cli HGET "北京" code'
echo '  "101010100"'