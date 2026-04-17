<%--
    Document   : profile
    Author     : meghabhagat
--%>
<%@ page import="java.sql.*, com.chatapp.DBConnection" %>
<%
if(session.getAttribute("user_id") == null){ response.sendRedirect("login.jsp"); return; }
int userId = (int) session.getAttribute("user_id");
String username = (String) session.getAttribute("username");

Connection con = DBConnection.getConnection();
PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE user_id=?");
ps.setInt(1, userId);
ResultSet rs = ps.executeQuery();
rs.next();

String email = rs.getString("email");
String bio = rs.getString("bio");
String profilePic = rs.getString("profile_pic");
String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Profile - ChatPlay</title>
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
        .nav-item.active { background: #eef2ff; color: var(--primary); }

        .main { flex: 1; display: flex; flex-direction: column; overflow-y: auto; }
        .topbar { height: 70px; background: #fff; border-bottom: 1px solid var(--border); display: flex; align-items: center; padding: 0 40px; justify-content: space-between; }
        
        .content { padding: 40px; display: flex; justify-content: center; }
        .profile-card { background: #fff; border-radius: 16px; border: 1px solid var(--border); width: 100%; max-width: 600px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        .banner { height: 120px; background: linear-gradient(135deg, #6366f1, #a855f7); }
        .profile-body { padding: 0 40px 40px; position: relative; }
        .avatar-wrap { width: 100px; height: 100px; border-radius: 50%; border: 4px solid #fff; background: #6366f1; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 40px; font-weight: 700; margin-top: -50px; margin-bottom: 20px; overflow: hidden; }
        .avatar-wrap img { width: 100%; height: 100%; object-fit: cover; }
        
        h2 { font-size: 24px; font-weight: 700; margin-bottom: 4px; }
        .email { color: var(--muted); font-size: 14px; margin-bottom: 20px; display: block; }
        .bio { font-size: 15px; color: #374151; line-height: 1.6; margin-bottom: 30px; }
        
        .btn { padding: 10px 20px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; border: none; font-family: inherit; }
        .btn-primary { background: var(--primary); color: #fff; }
        .btn-outline { background: #fff; border: 1px solid var(--border); color: var(--text); }
        .btn-danger { background: #fee2e2; color: #dc2626; margin-left: auto; }
        
        .alert { background: #dcfce7; color: #166534; padding: 12px; border-radius: 8px; font-size: 14px; margin-bottom: 20px; border: 1px solid #bbf7d0; }

        /* Notification Dropdown & Toasts */
        .topbar-actions { display: flex; align-items: center; gap: 20px; }
        .notif-wrapper { position: relative; cursor: pointer; }
        .notif-bell { font-size: 20px; color: var(--muted); transition: 0.2s; }
        .notif-bell:hover { color: var(--primary); }
        .notif-badge { position: absolute; top: -5px; right: -5px; background: #ef4444; color: #fff; font-size: 10px; padding: 2px 5px; border-radius: 50%; display: none; border: 2px solid #fff; }
        
        .notif-dropdown { position: absolute; top: 100%; right: 0; width: 320px; background: #fff; border-radius: 12px; border: 1px solid var(--border); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); display: none; z-index: 1000; margin-top: 10px; overflow: hidden; animation: slideIn 0.2s ease-out; }
        .notif-dropdown.show { display: block; }
        @keyframes slideIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        
        .notif-header { padding: 15px 20px; border-bottom: 1px solid var(--border); font-weight: 700; font-size: 14px; display: flex; justify-content: space-between; align-items: center; }
        .notif-list { max-height: 350px; overflow-y: auto; text-align: left; }
        .notif-item { padding: 12px 20px; border-bottom: 1px solid #f9fafb; display: flex; gap: 12px; align-items: flex-start; text-decoration: none; color: inherit; transition: 0.2s; }
        .notif-item:hover { background: #f8faff; }
        .notif-item:last-child { border-bottom: none; }
        .notif-icon { width: 32px; height: 32px; border-radius: 50%; background: #eef2ff; color: var(--primary); display: flex; align-items: center; justify-content: center; font-size: 14px; flex-shrink: 0; }
        .notif-content { flex: 1; font-size: 13px; line-height: 1.4; }
        .notif-content strong { color: var(--text); }
        .notif-content p { color: var(--muted); margin-top: 2px; }
        
        #toast-container { position: fixed; top: 20px; right: 20px; z-index: 9999; display: flex; flex-direction: column; gap: 10px; }
        .toast { background: #fff; border-left: 4px solid var(--primary); padding: 16px 20px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); display: flex; align-items: center; gap: 12px; animation: toastIn 0.3s ease-out; min-width: 250px; border: 1px solid var(--border); }
        @keyframes toastIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        .toast i { color: var(--primary); font-size: 18px; }
        .toast-msg { font-size: 13px; font-weight: 500; }
        
        .user-profile { display: flex; align-items: center; gap: 12px; font-weight: 600; font-size: 14px; color: var(--text); }
        .avatar-circle { width: 36px; height: 36px; border-radius: 50%; background: var(--primary); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 14px; }
        .avatar-img { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; }
    </style>
</head>
<body>
    <div class="sidebar">
        <a href="dashboard.jsp" class="logo"><i class="fas fa-comments"></i> ChatPlay</a>
        <a href="dashboard.jsp?page=home" class="nav-item"><i class="fas fa-home"></i> Home</a>
        <a href="dashboard.jsp?page=find" class="nav-item"><i class="fas fa-search"></i> Find Friends</a>
        <a href="dashboard.jsp?page=friends" class="nav-item"><i class="fas fa-user-group"></i> My Friends</a>
        <a href="chats.jsp" class="nav-item"><i class="fas fa-message"></i> Messages</a>
        <a href="profile.jsp" class="nav-item active"><i class="fas fa-user"></i> My Profile</a>
        <a href="LogoutServlet" class="nav-item" style="margin-top: auto; color: #dc2626;"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2 style="font-size:18px;">Profile</h2>
            <div class="topbar-actions">
                <div class="notif-wrapper" onclick="toggleNotif(event)">
                    <i class="fas fa-bell notif-bell"></i>
                    <span id="bellBadge" class="notif-badge"></span>
                    <div id="notifDropdown" class="notif-dropdown">
                        <div class="notif-header">
                            Notifications
                            <span id="notifCountText" style="font-weight:400; font-size:11px; color:var(--muted);"></span>
                        </div>
                        <div id="notifList" class="notif-list">
                            <div style="padding:20px; font-size:13px; color:var(--muted);">No new notifications</div>
                        </div>
                    </div>
                </div>
                
                <div class="user-profile">
                    <% String pPic = (String) session.getAttribute("profile_pic"); %>
                    <% if(pPic != null && !pPic.isEmpty()) { %>
                        <img src="<%= pPic %>" class="avatar-img" alt="Profile">
                    <% } else { %>
                        <div class="avatar-circle"><%= (username != null && !username.isEmpty()) ? username.charAt(0) : "?" %></div>
                    <% } %>
                    <%= (username != null) ? username : "User" %>
                </div>
            </div>
        </div>

        <div id="toast-container"></div>
        <div class="content">
            <div class="profile-card">
                <div class="banner"></div>
                <div class="profile-body">
                    <div class="avatar-wrap">
                        <% if(profilePic != null && !profilePic.isEmpty()) { %>
                            <img src="<%= profilePic %>" alt="Avatar">
                        <% } else { %>
                            <%= (username != null && !username.isEmpty()) ? username.charAt(0) : "?" %>
                        <% } %>
                    </div>
                    
                    <% if("updated".equals(msg)) { %>
                        <div class="alert"><i class="fas fa-check-circle"></i> Profile updated successfully!</div>
                    <% } %>

                    <h2><%= username %></h2>
                    <span class="email"><%= email %></span>
                    
                    <div class="bio">
                        <%= (bio != null && !bio.isEmpty()) ? bio : "You haven't added a bio yet. Tell your friends something about yourself!" %>
                    </div>

                    <div style="display:grid; grid-template-columns: repeat(3, 1fr); gap:15px; margin-bottom: 30px;">
                        <div style="background:#f8fafc; padding:15px; border-radius:12px; text-align:center; border:1px solid var(--border);">
                            <div style="font-size:12px; color:var(--muted); text-transform:uppercase; font-weight:700; margin-bottom:5px;">Wins</div>
                            <div style="font-size:20px; font-weight:700; color:#10b981;"><%= rs.getInt("wins") %></div>
                        </div>
                        <div style="background:#f8fafc; padding:15px; border-radius:12px; text-align:center; border:1px solid var(--border);">
                            <div style="font-size:12px; color:var(--muted); text-transform:uppercase; font-weight:700; margin-bottom:5px;">Losses</div>
                            <div style="font-size:20px; font-weight:700; color:#ef4444;"><%= rs.getInt("losses") %></div>
                        </div>
                        <div style="background:#f8fafc; padding:15px; border-radius:12px; text-align:center; border:1px solid var(--border);">
                            <div style="font-size:12px; color:var(--muted); text-transform:uppercase; font-weight:700; margin-bottom:5px;">Streak</div>
                            <div style="font-size:20px; font-weight:700; color:var(--primary);"><%= rs.getInt("streak") %> <i class="fas fa-fire"></i></div>
                        </div>
                    </div>

                    <div style="display:flex; gap:10px;">
                        <a href="editProfile.jsp" class="btn btn-primary"><i class="fas fa-pen"></i> Edit Profile</a>
                        <a href="DeleteAccountServlet" class="btn btn-danger" onclick="return confirm('Permanent delete? This cannot be undone.')"><i class="fas fa-trash"></i> Delete Account</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script>
        function toggleNotif(e) {
            e.stopPropagation();
            document.getElementById('notifDropdown').classList.toggle('show');
        }
        window.addEventListener('click', () => {
            document.getElementById('notifDropdown').classList.remove('show');
        });

        function showToast(title, msg, type = 'message') {
            const container = document.getElementById('toast-container');
            const t = document.createElement('div');
            t.className = 'toast';
            const icon = type === 'game' ? 'fa-gamepad' : 'fa-comment-dots';
            const subtitle = type === 'game' ? 'Game Challenge' : 'New Message';
            const iconStyle = type === 'game' ? 'color:#f97316;' : 'color:var(--primary);';
            const borderStyle = type === 'game' ? 'border-left-color:#f97316;' : '';

            t.style = borderStyle;
            t.innerHTML = `<i class="fas ${icon}" style="${iconStyle}"></i>` +
                          `<div><div style="font-size:11px; color:var(--muted);">${subtitle}</div>` +
                          `<div class="toast-msg"><strong>${title}:</strong> ${msg}</div></div>`;
            container.appendChild(t);
            setTimeout(() => {
                t.style.animation = 'toastIn 0.3s ease-in reverse forwards';
                setTimeout(() => t.remove(), 300);
            }, 4000);
        }

        function updateStatus() {
            fetch('RealTimeStatusServlet')
                .then(res => res.json())
                .then(data => {
                    const totalNotifs = (data.messages || 0) + (data.invites || 0);
                    updateBadge('bellBadge', totalNotifs);
                    document.getElementById('notifCountText').innerText = totalNotifs > 0 ? totalNotifs + ' unread' : 'No new alerts';

                    const list = document.getElementById('notifList');
                    let html = '';
                    
                    if(data.recentMsgs && data.recentMsgs.length > 0) {
                        data.recentMsgs.forEach(m => {
                            html += '<a href="chat.jsp?friendId=' + m.senderId + '&friendName=' + m.sender + '" class="notif-item">' +
                                    '<div class="notif-icon"><i class="fas fa-message"></i></div>' +
                                    '<div class="notif-content"><strong>' + m.sender + '</strong> sent a message:<p>' + m.text + '</p></div>' +
                                    '</a>';
                        });
                    }
                    if(data.recentInvs && data.recentInvs.length > 0) {
                        data.recentInvs.forEach(i => {
                            html += '<a href="dashboard.jsp?page=gameInvites" class="notif-item">' +
                                    '<div class="notif-icon" style="background:#fff7ed; color:#f97316;"><i class="fas fa-gamepad"></i></div>' +
                                    '<div class="notif-content"><strong>' + i.sender + '</strong> challenged you!<p>Game: ' + i.type.replace(/_/g, ' ') + '</p></div>' +
                                    '</a>';
                        });
                    }
                    
                    if(html) list.innerHTML = html;
                    else list.innerHTML = '<div style="padding:20px; font-size:13px; color:var(--muted);">No new notifications</div>';

                    if(window.lastData) {
                        if(data.messages > window.lastData.messages && data.recentMsgs && data.recentMsgs.length > 0) {
                            showToast(data.recentMsgs[0].sender, data.recentMsgs[0].text, 'message');
                        }
                        if(data.invites > window.lastData.invites && data.recentInvs && data.recentInvs.length > 0) {
                            showToast(data.recentInvs[0].sender, 'Challenged you to ' + data.recentInvs[0].type.replace(/_/g, ' '), 'game');
                        }
                    }

                    if(data.redirect > 0) window.location.href = 'game.jsp?gameId=' + data.redirect;
                    window.lastData = data;
                });
        }

        function updateBadge(id, count) {
            const el = document.getElementById(id);
            if(el) {
                el.innerText = count > 0 ? count : '';
                el.style.display = count > 0 ? 'block' : 'none';
            }
        }

        setInterval(updateStatus, 3000);
        updateStatus();
    </script>
</body>
</html>