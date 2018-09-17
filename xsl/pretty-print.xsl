<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ls="http://www.cardina1.red/_ns/xslt-lambda-calculus/stylesheet"
	exclude-result-prefixes="xsl ls"
>
<xsl:import href="lib/pretty-print.xsl" />

<xsl:output method="text" encoding="utf-8" />
<xsl:strip-space elements="*"/>

<xsl:template match="/">
	<xsl:call-template name="ls:pretty-print">
		<xsl:with-param name="omit-current-paren" select="'yes'" />
	</xsl:call-template>
	<xsl:text>&#x0a;</xsl:text>
</xsl:template>

</xsl:stylesheet>
