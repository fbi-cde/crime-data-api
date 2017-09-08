#MYPWD="$(pwd)/crime-data-api/dba/update/data"
YEAR=$1

if [ -n "$1" ]; then
    echo "Building update scripts for year $1"
else
    echo "Usage: update_data.sh YYYY"
    exit
fi

./build_upload_script_nibrs.sh $YEAR >upload_nibrs.sql
echo "upload_nibrs.sql successfully built"

./build_upload_script_reta.sh $YEAR >upload_reta.sql
echo "upload_reta.sql successfully built"

./build_upload_script_other.sh $YEAR >upload_other.sql
echo "upload_other.sql successfully built"

./build_update_script_reta.sh $YEAR >update_reta.sql
echo "update_reta.sql successfully built"

./build_update_script_nibrs.sh $YEAR >update_nibrs.sql
echo "update_nibrs.sql successfully built"