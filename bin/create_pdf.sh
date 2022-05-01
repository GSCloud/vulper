#!/bin/bash
#@author Fred Brooker <git@gscloud.cz>

if [ ! -f "./bin/_includes.sh" ]; then
    echo -en "\n\n\e[1;31mMissing _includes.sh file!\e[0m\n\n"
    exit 1
fi
source ./bin/_includes.sh
command -v docker >/dev/null 2>&1 || fail "Docker is NOT installed!"
[ ! -r ".env" ] && fail "Missing .env file!"
source .env

###############################################################################

# MarkDown -> ADOC
find . -maxdepth 1 -type d \( -path ./db -o -path ./www \) -prune -false -o -iname "*.md" \
    -exec echo "Converting {} to ADOC" \; \
    -exec docker run --rm -v "$(pwd)":/data pandoc/core:latest -f markdown -t asciidoc -i {} -o "{}.adoc" \;

# ADOC -> PDF
find . -maxdepth 1 -type d \( -path ./db -o -path ./www \) -prune -false -o -iname "*.adoc" \
    -exec echo "Converting {} to PDF" \; \
    -exec docker run --rm -v $(pwd):/documents/ asciidoctor/docker-asciidoctor:latest asciidoctor-pdf "{}" \;

exit 0
