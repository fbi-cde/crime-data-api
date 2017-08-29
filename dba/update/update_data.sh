#MYPWD="$(pwd)/crime-data-api/dba/update/data"
YEAR=$1

if [ -n "$1" ]; then
    echo echo "Building update scripts for year $1"
else
    echo "Usage: build_update_files.sh YYYY"
    exit
fi


./build_update_files.sh $YEAR >update.sql

echo "update.sql successfully built"