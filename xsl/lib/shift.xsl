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
<xsl:import href="pretty-print.xsl" />

<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*" />

<xsl:param name="int:debug" select="'no'" />

<!-- Named template. -->
<xsl:template name="int:shift">
	<xsl:param name="term" select="." />
	<xsl:param name="cutoff" select="1" />
	<xsl:param name="shift" select="0" />

	<xsl:apply-templates select="exsl:node-set($term)" mode="int:shift">
		<xsl:with-param name="cutoff" select="$cutoff" />
		<xsl:with-param name="shift" select="$shift" />
	</xsl:apply-templates>
</xsl:template>

<!-- Fallback for unknown elements. -->
<xsl:template match="*" mode="int:shift">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Unknown element: {</xsl:text>
		<xsl:value-of select="namespace-uri()" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="local-name()" />
		<xsl:text>, mode=int:shift</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="int:shift">
	<xsl:param name="cutoff" select="1" />
	<xsl:param name="shift" select="0" />

	<xsl:apply-templates mode="int:shift">
		<xsl:with-param name="cutoff" select="$cutoff" />
		<xsl:with-param name="shift" select="$shift" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="l:var" mode="int:shift">
	<xsl:copy-of select="." />
</xsl:template>

<xsl:template match="l:de-bruijn-var" mode="int:shift">
	<xsl:param name="cutoff" select="1" />
	<xsl:param name="shift" select="0" />
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=int:shift][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>][$cutoff=</xsl:text>
			<xsl:value-of select="$cutoff" />
			<xsl:text>][$shift=</xsl:text>
			<xsl:value-of select="$shift" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<xsl:choose>
		<xsl:when test="number(@index) &lt; number($cutoff)">
			<xsl:copy-of select="." />
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="$int:debug = 'yes'">
				<xsl:message terminate="no">
					<xsl:text>DEBUG: en-route template[@select=</xsl:text>
					<xsl:value-of select="local-name()" />
					<xsl:text>][@mode=int:shift][term=</xsl:text>
					<xsl:apply-templates select="." mode="ls:pretty-print" />
					<xsl:text>][$cutoff=</xsl:text>
					<xsl:value-of select="$cutoff" />
					<xsl:text>][$shift=</xsl:text>
					<xsl:value-of select="$shift" />
					<xsl:text>][new var index =</xsl:text>
					<xsl:value-of select="number(@index) + number($shift)" />
					<xsl:text>]</xsl:text>
				</xsl:message>
			</xsl:if>
			<de-bruijn-var index="{number(@index) + number($shift)}" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="l:de-bruijn-lambda" mode="int:shift">
	<xsl:param name="cutoff" select="1" />
	<xsl:param name="shift" select="0" />
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=int:shift][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>][$cutoff=</xsl:text>
			<xsl:value-of select="$cutoff" />
			<xsl:text>][$shift=</xsl:text>
			<xsl:value-of select="$shift" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<de-bruijn-lambda>
		<xsl:apply-templates mode="int:shift">
			<xsl:with-param name="cutoff" select="number($cutoff) + 1" />
			<xsl:with-param name="shift" select="$shift" />
		</xsl:apply-templates>
	</de-bruijn-lambda>
</xsl:template>

<xsl:template match="l:apply" mode="int:shift">
	<xsl:param name="cutoff" select="1" />
	<xsl:param name="shift" select="0" />
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=int:shift][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>][$cutoff=</xsl:text>
			<xsl:value-of select="$cutoff" />
			<xsl:text>][$shift=</xsl:text>
			<xsl:value-of select="$shift" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<apply>
		<xsl:apply-templates mode="int:shift">
			<xsl:with-param name="cutoff" select="$cutoff" />
			<xsl:with-param name="shift" select="$shift" />
		</xsl:apply-templates>
	</apply>
</xsl:template>

</xsl:stylesheet>
