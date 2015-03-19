<cfcomponent 
  rest="true" 
  restpath="Companies"
  extends="base"> 

<cffunction name="GetAll" roles="Admin,SuperAdmin" access="remote" httpmethod="GET" returntype="struct">
 
  <cfargument name="filter" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="sorter" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="limit" required="false" type="numeric" default="100" restargsource="query">
  <cfargument name="start" required="false" type="numeric" default="1"   restargsource="query">
  
 
  <cfquery name="local.qCount">
    select count(*) as thecount
    from company
    where endtime is null
    <cfif session.idRole is 1>
      and id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">
    </cfif>
  </cfquery>

  <cfquery name="local.data">
    select *
    from company
    where endtime is null
    <cfif session.idRole is 1>
      and id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">
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
            roles="Admin,SuperAdmin">
  
 <cfargument name="id" type="string" required="true" restargsource="Path">

 <cfquery name="local.q">
   select *
   from company
   where id = <cfqueryparam 
        cfsqltype="cf_sql_numeric"
        value="#arguments.Id#">
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


<cffunction 
   name="createRecord"
   access="remote"
   returntype="struct"
   httpMethod="post"
   roles="SuperAdmin">

 <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>

 <cftransaction>
   <cfquery>
    insert into company (companyName,updateuser,begintime,updatedate)
    values (
     <cfqueryparam cfsqltype="cf_sql_varchar"
          value="#requestdata.companyname#">,
      <cfqueryparam cfsqltype="cf_sql_varchar"
          value="#session.username#">,
     <cfqueryparam cfsqltype="cf_sql_timestamp"
          value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">,
     <cfqueryparam cfsqltype="cf_sql_timestamp"
          value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">
    )
   </cfquery>
  
   <cfquery name="local.getlast">
    select LAST_INSERT_ID() as lastid
    from company
   </cfquery>
 
 </cftransaction>

 
 <cfreturn {"success"="true", "id" = local.getlast.lastid, "data": toString(getHttpRequestData().content)}>

</cffunction>


<cffunction 
  name="updateRecord"
  access="remote"
  returntype="struct"
  httpMethod="PUT" 
  restpath = "{id}"
  roles="SuperAdmin">

  <cfargument 
  name="id"
  required="yes"
  restargsource="Path" />

  <cflog file="putlog" text="called with id #arguments.id#">

  <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>

  <cfquery>
    update company
    set companyname = <cfqueryparam 
                      cfsqltype="cf_sql_varchar"   
                      value="#requestdata.companyName#">,
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
    
  <cfreturn {"success"="true", "id" = arguments.id}>

</cffunction>

<cffunction 
  name="deleteRecord"
  access="remote"
  returntype="struct"
  httpMethod="delete"
  restpath="{id}"
  roles="SuperAdmin">

 <cfargument
  name="id"
  required="true"
  restargsource="Path"
  type="numeric" />

 <cfquery>
  update company
  set endtime = <cfqueryparam cfsqltype="cf_sql_timestamp"
          value="#dateformat(now(),'mm/dd/yyyy')# #timeformat(now())#">,
      updateuser = <cfqueryparam 
                      cfsqltype="cf_sql_varchar"   
                      value="#session.username#">
  where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.id#">
 </cfquery>
    
 <cfreturn {
     "success"="true",
     "id"="#arguments.id#",
     "operation"="delete"
    }
  >
  </cffunction>

</cfcomponent>