<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns="http://www.cardina1.red/_ns/xslt-lambda-calculus"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:l="http://www.cardina1.red/_ns/xslt-lambda-calculus"
	xmlns:ls="http://www.cardina1.red/_ns/xslt-lambda-calculus/stylesheet"
	xmlns:int="http://www.cardina1.red/_ns/xslt-lambda-calculus/_internal"
	exclude-result-prefixes="xsl exsl l ls int"
>
<xsl:import href="pretty-print.xsl" />
<xsl:import href="shift.xsl" />

<xsl:param name="int:debug" select="'no'" />

<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*"/>

<!-- Fallback for unknown elements. -->
<xsl:template match="*" mode="ls:eta-reduction">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Unknown element: {</xsl:text>
		<xsl:value-of select="namespace-uri()" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="local-name()" />
		<xsl:text>, mode=ls:eta-reduction</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Named template. -->
<xsl:template name="ls:eta-reduction">
	<xsl:param name="term" select="." />
	<xsl:param name="max-recursion" select="256" />
	<xsl:param name="int:recursion-count" select="0" />
	<xsl:param name="int:term-serialized" />

	<xsl:apply-templates select="exsl:node-set($term)" mode="ls:eta-reduction">
		<xsl:with-param name="max-recursion" select="$max-recursion" />
		<xsl:with-param name="int:recursion-count" select="number($int:recursion-count)" />
		<xsl:with-param name="int:term-serialized" select="$int:term-serialized" />
	</xsl:apply-templates>
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="ls:eta-reduction">
	<xsl:param name="max-recursion" select="256" />
	<xsl:param name="int:recursion-count" select="0" />
	<xsl:param name="int:term-serialized" />

	<xsl:apply-templates mode="ls:eta-reduction">
		<xsl:with-param name="max-recursion" select="$max-recursion" />
		<xsl:with-param name="int:recursion-count" select="number($int:recursion-count)" />
		<xsl:with-param name="int:term-serialized" select="$int:term-serialized" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="l:*" mode="ls:eta-reduction">
	<xsl:param name="max-recursion" select="256" />
	<xsl:param name="int:recursion-count" select="0" />
	<xsl:param name="int:term-serialized" />
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=ls:eta-reduction][recursion-count=</xsl:text>
			<xsl:value-of select="$int:recursion-count" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>
	<xsl:if test="$int:recursion-count &gt;= $max-recursion">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Recursion limit exceeded ($max-recursion=</xsl:text>
			<xsl:value-of select="$max-recursion" />
			<xsl:text>), current term:</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>, mode=ls:eta-reduction&#x0a;</xsl:text>
		</xsl:message>
	</xsl:if>

	<xsl:variable name="term-serialized">
		<xsl:choose>
			<xsl:when test="$int:term-serialized = ''">
				<xsl:apply-templates select="." mode="ls:pretty-print">
					<xsl:with-param name="omit-current-paren" select="'yes'" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$int:term-serialized" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="result">
		<xsl:apply-templates select="." mode="int:eta-reduction-step" />
	</xsl:variable>
	<xsl:variable name="result-serialized">
		<xsl:apply-templates select="exsl:node-set($result)" mode="ls:pretty-print">
			<xsl:with-param name="omit-current-paren" select="'yes'" />
		</xsl:apply-templates>
	</xsl:variable>

	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: en-route template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=ls:eta-reduction][recursion-count=</xsl:text>
			<xsl:value-of select="$int:recursion-count" />
			<xsl:text>]</xsl:text>
			<xsl:text>[term=</xsl:text>
			<xsl:value-of select="$term-serialized" />
			<xsl:text>]</xsl:text>
			<xsl:text>[result=</xsl:text>
			<xsl:value-of select="$result-serialized" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<xsl:choose>
		<xsl:when test="$result-serialized = $term-serialized">
			<!-- Eta reduction is done. -->
			<xsl:copy-of select="exsl:node-set($result)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="exsl:node-set($result)" mode="ls:eta-reduction">
				<xsl:with-param name="max-recursion" select="$max-recursion" />
				<xsl:with-param name="int:recursion-count" select="number($int:recursion-count) + 1" />
				<xsl:with-param name="int:term-serialized" select="$result-serialized" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="int:eta-reduction-step">
	<xsl:apply-templates mode="int:eta-reduction-step" />
</xsl:template>

<xsl:template match="l:var | l:de-bruijn-var" mode="int:eta-reduction-step">
	<xsl:copy-of select="." />
</xsl:template>

<xsl:template match="l:lambda" mode="int:eta-reduction-step">
	<xsl:variable name="name" select="normalize-space(l:param)" />
	<xsl:if test="contains($name, ' ')">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Variable name should not have whitespaces [@mode='int:eta-reduction-step'][select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][$name=</xsl:text>
			<xsl:value-of select="$name" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<lambda>
		<xsl:copy-of select="l:param" />
		<body>
			<xsl:apply-templates select="l:body/l:*" mode="int:eta-reduction-step" />
		</body>
	</lambda>
</xsl:template>

<xsl:template match="l:lambda[l:body/l:apply/l:*[2][self::l:var]]" mode="int:eta-reduction-step">
	<xsl:if test="count(l:body/l:apply/l:*) != 2">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: `l:apply` should have just 2 subterms, but found </xsl:text>
			<xsl:value-of select="count(l:body/l:apply/l:*)" />
			<xsl:text> (mode=int:eta-reduction-step)</xsl:text>
		</xsl:message>
	</xsl:if>
	<xsl:variable name="param-name" select="normalize-space(l:param)" />
	<xsl:if test="contains($param-name, ' ')">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Variable name should not have whitespaces [@mode='int:eta-reduction-step'][select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][$param-name=</xsl:text>
			<xsl:value-of select="$name" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>
	<xsl:variable name="varname" select="normalize-space(l:body/l:apply/l:*[2][self::l:var])" />
	<xsl:if test="contains($varname, ' ')">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Variable name should not have whitespaces [@mode='int:eta-reduction-step'][select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][$varname=</xsl:text>
			<xsl:value-of select="$name" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<xsl:choose>
		<xsl:when test="$param-name = $varname">
			<xsl:apply-templates select="l:body/l:apply/l:*[1]" mode="int:eta-reduction-step" />
		</xsl:when>
		<xsl:otherwise>
			<lambda>
				<xsl:copy-of select="l:param" />
				<body>
					<xsl:apply-templates select="l:body/l:*" mode="int:eta-reduction-step" />
				</body>
			</lambda>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="l:lambda[normalize-space(l:param) = normalize-space(l:body/l:apply/l:*[2][self::l:var])]" mode="int:eta-reduction-step">
	<xsl:apply-templates select="l:body/l:apply/l:*[1]" mode="int:eta-reduction-step" />
</xsl:template>

<xsl:template match="l:de-bruijn-lambda" mode="int:eta-reduction-step">
	<de-bruijn-lambda>
		<xsl:apply-templates mode="int:eta-reduction-step" />
	</de-bruijn-lambda>
</xsl:template>

<xsl:template match="l:de-bruijn-lambda[l:apply/l:*[2][self::l:de-bruijn-var][@index = 1]]" mode="int:eta-reduction-step">
	<xsl:if test="count(l:apply/l:*) != 2">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: `l:apply` should have just 2 subterms, but found </xsl:text>
			<xsl:value-of select="count(l:apply/l:*)" />
			<xsl:text> (mode=int:eta-reduction-step)</xsl:text>
		</xsl:message>
	</xsl:if>

	<xsl:call-template name="int:shift">
		<xsl:with-param name="shift" select="-1" />
		<xsl:with-param name="term">
			<xsl:apply-templates select="l:apply/l:*[1]" mode="int:eta-reduction-step" />
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template match="l:apply" mode="int:eta-reduction-step">
	<xsl:if test="count(l:*) != 2">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: `l:apply` should have just 2 subterms, but found </xsl:text>
			<xsl:value-of select="count(l:*)" />
			<xsl:text> (mode=int:eta-reduction-step)</xsl:text>
		</xsl:message>
	</xsl:if>

	<apply>
		<xsl:apply-templates mode="int:eta-reduction-step" />
	</apply>
</xsl:template>

</xsl:stylesheet>
