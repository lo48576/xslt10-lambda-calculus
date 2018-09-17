<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ls="http://www.cardina1.red/_ns/xslt-lambda-calculus/stylesheet"
	exclude-result-prefixes="xsl ls"
>
<xsl:import href="lib/eta-reduction.xsl" />

<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*"/>

<xsl:template match="/">
	<xsl:param name="max-recursion" select="256" />

	<xsl:call-template name="ls:eta-reduction">
		<xsl:with-param name="max-recursion" select="$max-recursion" />
	</xsl:call-template>
</xsl:template>

</xsl:stylesheet>
