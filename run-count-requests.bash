#!/bin/bash
# the script displays for each minutes the amount of new requests and the amount of completed requests
# and the differences between them

echo "Clear work directory"
rm work/requests*

echo "Counting the new and completed requests"
sed -n -f count-requests.sed application.log | sort |  uniq -c > work/requests_count

echo "Computing the differences"
sed -n 's/[ ]*[^ ]* [^ ]* \(08.*\)/\1/p' work/requests_count | sort | uniq > work/requests_count_time

while read line; do
    TIME=$line

    REQUEST_IN="$(sed -n "s/ *\([0-9]*\) REQUEST_IN $TIME/\1/p" work/requests_count)"
    REQUEST_IN=${REQUEST_IN:-0}

    REQUEST_OUT="$(sed -n "s/ *\([0-9]*\) REQUEST_OUT $TIME/\1/p" work/requests_count)"
    REQUEST_OUT=${REQUEST_OUT:-0}

    DIFF="$(echo $(($REQUEST_IN - $REQUEST_OUT)) | sed -n 's/-*\(.*\)/\1/p')"
    echo "$TIME $REQUEST_IN $REQUEST_OUT $DIFF" >> work/requests_count_diff
done < work/requests_count_time

echo "Time with too much differences between the new and the completed requests"
sed -n '/\([0-9][0-9]\|[4-9]\)$/p' work/requests_count_diff | tee work/requests_in_problem
