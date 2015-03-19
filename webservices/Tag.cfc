<cfcomponent rest="true" restpath="Tags" extends="base"> 

<cffunction name="GetAll" access="remote" httpmethod="GET" returntype="struct" roles="User,Admin,SuperAdmin">
  <cfargument name="query" required="false" type="string" default=""  restargsource="query">
  <cfargument name="filter" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="sorter" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="limit" required="false" type="numeric" default="100" restargsource="query">
  <cfargument name="start" required="false" type="numeric" default="1"   restargsource="query">
  
 
  <cfquery name="local.qCount">
    select count(*) as thecount
    from tag
    where endtime is null
    and idUser = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idUser#">
  </cfquery>

  <cfquery name="local.data">
    select *
    from tag
    where endtime is null
    and idUser = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idUser#">
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
          roles="User,Admin,SuperAdmin">
  
 <cfargument name="id" type="string" required="true" restargsource="Path">

 <cfquery name="local.q">
   select *
   from tag
   where id = <cfqueryparam 
        cfsqltype="cf_sql_numeric"
        value="#arguments.Id#">
    and idUser = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idUser#">
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

  <cfargument name="text" required="true" type="string">

  <cfset var stresult = "">

   <cfquery result="stresult">
    insert into tag (text,idUser,updateuser,begintime,updatedate)
    values (
     <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.text#">,
     <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idUser#">,
     <cfqueryparam cfsqltype="cf_sql_varchar"  value="#session.username#">,
     <cfqueryparam cfsqltype="cf_sql_timestamp"
          value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">,
     <cfqueryparam cfsqltype="cf_sql_timestamp"
          value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">
    )
   </cfquery>

  <cfreturn stResult.GENERATED_KEY>
</cffunction>

<cffunction  name="createRecord" access="remote" returntype="struct" httpMethod="post" roles="User,Admin,SuperAdmin">

 <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>

 <cfset local.newId = insertData(requestdata.text)>
 
 <cfreturn {"success"="true", "id" = local.newId, "data": toString(getHttpRequestData().content)}>

</cffunction>


<cffunction 
  name="updateRecord"
  access="remote"
  returntype="struct"
  httpMethod="PUT" 
  restpath = "{id}"
  roles="User,Admin,SuperAdmin">

  <cfargument name="id" required="yes" restargsource="Path" />

  <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>

  <cfquery>
    update tag 
    set text = <cfqueryparam 
                      cfsqltype="cf_sql_varchar"   
                      value="#requestdata.text#">,
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
  roles="User,Admin,SuperAdmin">

 <cfargument
  name="id"
  required="true"
  restargsource="Path"
  type="numeric" />

 <cfquery>
  update tag
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