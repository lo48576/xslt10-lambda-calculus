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
<xsl:import href="onestep-reduction.xsl" />

<xsl:param name="int:debug" select="$debug" />

<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*"/>

<!-- Fallback for unknown elements. -->
<xsl:template match="*" mode="ls:reduction-steps">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Unknown element: {</xsl:text>
		<xsl:value-of select="namespace-uri()" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="local-name()" />
		<xsl:text>, mode=ls:reduction-steps</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Named template. -->
<xsl:template name="ls:reduction-steps">
	<xsl:param name="term" select="." />
	<xsl:param name="max-recursion" select="256" />
	<xsl:param name="int:recursion-count" select="0" />
	<xsl:param name="int:term-serialized" />

	<xsl:apply-templates select="exsl:node-set($term)" mode="ls:reduction-steps">
		<xsl:with-param name="max-recursion" select="$max-recursion" />
		<xsl:with-param name="int:recursion-count" select="$int:recursion-count" />
		<xsl:with-param name="int:term-serialized" select="$int:term-serialized" />
	</xsl:apply-templates>
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="ls:reduction-steps">
	<xsl:param name="max-recursion" select="256" />
	<xsl:param name="int:recursion-count" select="0" />
	<xsl:param name="int:term-serialized" />

	<xsl:apply-templates mode="ls:reduction-steps">
		<xsl:with-param name="max-recursion" select="$max-recursion" />
		<xsl:with-param name="int:recursion-count" select="$int:recursion-count" />
		<xsl:with-param name="int:term-serialized" select="$int:term-serialized" />
	</xsl:apply-templates>
</xsl:template>

<!-- Fallback for unsupported elements. -->
<xsl:template match="l:lambda" mode="ls:reduction-steps">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Got `lambda` element, but it should be converted to de-bruijn-index [@mode=ls:reduction-steps]</xsl:text>
	</xsl:message>
</xsl:template>

<xsl:template match="l:var | l:de-bruijn-var | l:de-bruijn-lambda | l:apply" mode="ls:reduction-steps">
	<xsl:param name="max-recursion" select="256" />
	<xsl:param name="int:recursion-count" select="0" />
	<xsl:param name="int:term-serialized" />
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=ls:reduction-steps][recursion-count=</xsl:text>
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
			<xsl:text>, mode=ls:reduction-steps&#x0a;</xsl:text>
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
		<xsl:apply-templates select="." mode="ls:onestep-reduction" />
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
			<xsl:text>][@mode=ls:reduction-steps][recursion-count=</xsl:text>
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

	<xsl:copy-of select="." />
	<xsl:choose>
		<xsl:when test="$result-serialized = $term-serialized">
			<!-- All done. -->
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="exsl:node-set($result)" mode="ls:reduction-steps">
				<xsl:with-param name="int:recursion-count" select="number($int:recursion-count) + 1" />
				<xsl:with-param name="int:term-serialized" select="$result-serialized" />
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>
