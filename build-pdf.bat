@echo off
REM ============================================================
REM  CCNA Guide — PDF Builder (Windows)
REM  Requires: pandoc + typst (both installed via winget)
REM  Install pandoc: winget install JohnMacFarlane.Pandoc
REM  Install typst:  winget install Typst.Typst
REM ============================================================

setlocal enabledelayedexpansion

set PANDOC=%LOCALAPPDATA%\Pandoc\pandoc.exe
set TYPST_SEARCH=%LOCALAPPDATA%\Microsoft\WinGet\Packages\Typst.Typst_Microsoft.Winget.Source_8wekyb3d8bbwe

echo Building CCNA Complete Guide PDF...

REM Find typst.exe under WinGet packages
for /r "%TYPST_SEARCH%" %%f in (typst.exe) do set TYPST=%%f

if not exist "%PANDOC%" (
    echo ERROR: pandoc not found at %PANDOC%
    echo Run: winget install JohnMacFarlane.Pandoc
    pause & exit /b 1
)

if not defined TYPST (
    echo ERROR: typst not found under WinGet packages.
    echo Run: winget install Typst.Typst
    pause & exit /b 1
)

REM Step 1: Strip per-chapter TOC sections to avoid broken anchor links
echo Preparing clean source file...
python -c ^
  "import re; f=open('CCNA-Complete-Guide.md','r',encoding='utf-8'); c=f.read(); f.close(); c=re.sub(r'## Table of Contents\n(?:.*\n)*?---','---',c); f=open('CCNA-PDF-Ready.md','w',encoding='utf-8'); f.write(c); f.close()"

REM Step 2: Generate PDF
echo Generating PDF...
"%PANDOC%" ^
  CCNA-PDF-Ready.md ^
  --standalone ^
  --toc ^
  --toc-depth=2 ^
  --number-sections ^
  --syntax-highlighting=tango ^
  --metadata title="CCNA 200-301 Complete Study Guide" ^
  --pdf-engine="%TYPST%" ^
  -o CCNA-Complete-Guide.pdf

if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS! PDF created: CCNA-Complete-Guide.pdf
    del /q CCNA-PDF-Ready.md
    start "" "CCNA-Complete-Guide.pdf"
) else (
    echo.
    echo ERROR: PDF generation failed. Check pandoc and typst are installed.
)

pause
