<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    <xsl:param name="entiyID"/>
    <xsl:template match="/"><!--        http://digital-archiv.at:8081/exist/apps/aratea-online/pages/show.html?document=listWork.xml&directory=indices&stylesheet=listWork.xsl&work=hansi--><!-- Modal -->
        <div class="modal" id="myModal" role="dialog">
            <div class="modal-dialog"><!-- Modal content-->
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">
                            <span class="fa fa-times"/>
                        </button>
                        <h4 class="modal-title">
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="//tei:person[@xml:id=$entiyID]/tei:persName/@ref"/>
                                </xsl:attribute>
                                <xsl:value-of select="//tei:person[@xml:id=$entiyID]/tei:persName[1]/text()"/>
                            </xsl:element>
                        </h4>
                    </div>
                    <div class="modal-body">
                        <table class="table table-boardered table-hover">
                            <xsl:for-each select="//tei:person[@xml:id=$entiyID]/*[text()]">
                                <tr>
                                    <th>
                                        <xsl:value-of select="name(.)"/>
                                    </th>
                                    <td>
                                        <xsl:value-of select="./text()"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
        <script type="text/javascript">
            $(window).load(function(){
            $('#myModal').modal('show');
            });
        </script>
    </xsl:template>
</xsl:stylesheet>