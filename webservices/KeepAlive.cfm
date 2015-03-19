<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json">
<cfif isdefined("session.iduser")>
	<cfoutput>{"success": true, "username": "#session.username#", "userrole" : #session.idrole#, "idcompany" : #session.idcompany#, "id" : #session.iduser#}</cfoutput>
<cfelse>
 <cfoutput>{"success" : false}</cfoutput>
</cfif>

