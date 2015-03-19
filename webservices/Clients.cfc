<cfcomponent rest="true" restpath="Clients" extends="base"> 

<cffunction name="GetAll" access="remote" httpmethod="GET" returntype="struct">
  <cfargument name="query" required="false" type="string" default=""  restargsource="query">
  <cfargument name="filter" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="sorter" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="limit" required="false" type="numeric" default="100" restargsource="query">
  <cfargument name="start" required="false" type="numeric" default="1"   restargsource="query">
  
 
  <cfquery name="local.qCount">
    select count(*) as thecount
    from client
    where endtime is null
    and idCompany = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">
    <cfif arguments.query is not "">
      and clientname like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.query#%">
    </cfif>
  </cfquery>

  <cfquery name="local.data">
    select *
    from client
    where endtime is null
    and idCompany = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">
    <cfif arguments.query is not "">
      and clientname like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.query#%">
    </cfif>
  </cfquery>
 
 <cfset out = {
   "records" = query2array(local.data),
   "success" = true,
   "total" = local.qCount.thecount
 }>
 

 <cfreturn out>

</cffunction>

<cffunction name="getdetail" 
            access="remote"
            returntype="struct"
            httpMethod="get"
            restpath="{id}"
          >
  
 <cfargument name="id" type="string" required="true" restargsource="Path">

 <cfquery name="local.q">
   select *
   from client 
   where id = <cfqueryparam 
        cfsqltype="cf_sql_numeric"
        value="#arguments.Id#">
    and idCompany = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">
    and endtime is null
 </cfquery>

 <!---
 <cfset local.result = query2array(local.q)>
 --->

 <cfset local.result = {
   "records": query2array(local.q)[1],
   "success": true
 }>

 <cfreturn local.result>

</cffunction>


<cffunction name="insertData" access="package" returntype="numeric">

  <cfargument name="clientname" required="true" type="string">

  <cftransaction>
   <cfquery>
    insert into client (clientname,idcompany,updateuser,begintime,updatedate)
    values (
     <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.clientname#">,
     <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">,
     <cfqueryparam cfsqltype="cf_sql_varchar"  value="#session.username#">,
     <cfqueryparam cfsqltype="cf_sql_timestamp"
          value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">,
     <cfqueryparam cfsqltype="cf_sql_timestamp"
          value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">
    )
   </cfquery>
  
   <cfquery name="local.getlast">
    select LAST_INSERT_ID() as lastid
    from client
   </cfquery>
 
 </cftransaction>

  <cfreturn local.getlast.lastid>
</cffunction>

<cffunction  name="createRecord" access="remote" returntype="struct" httpMethod="post">

 <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>

 <cfset local.newId = insertData(requestdata.clientname)>
 
 <cfreturn {"success"="true", "id" = local.newId, "data": toString(getHttpRequestData().content)}>

</cffunction>


<cffunction 
  name="updateRecord"
  access="remote"
  returntype="struct"
  httpMethod="PUT" 
  restpath = "{id}"
  roles="Admin,SuperAdmin">

  <cfargument name="id" required="yes" restargsource="Path" />

  <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>

  <cfquery>
    update client 
    set clientname = <cfqueryparam 
                      cfsqltype="cf_sql_varchar"   
                      value="#requestdata.clientName#">,
        updateuser = <cfqueryparam 
                      cfsqltype="cf_sql_varchar"   
                      value="#session.username#">,

        updatedate = <cfqueryparam 
          cfsqltype="cf_sql_timestamp"
          value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">

    where id = <cfqueryparam 
                      cfsqltype="cf_sql_numeric"
                      value="#arguments.id#">

  </cfquery>
    
  <cfreturn {success="true", id = arguments.id}>

</cffunction>

<cffunction 
  name="deleteRecord"
  access="remote"
  returntype="struct"
  httpMethod="delete"
  restpath="{id}"
  roles="Admin,SuperAdmin">

 <cfargument
  name="id"
  required="true"
  restargsource="Path"
  type="numeric" />

 <cfquery>
  update client
  set endtime = <cfqueryparam cfsqltype="cf_sql_timestamp"
          value="#dateformat(now(),'mm/dd/yyyy')# #timeformat(now())#">,
      updateuser = <cfqueryparam 
                      cfsqltype="cf_sql_varchar"   
                      value="#session.username#">
  where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
 </cfquery>
    
 <cfreturn {
     success="true",
     id="#arguments.id#",
     operation="delete"
    }
  >
  </cffunction>

</cfcomponent>