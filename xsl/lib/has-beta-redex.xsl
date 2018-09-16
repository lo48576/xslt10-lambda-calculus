<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns="http://www.cardina1.red/_ns/xslt-lambda-calculus"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:l="http://www.cardina1.red/_ns/xslt-lambda-calculus"
	xmlns:ls="http://www.cardina1.red/_ns/xslt-lambda-calculus/stylesheet"
	exclude-result-prefixes="xsl exsl l ls"
>
<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*" />

<!-- Fallback for document root. -->
<xsl:template match="/" mode="ls:has-beta-redex">
	<xsl:apply-templates mode="ls:has-beta-redex" />
</xsl:template>

<!-- Fallback for unknown elements. -->
<xsl:template match="*" mode="ls:has-beta-redex">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Unknown element: {</xsl:text>
		<xsl:value-of select="namespace-uri()" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="local-name()" />
		<xsl:text>, mode=ls:has-beta-redex</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Fallback for unsupported elements. -->
<xsl:template match="l:lambda" mode="ls:has-beta-redex">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Got `lambda` element, but it should be converted to de-bruijn-lambda [@mode=ls:has-beta-redex]</xsl:text>
	</xsl:message>
</xsl:template>

<xsl:template match="l:var | l:de-bruijn-var" mode="ls:has-beta-redex">
	<xsl:text>false</xsl:text>
</xsl:template>

<xsl:template match="l:de-bruijn-lambda" mode="ls:has-beta-redex">
	<xsl:apply-templates mode="ls:has-beta-redex" />
</xsl:template>

<xsl:template match="l:apply" mode="ls:has-beta-redex">
	<xsl:choose>
		<xsl:when test="l:*[1][self::l:de-bruijn-lambda]">
			<xsl:text>true</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="lhs-has-beta-redex">
				<xsl:apply-templates select="*[1]" mode="ls:has-beta-redex" />
			</xsl:variable>
			<xsl:variable name="rhs-has-beta-redex">
				<xsl:apply-templates select="*[2]" mode="ls:has-beta-redex" />
			</xsl:variable>
			<xsl:value-of select="$lhs-has-beta-redex = 'true' or $rhs-has-beta-redex = 'true'" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>
