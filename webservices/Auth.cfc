<cfcomponent rest="true" restpath="Auth" extends="base"> 

<cffunction name="logout" access="remote" httpMethod="delete" returntype="struct">
    
   <cfset session.role = "">
   <cfset session.username = "">
   <cflogout>

   <cfreturn {"success" = true}>
</cffunction>

<cffunction name="loginuser" access="remote" returntype="struct" httpmethod="POST">

  <cfset var requestData = deserializeJson(toString(getHttpRequestData().content))>

  <cfquery name="local.data">
    select AppUser.*, 
          company.companyName, 
          UserRole.label as rolename
    from AppUser join Company
    on AppUser.idCompany = Company.id 
    join UserRole
      on AppUser.idRole = UserRole.id 
    where AppUser.endtime is null
    and Company.endtime is null
    and username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#requestdata.username#">
    and password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#requestdata.password#">
  </cfquery>

 <cfif local.data.recordcount is 1>
   <cfset session.role = local.data.rolename>
   <cfset session.idRole = local.data.idRole> 
 	 <cfset session.username = requestdata.username>
   <cfset session.idCompany = local.data.idCompany>
   <cfset session.idUser = local.data.id>
 	 <cflogin>
 	 	<cfloginuser name="#local.data.rolename#" 
 	 			password="#requestdata.password#"
 	 			roles="#local.data.rolename#">
 	 			
 	 </cflogin>
     <cfreturn query2Array(local.data)[1]>
  <cfelse>
      <cfreturn {"success" = false, "id" = 0}>
  </cfif>

 </cffunction>

 </cfcomponent> 

 