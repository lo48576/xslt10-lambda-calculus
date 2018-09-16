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
<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*"/>

<!-- Fallback for unknown elements. -->
<xsl:template match="*" mode="ls:desugar-apply-at-once">
	<xsl:copy-of select="." />
</xsl:template>

<!-- Named template. -->
<xsl:template name="ls:desugar-apply-at-once">
	<xsl:param name="term" select="." />
	<xsl:if test="count($term) &gt; 1">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Multiple root element is given for template[@name='ls:desugar-apply-at-once']: [</xsl:text>
			<xsl:for-each select="$term">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name(.)" />
			</xsl:for-each>
		</xsl:message>
		<xsl:text>]&#x0a;</xsl:text>
	</xsl:if>

	<xsl:apply-templates select="exsl:node-set($term)" mode="ls:desugar-apply-at-once" />
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="ls:desugar-apply-at-once">
	<xsl:if test="count(l:*) &gt; 1">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Multiple root element is given for template[@name='ls:desugar-apply-at-once']: [</xsl:text>
			<xsl:for-each select="l:*">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name(.)" />
			</xsl:for-each>
		</xsl:message>
		<xsl:text>]&#x0a;</xsl:text>
	</xsl:if>

	<xsl:apply-templates mode="ls:desugar-apply-at-once" />
</xsl:template>

<xsl:template match="l:*" mode="ls:desugar-apply-at-once">
	<xsl:element name="{local-name()}" namespace="{namespace-uri()}">
		<xsl:copy-of select="@*" />
		<xsl:apply-templates mode="ls:desugar-apply-at-once" />
	</xsl:element>
</xsl:template>

<xsl:template match="l:apply[count(l:*) = 0]" mode="ls:desugar-apply-at-once">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: `l:apply` should have one or more children, but got nothing: template[@name='ls:desugar-apply-at-once']</xsl:text>
	</xsl:message>
</xsl:template>

<xsl:template match="l:apply[count(l:*) = 1]" mode="ls:desugar-apply-at-once">
	<xsl:apply-templates mode="ls:desugar-apply-at-once" />
</xsl:template>

<xsl:template match="l:apply[count(l:*) &gt; 2]" mode="ls:desugar-apply-at-once">
	<xsl:variable name="except-last">
		<apply>
			<xsl:copy-of select="l:*[not(position() = last())]" />
		</apply>
	</xsl:variable>

	<apply>
		<xsl:apply-templates select="exsl:node-set($except-last)" mode="ls:desugar-apply-at-once" />
		<xsl:apply-templates select="l:*[last()]" mode="ls:desugar-apply-at-once" />
	</apply>
</xsl:template>

</xsl:stylesheet>
