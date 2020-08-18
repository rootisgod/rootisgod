---
layout: post
title:  "Microsoft SQL Server Backups and Deletions"
date:   2020-07-29 15:54:00 +0100
categories: sql backup
---

{% include header.md %}

This is an unashamed post for me to remember something later. Below are a couple of scripts to backup a set of Microsoft SQL Server DBs. Also, to delete, perhaps those same DBs, that you no longer need.

**NOTE: RUN AT YOUR OWN RISK!**

## Backups

Tweak as necessary. Hopefully it is pretty clear where to amend certain things if you have a slight familiarity with SQL already. Apologies to the people I ripped this off ([https://www.mssqltips.com/sqlservertip/1070/simple-script-to-backup-all-sql-server-databases/](https://www.mssqltips.com/sqlservertip/1070/simple-script-to-backup-all-sql-server-databases/)), but this is a version I can use without thinking too hard.

```sql
DECLARE @name VARCHAR(50) -- database name
DECLARE @path VARCHAR(256) -- path for backup files
DECLARE @fileName VARCHAR(256) -- filename for backup
DECLARE @fileDate VARCHAR(20) -- used for file name

-- specify database backup directory
SET @path = 'C:\SQL_Backups_Temp\'

-- specify filename format
-- SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) -- DBname_YYYYDDMM.BAK
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) + '_' + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','') -- DBname_YYYYDDMM_HHMMSS.BAK

DECLARE db_cursor CURSOR READ_ONLY FOR
SELECT name
FROM master.sys.databases
WHERE name NOT IN ('master','model','msdb','tempdb') -- exclude these databases
AND name like 'DB_Name_00%' -- % means any chars afterwards. Remove if no filter needed
AND state = 0 -- database is online
AND is_in_standby = 0 -- database is not read only for log shipping

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
  PRINT @name
  SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
  BACKUP DATABASE @name TO DISK = @fileName WITH COMPRESSION
  FETCH NEXT FROM db_cursor INTO @name
END

CLOSE db_cursor
DEALLOCATE db_cursor
```

## Deletions

This to delete Databases

```sql
use master
go

declare @dbnames nvarchar (max)
declare @statement nvarchar (max)
set @dbnames = ''
set @statement = ''

select @dbnames = @dbnames + ', [' + name + ']' from sys.databases where name like 'DB_Name_00%'
if len (@dbnames) = 0
  begin
    print 'No databases to drop.'
  end
else
  begin
    set @statement = 'DROP DATABASE ' + substring (@dbnames, 2, len (@dbnames)) -- The 2 is just to ignore the ', ' from the select above
    print @statement
    exec sp_executesql @statement -- Comment to show results first
end
```