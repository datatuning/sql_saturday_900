ECHO OFF
rd /s /q %temp%\output
"ostress.exe" -E -S.\ -dSQLSat900 -Q"exec SQLSat900.dbo.spInserePedido" -mstress -quiet -n256 -r250 | FINDSTR "QEXEC Starting Creating elapsed"