<%-- 
    Document   : friendRequests
    Created on : 08-Apr-2026, 9:40:50?pm
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
    "SELECT f.id, u.username FROM friends f " +
    "JOIN users u ON f.user_id = u.user_id " +
    "WHERE f.friend_id=? AND f.status='pending'"
);

ps.setInt(1, userId);

ResultSet rs = ps.executeQuery();
%>

<h2>Friend Requests</h2>

<%
while(rs.next()){
%>
    <div>
        <%= rs.getString("username") %>
        <a href="AcceptRequestServlet?id=<%= rs.getInt("id") %>">Accept</a>
    </div>
<%
}
%>

<br><a href="dashboard.jsp">Back</a>