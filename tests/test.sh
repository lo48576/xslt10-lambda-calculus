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

# $1: exp_path
# $2: exp_stem
test_de_bruijn_index() {
	result_path="de-bruijn-index/${2}.txt"
	diff_out="$(xsltproc ../xsl/conv-to-de-bruijn-index.xsl "$1" | xsltproc ../xsl/pretty-print.xsl - | diff --unified -- "${result_path}" -)"
	if [ -n "${diff_out}" ] ; then
		echo "Different output: case ${2} for de-bruijn-index"
		echo "$diff_out"
	fi
}

# $1: exp_path
# $2: exp_stem
test_reduction_steps() {
	result_path="reduction-steps/${2}.txt"
	diff_out="$(xsltproc ../xsl/conv-to-de-bruijn-index.xsl "$1" | xsltproc reduction-steps.xsl - | diff --unified -- "${result_path}" -)"
	if [ -n "${diff_out}" ] ; then
		echo "Different output: case ${2} for reduction-steps"
		echo "$diff_out"
	fi
}

# $1: exp_path
# $2: exp_stem
test_full_reduction() {
	result_path="reduction-steps/${2}.txt"
	expected_result="$(tail -n 1 "$result_path")"
	actual_result="$(xsltproc ../xsl/conv-to-de-bruijn-index.xsl "$1" | xsltproc ../xsl/full-reduction.xsl - | xsltproc ../xsl/pretty-print.xsl -)"
	if [ "$expected_result" != "$actual_result" ] ; then
		echo "Different output: case ${2} for full-reduction"
		echo "$diff_out"
	fi
}

for exp_path in expr/*.xml ; do
	exp_stem="$(basename "$exp_path" .xml)"

	echo "======== case ${exp_stem} ========"
	test_plain "$exp_path" "$exp_stem"
	test_de_bruijn_index "$exp_path" "$exp_stem"
	test_reduction_steps "$exp_path" "$exp_stem"
	test_full_reduction "$exp_path" "$exp_stem"
done
