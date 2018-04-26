#!/bin/bash


sed -n 's/.* 08:.*\(http-8080-[0-9]*\).*/\1/p' application.log | sort | uniq > work/list-of-threads

while read line; do
    THREAD=$line
    echo $THREAD
    THREAD_SED="work/$THREAD.sed"
    THREAD_START_END_FILE=work\\/${THREAD}_start_end

    sed -e "s/#THREAD#/$THREAD/g" -e "s/#FILE#/$THREAD_START_END_FILE/g"  compute-start-end.sed > "$THREAD_SED"

    sed -n -f "$THREAD_SED" application.log

    THREAD_DURATION_FILE="work/${THREAD}_duration"

    while read line; do
        START_TIME="$(echo $line | sed -n 's/START \([^ ][^ ]*\).*/\1/p' )"
        END_TIME="$(echo $line | sed -n 's/START [^ ][^ ]* END \([^ ][^ ]*\).*/\1/p' )"
        DURATION="$(echo $(( ($(date --date="2018-04-18 $END_TIME" +%s) - $(date --date="2018-04-18 $START_TIME" +%s) ) )))"
        echo "$line $DURATION" >> $THREAD_DURATION_FILE
    done < $THREAD_START_END_FILE

done < work/list-of-threads

grep -e  '[0-9][0-9][0-9]$' work/*_duration > work/long-queries


while read line; do
    THREAD="$(echo "$line" | sed 's/.*\(http-8080-[^_]*\).*/\1/g')"
    TIME="$(echo "$line" | sed 's/.*START \([0-9][0-9]:[0-9][0-9]\).*/\1/g')"

    sed -n "s/.*$TIME.*$THREAD.*EXEC QUERY.*\(P_.*\)/$THREAD $TIME \1/p" application.log
done < work/long-queries