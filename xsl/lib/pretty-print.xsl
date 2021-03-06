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

<!-- Variable names. -->
<!-- `l:var`: Variable with name. -->
<!-- `l:param`: Virtual parameter of lambda abstraction (`<lambda>`). -->
<xsl:template match="l:var | l:param" mode="ls:pretty-print">
	<xsl:variable name="name" select="normalize-space()" />
	<xsl:if test="contains($name, ' ')">
		<xsl:message terminate="yes">
			<xsl:text>ERROR: Variable name should not have whitespaces [@mode='ls:pretty-print'][select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][$name=</xsl:text>
			<xsl:value-of select="$name" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<xsl:value-of select="$name" />
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
	<xsl:for-each select="l:param">
		<xsl:if test="position() != 1">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:apply-templates select="." mode="ls:pretty-print" />
	</xsl:for-each>
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

<!-- Body of lambda abstraction (`<lambda>`) and let-expression (`<let>`). -->
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
			<xsl:when test="count(l:*) = 1">no</xsl:when>
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

<!-- Let-expression (syntax sugar) with 'independent' binding mode. -->
<!-- `let` of Scheme programming language. -->
<xsl:template match="l:let" mode="ls:pretty-print">
	<xsl:param name="force-paren" select="'no'" />
	<xsl:param name="omit-current-paren" select="'no'" />
	<xsl:variable name="paren">
		<xsl:choose>
			<xsl:when test="$omit-current-paren = 'yes'">no</xsl:when>
			<xsl:when test="$force-paren = 'yes'">yes</xsl:when>
			<xsl:otherwise>no</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="let-name">
		<xsl:choose>
			<xsl:when test="not(@mode) or @mode = 'independent'">let</xsl:when>
			<xsl:when test="@mode = 'one-by-one'">let*</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">
					<xsl:text>ERROR: Unknown binding mode for `l:let` at template[@mode='ls:pretty-print']: [l:let/@mode=</xsl:text>
					<xsl:value-of select="@mode" />
					<xsl:text>]</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:if test="$paren = 'yes'">
		<xsl:text>(</xsl:text>
	</xsl:if>
	<xsl:value-of select="$let-name" />
	<xsl:text> </xsl:text>
	<xsl:for-each select="l:bind">
		<xsl:apply-templates select="l:var[1]" mode="ls:pretty-print" />
		<xsl:text>=</xsl:text>
		<xsl:apply-templates select="l:*[2]" mode="ls:pretty-print" />
		<xsl:if test="position() != last()">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:for-each>
	<xsl:text> in </xsl:text>
	<xsl:apply-templates select="l:body" mode="ls:pretty-print" />
	<xsl:if test="$paren = 'yes'">
		<xsl:text>)</xsl:text>
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
