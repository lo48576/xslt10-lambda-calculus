# xslt10-lambda-calculus

## About

This project provides XSLT 1.0 stylesheets to evaluate terms of Lambda Calculus.

## Files and directories

### `xsl/` directory

Contains XSLT files.

For users (for use by CLI XSLT processor):

  * conv-to-de-bruijn-term.xsl
      - Front-end of /lib/conv-to-de-bruijn-term.xsl.
  * eta-reduction.xsl
      - Front-end of /lib/eta-reduction.xsl.
  * full-reduction.xsl
      - Front-end of /lib/full-reduction.xsl.
  * onestep-reduction.xsl
      - Front-end of /lib/onestep-reduction.xsl.
  * pretty-print.xsl
      - Front-end of /lib/pretty-print.xsl.

For developers (for use by `<xsl:import>` or `<xsl:include>`):

  * lib/
      + conv-to-de-bruijn-term.xsl
          - Converts the given term into a de Bruijn term.
      + eta-reduction.xsl
          - Applies eta (η) reduction as possible.
      + full-reduction.xsl
          - Evaluates the given de Bruijn term as possible.
      + has-beta-redex.xsl
          - Returns whether the given de Bruijn term has beta redex, by string
            value `'true'` or `'false'`.
      + onestep-reduction.xsl
          - Does a reduction of single beta redex of the given de Bruijn term.
          - This is leftmost outermost reduction.
      + pretty-print.xsl
          - Prints the given term into the text.
          - Both normal terms and de Bruijn terms are supported.
          - This does not add trailing newline character (`&#x0a;`).
      + reduction-steps.xsl
          - Returns results of each reduction steps.
          - For examples, see `/tests/reduction-steps/*.txt`.
          - By default, it applies eta reduction as the last step.
            This can be disabled by setting parameter `eta-reduction` to `'no'`.
      + shift.xsl
          - Does shift operation for the given de Bruijn term.
          - For detail, see chapter 6.2 of TaPL.
      + substitute.xsl
          - Does substitution for the given de Bruijn term.
          - For detail, see chapter 6.2 of TaPL.

### `tests/` directory

Test scripts and helpers:

  * `reduction-steps.xsl`
      + Front-end of `reduction-steps` feature with pretty-printing enabled.
  * `test.sh`
      + Script to run tests.
      + Nothing other than running test-case names should be printed on success.

Test cases:

  * `de-bruijn-term/*.txt`
      + Expected results for `conv-to-de-bruijn-term` feature.
  * `expr/*.xml`
      + Original (starting) term to be used as test cases.
  * `plain/*.txt`
      + Expected results for `pretty-print` feature.
  * `plain/*.eta.txt`
      + Expected results for `eta-reduction` feature.
  * `reduction-steps/*.txt`
      + Expected results for `reduction-steps` and `full-reduction` feature.


## Namespaces

  * `http://www.cardina1.red/_ns/xslt-lambda-calculus`
      + For lambda calculus terms.
  * `http://www.cardina1.red/_ns/xslt-lambda-calculus/stylesheet`
      + For stylesheet-specific stuff.
      + Template modes, template names, etc.
  * `http://www.cardina1.red/_ns/xslt-lambda-calculus/_internal`
      + For internal stuff.
      + This should not be used by end users, or stylesheet may use inconsistent
        data and result in broken calculation.

## Lambda terms representation

Consider `xmlns:l="http://www.cardina1.red/_ns/xslt-lambda-calculus"`.

### Named variable

```xml
<l:var>{{varname}}</l:var>
```

`{{varname}}` is variable name.
It should be string, and should not contain space characters.

`l:var` can be used in any terms.

### Variable with de Bruijn index

```xml
<l:de-bruijn-var index="{{index}} />
```

`{{index}}` is de Bruijn index.
It should be integer `>= 1`.

The index is 1-based, because
[De Bruijn index - Wikipedia](https://en.wikipedia.org/wiki/De_Bruijn_index)
uses 1-based index (at 2018-09-16 edition).

`l:de-bruijn-var` can only be used in de Bruijn terms.

### Lambda abstraciton

```xml
<l:lambda>
  <l:param>{{varname}}</l:param>
  <l:body>{{term}}</l:body>
</l:lambda>
```

`{{varname}}` is parameter name.
It should be string, and should not contain space characters.

`{{term}}` is XML representation of body term.
It can be any (non-de-Bruijn) term, it should be just one XML element.

`l:lambda` can only be used in non-de-Bruijn terms.

### Lambda abstraction of de Bruijn term

```xml
<l:de-bruijn-lambda>
  {{term}}
</l:de-bruijn-lambda>
```

`{{term}}` is XML representation of body term.
It can be any de Bruijn term, but it should be just one XML element.

`l:lambda` can only be used in de Bruijn terms.

### Application

```xml
<l:apply>
  {{term1}}
  {{term2}}
</l:apply>
```

`{{term1}}` and `{{term2}}` are XML representations of applied term and
argument.
They can be any terms (which can appear in `l:apply`'s position), but each of
them should be just one XML element.

`l:apply` can only be used in any terms.


## Use of EXSLT (`node-set()`)

Some of stylesheets uses
[`node-set()` function](http://exslt.org/exsl/functions/node-set/) of
[EXSLT](http://exslt.org/).

This is required for multi-step tree processing, because plain XSLT 1.0 does not
allow result node-set of template to be bound to variables as node-set.
This means, you cannot do "pass result tree of some template A to other template
B" without some extension.

EXSLT is widely known and `node-set()` is supported by many XSLT processors.

## License

Licensed under either of

* Apache License, Version 2.0, ([LICENSE-APACHE.txt](LICENSE-APACHE.txt) or
  <https://www.apache.org/licenses/LICENSE-2.0>)
* MIT license ([LICENSE-MIT.txt](LICENSE-MIT.txt) or
  <https://opensource.org/licenses/MIT>)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
