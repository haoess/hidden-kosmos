<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:k="urn:k" version="1.0">

<xsl:output
  method="text" media-type="text/plain"
  indent="no"
  encoding="utf-8"/>

<xsl:template match="root">
"Name","alternative Namen","Suche","Exemplare von"
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="title"/>

<xsl:template match="instrument">
"<xsl:apply-templates select="name"/>","<xsl:apply-templates select="alternative_names"/>","<xsl:apply-templates select="grep[@type='avhkv']"/>","<xsl:for-each select="exemplar"><xsl:apply-templates select="current()"/></xsl:for-each>"
</xsl:template>

<xsl:template match="name">
<xsl:apply-templates/>
</xsl:template>

<xsl:template match="grep[@type='avhkv']">
  <xsl:choose>
    <xsl:when test="text() = 'no hit'"/>
    <xsl:otherwise>
      http://www.deutschestextarchiv.de/search?in=text&amp;q=<xsl:value-of select="k:urlencode(text())"/>+%23has%5Bflags%2C%2Favhkv%2F%5D
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="grep[@type='humboldt']">
  <xsl:choose>
    <xsl:when test="text() = 'no hit'"/>
    <xsl:otherwise>
      http://www.deutschestextarchiv.de/search?in=text&amp;q=<xsl:value-of select="k:urlencode(text())"/>+%23has%5Bauthor%2C%2Fhumboldt%2Fi%5D
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="exemplar">
  <div class="exemplar">
    <xsl:if test="persName">
      <xsl:for-each select="persName">
        <xsl:apply-templates select="current()"/>
        <xsl:if test="position() != last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
      <br />
    </xsl:if>
    <xsl:if test="desc">
      <xsl:apply-templates select="desc"/>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="persName">
  <xsl:apply-templates/>
  <xsl:if test="@source">
    <xsl:text> (</xsl:text>
    <xsl:if test="@source">
      <xsl:value-of select="@source"/>
    </xsl:if>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="bibl">
  <xsl:value-of select="@ref"/>
</xsl:template>

<xsl:template match="placeName">
  <xsl:value-of select="@ref"/>
</xsl:template>

<xsl:template match="orgName">
  <xsl:value-of select="@ref"/>
</xsl:template>

</xsl:stylesheet>
