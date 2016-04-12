<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:output
  method="html" media-type="text/html"
  cdata-section-elements="script style"
  indent="no"
  encoding="utf-8"/>

<xsl:template match="root">
  <table id="instrumente" class="display compact" cellspacing="0" width="100%">
    <thead>
      <tr>
        <th>Name</th>
        <th>alternative Namen</th>
        <th>Suche</th>
        <th>Exemplare von</th>
      </tr>
    </thead>
    <tbody>
      <xsl:apply-templates/>
    </tbody>
  </table>
</xsl:template>

<xsl:template match="title"/>

<xsl:template match="instrument">
  <tr>
    <td><xsl:apply-templates select="name"/></td>
    <td><xsl:apply-templates select="alternative_names"/></td>
    <td>
      <xsl:apply-templates select="avhkv-grep"/>
      <xsl:if test="avhkv-grep/text() != 'no hit' and dingler-grep/@ref">
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="dingler-grep"/>
    </td>
    <td>
      <xsl:for-each select="exemplar">
        <xsl:apply-templates select="current()"/>
      </xsl:for-each>
    </td>
  </tr>
</xsl:template>

<xsl:template match="name">
  <xsl:choose>
    <xsl:when test="@ref">
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="@ref"/></xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="avhkv-grep">
  <xsl:choose>
    <xsl:when test="text() = 'no hit'"/>
    <xsl:otherwise>
      <xsl:element name="a">
        <xsl:attribute name="href">http://kaskade.dwds.de/dstar/dta/dstar.perl?fmt=html&amp;q=<xsl:value-of select="text()"/>+%23has%5Bflags%2C%2Favhkv%2F%5D</xsl:attribute>
        <xsl:text>Nachschriften</xsl:text>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="dingler-grep">
  <xsl:if test="@ref">
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="@ref"/></xsl:attribute>
      Dingler
    </xsl:element>
  </xsl:if>
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
      <p style="font-size:smaller">
        <xsl:apply-templates select="desc"/>
              </p>
    </xsl:if>
  </div>
</xsl:template>

<xsl:template match="persName">
  <xsl:choose>
    <xsl:when test="@ref">
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="@ref"/></xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="@source">
    <xsl:text> (</xsl:text>
    <xsl:if test="@source">
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="@source"/></xsl:attribute>
        <xsl:text>Quelle</xsl:text>
      </xsl:element>
    </xsl:if>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="bibl">
  <xsl:element name="a">
    <xsl:attribute name="href"><xsl:value-of select="@ref"/></xsl:attribute>
    <xsl:choose>
      <xsl:when test="text()">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>(vgl.)</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="placeName">
  <xsl:element name="a">
    <xsl:attribute name="href"><xsl:value-of select="@ref"/></xsl:attribute>
      <xsl:if test="text()">
        <xsl:apply-templates/>
      </xsl:if>
  </xsl:element>
</xsl:template>


</xsl:stylesheet>
