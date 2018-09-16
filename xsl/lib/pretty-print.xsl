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
<xsl:output method="text" encoding="utf-8" />
<xsl:strip-space elements="*" />

<!-- Fallback for unknown elements. -->
<xsl:template match="*" mode="ls:pretty-print">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Unknown element: {</xsl:text>
		<xsl:value-of select="namespace-uri()" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="local-name()" />
		<xsl:text>, mode=ls:pretty-print</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Named template. -->
<xsl:template name="ls:pretty-print">
	<xsl:param name="term" select="." />
	<xsl:param name="force-paren" select="'no'" />
	<xsl:param name="omit-current-paren" select="'no'" />
	<xsl:if test="count($term) &gt; 1">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Multiple root element is given for template[@name='ls:pretty-print']: [</xsl:text>
			<xsl:for-each select="$term">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name(.)" />
			</xsl:for-each>
		</xsl:message>
		<xsl:text>]&#x0a;</xsl:text>
	</xsl:if>

	<xsl:apply-templates select="exsl:node-set($term)" mode="ls:pretty-print">
		<xsl:with-param name="force-paren" select="$force-paren" />
		<xsl:with-param name="omit-current-paren" select="$omit-current-paren" />
	</xsl:apply-templates>
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="ls:pretty-print">
	<xsl:param name="force-paren" select="'no'" />
	<xsl:param name="omit-current-paren" select="'no'" />
	<xsl:if test="count(l:*) &gt; 1">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Multiple root element is given for template[@name='ls:pretty-print']: [</xsl:text>
			<xsl:for-each select="l:*">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name(.)" />
			</xsl:for-each>
		</xsl:message>
		<xsl:text>]&#x0a;</xsl:text>
	</xsl:if>

	<xsl:apply-templates mode="ls:pretty-print">
		<xsl:with-param name="force-paren" select="$force-paren" />
		<xsl:with-param name="omit-current-paren" select="$omit-current-paren" />
	</xsl:apply-templates>
</xsl:template>

<!-- Variable with name. -->
<xsl:template match="l:var" mode="ls:pretty-print">
	<xsl:value-of select="." />
</xsl:template>

<!-- Variable with de Bruijn index. -->
<xsl:template match="l:de-bruijn-var" mode="ls:pretty-print">
	<xsl:text>$</xsl:text>
	<xsl:value-of select="@index" />
</xsl:template>

<!-- Lambda abstraction with parameter name. -->
<xsl:template match="l:lambda" mode="ls:pretty-print">
	<xsl:param name="force-paren" select="'no'" />
	<xsl:param name="omit-current-paren" select="'no'" />
	<xsl:variable name="paren">
		<xsl:choose>
			<xsl:when test="$omit-current-paren = 'yes'">no</xsl:when>
			<xsl:when test="$force-paren = 'yes'">yes</xsl:when>
			<xsl:when test="parent::l:body">no</xsl:when>
			<xsl:otherwise>yes</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:if test="$paren = 'yes'">
		<xsl:text>(</xsl:text>
	</xsl:if>
	<xsl:text>λ</xsl:text>
	<xsl:apply-templates select="l:param[1]" mode="ls:pretty-print" />
	<xsl:text>. </xsl:text>
	<xsl:apply-templates select="l:body[1]" mode="ls:pretty-print" />
	<xsl:if test="$paren = 'yes'">
		<xsl:text>)</xsl:text>
	</xsl:if>
</xsl:template>

<!-- Lambda abstraction converted into de Bruijn term. -->
<xsl:template match="l:de-bruijn-lambda" mode="ls:pretty-print">
	<xsl:param name="force-paren" select="'no'" />
	<xsl:param name="omit-current-paren" select="'no'" />
	<xsl:variable name="paren">
		<xsl:choose>
			<xsl:when test="$omit-current-paren = 'yes'">no</xsl:when>
			<xsl:when test="$force-paren = 'yes'">yes</xsl:when>
			<xsl:when test="parent::l:de-bruijn-lambda">no</xsl:when>
			<xsl:otherwise>yes</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:if test="$paren = 'yes'">
		<xsl:text>(</xsl:text>
	</xsl:if>
	<xsl:text>λ </xsl:text>
	<xsl:apply-templates mode="ls:pretty-print" />
	<xsl:if test="$paren = 'yes'">
		<xsl:text>)</xsl:text>
	</xsl:if>
</xsl:template>

<!-- Virtual parameter of lambda abstraction (`<lambda>`). -->
<xsl:template match="l:param" mode="ls:pretty-print">
	<xsl:value-of select="text()" />
</xsl:template>

<!-- Body of lambda abstraction (`<lambda>`). -->
<xsl:template match="l:body" mode="ls:pretty-print">
	<xsl:param name="force-paren" select="'no'" />
	<xsl:param name="omit-current-paren" select="'no'" />

	<xsl:apply-templates mode="ls:pretty-print">
		<xsl:with-param name="force-paren" select="$force-paren" />
		<xsl:with-param name="omit-current-paren" select="$omit-current-paren" />
	</xsl:apply-templates>
</xsl:template>

<!-- Application. -->
<xsl:template match="l:apply" mode="ls:pretty-print">
	<xsl:param name="force-paren" select="'no'" />
	<xsl:param name="omit-current-paren" select="'no'" />
	<xsl:variable name="paren">
		<xsl:choose>
			<xsl:when test="$omit-current-paren = 'yes'">no</xsl:when>
			<xsl:when test="$force-paren = 'yes'">yes</xsl:when>
			<xsl:when test="parent::l:body | parent::l:de-bruijn-lambda">no</xsl:when>
			<xsl:when test="self::*[parent::l:apply][not(preceding-sibling::*)]">no</xsl:when>
			<xsl:otherwise>yes</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:if test="$paren = 'yes'">
		<xsl:text>(</xsl:text>
	</xsl:if>
	<xsl:for-each select="l:*">
		<xsl:if test="position() != 1">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="." mode="ls:pretty-print" />
	</xsl:for-each>
	<xsl:if test="$paren = 'yes'">
		<xsl:text>)</xsl:text>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
