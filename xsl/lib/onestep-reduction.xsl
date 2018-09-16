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
<xsl:import href="has-beta-redex.xsl" />
<xsl:import href="shift.xsl" />
<xsl:import href="substitute.xsl" />

<xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" />
<xsl:strip-space elements="*" />

<xsl:param name="int:debug" select="'no'" />

<!-- Named template. -->
<xsl:template name="ls:onestep-reduction">
	<xsl:param name="term" select="." />

	<xsl:apply-templates select="exsl:node-set($term)" mode="ls:onestep-reduction" />
</xsl:template>

<!-- Fallback for document root. -->
<xsl:template match="/" mode="ls:onestep-reduction">
	<xsl:apply-templates mode="ls:onestep-reduction" />
</xsl:template>

<!-- Fallback for unknown elements. -->
<xsl:template match="*" mode="ls:onestep-reduction">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Unknown element: {</xsl:text>
		<xsl:value-of select="namespace-uri()" />
		<xsl:text>}</xsl:text>
		<xsl:value-of select="local-name()" />
		<xsl:text>, mode=ls:onestep-reduction</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Fallback for unsupported elements. -->
<xsl:template match="l:lambda" mode="ls:onestep-reduction">
	<xsl:message terminate="yes">
		<xsl:text>ERROR: Got `lambda` element, but it should be converted to de-bruijn-lamdbda [@mode=ls:onestep-reduction]</xsl:text>
	</xsl:message>
</xsl:template>

<!-- Variables. -->
<xsl:template match="l:var | l:de-bruijn-var" mode="ls:onestep-reduction">
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=ls:onestep-reduction][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>
	<xsl:copy-of select="." />
</xsl:template>

<xsl:template match="l:de-bruijn-lambda" mode="ls:onestep-reduction">
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=ls:onestep-reduction][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<de-bruijn-lambda>
		<xsl:apply-templates mode="ls:onestep-reduction" />
	</de-bruijn-lambda>
</xsl:template>

<xsl:template match="l:apply" mode="ls:onestep-reduction">
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: beginning template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=ls:onestep-reduction][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<xsl:variable name="lhs-has-beta-redex">
		<xsl:apply-templates select="*[1]" mode="ls:has-beta-redex" />
	</xsl:variable>
	<xsl:variable name="rhs-has-beta-redex">
		<xsl:apply-templates select="*[2]" mode="ls:has-beta-redex" />
	</xsl:variable>
	<xsl:if test="$int:debug = 'yes'">
		<xsl:message terminate="no">
			<xsl:text>DEBUG: en-route template[@select=</xsl:text>
			<xsl:value-of select="local-name()" />
			<xsl:text>][@mode=ls:onestep-reduction][term=</xsl:text>
			<xsl:apply-templates select="." mode="ls:pretty-print" />
			<xsl:text>]</xsl:text>
			<xsl:text>[$lhs-has-beta-redex=</xsl:text>
			<xsl:value-of select="$lhs-has-beta-redex" />
			<xsl:text>][$rhs-has-beta-redex=</xsl:text>
			<xsl:value-of select="$rhs-has-beta-redex" />
			<xsl:text>]</xsl:text>
		</xsl:message>
	</xsl:if>

	<xsl:choose>
		<xsl:when test="l:de-bruijn-lambda[position() = 1]">
			<xsl:if test="$int:debug = 'yes'">
				<xsl:message terminate="no">
					<xsl:text>DEBUG: en-route template[@select=</xsl:text>
					<xsl:value-of select="local-name()" />
					<xsl:text>][@mode=ls:onestep-reduction][term=</xsl:text>
					<xsl:apply-templates select="." mode="ls:pretty-print" />
					<xsl:text>]</xsl:text>
					<xsl:text>[l:de-bruijn-lambda[position() = 1]=</xsl:text>
					<xsl:apply-templates select="l:de-bruijn-lambda[position() = 1]" mode="ls:pretty-print" />
					<xsl:text>]</xsl:text>
				</xsl:message>
			</xsl:if>

			<xsl:call-template name="int:shift">
				<xsl:with-param name="shift" select="-1" />
				<xsl:with-param name="term">
					<xsl:apply-templates select="l:de-bruijn-lambda[1]/*" mode="int:substitute">
						<xsl:with-param name="lhs" select="1" />
						<xsl:with-param name="rhs">
							<xsl:apply-templates select="l:*[2]" mode="int:shift">
								<xsl:with-param name="shift" select="1" />
							</xsl:apply-templates>
						</xsl:with-param>
					</xsl:apply-templates>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$lhs-has-beta-redex = 'true'">
			<apply>
				<xsl:apply-templates select="*[1]" mode="ls:onestep-reduction" />
				<xsl:copy-of select="*[2]" />
			</apply>
		</xsl:when>
		<xsl:when test="$rhs-has-beta-redex = 'true'">
			<apply>
				<xsl:copy-of select="*[1]" />
				<xsl:apply-templates select="*[2]" mode="ls:onestep-reduction" />
			</apply>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="." />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>
