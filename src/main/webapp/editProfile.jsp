<%--
    Document   : editProfile
    Author     : meghabhagat
--%>
<%@ page import="java.sql.*, com.chatapp.DBConnection" %>
<%
if(session.getAttribute("user_id") == null){ response.sendRedirect("login.jsp"); return; }
int userId = (int) session.getAttribute("user_id");
Connection con = DBConnection.getConnection();
PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE user_id=?");
ps.setInt(1, userId);
ResultSet rs = ps.executeQuery();
rs.next();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Profile - ChatPlay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --primary: #6366f1; --bg: #f9fafb; --text: #111827; --muted: #6b7280; --border: #e5e7eb; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); display: flex; height: 100vh; }
        .sidebar { width: 280px; background: #fff; border-right: 1px solid var(--border); display: flex; flex-direction: column; padding: 30px 20px; }
        .logo { font-size: 24px; font-weight: 700; color: var(--primary); margin-bottom: 40px; text-decoration: none; display: block; }
        .nav-item { padding: 12px 16px; border-radius: 10px; color: var(--muted); text-decoration: none; display: flex; align-items: center; gap: 12px; margin-bottom: 4px; font-weight: 500; transition: 0.2s; }
        .nav-item:hover, .nav-item.active { background: #f3f4f6; color: var(--primary); }
        
        .main { flex: 1; display: flex; flex-direction: column; overflow-y: auto; }
        .topbar { height: 70px; background: #fff; border-bottom: 1px solid var(--border); display: flex; align-items: center; padding: 0 40px; }
        .content { padding: 40px; display: flex; justify-content: center; }
        
        .form-card { background: #fff; padding: 32px; border-radius: 16px; border: 1px solid var(--border); width: 100%; max-width: 500px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        .form-group { margin-bottom: 20px; text-align: left; }
        label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 8px; color: #374151; }
        input, textarea { width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 14px; outline: none; transition: 0.2s; font-family: inherit; }
        input:focus, textarea:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
        textarea { resize: vertical; min-height: 100px; }
        
        .btn-row { display: flex; gap: 10px; margin-top: 20px; }
        .btn { flex: 1; padding: 12px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; border: none; font-family: inherit; transition: 0.2s; text-decoration: none; text-align: center; }
        .btn-primary { background: var(--primary); color: #fff; }
        .btn-secondary { background: #fff; border: 1px solid var(--border); color: var(--muted); }
    </style>
</head>
<body>
    <div class="sidebar">
        <a href="dashboard.jsp" class="logo"><i class="fas fa-comments"></i> ChatPlay</a>
        <a href="dashboard.jsp?page=home" class="nav-item"><i class="fas fa-home"></i> Home</a>
        <a href="profile.jsp" class="nav-item active"><i class="fas fa-user"></i> My Profile</a>
    </div>
    <div class="main">
        <div class="topbar"><h2 style="font-size:18px;">Edit Profile</h2></div>
        <div class="content">
            <div class="form-card">
                <form action="EditProfileServlet" method="post" enctype="multipart/form-data">
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" value="<%= rs.getString("username") %>" required>
                    </div>
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" value="<%= rs.getString("email") %>" required>
                    </div>
                    <div class="form-group">
                        <label>Upload Profile Picture</label>
                        <input type="file" name="profile_pic" accept="image/*">
                        <div style="font-size:11px; color:var(--muted); margin-top:5px;">Current: <%= (rs.getString("profile_pic") != null) ? rs.getString("profile_pic") : "None" %></div>
                    </div>
                    <div class="form-group">
                        <label>Bio</label>
                        <textarea name="bio"><%= (rs.getString("bio") != null) ? rs.getString("bio") : "" %></textarea>
                    </div>
                    <div class="btn-row">
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                        <a href="profile.jsp" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>