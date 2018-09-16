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
<xsl:import href="shift.xsl" />

<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*" />

<xsl:param name="int:debug" select="'no'" />

<!-- Named template. -->
<xsl:template name="int:substitute">
	<!-- term: node-set -->
	<xsl:param name="term" select="." />
	<!-- lhs: de bruijn index -->
	<xsl:param name="lhs" select="1" />
	<!-- rhs: node-set -->
	<xsl:param name="rhs" />

	<xsl:apply-templates select="exsl:node-set($term)" mode="int:substitute">
		<xsl:with-param name="lhs" select="$lhs" />
		<xsl:with-param name="rhs" select="exsl:node-set($rhs)" />
	</xsl:apply-templates>
</xsl:template>

<!-- Fallback for unknown elements. -->
<xsl:template match="*" mode="int:substitute">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Unknown element: {</xsl:text>
		<xsl:value-of select="namespace-uri()" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="local-name()" />
		<xsl:text>, mode=int:substitute</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="int:substitute">
	<!-- term: node-set -->
	<xsl:param name="term" select="." />
	<!-- lhs: de bruijn index -->
	<xsl:param name="lhs" select="1" />
	<!-- rhs: node-set -->
	<xsl:param name="rhs" />

	<xsl:apply-templates mode="int:substitute">
		<xsl:with-param name="lhs" select="$lhs" />
		<xsl:with-param name="rhs" select="exsl:node-set($rhs)" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="l:var" mode="int:substitute">
	<xsl:copy-of select="." />
</xsl:template>

<xsl:template match="l:de-bruijn-var" mode="int:substitute">
	<!-- lhs: de bruijn index -->
	<xsl:param name="lhs" select="1" />
	<!-- rhs: node-set -->
	<xsl:param name="rhs" />
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=int:substitute][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>][$lhs=</xsl:text>
			<xsl:value-of select="$lhs" />
			<xsl:text>][$rhs=</xsl:text>
			<xsl:apply-templates select="exsl:node-set($rhs)" mode="ls:pretty-print" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<xsl:choose>
		<xsl:when test="@index = $lhs">
			<xsl:if test="$int:debug = 'yes'">
				<xsl:message terminate="no">
					<xsl:text>DEBUG: en-route template[@select=</xsl:text>
					<xsl:value-of select="local-name()" />
					<xsl:text>][@mode=int:substitute][term=</xsl:text>
					<xsl:apply-templates select="." mode="ls:pretty-print" />
					<xsl:text>][$lhs=</xsl:text>
					<xsl:value-of select="$lhs" />
					<xsl:text>][$rhs=</xsl:text>
					<xsl:apply-templates select="exsl:node-set($rhs)" mode="ls:pretty-print" />
					<xsl:text>][replacing lhs to rhs]</xsl:text>
				</xsl:message>
			</xsl:if>
			<xsl:copy-of select="exsl:node-set($rhs)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="." />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="l:de-bruijn-lambda" mode="int:substitute">
	<!-- lhs: de bruijn index -->
	<xsl:param name="lhs" select="1" />
	<!-- rhs: node-set -->
	<xsl:param name="rhs" />
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=int:substitute][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>][$lhs=</xsl:text>
			<xsl:value-of select="$lhs" />
			<xsl:text>][$rhs=</xsl:text>
			<xsl:apply-templates select="exsl:node-set($rhs)" mode="ls:pretty-print" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<de-bruijn-lambda>
		<xsl:apply-templates mode="int:substitute">
			<xsl:with-param name="lhs" select="number($lhs) + 1" />
			<xsl:with-param name="rhs">
				<xsl:apply-templates select="exsl:node-set($rhs)" mode="int:shift">
					<xsl:with-param name="shift" select="1" />
				</xsl:apply-templates>
			</xsl:with-param>
		</xsl:apply-templates>
	</de-bruijn-lambda>
</xsl:template>

<xsl:template match="l:apply" mode="int:substitute">
	<!-- lhs: de bruijn index -->
	<xsl:param name="lhs" select="1" />
	<!-- rhs: node-set -->
	<xsl:param name="rhs" />
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=int:substitute][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>][$lhs=</xsl:text>
			<xsl:value-of select="$lhs" />
			<xsl:text>][$rhs=</xsl:text>
			<xsl:apply-templates select="exsl:node-set($rhs)" mode="ls:pretty-print" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<apply>
		<xsl:apply-templates mode="int:substitute">
			<xsl:with-param name="lhs" select="$lhs" />
			<xsl:with-param name="rhs" select="exsl:node-set($rhs)" />
		</xsl:apply-templates>
	</apply>
</xsl:template>

</xsl:stylesheet>
