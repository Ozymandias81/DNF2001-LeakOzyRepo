@echo off

for /R %%f in (*.dfx) do start ../System/ucc batchexport "%%f" Sound wav ../#extracted/%%~nf\
pause