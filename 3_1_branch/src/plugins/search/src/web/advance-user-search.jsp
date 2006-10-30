<%@ page import="java.util.*,
				 java.net.URLEncoder,
				 org.jivesoftware.util.*,
				 org.jivesoftware.wildfire.PresenceManager,
                 org.jivesoftware.wildfire.user.*,
                 org.jivesoftware.wildfire.XMPPServer,
                 org.xmpp.packet.Presence"
%>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/fmt_rt" prefix="fmt" %>

<html>
    <head>
        <title>User Search</title>
        <meta name="pageID" content="advance-user-search"/>
    </head>
    <body>

<%
    String criteria = ParamUtils.getParameter(request, "criteria");
    boolean moreOptions = ParamUtils.getBooleanParameter(request, "moreOptions", false);

    UserManager userManager = UserManager.getInstance();
    Set<String> searchFields = userManager.getSearchFields();
    List<String> selectedFields = new ArrayList<String>();

    Set<User> users = new HashSet<User>();

    if (criteria != null) {
        for (String searchField : searchFields) {

            boolean searchValue = ParamUtils.getBooleanParameter(request, searchField, false);
            if (!moreOptions || searchValue) {
                selectedFields.add(searchField);
                Collection<User> foundUsers = userManager.findUsers(new HashSet<String>(Arrays.asList(searchField)), criteria);

                for (User user : foundUsers) {
                    if (user != null) {
                        users.add(user);
                    }
                }
            }
        }
    }
%>

<form name="f" action="advance-user-search.jsp">
    <input type="hidden" name="search" value="true"/>
    <input type="hidden" name="moreOptions" value="<%=moreOptions %>"/>
    <fieldset>
        <legend><fmt:message key="user.search.search_user" /></legend>
        <div>
        <table cellpadding="3" cellspacing="1" border="0" width="600">    
        <tr class="c1">
            <td width="1%" colspan="2" nowrap>
                Search:
                &nbsp;<input type="text" name="criteria" value="<%=(criteria != null ? criteria : "") %>" size="30" maxlength="75"/>
                &nbsp;<input type="submit" name="search" value="<fmt:message key="user.search.search" />"/>
	        </td>
        </tr>
        <% if (moreOptions) { %>
        <tr class="c1">
            <td width="1%" colspan="2" nowrap>Wildcard (*) characters are allowed as part the of query. The following fields are available for searching:</td>
        </tr>
			
        <% for (String searchField : searchFields) { %>
        <tr class="c1">
            <td width="1%" nowrap><%=searchField %>:</td>
            <td class="c2">
            <% if (criteria == null) { %>
                <input type="checkbox" checked name="<%=searchField %>"/>
		        
            <% } else { %>
                <input type="checkbox" <%=selectedFields.contains(searchField) ? "checked" : "" %> name="<%=searchField %>"/>
		        
            <% } %>
            </td>
        </tr>
        <% } %>
        <tr>
            <td nowrap>&raquo;&nbsp;<a href="advance-user-search.jsp?moreOptions=false">Less Options</a></td>
        </tr>
        <% } else { %>
        <tr>
            <td nowrap>&raquo;&nbsp;<a href="advance-user-search.jsp?moreOptions=true">More Options</a></td>
        </tr>
        <% } %>
        </table>
        </div>
    </fieldset>
</form>	

<% if (criteria != null) { %>
<p>
Users Found: <%=users.size() %>
</p>

<div class="jive-table">
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<thead>
    <tr>
        <th>&nbsp;</th>
        <th nowrap><fmt:message key="session.details.online" /></th>
        <th nowrap><fmt:message key="user.create.username" /></th>
        <th nowrap><fmt:message key="user.create.name" /></th>
        <th nowrap><fmt:message key="user.summary.created" /></th>
        <%  // Don't allow editing or deleting if users are read-only.
            if (!UserManager.getUserProvider().isReadOnly()) { %>
        <th nowrap><fmt:message key="user.summary.edit" /></th>
        <th nowrap><fmt:message key="global.delete" /></th>
        <% } %>
    </tr>
</thead>
<tbody>

    <% if (users.isEmpty()) { %>
    <tr>
        <td align="center" colspan="7"><fmt:message key="user.summary.not_user" /></td>
    </tr>
	    
    <% 
    } else {
       int i = 0;
       PresenceManager presenceManager = XMPPServer.getInstance().getPresenceManager();
	    
       for (User user : users) {
           i++;
    %>
    <tr class="jive-<%= (((i%2)==0) ? "even" : "odd") %>">
        <td width="1%">
            <%= i %>
        </td>
        <td width="1%" align="center" valign="middle">
        <% if (presenceManager.isAvailable(user)) {
               Presence presence = presenceManager.getPresence(user);
               
               if (presence.getShow() == null) { 
               %> <img src="images/user-green-16x16.gif" width="16" height="16" border="0" alt="<fmt:message key="user.properties.available" />"> <% 
               } 
               
               if (presence.getShow() == Presence.Show.chat) {
               %> <img src="images/user-green-16x16.gif" width="16" height="16" border="0" alt="<fmt:message key="session.details.chat_available" />"> <% 
               }
               
               if (presence.getShow() == Presence.Show.away) { 
               %> <img src="images/user-yellow-16x16.gif" width="16" height="16" border="0" alt="<fmt:message key="session.details.away" />"> <% 
               } 
               
               if (presence.getShow() == Presence.Show.xa) { 
               %> <img src="images/user-yellow-16x16.gif" width="16" height="16" border="0" alt="<fmt:message key="session.details.extended" />"> <% 
               } 
               
               if (presence.getShow() == Presence.Show.dnd) { 
               %> <img src="images/user-red-16x16.gif" width="16" height="16" border="0" alt="<fmt:message key="session.details.not_disturb" />"> <% 
               }
           } else { 
           %> <img src="images/user-clear-16x16.gif" width="16" height="16" border="0" alt="<fmt:message key="user.properties.offline" />"> <% 
           }
        %>
       </td>
       <td width="30%">
           <a href="../../user-properties.jsp?username=<%= URLEncoder.encode(user.getUsername(), "UTF-8") %>"><%= user.getUsername() %></a>
       </td>
       <td width="35">
           <%= user.getName() %> &nbsp;
       </td>
       <td width="35%">
           <%= user.getEmail() %> &nbsp;
       </td>
        <%  // Don't allow editing or deleting if users are read-only.
            if (!UserManager.getUserProvider().isReadOnly()) { %>
       <td width="1%" align="center">
           <a href="../../user-edit-form.jsp?username=<%= URLEncoder.encode(user.getUsername(), "UTF-8") %>"
              title="<fmt:message key="global.click_edit" />"
              ><img src="images/edit-16x16.gif" width="17" height="17" border="0"></a>
       </td>
       <td width="1%" align="center" style="border-right:1px #ccc solid;">
           <a href="../../user-delete.jsp?username=<%= URLEncoder.encode(user.getUsername(), "UTF-8") %>"
              title="<fmt:message key="global.click_delete" />"
              ><img src="images/delete-16x16.gif" width="16" height="16" border="0"></a>
       </td>
       <% } %>
   </tr>
<%
        }
    }
%>

</tbody>
</table>
</div>

<% } %>

<script language="JavaScript" type="text/javascript">
document.f.criteria.focus();
</script>

</body>
</html>