<cfcomponent>
  <cfset this.name = "ProposalManager">
  <cfset this.sessionmanagement = true>

  <cfset this.datasource="ProposalManager">
  
  <cffunction name="onApplicationStart">
	<cfset restInitApplication(
	       getDirectoryFromPath(getCurrentTemplatePath()),
	       this.name
	 )>
  </cffunction>
  
  <cffunction name="onRequestStart">
    
    <cfif isdefined("url.init")>
       <cfset onApplicationStart()>
    </cfif>
  
  </cffunction>
  
</cfcomponent>