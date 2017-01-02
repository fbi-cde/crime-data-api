#!/bin/bash
# Keeps retrying representations.sql
# Useful for getting over intermittently broken connection
i=0
for (( ; ; ))
do
  RESULT=`psql -f representations_chunk.sql $CRIME_DATA_API_DEV_DB_URL`
  echo "got $RESULT"
  if [[ $RESULT == *"INSERT 0 0"* ]]
  then
    echo "Insertions are done, exiting"
    exit 0
  fi
  echo "got $RESULT"
  if [ $? -eq 0 ]
  then
    echo "batch $i done"
    ((i++))
  else
    echo "error, retrying in 5 seconds"
    sleep 5
  fi
done
