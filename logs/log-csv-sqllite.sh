#!/usr/bin/env bash

#exec >> $PWD/sqlite-data-loading.log 2>&1

LASTDAY=$(date --iso-8601='date' --date='1 day ago')
TODAY=$(date --iso-8601='date')
LOGDIR=/data/data/com.termux/files/home/workdir/iplog/
# LOGFILE=ip-addr-record-$LASTDAY.log
LOGFILE=ip-addr-record-2026-09-27.log
LOGDATA="$LOGDIR$LOGFILE"

echo -e "Start dsily data processing"
echo -e "And SQL dstabase loading";
echo -e "Date: $TODAY"
echo -e "File: $LOGFILE"
echo -e "--------------"
echo -e "--------------"
echo -e ""
# echo -e "Deleting old data from te. table: "

# sqlite3 -noinit ip_logs.db "DROP TABLE IF EXISTS ipv4" ;
# sqlite3 -noinit ip_logs.db "DROP TABLE IF EXISTS ipv6" ;
#
# sqlite3 -noinit IPRecBTCL.db "DROP  TABLE IF EXISTS IPv4LoadTab" ;
# sqlite3 -noinit IPRecBTCL.db "DROP  TABLE IF EXISTS IPv6LoadTab" ;

# sqlite3 -noinit ip_logs.db "DELETE FROM TESTTAB";

# echo -e "Done"
echo -e "Current Loading Table status:"
echo -e "Before Loading Single Row"

/data/data/com.termux/files/home/wd/iplog/db/loadig-table-status.sh | tail -12

#sqlite3 -noinit ip_logs.db "SELECT MAX(ROWID) AS ROWNUM, 
#MIN(logtime) ST,
#MAX(logtime) ET, 
#$COUNT(IP) AS IPNUM, 
#'IPv4' as REC_TAG from IPv4
#UNION ALL
#SELECT MAX(ROWID) AS ROWNUM, 
#MIN(logtime) ST,
#MAX(logtime) ET, 
#COUNT(IP) AS IPNUM, 
#'IPv6' as REC_TAG from IPv6";

sqlite3 -noinit IPRecBTCL.db "CREATE TABLE IF NOT EXISTS IPv4LoadTab (
    logtime TEXT,
    ip      TEXT,
    prefix  TEXT,
    host    TEXT,
    RedirNum    INTEGER,
    FinURL  TEXT,
    RedirTime   REAL,
    httpcode    INTEGER,
    exitcode    INTEGER,
    time_q      REAL,
    time_dns    REAL,
    time_connect    REAL,
    time_appconnect REAL,
    time_starttr    REAL,
    time_total      REAL,
    size_deliver    INTEGER,
    size_download   INTEGER,
    speed       INTEGERR,
    IPnError    TEXT,
    rectag      TEXT 
    )";

sqlite3 -noinit IPRecBTCL.db "CREATE TABLE IF NOT EXISTS IPv6LoadTab (
    logtime TEXT,
    ip      TEXT,
    prefix  TEXT,
    host    TEXT,
    RedirNum    INTEGER,
    FinURL  TEXT,
    RedirTime   REAL,
    httpcode    INTEGER,
    exitcode    INTEGER,
    time_q      REAL,
    time_dns    REAL,
    time_connect    REAL,
    time_appconnect REAL,
    time_starttr    REAL,
    time_total      REAL,
    size_deliver    INTEGER,
    size_download   INTEGER,
    speed       INTEGERR,
    IPnError    TEXT,
    rectag      TEXT 
    )";


echo -e "Loading IPv6 Records";

awk -F';' 'BEGIN {OFS=","} /^REC_IPv6/ { ip=$3; if (match(ip, /^([0-9a-fA-F]*:){3}[0-9a-fA-F]*/)) { prefix=substr(ip, RSTART, RLENGTH); sub(/:+$/, "", prefix); prefix=prefix"::" } else { prefix="INVALID" }; print $2,$3,prefix,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1 }' $LOGDATA | sqlite3 -noinit -csv IPRecBTCL.db  ".import /dev/stdin IPv6LoadTab"
 
echo -e "IPv6 Init LoadbDone";
echo -e "Now Loading IPv4 Records";

awk -F';' 'BEGIN {OFS=","} /^REC_IPv4/ { 
    ip=$3; 
    if (split(ip, octets, ".") == 4) { 
        prefix = octets[1]"."octets[2]"."octets[3] 
    } else { 
        prefix = "INVALID" 
    }; 
    print $2,$3,prefix,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1 }' $LOGDATA | sqlite3 -noinit -csv IPRecBTCL.db ".import /dev/stdin IPv4LoadTab"

echo "Done Losding IPv4" 
echo "Done Processing $LOGFILE"

echo -e "Current Table Ststus:"

sqlite3 -noinit IPRecBTCL.db " \
    SELECT 'IPv4' as TabName, MAX(ROWID) as MaxRowId, 
MIN(DATETIME(logtime,'subsec','localtime')) as StartTime,
MAX(DATETIME(logtime,'subsec','localtime')) as EndTime,
COUNT(*) as TotalRow 
from  IPv4LoadTab  
GROUP BY DATE(logtime,'subsec','localtime') 
UNION ALL
SELECT 'IPv6' as TabName, MAX(ROWID) as MaxRowId,
MIN(DATETIME(logtime,'subsec','localtime')) as StartTime,
MAX(DATETIME(logtime,'subsec','localtime')) as EndTime,
COUNT(*) as TotalRow 
from  IPv6LoadTab  
GROUP BY DATE(logtime,'subsec','localtime')
ORDER BY MAXROWID,TabName ";


#/data/data/com.termux/files/home/wd/iplog/db/loadig-table-status.sh

# sqlite3 -noinit ip_logs.db " \
#    SELECT LogDate, SUM(DataRow) as TotalRow, 'AllRec' as TName FROM (
#    SELECT Date(logtime) as LogDate, COUNT(*) as DataRow, 'ipv4' as TName  from  ipv4 group by LogDate
#UNION ALL
#SELECT Date(logtime) as LogDate, COUNT(*) as DataRow, 'ipv6' as TName  from  ipv6 group by LogDate 
#) GROUP BY LogDate,Tname
#ORDER BY LogDate";

echo -e "Total Line on Logfile: $(wc -l $LOGDATA | awk '{ print $1}')";
    echo -e "Done Loading Data"
    wc -l $LOGDATA 

    exit 0
