<cfcomponent 
  rest="true" 
  restpath="Assets"
  extends="base"> 

<cffunction name="GetAll" roles="Admin,SuperAdmin,User" access="remote" httpmethod="GET" returntype="struct">
 
  <cfargument name="filter" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="sort" required="false" type="string" default="[]"  restargsource="query">
  <cfargument name="limit" required="false" type="numeric" default="100" restargsource="query">
  <cfargument name="start" required="false" type="numeric" default="1"   restargsource="query">
  
  <cfset var sorters = deserializeJSON(arguments.sort)>
  <cfset var filters = deserializeJSON(arguments.filter)>
  <cfset var thisfilter = "">
  <cfset var thisbitmask = "">
  <cfset var loc = "">

  <cfif arraylen(sorters) gt 0 and sorters[1].property is "assettype">
    <cfset sorters[1].property = "assetType.text">  
  </cfif>


  <cfquery name="local.qCount">
    select count(*) as thecount
    from asset
    where endtime is null
    and idCompany = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">

    <cfloop array="#filters#" index="thisFilter">
      <cfswitch expression="#thisfilter.property#">
        
        <cfcase value="idassettype">
          and idAssetType = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisfilter.value#">
        </cfcase>

        <cfcase value="idclient">
          and idClient = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisfilter.value#">
        </cfcase>
        
        <cfcase value="taxonomyterms">
           
           <!--- get bitmasks for selected terms --->
           <cfquery name="local.bitmasks">
            select bitmask
            from taxonomy
            where id in (<cfqueryparam cfsqltype="cf_sql_numeric" value="#thisfilter.value#" list="true">)
           </cfquery>
          
           <!--- convert to list --->
           <cfset local.lBitmasks = valuelist(local.bitmasks.bitmask)>

           <!--- apply subqueries --->
           <cfloop list="#local.lBitmasks#" index="thisbitmask">
              <cfset loc = find("00",thisbitmask)>
              <cfif loc is not 0>
                <cfset thisbitmask = left(thisbitmask,loc - 1)>
              </cfif>
              and asset.id in (
                select assetid 
                from assetterm inner join taxonomy 
                  on assetterm.termid = taxonomy.id 
                where taxonomy.bitmask like <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisbitmask#%">
              )
           </cfloop>

        </cfcase>

        <cfcase value="searchterm">
          and match(title,description,fullContent) against (<cfqueryparam cfsqltype="cf_sql_varchar" value="#thisfilter.value#">)
        </cfcase>
      </cfswitch>
    </cfloop>

  </cfquery>

  <cfquery name="local.data">
    select asset.id, 
          asset.title, 
          asset.description, 
          asset.datedue,
          asset.contentUrl, 
          asset.updatedate,
          asset.updateuser,
          assetType.text as assetType,
          client.clientName
    from asset inner join assetType
      on asset.idAssetType = assetType.id
      left join client on 
        asset.idclient = client.id 

    where asset.endtime is null
    and asset.idCompany = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">

    <cfloop array="#filters#" index="thisFilter">
      <cfswitch expression="#thisfilter.property#">
        <cfcase value="idassettype">
          and idAssetType = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisfilter.value#">
        </cfcase>
        <cfcase value="idclient">
          and idClient = <cfqueryparam cfsqltype="cf_sql_numeric" value="#thisfilter.value#">
        </cfcase>

        <cfcase value="taxonomyterms">

           <cfloop list="#local.lbitmasks#" index="thisbitmask">
              <cfset loc = find("00",thisbitmask)>
              <cfif loc is not 0>
                <cfset thisbitmask = left(thisbitmask,loc - 1)>
              </cfif>
              and asset.id in (
                select assetid 
                from assetterm inner join taxonomy 
                  on assetterm.termid = taxonomy.id 
                where taxonomy.bitmask like <cfqueryparam cfsqltype="cf_sql_varchar" value="#thisbitmask#%">
              )
           </cfloop>

        </cfcase>
        <cfcase value="searchterm">
          and match(title,description,fullContent) against (<cfqueryparam cfsqltype="cf_sql_varchar" value="#thisfilter.value#">)
        </cfcase>
      </cfswitch>
    </cfloop>

    <cfif arraylen(sorters) gt 0>
      <cfif listfind("ASC,DESC", sorters[1].direction) gt 0 and listfind("updateuser,updatedate,title,assetType.text",sorters[1].property) gt 0>
           order by #sorters[1].property# #sorters[1].direction#
      <cfelse>
        <cfthrow message="Invalid sorter">
      </cfif>
    </cfif>
    limit #val(arguments.start)#, #val(arguments.limit)#
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

 <cfset var result = "">

 <cfquery name="local.q">
   select asset.*, filename as fileurl, client.clientName, '' as tags
   from asset left join client 
    on asset.idClient = client.id
   where asset.id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.Id#">
    and asset.endtime is null
    and asset.idCompany = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">
 </cfquery>

 <cfquery name="local.tags">
   select tagid
   from assetTag inner join tag 
   on assetTag.tagid = tag.id 
   where 
     assettag.assetid = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.Id#">
     and tag.idUser = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idUser#">
     and tag.endtime is null
 </cfquery>

 <cfset result = query2array(local.q)[1]>
 <cfset result["tags"] =  listToArray(valuelist(local.tags.tagid))>
 
