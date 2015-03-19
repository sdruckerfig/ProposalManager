<cfcomponent rest="true" restpath="WinRate" extends="base"> 


<cffunction name="getstats" access="remote" returntype="array" httpmethod="GET">
  <cfargument name="filter" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="sort" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="limit" required="false" type="numeric" default="100" restargsource="query">
  <cfargument name="start" required="false" type="numeric" default="1"   restargsource="query">
  
  <cfset var qtotal =  "">
  <cfset var qwins = "">
  <cfset var stData = structnew()>
  <cfset var aResult = []>
  <cfset var thisitem = "">

  <cfquery name="qTotal">
    select count(*) as total, date_format(dateDue,'%Y-%m') as month
    from asset
    where idCompany = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">
    and idAssetType = 1
    and asset.endtime is null
    and dateDue is not null
    group by date_format(dateDue,'%Y-%m')
  </cfquery>

  <cfquery name="qWins">
    select count(*) as wins, date_format(dateDue,'%Y-%m') as month
    from asset
    where idCompany = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">
    and idAssetType = 1
    and asset.endtime is null
    and dateDue is not null
    and bWin = 1
    group by date_format(dateDue,'%Y-%m')
  </cfquery>

  <cfloop query="qTotal">
    <cfset stData[qtotal.month] = {
      "month" = qtotal.month,
      "total" = qtotal.total,
      "wins" = 0
    }>
  </cfloop>

  <cfloop query="qWins">
    <cfset stData[qWins.month]["wins"] = qWins.wins>
  </cfloop>

  <cfloop collection="#stData#" item="thisItem">
    <cfset arrayAppend(aResult,stdata[thisitem])>
  </cfloop>


  <cfreturn aResult>

 </cffunction>

 </cfcomponent> 

 