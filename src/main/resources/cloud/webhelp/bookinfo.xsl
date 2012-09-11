<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:raxm="http://docs.rackspace.com/api/metadata"
    xmlns:f="http://docbook.org/xslt/ns/extension"
    xmlns:db="http://docbook.org/ns/docbook"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs db raxm f"
    version="2.0">
    
    <xsl:param name="base.dir" select="'target/docbkx/xhtml/example/'"/>
    <xsl:param name="input.filename">cs-devguide.xml</xsl:param>
    
    <!-- We need too collect lists that contain their own raxm:metadata so we can 
        add <type>s to the bookinfo for resources mentioned in lists in the doc -->
    <xsl:variable name="resource-lists" select="//db:itemizedlist[db:info/raxm:metadata]"/> 
    
    <xsl:template match="/">
        
        <xsl:apply-templates/>
        <xsl:result-document 
            href="{$base.dir}/bookinfo.xml" 
            method="xml" indent="yes" encoding="UTF-8">
            <products xmlns="">
                <xsl:for-each-group select="//db:info/raxm:metadata" group-by="raxm:product">
                    <product>
                        <id><xsl:value-of select="f:productnumber(current-grouping-key())"/></id>
                        <types>
                            <xsl:variable name="types">
<xsl:if test="/*/db:info/raxm:metadata">
                                <type xmlns="">
                                    <id><xsl:value-of select="f:calculatetype(/*/db:info/raxm:metadata/raxm:type)"/></id>
                                    <displayname><xsl:value-of select="/*/db:title|/*/db:info/db:title"/></displayname>
                                    <url><xsl:value-of select="concat(/*/raxm:product,'/api/',raxm:product/@version,'/',$input.filename)"/></url>
                                    <sequence><xsl:value-of select="f:calculatepriority(/*/db:info//raxm:priority[1])"/></sequence> 
                                </type>  
</xsl:if>
                                <xsl:apply-templates 
                                    select="$resource-lists[db:info/raxm:metadata//raxm:product = current-grouping-key()]/db:listitem" 
                                    mode="bookinfo"/>
                            </xsl:variable>
                            <xsl:apply-templates select="$types/type" mode="copy-types">
                                <xsl:sort select="number(./id)" data-type="number"/>
                            </xsl:apply-templates>
                        </types>
                    </product>                    
                </xsl:for-each-group>
            </products>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="copy-types">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="copy-types"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="db:listitem" mode="bookinfo">
        <xsl:param name="type" select="normalize-space(db:info//raxm:type[1])"/>
        <xsl:param name="priority" select="normalize-space(db:info//raxm:priority[1])"/>
        <xsl:variable name="idNumber" select="f:calculatetype($type)"/>
        
                <type xmlns="">
                    <id><xsl:value-of select="f:calculatetype(parent::*/db:info//raxm:type[1])"/></id>
                    <displayname><xsl:value-of select=".//db:link[1]"/></displayname>
                    <url><xsl:value-of select=".//db:link[1]/@xlink:href"/></url>
                    <sequence><xsl:value-of select="f:calculatepriority(parent::*/db:info//raxm:priority[1])"/></sequence> 
                </type>        
    </xsl:template>
        
    <xsl:function name="f:productname" as="xs:string">
        <xsl:param name="key"/>
        <xsl:choose>
            <xsl:when test="$key = 'servers'">Cloud Servers</xsl:when>
            <xsl:when test="$key = 'servers-firstgen'">First Generation Cloud Servers</xsl:when>
            <xsl:when test="$key= 'cdb'">Cloud Databases</xsl:when>
            <xsl:when test="$key= 'cm'">Cloud Montioring</xsl:when>
            <xsl:when test="$key= 'cbs'">Cloud Block Storage</xsl:when>            
            <xsl:when test="$key= 'cloudfiles'">Cloud Files</xsl:when>            
            <xsl:when test="$key= 'loadbalancers'">Cloud Loadbalancers</xsl:when>
            <xsl:when test="$key= 'auth'">Cloud Identity</xsl:when>
            <xsl:when test="$key= 'cdns'">Cloud DNS</xsl:when>
            <xsl:otherwise>&#160;</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:productnumber" as="xs:string">
        <xsl:param name="key"/>
        <xsl:choose>
            <xsl:when test="$key = 'servers'">1</xsl:when>
            <xsl:when test="$key = 'servers-firstgen'">1</xsl:when>
            <xsl:when test="$key= 'cdb'">2</xsl:when>
            <xsl:when test="$key= 'cm'">3</xsl:when>
            <xsl:when test="$key= 'cbs'">4</xsl:when>      
            <xsl:when test="$key= 'cloudfiles'">5</xsl:when>
            <xsl:when test="$key= 'loadbalancers'">6</xsl:when>
            <xsl:when test="$key= 'auth'">7</xsl:when>
            <xsl:when test="$key= 'cdns'">8</xsl:when>      
            <xsl:otherwise>&#160;</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:calculatetype" as="xs:string">
        <xsl:param name="key"/>
        <xsl:choose>
            <xsl:when test="$key = 'concept'">1</xsl:when>
            <xsl:when test="$key= 'apiref'">2</xsl:when>
            <xsl:when test="$key= 'resource'">3</xsl:when>
            <xsl:when test="$key= 'tutorial'">4</xsl:when>      
            <xsl:when test="$key= 'apiref-mgmt'">5</xsl:when>
            <xsl:otherwise>100</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:calculatepriority">
        <xsl:param name="priority"/>
        <xsl:choose>
            <xsl:when test="normalize-space($priority) != ''">
                <xsl:value-of select="normalize-space($priority)"/>
            </xsl:when>
            <xsl:otherwise>100000</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>