<!---
 <cfset local.result = {
   "records": result,
   "success": true
 }>
 --->

 <cfreturn result>

</cffunction>


<cffunction name="handletags" access="private" returntype="void">
  <cfargument name="aTags" type="array" required="true">
  <cfargument name="assetId" type="numeric" required="true">

  <cfset var thistag = "">
  <cfset var i = "">
  <cfset var cfcTags = createObject("component","tag")>

  <cfquery>
    delete
    from assettag
    where assetid = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.assetid#">
    and tagid in (
      select id
      from tag
      where idUser = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idUser#">
    )
  </cfquery>

  <cfloop array="#arguments.aTags#" index="thistag">
    <cfif not isnumeric(thistag)>
      <cfset thistag = cfcTags.insertData(thistag)>
    </cfif>
    <cfquery>
      insert into assetTag (assetId,tagid)
      values (
        <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.assetid#">,
        <cfqueryparam cfsqltype="cf_sql_numeric" value="#thistag#">
      )
    </cfquery>
  </cfloop>
</cffunction>


<cffunction  name="createRecord" access="remote" returntype="struct" httpMethod="post" roles="User,Admin,SuperAdmin">

 <cfset var rd = deserializeJson(toString(getHttpRequestData().content))>
 <cfset var stResult = "">

 <cfif isdefined('rd.bWin') and rd.bWin>
   <cfset local.bWin = 1>
 <cfelse>
   <cfset local.bWin = 0>
 </cfif>

 <cfif isdefined("rd.idclient") and not isNumeric(rd.idclient) and trim(rd.idClient) is not "">
   <cfset cfcClient = createObject("component","Clients")>
   <cfset rd.idClient = cfcClient.insertData(rd.idClient)>
 </cfif>

 <cftransaction>
   <cfquery result="stResult">
    insert into asset (
      <cfif isdefined("rd.datedue")>
      datedue,
      </cfif>
      <cfif isdefined("rd.fullcontent")>
         fullcontent,
      </cfif>
      <cfif isdefined("rd.title")>
      title,
      </cfif>
      <cfif isdefined("rd.idAssetType")>
      idAssetType,
      </cfif>
      <cfif isdefined("rd.idClient")>
      idClient,
      </cfif>
      <cfif isdefined("rd.description")>
      description,
      </cfif>
      <cfif isdefined("rd.bWin")>
      bWin,
      </cfif>
      <cfif isdefined("rd.contenturl")>
      contentUrl,
      </cfif>
      ownerId,
      idCompany,
      updateuser,
      begintime,
      updatedate
    )
    values (

      <cfif isdefined("rd.datedue")>
        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#rd.datedue#">,
      </cfif>

       <cfif isdefined("rd.fullcontent")>
        <cfqueryparam cfsqltype="cf_sql_varchar" value="#rd.fullcontent#">,
       </cfif>
      
      <cfif isdefined("rd.title")>
        <cfqueryparam cfsqltype="cf_sql_varchar" value="#rd.title#">,
      </cfif>

      <cfif isdefined("rd.idAssetType")>
        <cfqueryparam cfsqltype="cf_sql_numeric" value="#rd.idAssetType#">,
      </cfif>

      <cfif isdefined("rd.idClient")>
        <cfqueryparam cfsqltype="cf_sql_numeric" value="#rd.idClient#">,
      </cfif>
     
      <cfif isdefined("rd.description")>
        <cfqueryparam cfsqltype="cf_sql_varchar" value="#rd.description#">,
      </cfif>

      <cfif isdefined("rd.bWin")>
        <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.bWin#">,
      </cfif>
     
      <cfif isdefined("rd.contenturl")>
        <cfqueryparam cfsqltype="cf_sql_varchar" value="#rd.contentUrl#">,
      </cfif>

      <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idUser#">,
      <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.idCompany#">,
      <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.username#">,
      <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">,
      <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">
  
    )
   </cfquery>
  
   

   <cfif isdefined("rd.taxonomy")>
      <cfloop list="#rd.taxonomy#" index="thispk">
        <cfquery>
          insert into assetterm (assetid,termid)
          values (
            <cfqueryparam  cfsqltype="cf_sql_numeric" value="#arguments.id#">,
            <cfqueryparam  cfsqltype="cf_sql_numeric" value="#thispk#">
          )
        </cfquery>
      </cfloop>
    </cfif>

    <cfif isdefined("rd.tags")>
      <cfset handleTags(rd.tags, stresult.GENERATED_KEY)>
    </cfif>
 
 </cftransaction>

 
 <cfreturn {"success"="true", "id" = stresult.GENERATED_KEY}>

