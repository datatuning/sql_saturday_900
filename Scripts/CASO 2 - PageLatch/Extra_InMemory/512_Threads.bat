rd /s /q %temp%\output
"ostress.exe" -E -S.\ -dSQLSat900 -Q"exec SQLSat900.dbo.spInserePedido_InMemory" -mstress -quiet -n512 -r250 | FINDSTR "QEXEC Starting Creating elapsed"