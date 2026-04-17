<%--
    Document   : admin - Monitor reports, ban/unban users
    Author     : meghabhagat
--%>
<%@ page import="java.sql.*, com.chatapp.DBConnection" %>
<%
if(session.getAttribute("user_id") == null){ response.sendRedirect("login.jsp"); return; }
int userId = (int) session.getAttribute("user_id");
String username = (String) session.getAttribute("username");

// You can add an admin role check here; for now all users can view
Connection con = DBConnection.getConnection();
String action = request.getParameter("action");
String targetId = request.getParameter("uid");
String msg = "";

if("ban".equals(action) && targetId != null){
    PreparedStatement psB = con.prepareStatement("UPDATE users SET status='banned' WHERE user_id=?");
    psB.setInt(1, Integer.parseInt(targetId));
    psB.executeUpdate();
    msg = "banned";
} else if("unban".equals(action) && targetId != null){
    PreparedStatement psU = con.prepareStatement("UPDATE users SET status='active' WHERE user_id=?");
    psU.setInt(1, Integer.parseInt(targetId));
    psU.executeUpdate();
    msg = "unbanned";
} else if("resolve".equals(action) && targetId != null){
    PreparedStatement psR = con.prepareStatement("UPDATE reports SET status='resolved' WHERE id=?");
    psR.setInt(1, Integer.parseInt(targetId));
    psR.executeUpdate();
    msg = "resolved";
}

