#! /usr/bin/env bash

set -e
set -u
NEXTYEAR=$(($(date +%Y) + 1))
YEAR=${1:-NEXTYEAR}
CWD=$(pwd)

run_build() {
  FIL=$1
  __FILE=$(basename "${FIL}")
  __FNAME="${__FILE}"
  __CNAME="$CWD/config/${__FNAME}"
  sed "s|CURRENTYEARPLACEHOLDER|$YEAR|" "$FIL" >"${__CNAME}"
  bundle exec "${CWD}"/exe/latex_yearly_planner generate "${__CNAME}" -w "$CWD/out-${__FNAME}" && rm "${__CNAME}"
  mv "$CWD"/out-"${__FNAME}"/index.pdf "$CWD"/out/"${__FNAME%.*}".pdf && rm -rf "$CWD"/out-"${__FNAME}"
  echo "[DONE] ${__FNAME}"
}

mkdir -p "$CWD"/out

echo "Setting up configs"
(
  for FILE in "$CWD"/config/template/*.yaml; do
    echo "[PROGRESS] $(basename "${FILE%.*}")"
    (run_build "$FILE") &
  done
  wait
) &
all_configs=$!

wait $all_configs
