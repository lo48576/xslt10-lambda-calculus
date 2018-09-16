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
<xsl:import href="reduction-steps.xsl" />

<xsl:param name="int:debug" select="'no'" />

<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*"/>

<!-- Fallback for unknown elements. -->
<xsl:template match="*" mode="ls:full-reduction">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Unknown element: {</xsl:text>
		<xsl:value-of select="namespace-uri()" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="local-name()" />
		<xsl:text>, mode=ls:reduction-steps</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Named template. -->
<xsl:template name="ls:full-reduction">
	<xsl:param name="term" select="." />
	<xsl:param name="max-recursion" select="256" />

	<xsl:apply-templates select="exsl:node-set($term)" mode="ls:full-reduction">
		<xsl:with-param name="max-recursion" select="$max-recursion" />
	</xsl:apply-templates>
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="ls:full-reduction">
	<xsl:param name="max-recursion" select="256" />

	<xsl:apply-templates mode="ls:full-reduction">
		<xsl:with-param name="max-recursion" select="$max-recursion" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="l:*" mode="ls:full-reduction">
	<xsl:param name="max-recursion" select="256" />

	<xsl:variable name="steps">
		<xsl:apply-templates select="." mode="ls:reduction-steps">
			<xsl:with-param name="max-recursion" select="$max-recursion" />
		</xsl:apply-templates>
	</xsl:variable>
	<xsl:copy-of select="exsl:node-set($steps)/l:*[last()]" />
</xsl:template>

</xsl:stylesheet>
