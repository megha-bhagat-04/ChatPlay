<%--
    Document   : admin_dashboard
    Author     : meghabhagat
--%>
<%@ page import="java.sql.*, com.chatapp.DBConnection" %>
<%
if(session.getAttribute("user_id") == null || !"admin".equalsIgnoreCase((String)session.getAttribute("role"))){
    response.sendRedirect("login.jsp");
    return;
}

int adminId = (int) session.getAttribute("user_id");
Connection con = DBConnection.getConnection();
String action = request.getParameter("action");
String targetId = request.getParameter("uid");

if("ban".equals(action) && targetId != null){
    PreparedStatement ps = con.prepareStatement("UPDATE users SET status='banned' WHERE user_id=?");
    ps.setInt(1, Integer.parseInt(targetId));
    ps.executeUpdate();
} else if("unban".equals(action) && targetId != null){
    PreparedStatement ps = con.prepareStatement("UPDATE users SET status='active' WHERE user_id=?");
    ps.setInt(1, Integer.parseInt(targetId));
    ps.executeUpdate();
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Dashboard – ChatPlay</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
  :root { --bg: #f8fafc; --sidebar: #1e293b; --accent: #6366f1; --white: #ffffff; --text: #1e293b; --muted: #64748b; }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); display: flex; min-height: 100vh; }
  .sidebar { width: 260px; background: var(--sidebar); color: #fff; padding: 30px 20px; display: flex; flex-direction: column; }
  .sidebar h1 { font-size: 20px; font-weight: 700; margin-bottom: 40px; display: flex; align-items: center; gap: 10px; }
  .nav-item { padding: 12px 15px; border-radius: 8px; color: #cbd5e1; text-decoration: none; display: flex; align-items: center; gap: 12px; margin-bottom: 5px; transition: 0.2s; }
  .nav-item:hover, .nav-item.active { background: rgba(255,255,255,0.1); color: #fff; }
  .main { flex: 1; padding: 40px; }
  .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
  .card { background: var(--white); border-radius: 12px; padding: 25px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); margin-bottom: 25px; }
  table { width: 100%; border-collapse: collapse; }
  th { text-align: left; color: var(--muted); font-size: 12px; text-transform: uppercase; padding-bottom: 15px; border-bottom: 1px solid #e2e8f0; }
  td { padding: 15px 0; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
  .status { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; }
  .status-active { background: #dcfce7; color: #166534; }
  .status-banned { background: #fee2e2; color: #991b1b; }
  .btn { padding: 6px 12px; border-radius: 6px; font-size: 13px; cursor: pointer; border: none; font-weight: 500; }
  .btn-ban { background: #fee2e2; color: #dc2626; }
  .btn-unban { background: #dcfce7; color: #16a34a; }
</style>
</head>
<body>
  <div class="sidebar">
    <h1><i class="fas fa-shield-halved"></i> ChatPlay Admin</h1>
    <a href="admin_dashboard.jsp?tab=users" class="nav-item <%= !"reports".equals(request.getParameter("tab")) ? "active" : "" %>"><i class="fas fa-users"></i> Users</a>
    <a href="admin_dashboard.jsp?tab=reports" class="nav-item <%= "reports".equals(request.getParameter("tab")) ? "active" : "" %>"><i class="fas fa-flag"></i> Reports</a>
    <a href="LogoutServlet" class="nav-item" style="margin-top:auto;"><i class="fas fa-sign-out-alt"></i> Logout</a>
  </div>
  <div class="main">
    <% String tab = request.getParameter("tab"); %>
    <div class="header">
      <h2><%= "reports".equals(tab) ? "Abuse Reports" : "User Management" %></h2>
      <div class="admin-profile">Welcome, <%= session.getAttribute("username") %></div>
    </div>
    
    <div class="card">
      <% if("reports".equals(tab)) { %>
        <table>
          <thead>
            <tr>
              <th>Reported User</th>
              <th>Reported By</th>
              <th>Reason</th>
              <th>Time</th>
            </tr>
          </thead>
          <tbody>
            <%
            PreparedStatement psR = con.prepareStatement(
                "SELECT r.*, u1.username as reported, u2.username as reporter " +
                "FROM reports r JOIN users u1 ON r.reported_user = u1.user_id " +
                "JOIN users u2 ON r.reported_by = u2.user_id ORDER BY r.timestamp DESC"
            );
            ResultSet rsR = psR.executeQuery();
            while(rsR.next()){
            %>
            <tr>
              <td><strong><%= rsR.getString("reported") %></strong></td>
              <td><%= rsR.getString("reporter") %></td>
              <td><%= rsR.getString("reason") %></td>
              <td style="color:var(--muted); font-size:12px;"><%= rsR.getTimestamp("timestamp") %></td>
            </tr>
            <% } %>
          </tbody>
        </table>
      <% } else { %>
        <table>
          <thead>
            <tr>
              <th>User</th>
              <th>Email</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <%
            PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE role != 'admin'");
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                String status = rs.getString("status");
            %>
            <tr>
              <td><strong><%= rs.getString("username") %></strong></td>
              <td><%= rs.getString("email") %></td>
              <td><span class="status status-<%= status %>"><%= status %></span></td>
              <td>
                <% if("active".equals(status)){ %>
                  <a href="admin_dashboard.jsp?action=ban&uid=<%= rs.getInt("user_id") %>" class="btn btn-ban">Ban</a>
                <% } else { %>
                  <a href="admin_dashboard.jsp?action=unban&uid=<%= rs.getInt("user_id") %>" class="btn btn-unban">Unban</a>
                <% } %>
              </td>
            </tr>
            <% } %>
          </tbody>
        </table>
      <% } %>
    </div>
  </div>
</body>
</html>
