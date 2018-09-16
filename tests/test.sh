#!/bin/sh
cd "$(dirname "$(readlink -f "$0")")"

# $1: exp_path
# $2: exp_stem
test_plain() {
	result_path="plain/${2}.txt"
	diff_out="$(xsltproc ../xsl/pretty-print.xsl "$1" | diff --unified -- "${result_path}" -)"
	if [ -n "${diff_out}" ] ; then
		echo "Different output: case ${2} for plain"
		echo "$diff_out"
	fi
}

for exp_path in expr/*.xml ; do
	exp_stem="$(basename "$exp_path" .xml)"

	echo "======== case ${exp_stem} ========"
	test_plain "$exp_path" "$exp_stem"
done
