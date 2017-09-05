#MYPWD="$(pwd)/crime-data-api/dba/update/data"
YEAR=$1

if [ -n "$1" ]; then
    echo "Building update scripts for year $1"
else
    echo "Usage: build_update_files.sh YYYY"
    exit
fi

./build_upload_script.sh $YEAR $MYPWD>upload.sql
echo "upload.sql successfully built"
./build_update_script_nibrs.sh $YEAR $MYPWD>update_nibrs.sql
echo "update_nibrs.sql successfully built"
./build_update_script_reta.sh $YEAR $MYPWD>update_reta.sql
echo "update_reta.sql successfully built"

