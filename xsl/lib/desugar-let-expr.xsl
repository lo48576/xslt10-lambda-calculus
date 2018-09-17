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
<xsl:template match="*" mode="ls:desugar-let-expr">
	<xsl:copy-of select="." />
</xsl:template>

<!-- Named template. -->
<xsl:template name="ls:desugar-let-expr">
	<xsl:param name="term" select="." />
	<xsl:if test="count($term) &gt; 1">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Multiple root element is given for template[@name='ls:desugar-let-expr']: [</xsl:text>
			<xsl:for-each select="$term">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name(.)" />
			</xsl:for-each>
		</xsl:message>
		<xsl:text>]&#x0a;</xsl:text>
	</xsl:if>

	<xsl:apply-templates select="exsl:node-set($term)" mode="ls:desugar-let-expr" />
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="ls:desugar-let-expr">
	<xsl:if test="count(l:*) &gt; 1">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Multiple root element is given for template[@name='ls:desugar-let-expr']: [</xsl:text>
			<xsl:for-each select="l:*">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name(.)" />
			</xsl:for-each>
		</xsl:message>
		<xsl:text>]&#x0a;</xsl:text>
	</xsl:if>

	<xsl:apply-templates mode="ls:desugar-let-expr" />
</xsl:template>

<xsl:template match="l:*" mode="ls:desugar-let-expr">
	<xsl:element name="{local-name()}" namespace="{namespace-uri()}">
		<xsl:copy-of select="@*" />
		<xsl:apply-templates mode="ls:desugar-let-expr" />
	</xsl:element>
</xsl:template>

<!-- The output requires `apply-at-once` and `multiple-params` syntax sugar. -->
<xsl:template match="l:let" mode="ls:desugar-let-expr">
	<apply>
		<lambda>
			<xsl:for-each select="l:bind">
				<param>
					<xsl:value-of select="l:var[1]" />
				</param>
			</xsl:for-each>
			<xsl:apply-templates select="l:body" mode="ls:desugar-let-expr" />
		</lambda>
		<xsl:for-each select="l:bind">
			<xsl:copy-of select="l:*[2]" />
		</xsl:for-each>
	</apply>
</xsl:template>

</xsl:stylesheet>
