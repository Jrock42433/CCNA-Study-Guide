@echo off
REM ============================================================
REM  CCNA Guide — PDF Builder (Windows)
REM  Requires: pandoc + MiKTeX (or another LaTeX distribution)
REM  Install pandoc: https://pandoc.org/installing.html
REM  Install MiKTeX: https://miktex.org/download
REM ============================================================

echo Building CCNA Complete Guide PDF...

REM Check if pandoc is installed
where pandoc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: pandoc not found. Install from https://pandoc.org/installing.html
    pause
    exit /b 1
)

REM Build PDF from all chapters
pandoc ^
  README.md ^
  chapters/01-network-fundamentals.md ^
  chapters/02-network-access.md ^
  chapters/03-ip-connectivity.md ^
  chapters/04-ip-services.md ^
  chapters/05-security.md ^
  chapters/06-automation.md ^
  -o CCNA-Complete-Guide.pdf ^
  --toc ^
  --toc-depth=2 ^
  --number-sections ^
  -V geometry:margin=1in ^
  -V fontsize=10pt ^
  -V documentclass=article ^
  -V colorlinks=true ^
  -V linkcolor=blue ^
  --highlight-style=tango ^
  --pdf-engine=pdflatex

if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS! PDF created: CCNA-Complete-Guide.pdf
    echo.
    start "" "CCNA-Complete-Guide.pdf"
) else (
    echo.
    echo ERROR: PDF generation failed.
    echo Make sure MiKTeX is installed and pandoc can find pdflatex.
    echo Try running: pandoc --version
    echo.
    echo ALTERNATIVE: Install md-to-pdf
    echo   npm install -g md-to-pdf
    echo   md-to-pdf CCNA-Complete-Guide.md
)

pause
