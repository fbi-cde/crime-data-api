#!/usr/bin/env python
"""

Uploads large (> 5GB) files to an S3 bucket using multipart upload.

Assumes that these env vars are set:

    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
    AWS_DEFAULT_REGION
    BUCKET_NAME

Directions for setting them are in ./upload.md.

Thanks to http://codeinpython.blogspot.com/2015/08/s3-upload-large-files-to-amazon-using.html
"""
import datetime
import glob
import math
import os
import sys
import time

import boto
import click

# handle arguments better
# timing

CHUNK_MB = 5000

try:
    AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
    AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']
    AWS_DEFAULT_REGION = os.environ['AWS_DEFAULT_REGION']
    BUCKET_NAME = os.environ['BUCKET_NAME']
except KeyError:
    print(
        'Required environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, BUCKET_NAME')
    raise


def upload_file(s3, file_path, chunk_in_mb=CHUNK_MB):
    print('Uploading {} to {} in {} MB chunks'.format(file_path, BUCKET_NAME,
                                                      chunk_in_mb))

    b = s3.get_bucket(BUCKET_NAME, validate=False)

    filename = os.path.basename(file_path)
    k = b.new_key(filename)

    mp = b.initiate_multipart_upload(filename)

    source_size = os.stat(file_path).st_size
    bytes_per_chunk = chunk_in_mb * 1024 * 1024
    chunks_count = int(math.ceil(source_size / float(bytes_per_chunk)))
    begin_timestamp = time.time()
    begin_datetime = datetime.datetime.now()
    bytes_total = 0

    for i in range(chunks_count):
        offset = i * bytes_per_chunk
        remaining_bytes = source_size - offset
        bytes = min([bytes_per_chunk, remaining_bytes])
        part_num = i + 1

        success = False
        retries = 0
        while not success:
            print("{}: uploading part {} of {}... ".format(datetime.datetime.now(), part_num, chunks_count), end="")
            with open(file_path, 'r') as fp:
                fp.seek(offset)
                try:
                    mp.upload_part_from_file(fp=fp,
                                             part_num=part_num,
                                             size=bytes)
                    print('success') 
                    success = True
                    bytes_total += bytes
                except Exception as e:
                    print('failure')
                    print('Error during upload:')
                    print(str(e))
                    retries += 1
                    print('Retry #{}'.format(retries))

        elapsed_seconds = time.time() - begin_timestamp
        mb_total = bytes_total / 1024**2.0
        gb_per_hour = (bytes_total / 1024**3.0) / (elapsed_seconds / 3600.)
        print('elapsed: {} MB / {} seconds = {} GB / hr'.format(mb_total, elapsed_seconds, gb_per_hour))
        estimated_completion = begin_datetime + datetime.timedelta(
            seconds=(elapsed_seconds * chunks_count) / part_num)
        print('estimated completion: {}'.format(estimated_completion))

    if len(mp.get_all_parts()) == chunks_count:
        mp.complete_upload()
        print("upload_file done")
    else:
        mp.cancel_upload()
        print("upload_file failed")


@click.command()
@click.argument('filepaths')
@click.option('--chunk_mb',
              prompt='MB per chunk',
              help='Upload file(s) in chunks of this size (in MB)',
              default=CHUNK_MB)
def upload_files(filepaths, chunk_mb):

    s3 = boto.s3.connect_to_region(AWS_DEFAULT_REGION,
                                   aws_access_key_id=AWS_ACCESS_KEY_ID,
                                   aws_secret_access_key=AWS_SECRET_ACCESS_KEY)
    for filepath in glob.glob(filepaths):
        upload_file(s3, filepath, chunk_mb)
    print('Upload complete.  `aws s3 ls s3://${BUCKET_NAME}` to view.')


if __name__ == '__main__':
    upload_files()
