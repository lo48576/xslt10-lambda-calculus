#!/bin/sh
cd "$(dirname "$(readlink -f "$0")")"

# $1: exp_path
# $2: exp_stem
test_plain() {
	result_path="plain/${2}.txt"
	if [ ! -e "$result_path" ] ; then
		echo "[SKIP] Case ${2} for plain is skipped"
		return
	fi
	diff_out="$(xsltproc ../xsl/pretty-print.xsl "$1" | diff --unified -- "${result_path}" -)"
	if [ -n "${diff_out}" ] ; then
		echo "Different output: case ${2} for plain"
		echo "$diff_out"
	fi
}

# $1: exp_path
# $2: exp_stem
test_desugar() {
	result_path="desugar/${2}.txt"
	if [ ! -e "$result_path" ] ; then
		echo "[SKIP] Case ${2} for desugar is skipped"
		return
	fi
	diff_out="$(xsltproc ../xsl/desugar.xsl "$1" | xsltproc ../xsl/pretty-print.xsl - | diff --unified -- "${result_path}" -)"
	if [ -n "${diff_out}" ] ; then
		echo "Different output: case ${2} for desugar"
		echo "$diff_out"
	fi
}

# $1: exp_path
# $2: exp_stem
test_de_bruijn_term() {
	result_path="de-bruijn-term/${2}.txt"
	if [ ! -e "$result_path" ] ; then
		echo "[SKIP] Case ${2} for de-bruijn-term is skipped"
		return
	fi
	diff_out="$(xsltproc ../xsl/desugar.xsl "$1" | xsltproc ../xsl/conv-to-de-bruijn-term.xsl - | xsltproc ../xsl/pretty-print.xsl - | diff --unified -- "${result_path}" -)"
	if [ -n "${diff_out}" ] ; then
		echo "Different output: case ${2} for de-bruijn-term"
		echo "$diff_out"
	fi
}

# $1: exp_path
# $2: exp_stem
test_de_bruijn_eta() {
	result_path="de-bruijn-term/${2}.eta.txt"
	if [ ! -e "$result_path" ] ; then
		return
	fi
	diff_out="$(xsltproc ../xsl/desugar.xsl "$1" | xsltproc ../xsl/conv-to-de-bruijn-term.xsl - | xsltproc ../xsl/eta-reduction.xsl - | xsltproc ../xsl/pretty-print.xsl - | diff --unified -- "${result_path}" -)"
	if [ -n "${diff_out}" ] ; then
		echo "Different output: case ${2} for de-bruijn-eta"
		echo "$diff_out"
	fi
}

# $1: exp_path
# $2: exp_stem
test_reduction_steps() {
	result_path="reduction-steps/${2}.txt"
	if [ ! -e "$result_path" ] ; then
		echo "[SKIP] Case ${2} for reduction-steps is skipped"
		return
	fi
	diff_out="$(xsltproc ../xsl/desugar.xsl "$1" | xsltproc ../xsl/conv-to-de-bruijn-term.xsl - | xsltproc reduction-steps.xsl - | diff --unified -- "${result_path}" -)"
	if [ -n "${diff_out}" ] ; then
		echo "Different output: case ${2} for reduction-steps"
		echo "$diff_out"
	fi
}

# $1: exp_path
# $2: exp_stem
test_full_reduction() {
	result_path="reduction-steps/${2}.txt"
	if [ ! -e "$result_path" ] ; then
		result_path="reduction-steps/${2}.final.txt"
		if [ ! -e "$result_path" ] ; then
			echo "[SKIP] Case ${2} for full-reduction is skipped"
			return
		fi
	fi
	expected_result="$(tail -n 1 "$result_path")"
	actual_result="$(xsltproc ../xsl/desugar.xsl "$1" | xsltproc ../xsl/conv-to-de-bruijn-term.xsl - | xsltproc ../xsl/full-reduction.xsl - | xsltproc ../xsl/pretty-print.xsl -)"
	if [ "$expected_result" != "$actual_result" ] ; then
		echo "Different output: case ${2} for full-reduction"
		echo "expected: ${expected_result}"
		echo "actual: ${actual_result}"
	fi
}

for exp_path in expr/*.xml ; do
	exp_stem="$(basename "$exp_path" .xml)"

	echo "======== case ${exp_stem} ========"
	test_plain "$exp_path" "$exp_stem"
	test_desugar "$exp_path" "$exp_stem"
	test_de_bruijn_term "$exp_path" "$exp_stem"
	test_de_bruijn_eta "$exp_path" "$exp_stem"
	test_reduction_steps "$exp_path" "$exp_stem"
	test_full_reduction "$exp_path" "$exp_stem"
done
