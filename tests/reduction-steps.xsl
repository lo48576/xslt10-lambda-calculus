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
<xsl:import href="../xsl/lib/pretty-print.xsl" />
<xsl:import href="../xsl/lib/reduction-steps.xsl" />

<xsl:param name="debug" select="'no'" />
<xsl:variable name="int:debug" select="$debug" />

<xsl:output method="text" encoding="utf-8" />
<xsl:strip-space elements="*"/>

<xsl:param name="max-recursion" select="256" />

<!-- Entrypoint. -->
<xsl:template match="/">
	<xsl:variable name="steps">
		<xsl:apply-templates mode="ls:reduction-steps">
			<xsl:with-param name="max-recursion" select="$max-recursion" />
		</xsl:apply-templates>
	</xsl:variable>
	<xsl:for-each select="exsl:node-set($steps)/*">
		<xsl:apply-templates select="." mode="ls:pretty-print">
			<xsl:with-param name="omit-current-paren" select="'yes'" />
		</xsl:apply-templates>
		<xsl:text>&#x0a;</xsl:text>
	</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