</cffunction>


<cffunction 
  name="updateRecord"
  access="remote"
  returntype="struct"
  httpMethod="PUT" 
  restpath = "{id}"
  roles="User,Admin,SuperAdmin">

  <cfargument 
  name="id"
  required="yes"
  restargsource="Path" />

  <cflog file="putlog" text="called with id #arguments.id#">

  <cfset var rd = deserializeJson(toString(getHttpRequestData().content))>
  <cfset var thispk = "">

 <cfif isdefined('rd.bWin') and rd.bWin>
   <cfset local.bWin = 1>
 <cfelse>
   <cfset local.bWin = 0>
 </cfif>

 
 <cfif isdefined("rd.idclient") and not isNumeric(rd.idclient) and trim(rd.idClient) is not "">
   <cfset cfcClient = createObject("component","Clients")>
   <cfset rd.idClient = cfcClient.insertData(rd.idClient)>
 </cfif>

 <cftransaction>
  
   <cfquery>
    update asset 
    set 
      <cfif isdefined("rd.fullcontent")>
         fullcontent =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#rd.fullcontent#">,
      </cfif>
      <cfif isdefined("rd.title")>
      title =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#rd.title#">,
      </cfif>
      <cfif isdefined("rd.idAssetType")>
      idAssetType = <cfqueryparam cfsqltype="cf_sql_numeric" value="#rd.idAssetType#">,
      </cfif>
      <cfif isdefined("rd.idClient")>
      idClient =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#rd.idClient#">,
      </cfif>
      <cfif isdefined("rd.description")>
      description =   <cfqueryparam cfsqltype="cf_sql_varchar" value="#rd.description#">,
      </cfif>
      <cfif isdefined("rd.bWin")>
      bWin =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.bWin#">,
      </cfif>
      <cfif isdefined("rd.contenturl")>
      contentUrl = <cfqueryparam cfsqltype="cf_sql_varchar" value="#rd.contentUrl#">,
      </cfif>
      <cfif isdefined("rd.datedue")>
         datedue =  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#rd.datedue#">,
      </cfif>
      updateuser =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#session.username#">,
      updatedate =  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateformat(now(),"mm/dd/yyyy")# #timeformat(now())#">
  
    where id = <cfqueryparam  cfsqltype="cf_sql_numeric" value="#arguments.id#">

  </cfquery>

  <cfif isdefined("rd.taxonomy")>
    <cfquery>
      delete from assetterm where assetId = <cfqueryparam  cfsqltype="cf_sql_numeric" value="#arguments.id#">
    </cfquery>
    <cfloop list="#rd.taxonomy#" index="thispk">
      <cfquery>
        insert into assetterm (assetid,termid)
        values (
          <cfqueryparam  cfsqltype="cf_sql_numeric" value="#arguments.id#">,
          <cfqueryparam  cfsqltype="cf_sql_numeric" value="#thispk#">
        )
      </cfquery>
    </cfloop>
  </cfif>

  <cfif isdefined("rd.tags")>
    <cfset handleTags(rd.tags, arguments.id)>
  </cfif>

  </cftransaction>
    
  <cfreturn {"success"="true", "id" = arguments.id}>

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
  update asset
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