#!/bin/bash
# ============================================================
#  CCNA Guide — PDF Builder (Linux/macOS)
#  Requires: pandoc + texlive-full (Linux) or MacTeX (macOS)
#
#  Linux:  sudo apt install pandoc texlive-full
#  macOS:  brew install pandoc
#          Download MacTeX: https://www.tug.org/mactex/
# ============================================================

set -e

echo "Building CCNA Complete Guide PDF..."

# Check pandoc
if ! command -v pandoc &> /dev/null; then
    echo "ERROR: pandoc not found."
    echo "Linux:  sudo apt install pandoc texlive-full"
    echo "macOS:  brew install pandoc"
    exit 1
fi

pandoc \
  README.md \
  chapters/01-network-fundamentals.md \
  chapters/02-network-access.md \
  chapters/03-ip-connectivity.md \
  chapters/04-ip-services.md \
  chapters/05-security.md \
  chapters/06-automation.md \
  -o CCNA-Complete-Guide.pdf \
  --toc \
  --toc-depth=2 \
  --number-sections \
  -V geometry:margin=1in \
  -V fontsize=10pt \
  -V documentclass=article \
  -V colorlinks=true \
  -V linkcolor=blue \
  --highlight-style=tango \
  --pdf-engine=pdflatex

echo ""
echo "SUCCESS! PDF created: CCNA-Complete-Guide.pdf"
