<cfcomponent rest="true" restpath="User" extends="base"> 


<cffunction name="MailLogin" access="remote" returntype="struct" roles="Admin,SuperAdmin">
  
  <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>

  <cfquery name="local.getUser">
    select *
    from AppUser
    where id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#requestData.id#">
  </cfquery>

  <cfmail from="sdrucker@figleaf.com"
    to="#local.getUser.email#"
    subject="Your Password">
    
    Your Proposal Manager password is #local.getUser.password#

  </cfmail>

  <cfreturn {"success": true}>
</cffunction>


<cffunction name="GetRecords" access="remote" httpmethod="GET" returntype="struct" roles="Admin,SuperAdmin">
 
  <cfargument name="filter" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="sort" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="limit" required="false" type="numeric" default="100" restargsource="query">
  <cfargument name="start" required="false" type="numeric" default="1"   restargsource="query">
  
  <cfset var thisitem = "">
  <cfset local.filters = deserializeJson(arguments.filter)>
  <cfset local.sorters = deserializeJson(arguments.sort)>

  <cfquery name="local.qCount">
    select count(*) as thecount
    from AppUser join Company
    on AppUser.idCompany = Company.id 
    join userRole on AppUser.idRole = UserRole.id
    where AppUser.endtime is null
          and Company.endtime is null

    <cfloop array="#local.filters#" index="thisitem">
     
      <cfif thisitem.property is "username" 
            or thisitem.property is "email" 
            or thisitem.property is "idcompany" 
            or thisitem.property is "idrole">

         <cfif thisitem.property is "idcompany">
           <cfset thisitem.property = "Company.companyname">
         <cfelseif thisitem.property is "idrole">
           <cfset thisitem.property = "UserRole.label">
         </cfif>  

         <cfif thisitem.property is "UserRole.label">

            <cfset local.searchRoles = listqualify(arrayToList(thisitem.value),"'")>

            and UserRole.label in (
              #preservesinglequotes(local.searchroles)#
            )
         <cfelse>
            and #thisitem.property# like <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisitem.value#%">
         </cfif>
      <cfelse>
        <cfset thisitem.property = "">
      </cfif>
    
    </cfloop>
  </cfquery>

  <cfquery name="local.data" result = "local.stresult">
    select AppUser.*, 
          company.companyName, 
          userRole.label as role

    from AppUser join Company
          on AppUser.idCompany = Company.id 
        join userRole on AppUser.idRole = UserRole.id

    where   AppUser.endtime is null
            and Company.endtime is null
   
    <!--- handle remote filters --->
    <cfloop array="#local.filters#" index="thisitem">
       <cfif thisitem.property is "UserRole.label">
           and UserRole.label in (
              #preservesinglequotes(local.searchroles)#
           )
       <cfelse>
          and #thisitem.property# like <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisitem.value#%">
       </cfif>
    </cfloop>

    <!--- handle remote sorters --->
    <cfif arraylen(local.sorters) gt 0>
      <cfif local.sorters[1].property is "idcompany">
        <cfset local.sorters[1].property = "companyName">
      </cfif>
      <cfif local.sorters[1].property is "idrole">
        <cfset local.sorters[1].property = "userrole.label">
      </cfif>
      order by 
       #local.sorters[1].property# #local.sorters[1].direction#
    </cfif>
  
    LIMIT  #val(arguments.start)#, #val(arguments.limit)#
    
  </cfquery>
 

 <cflog file="q" text="#local.stresult.sql#">

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
            restpath="{id}" roles="Admin,SuperAdmin">
  
 <cfargument name="id" type="string" required="true" restargsource="Path">

 <cfquery name="local.q">
   select AppUser.*, Company.companyName
   from AppUser join Company
   on AppUser.idCompany = Company.id 
   where 
   AppUser.endtime is null
   and Company.endtime is null
   and AppUser.id = <cfqueryparam 
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
   httpMethod="post" roles="Admin,SuperAdmin">

 <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>
 <cfset var randomPwd = "">

 <cfloop from="1" to="6" index="local.i">
   <cfset randomPwd = randomPwd & chr(randrange(65,90))>
 </cfloop>
 <cftransaction>

   <cfquery>
    insert into AppUser (username,password,email,idcompany,idrole,updateuser,updatedate, begintime)
    values (
     <cfqueryparam cfsqltype="cf_sql_varchar"
          value="#requestdata.username#">,
     <cfqueryparam cfsqltype="cf_sql_varchar"
          value="#randomPwd#">,
     <cfqueryparam cfsqltype="cf_sql_varchar"
          value="#requestdata.email#">,
     <cfqueryparam cfsqltype="cf_sql_numeric"
          value="#requestdata.idcompany#">,
     <cfqueryparam cfsqltype="cf_sql_numeric"
          value="#requestdata.idRole#">,
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
    from AppUser
   </cfquery>
 
 </cftransaction>

 <cfmail from="sdrucker@figleaf.com"
 to="#requestdata.email#"
 subject="Your Proposal Manager password">
     Your password is #randomPwd#
 </cfmail>

 <cfreturn {"success"="true", "id" = local.getlast.lastid, "data": toString(getHttpRequestData().content)}>

</cffunction>


<cffunction 
  name="updateRecord"
  access="remote"
  returntype="struct"
  httpMethod="PUT" 
  restpath = "{id}" roles="Admin,SuperAdmin">

  <cfargument 
  name="id"
  required="yes"
  restargsource="Path" />

 
  <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>

  <cfquery>
    update AppUser
    set username = <cfqueryparam 
                      cfsqltype="cf_sql_varchar"   
                      value="#requestdata.username#">,
        
        email = <cfqueryparam 
                      cfsqltype="cf_sql_varchar"   
                      value="#requestdata.email#">,
        idCompany = <cfqueryparam 
                      cfsqltype="cf_sql_numeric"   
                      value="#requestdata.idCompany#">,
        idRole = <cfqueryparam 
                      cfsqltype="cf_sql_numeric"   
                      value="#requestdata.idRole#">,              
        updateuser = <cfqueryparam 
                      cfsqltype="cf_sql_varchar"   
                      value="#session.username#">,
        
        updatedate =  <cfqueryparam cfsqltype="cf_sql_timestamp"
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
  restpath="{id}" roles="Admin,SuperAdmin">

 <cfargument
  name="id"
  required="true"
  restargsource="Path"
  type="numeric" />

 <cfquery>
  update AppUser
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
  }>
</cffunction>

</cfcomponent>