#!/usr/bin/env bash

LOGDATA=./query-dns-samtv-2006-09-27.log

sqlite3 SamTVDATA.db "DROP TABLE IF EXISTS SamTV" ;
    
sqlite3 SamTVDATA.db  "DELETE FROMN SamTV";

sqlite3 SamTVDATA.db " \
CREATE TABLE IF NOT EXISTS SamTV (
logtime txt,
hostid txt,
action txt,
clientIP txt,
qdata txt,
w1 txt,
w2 tct,
qresult txt,
cdata int,
size int,
proto txt,
nsid txt,
nsport init )";

awk -F' ' 'BEGIN {OFS=","} /^2026-09/ { 
    ip=$4; 
    if (split(ip, octets, ".") == 4) { 
        prefix = octets[1]"."octets[2]"."octets[3] 
    } else { 
        prefix = "INVALID" 
    }; 
    print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1 }' $LOGDATA | sqlite3 -noinit -csv SamTVDATA.db ".import /dev/stdin SamTV"


    sqlite3 SamTVDATA.db  "SELECT 
    MIN(DATETIME(logtime,'subsec','localtime')) as ST, 
    MAX(DATETIME(logtime,'subsec','localtime')) as ET, 
    COUNT(*) DataRow FROM SamTV group by date(logtime,'subsec','localtime') ";

