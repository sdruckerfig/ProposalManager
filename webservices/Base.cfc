<cfcomponent>


<cffunction name="query2array" access="private" 
            returntype="array" output="false">
   
  <cfargument name="qdata" type="query" required="yes">
		
  <cfset local.i = "0">
  <cfset local.stdata = structnew()>
  <cfset local.thiscolumn = "">
  <cfset local.aresult = arraynew(1)>
		
  <cfloop from="1" to="#qdata.recordcount#" index="i">
	<cfset local.stdata = structnew()>
       <cfloop list="#qdata.columnlist#" 
               index="local.thiscolumn">
           <cfif local.thiscolumn contains "date" and local.thiscolumn is not "updateuser">
               <cfset local.thedate = qdata[local.thiscolumn][i]>
               <cfset stdata[lcase(local.thiscolumn)] = 
                                        "#dateformat(local.thedate,'mm/dd/yyyy')# #timeformat(local.thedate,'HH:nn')#">
           <cfelse>
              <cfset stdata[lcase(local.thiscolumn)] = 
                                        qdata[local.thiscolumn][i]>
           </cfif>
	   
 	</cfloop>
	<cfset arrayAppend(local.aresult,local.stdata)>
  </cfloop>
		
  <cfreturn aResult>
 </cffunction>

</cfcomponent>