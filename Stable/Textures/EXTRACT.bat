@echo off

for /R %%f in (*.dtx) do start ../System/ucc batchexport "%%f" Texture bmp C:\DNFExport\%%~nf\
pause