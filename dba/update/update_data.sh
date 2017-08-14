MYPWD=$(pwd)
YEAR=$1

if [ -n "$1" ]; then
    echo "Building update scripts for year $1"
else
    echo "Usage: build_update_files.sh YYYY"
    exit
fi

./build_update_files.sh $YEAR >update_$YEAR.sql

echo "update_$YEAR.sql successfully built"