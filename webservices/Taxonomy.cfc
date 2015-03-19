<cfcomponent rest="true" restpath="Taxonomy" extends="base"> 

<cffunction name="GetRecords" access="remote" httpmethod="GET" returntype="array">
  <cfargument name="checkboxes" required="false" type="boolean" default="false"  restargsource="query">
  <cfargument name="noLeafs" required="false" type="boolean" default="false"  restargsource="query">
  <cfargument name="assetId" required="false" type="numeric" default="0"  restargsource="query">
  
  <cfset var rec = {}>
  <cfset var i = 0>


  <cfif arguments.assetId gt 0>
    <cfquery name="local.taxonomy">
      select termid
      from assetTerm
      where assetid = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.assetid#">
    </cfquery>
    <cfset local.taxonomyIds = ListToArray(valuelist(local.taxonomy.termid))>
  </cfif>

  <cfquery name="local.tree">
      select id,text,bitmask,parentId
      from taxonomy
      where endtime is null
      and companyId = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">
      order by bitmask,text
  </cfquery>

  <cfset local.a = []>
  <cfset local.aObjs = {}>

  <cfloop query="local.tree">
    
    <cfset rec = {
      "text" = local.tree.text,
      "bitmask" = local.tree.bitmask,
      "parentId" = local.tree.parentId,
      "id" = local.tree.id,
      "leaf" = !arguments.noLeafs,
      "children" = [],
      "expanded" = false,
      "loaded" = false
    }>

    <cfif arguments.checkboxes>
      <cfset rec["checked"] = false>
      <cfset rec["expanded"] = true>
    </cfif>

    <cfif isdefined("local.taxonomyIds")>
      <cfif arrayFind(local.taxonomyIds,rec.id) gt 0>
        <cfset rec["checked"] = true>
      </cfif>
    </cfif>

    <cfset local.aObjs[local.tree.id] = rec>

    <cfif local.tree.parentId is "">
      <cfset arrayAppend(local.a,rec)>
    <cfelse>
      <cfset arrayAppend(local.aObjs[local.tree.parentId].children,rec)>
      <cfset local.aObjs[local.tree.parentId].leaf = false>
    </cfif>

  </cfloop>

  <cfreturn local.a>

</cffunction>


<cffunction name="handleChildren" access="private">
  <cfargument name="parent" type="struct">
  <cfargument name="stub" type="string">

  <cfset var thisNode = "">
  <cfset var counter = 1>
  <cfset var currentStub = "">
  <cfset var writeStub = "">
  <cfset var stResult = "">

  <cfloop array="#parent.children#" index="thisNode">
    
    <cfset currentStub = stub & numberformat(counter,'00')>
    <cfset writeStub = currentStub & repeatstring("0",10 - len(currentStub))>
    
    <cfif isNumeric(thisnode.id)>
        
        <!--- update --->
        <cfquery>
          update taxonomy
          set 
            text = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisnode.text#">,
            bitmask = <cfqueryparam cfsqltype="cf_sql_varchar" value="#writeStub#">,
            <cfif parent.id is "root">
              parentId = null,
            <cfelse>
              parentId =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#parent.id#">,
            </cfif>
            updateuser = <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.username#">,
            updatedate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">
          
          where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisnode.id#">
        </cfquery>

        <cfset counter = counter + 1>

    <cfelse>
        <!--- insert --->
        <cfquery name="local.insertNode" result = "stResult">
          insert into taxonomy (text,bitmask,parentid,companyid,updateuser,updatedate)
          values (
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisnode.text#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#writeStub#">,
             <cfif parent.id is "root">
             null,
            <cfelse>
             <cfqueryparam cfsqltype="cf_sql_numeric" value="#parent.id#">,
            </cfif>
            <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.username#">,
            <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">
    
          )
        </cfquery>

        <cfset thisnode.id = stresult.GENERATED_KEY>

    </cfif>
    <cfif isdefined("thisnode.children")>
      <cfset handleChildren(thisNode,currentStub)>
    </cfif>
   
  </cfloop>


</cffunction>

<cffunction 
   name="updateRecords"
   access="remote"
   returntype="struct"
   httpMethod="post" 
   roles="Admin,SuperAdmin">

 <cfset var rd = deserializeJson(toString(getHttpRequestData().content))>

 <cfif isdefined('rd.nodes') and isdefined('rd.nodeIds')>
   <!--- parse nodes --->
   <cfset local.root = rd.nodes>

   <cftransaction>
     
     <!--- perform deletes --->
     <cfif rd.nodeIds is not "">
        <cfquery>
          delete 
          from assetTerm
          where termid not in (<cfqueryparam cfsqltype="cf_sql_numeric" value="#rd.nodeIds#" list="true">)
        </cfquery>

        <cfquery>
          update taxonomy 
          set endtime =  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">,
          updateuser =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.username#">
          where 
          companyId =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#"> 
          and 
          id not in (<cfqueryparam cfsqltype="cf_sql_numeric" value="#rd.nodeIds#" list="true">)
        </cfquery>

        <cfset handleChildren(local.root,"")>
       </cfif>
   
   </cftransaction>

 <cfelse>
    <cfthrow message="You must pass nodes and nodeIds as the request payload">
 </cfif>

 <cfreturn {"success"="true"}>

</cffunction>

</cfcomponent>