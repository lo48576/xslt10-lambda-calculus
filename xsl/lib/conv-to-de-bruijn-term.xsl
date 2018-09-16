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
<xsl:template match="*" mode="ls:conv-to-de-bruijn-term">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Unknown element: {</xsl:text>
		<xsl:value-of select="namespace-uri()" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="local-name()" />
	</xsl:message>
</xsl:template>

<!-- Named template. -->
<xsl:template name="ls:conv-to-de-bruijn-term">
	<xsl:param name="term" select="." />
	<xsl:if test="count($term) &gt; 1">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Multiple root element is given for template[@name='ls:conv-to-de-bruijn-term']: [</xsl:text>
			<xsl:for-each select="$term">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name(.)" />
			</xsl:for-each>
		</xsl:message>
		<xsl:text>]&#x0a;</xsl:text>
	</xsl:if>

	<xsl:apply-templates select="exsl:node-set($term)" mode="ls:conv-to-de-bruijn-term" />
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="ls:conv-to-de-bruijn-term">
	<xsl:if test="count(l:*) &gt; 1">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Multiple root element is given for template[@name='ls:conv-to-de-bruijn-term']: [</xsl:text>
			<xsl:for-each select="l:*">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name(.)" />
			</xsl:for-each>
		</xsl:message>
		<xsl:text>]&#x0a;</xsl:text>
	</xsl:if>

	<xsl:apply-templates mode="ls:conv-to-de-bruijn-term" />
</xsl:template>

<!-- Already converted terms. -->
<xsl:template match="l:de-bruijn-var | l:de-bruijn-lambda" mode="ls:conv-to-de-bruijn-term">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: The given term `</xsl:text>
		<xsl:value-of select="local-name()" />
		<xsl:text>` is already converted</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Named variable. -->
<xsl:template match="l:var" mode="ls:conv-to-de-bruijn-term">
	<xsl:param name="bindings" />
	<xsl:variable name="index">
		<xsl:call-template name="int:de-bruijn-index">
			<xsl:with-param name="bindings" select="normalize-space($bindings)" />
			<xsl:with-param name="varname" select="." />
		</xsl:call-template>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="normalize-space($index) = ''">
			<xsl:copy-of select="." />
		</xsl:when>
		<xsl:otherwise>
			<de-bruijn-var index="{$index}" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Lambda abstraction with parameter name. -->
<xsl:template match="l:lambda" mode="ls:conv-to-de-bruijn-term">
	<xsl:param name="bindings" />

	<de-bruijn-lambda>
		<xsl:apply-templates select="l:body" mode="ls:conv-to-de-bruijn-term">
			<xsl:with-param name="bindings">
				<xsl:value-of select="l:param" />
				<xsl:text> </xsl:text>
				<xsl:value-of select="$bindings" />
			</xsl:with-param>
		</xsl:apply-templates>
	</de-bruijn-lambda>
</xsl:template>

<!-- Virtual parameter of lambda abstraction (`<lambda>`). -->
<xsl:template match="l:param" mode="ls:conv-to-de-bruijn-term">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: `param` element should not be directly processed by `ls:conv-to-de-bruijn-term` mode</xsl:text>
		<xsl:text> (this may be caller's bug)</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Body of lambda abstraction (`<lambda>`). -->
<xsl:template match="l:body" mode="ls:conv-to-de-bruijn-term">
	<xsl:param name="bindings" />

	<xsl:apply-templates mode="ls:conv-to-de-bruijn-term">
		<xsl:with-param name="bindings" select="$bindings" />
	</xsl:apply-templates>
</xsl:template>

<!-- Application. -->
<xsl:template match="l:apply" mode="ls:conv-to-de-bruijn-term">
	<xsl:param name="bindings" />

	<apply>
		<xsl:apply-templates mode="ls:conv-to-de-bruijn-term">
			<xsl:with-param name="bindings" select="$bindings" />
		</xsl:apply-templates>
	</apply>
</xsl:template>

<!-- Returns de Bruijn index of the given variable name from the given bindings. -->
<xsl:template name="int:de-bruijn-index">
	<xsl:param name="bindings" />
	<xsl:param name="varname" />
	<xsl:param name="int:current" select="1" />
	<xsl:variable name="first" select="substring-before(concat($bindings, ' '), ' ')" />

	<xsl:choose>
		<xsl:when test="$first = ''">
			<!-- No more bindings to check. -->
		</xsl:when>
		<xsl:when test="$first = $varname">
			<!-- Gotcha! -->
			<xsl:value-of select="$int:current" />
		</xsl:when>
		<xsl:otherwise>
			<!-- Check rest bindings. -->
			<xsl:call-template name="int:de-bruijn-index">
				<xsl:with-param name="bindings" select="substring-after($bindings, ' ')" />
				<xsl:with-param name="varname" select="$varname" />
				<xsl:with-param name="int:current" select="$int:current + 1" />
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>
