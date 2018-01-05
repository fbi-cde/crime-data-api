declare -a arr_years=("2016" "2015" "2014" "2013" "2012" "2011" "2010" "2009" "2008" "2007" "2006" "2005" "2004" "2003" "2002" "2001" "2000" "1999" "1998" "1997" "1996" "1995" "1994" "1993" "1992" "1991")

export S3_CREDENTIALS="`cf service-key fbi-cde-s3  colin-key | tail -n +2`"
export AWS_ACCESS_KEY_ID=`echo "${S3_CREDENTIALS}" | jq -r .access_key_id`
export AWS_SECRET_ACCESS_KEY=`echo "${S3_CREDENTIALS}" | jq -r .secret_access_key`
export BUCKET_NAME=`echo "${S3_CREDENTIALS}" | jq -r .bucket`
export AWS_DEFAULT_REGION=`echo "${S3_CREDENTIALS}" | jq -r '.region'`

for i in "${arr_years[@]}"; do
        aws s3 rm --recursive s3://${BUCKET_NAME}/$i
        aws s3 cp --recursive zips/$i/ s3://${BUCKET_NAME}/$i
done