String activeTab = request.getParameter("tab");
if(activeTab == null) activeTab = "reports";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ChatPlay – Admin Panel</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
:root {
  --bg: #0d0f1a; --sidebar-bg: #13162a; --surface: rgba(255,255,255,0.05);
  --border: rgba(255,255,255,0.08); --accent: #6c63ff; --accent2: #f857a6;
  --text: #e4e6f0; --muted: #8892b0; --error: #ff6b6b;
  --success: #43e97b; --warning: #ffd43b; --radius: 14px;
}
body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; display: flex; }
.sidebar {
  width: 240px; background: var(--sidebar-bg); border-right: 1px solid var(--border);
  display: flex; flex-direction: column; position: fixed; left: 0; top: 0; bottom: 0; z-index: 100;
}
.sidebar-logo { padding: 24px 20px 20px; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid var(--border); }
.sidebar-logo .icon { width: 40px; height: 40px; background: linear-gradient(135deg, #6c63ff, #f857a6); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 20px; }
.sidebar-logo span { font-size: 18px; font-weight: 700; }
.sidebar-user { padding: 16px 20px; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid var(--border); margin-bottom: 8px; }
.s-avatar { width: 38px; height: 38px; border-radius: 50%; background: linear-gradient(135deg, #6c63ff, #f857a6); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 15px; }
.nav-section { padding: 0 12px; }
.nav-label { font-size: 10px; font-weight: 600; color: var(--muted); letter-spacing: 1px; text-transform: uppercase; padding: 12px 8px 6px; }
.nav-item { display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: 10px; font-size: 14px; font-weight: 500; color: var(--muted); text-decoration: none; transition: all 0.2s; margin-bottom: 2px; }
.nav-item:hover { background: rgba(108,99,255,0.12); color: var(--text); }
.nav-item.active { background: rgba(108,99,255,0.2); color: var(--accent); }
.nav-item i { width: 18px; text-align: center; }
.sidebar-bottom { margin-top: auto; padding: 16px 12px; border-top: 1px solid var(--border); }

.main { margin-left: 240px; flex: 1; padding: 36px; }
.topbar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; }
.topbar h1 { font-size: 22px; font-weight: 700; display: flex; align-items: center; gap: 10px; }
.admin-badge { background: linear-gradient(135deg, var(--accent2), var(--accent)); border-radius: 6px; font-size: 10px; font-weight: 700; padding: 3px 9px; letter-spacing: 0.5px; }

/* Stats */
.stats-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 14px; margin-bottom: 28px; }
.stat-box { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 18px; }
.stat-box .val { font-size: 28px; font-weight: 700; margin-bottom: 4px; }
.stat-box .lbl { font-size: 12px; color: var(--muted); }

/* Tabs */
.tabs { display: flex; gap: 4px; background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 4px; margin-bottom: 24px; width: fit-content; }
.tab { padding: 8px 18px; border-radius: 8px; font-size: 13px; font-weight: 500; cursor: pointer; text-decoration: none; color: var(--muted); transition: all 0.2s; }
.tab.active { background: var(--accent); color: #fff; }
.tab:hover:not(.active) { color: var(--text); }

/* Table */
.table-wrap { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; }
table { width: 100%; border-collapse: collapse; }
thead { background: rgba(255,255,255,0.04); }
th { padding: 14px 18px; text-align: left; font-size: 11px; font-weight: 600; color: var(--muted); letter-spacing: 0.5px; text-transform: uppercase; border-bottom: 1px solid var(--border); }
td { padding: 14px 18px; font-size: 13px; border-bottom: 1px solid var(--border); vertical-align: middle; }
tr:last-child td { border-bottom: none; }
tr:hover td { background: rgba(255,255,255,0.02); }

.status { display: inline-flex; align-items: center; gap: 4px; font-size: 11px; padding: 3px 10px; border-radius: 20px; font-weight: 600; }
.status-active { background: rgba(67,233,123,0.15); color: var(--success); }
.status-banned { background: rgba(255,107,107,0.15); color: var(--error); }
.status-pending { background: rgba(255,212,59,0.15); color: var(--warning); }
.status-resolved { background: rgba(108,99,255,0.15); color: var(--accent); }

.btn { display: inline-flex; align-items: center; gap: 5px; padding: 6px 14px; border-radius: 8px; font-size: 12px; font-weight: 500; font-family: inherit; cursor: pointer; text-decoration: none; transition: all 0.2s; border: none; }
.btn-ban { background: rgba(255,107,107,0.15); color: var(--error); border: 1px solid rgba(255,107,107,0.25); }
.btn-ban:hover { background: rgba(255,107,107,0.25); }
.btn-unban { background: rgba(67,233,123,0.15); color: var(--success); border: 1px solid rgba(67,233,123,0.25); }
.btn-unban:hover { background: rgba(67,233,123,0.25); }
.btn-resolve { background: rgba(108,99,255,0.15); color: var(--accent); border: 1px solid rgba(108,99,255,0.25); }
.btn-resolve:hover { background: rgba(108,99,255,0.25); }

.alert { padding: 12px 16px; border-radius: 10px; font-size: 13px; margin-bottom: 20px; display: flex; align-items: center; gap: 8px; }
.alert-success { background: rgba(67,233,123,0.12); border: 1px solid rgba(67,233,123,0.3); color: var(--success); }
.empty { padding: 40px; text-align: center; color: var(--muted); font-size: 14px; }
</style>
</head>
<body>
<aside class="sidebar">
  <div class="sidebar-logo">
    <div class="icon">💬</div><span>ChatPlay</span>
  </div>
  <div class="sidebar-user">
    <div class="s-avatar"><%= username.charAt(0) %></div>
    <div>
      <div style="font-size:14px;font-weight:600;"><%= username %></div>
      <div style="font-size:11px;color:#f857a6;">Admin</div>
    </div>
  </div>
  <nav class="nav-section">
    <div class="nav-label">Menu</div>
    <a href="dashboard.jsp" class="nav-item"><i class="fas fa-home"></i> Home</a>
    <a href="dashboard.jsp?page=find" class="nav-item"><i class="fas fa-user-plus"></i> Find Friends</a>
    <a href="chats.jsp" class="nav-item"><i class="fas fa-comment-dots"></i> Messages</a>
    <div class="nav-label">Admin</div>
    <a href="admin.jsp" class="nav-item active"><i class="fas fa-shield-halved"></i> Admin Panel</a>
    <a href="profile.jsp" class="nav-item"><i class="fas fa-circle-user"></i> Profile</a>
  </nav>
  <div class="sidebar-bottom">
    <a href="LogoutServlet" class="nav-item" style="color:#ff6b6b;"><i class="fas fa-right-from-bracket"></i> Logout</a>
  </div>
</aside>

<main class="main">
  <div class="topbar">
    <h1><i class="fas fa-shield-halved" style="color:var(--accent2);"></i> Admin Panel <span class="admin-badge">ADMIN</span></h1>
  </div>

  <% if(!msg.isEmpty()) { %>
  <div class="alert alert-success"><i class="fas fa-check-circle"></i> Action completed: <%= msg %>.</div>
  <% } %>

  <!-- Stats -->
  <div class="stats-row">
    <%
    int totalUsers=0, activeUsers=0, bannedUsers=0, totalReports=0, openReports=0;
    try {
        PreparedStatement psTU = con.prepareStatement("SELECT COUNT(*) FROM users");
        ResultSet rsTU = psTU.executeQuery(); if(rsTU.next()) totalUsers=rsTU.getInt(1);

        PreparedStatement psAU = con.prepareStatement("SELECT COUNT(*) FROM users WHERE status='active'");
        ResultSet rsAU = psAU.executeQuery(); if(rsAU.next()) activeUsers=rsAU.getInt(1);

        PreparedStatement psBU = con.prepareStatement("SELECT COUNT(*) FROM users WHERE status='banned'");
        ResultSet rsBU = psBU.executeQuery(); if(rsBU.next()) bannedUsers=rsBU.getInt(1);

        try {
            PreparedStatement psTR = con.prepareStatement("SELECT COUNT(*) FROM reports");
            ResultSet rsTR = psTR.executeQuery(); if(rsTR.next()) totalReports=rsTR.getInt(1);

            PreparedStatement psOR = con.prepareStatement("SELECT COUNT(*) FROM reports WHERE status='pending'");
            ResultSet rsOR = psOR.executeQuery(); if(rsOR.next()) openReports=rsOR.getInt(1);
        } catch(Exception ignore){}
    } catch(Exception ignore){}
    %>
    <div class="stat-box"><div class="val" style="color:var(--accent);"><%= totalUsers %></div><div class="lbl">👥 Total Users</div></div>
    <div class="stat-box"><div class="val" style="color:var(--success);"><%= activeUsers %></div><div class="lbl">✅ Active</div></div>
    <div class="stat-box"><div class="val" style="color:var(--error);"><%= bannedUsers %></div><div class="lbl">🚫 Banned</div></div>
    <div class="stat-box"><div class="val" style="color:var(--warning);"><%= openReports %></div><div class="lbl">🚩 Open Reports</div></div>
    <div class="stat-box"><div class="val" style="color:var(--muted);"><%= totalReports %></div><div class="lbl">📋 Total Reports</div></div>
  </div>

  <!-- Tabs -->
  <div class="tabs">
    <a href="admin.jsp?tab=reports" class="tab <%= "reports".equals(activeTab) ? "active" : "" %>"><i class="fas fa-flag"></i> Reports</a>
    <a href="admin.jsp?tab=users" class="tab <%= "users".equals(activeTab) ? "active" : "" %>"><i class="fas fa-users"></i> Users</a>
  </div>

  <%
  if("reports".equals(activeTab)){
      ResultSet rsRep = null;
      try {
          PreparedStatement psRep = con.prepareStatement(
              "SELECT r.id, r.reason, r.created_at, COALESCE(r.status,'pending') as status, " +
              "rep.username as reporter, rep_u.username as reported " +
              "FROM reports r " +
              "JOIN users rep ON r.reported_by = rep.user_id " +
              "JOIN users rep_u ON r.reported_user = rep_u.user_id " +
              "ORDER BY r.created_at DESC"
          );
          rsRep = psRep.executeQuery();
      } catch(Exception e){
          e.printStackTrace();
      }
  %>
  <div class="table-wrap">
    <table>
      <thead>
        <tr>
          <th>#</th>
          <th>Reported User</th>
          <th>Reported By</th>
          <th>Reason</th>
          <th>Status</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <%
        boolean anyRep = false;
        if(rsRep != null){
            while(rsRep.next()){
                anyRep = true;
                String status = rsRep.getString("status");
        %>
        <tr>
          <td style="color:var(--muted);"><%= rsRep.getInt("id") %></td>
          <td><strong><%= rsRep.getString("reported") %></strong></td>
          <td style="color:var(--muted);"><%= rsRep.getString("reporter") %></td>
          <td style="max-width:220px;"><%= rsRep.getString("reason") %></td>
          <td>
            <span class="status <%= "resolved".equals(status) ? "status-resolved" : "status-pending" %>">
              <%= status %>
            </span>
          </td>
          <td>
            <% if(!"resolved".equals(status)) { %>
            <a href="admin.jsp?action=resolve&uid=<%= rsRep.getInt("id") %>&tab=reports" class="btn btn-resolve"><i class="fas fa-check"></i> Resolve</a>
            <% } %>
          </td>
        </tr>
        <% }
        }
        if(!anyRep){ %>
        <tr><td colspan="6"><div class="empty">🎉 No reports found!</div></td></tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } else { // users tab
      ResultSet rsUsr = null;
      try {
          PreparedStatement psUsr = con.prepareStatement(
              "SELECT u.user_id, u.username, u.email, u.status, " +
              "(SELECT COUNT(*) FROM reports WHERE reported_user=u.user_id) as report_count " +
              "FROM users u ORDER BY report_count DESC, u.username"
          );
          rsUsr = psUsr.executeQuery();
      } catch(Exception e){ e.printStackTrace(); }
  %>
  <div class="table-wrap">
    <table>
      <thead>
        <tr>
          <th>User</th>
          <th>Email</th>
          <th>Reports</th>
          <th>Status</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <%
        if(rsUsr != null) while(rsUsr.next()){
            String uStatus = rsUsr.getString("status");
            if(uStatus == null) uStatus = "active";
            int rCount = rsUsr.getInt("report_count");
        %>
        <tr>
          <td><strong><%= rsUsr.getString("username") %></strong></td>
          <td style="color:var(--muted);font-size:12px;"><%= rsUsr.getString("email") %></td>
          <td>
            <span style="color:<%= rCount >= 3 ? "var(--error)" : rCount >= 1 ? "var(--warning)" : "var(--muted)" %>;font-weight:700;">
              <%= rCount %>
            </span>
          </td>
          <td>
            <span class="status <%= "banned".equals(uStatus) ? "status-banned" : "status-active" %>">
              ● <%= uStatus %>
            </span>
          </td>
          <td>
            <% if("active".equals(uStatus)) { %>
            <a href="admin.jsp?action=ban&uid=<%= rsUsr.getInt("user_id") %>&tab=users" class="btn btn-ban"
               onclick="return confirm('Ban <%= rsUsr.getString("username") %>?')">
              <i class="fas fa-ban"></i> Ban
            </a>
            <% } else { %>
            <a href="admin.jsp?action=unban&uid=<%= rsUsr.getInt("user_id") %>&tab=users" class="btn btn-unban">
              <i class="fas fa-check"></i> Unban
            </a>
            <% } %>
          </td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } %>
</main>
</body>
</html>
