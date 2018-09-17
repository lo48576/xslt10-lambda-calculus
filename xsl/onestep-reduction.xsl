<?xml version="1.0"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ls="http://www.cardina1.red/_ns/xslt-lambda-calculus/stylesheet"
	exclude-result-prefixes="xsl ls"
>
<xsl:import href="lib/onestep-reduction.xsl" />

<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*"/>

<xsl:template match="/">
	<xsl:call-template name="ls:onestep-reduction" />
</xsl:template>

</xsl:stylesheet>
