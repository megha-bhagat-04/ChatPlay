<%-- 
    Document   : friendsList
    Created on : 08-Apr-2026, 9:41:54?pm
    Author     : meghabhagat
--%>

<%@ page import="java.sql.*, com.chatapp.DBConnection" %>

<%
Integer userIdObj = (Integer) session.getAttribute("user_id");

if(userIdObj == null){
    response.sendRedirect("login.jsp");
    return;
}

int userId = userIdObj;

Connection con = DBConnection.getConnection();

PreparedStatement ps = con.prepareStatement(
    "SELECT DISTINCT u.username FROM friends f " +
    "JOIN users u ON (u.user_id = f.friend_id AND f.user_id=?) " +
    "OR (u.user_id = f.user_id AND f.friend_id=?) " +
    "WHERE f.status='accepted'"
);

ps.setInt(1, userId);
ps.setInt(2, userId);

ResultSet rs = ps.executeQuery();
%>

<h2>My Friends</h2>
<%
while(rs.next()){
%>
    <div>
        <a href="chat.jsp?friend=<%= rs.getString("username") %>">
            <%= rs.getString("username") %>
        </a>
    </div>
<%
}
%>

<br><a href="dashboard.jsp">Back</a>