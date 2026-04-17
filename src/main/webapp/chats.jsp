<%--
    Document   : chats
    Author     : meghabhagat
--%>
<%@ page import="java.sql.*, com.chatapp.DBConnection" %>
<%
if(session.getAttribute("user_id") == null){ response.sendRedirect("login.jsp"); return; }
int userId = (int) session.getAttribute("user_id");
String username = (String) session.getAttribute("username");
Connection con = DBConnection.getConnection();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Messages - ChatPlay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --primary: #6366f1; --sidebar: #ffffff; --bg: #f9fafb; --text-main: #111827; --text-muted: #6b7280; --border: #e5e7eb; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg); color: var(--text-main); display: flex; height: 100vh; overflow: hidden; }
        
        .sidebar { width: 280px; background: var(--sidebar); border-right: 1px solid var(--border); display: flex; flex-direction: column; padding: 30px 20px; }
        .logo { font-size: 24px; font-weight: 700; color: var(--primary); margin-bottom: 40px; text-decoration: none; display: block; }
        .nav-item { padding: 12px 16px; border-radius: 10px; color: var(--text-muted); text-decoration: none; display: flex; align-items: center; gap: 12px; margin-bottom: 4px; font-weight: 500; transition: 0.2s; }
        .nav-item:hover, .nav-item.active { background: #f3f4f6; color: var(--primary); }
        .nav-item.active { background: #eef2ff; color: var(--primary); }
        
        .main { flex: 1; display: flex; flex-direction: column; }
        .topbar { height: 70px; background: #fff; border-bottom: 1px solid var(--border); display: flex; align-items: center; padding: 0 40px; width: 100%; }
        
        .content { flex: 1; display: flex; overflow: hidden; background: #fff; }
        .inbox-list { width: 350px; border-right: 1px solid var(--border); overflow-y: auto; }
        .chat-view { flex: 1; display: flex; flex-direction: column; background: #f9fafb; position: relative; }
        
        .inbox-item { padding: 16px 20px; border-bottom: 1px solid #f3f4f6; cursor: pointer; display: flex; align-items: center; gap: 12px; transition: 0.1s; text-decoration: none; color: inherit; }
        .inbox-item:hover { background: #f9fafb; }
        .inbox-item.active { background: #eef2ff; border-left: 4px solid var(--primary); }
        .avatar { width: 44px; height: 44px; border-radius: 50%; background: var(--primary); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 600; flex-shrink: 0; }
        .chat-meta { flex: 1; min-width: 0; }
        .chat-name { font-weight: 600; font-size: 15px; margin-bottom: 2px; }
        .chat-name.unread { font-weight: 800; color: var(--primary); }
        .last-msg { font-size: 13px; color: var(--text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .last-msg.unread { font-weight: 700; color: var(--text-main); }
        .unread-dot { width: 10px; height: 10px; background: var(--primary); border-radius: 50%; margin-left: auto; }

        .empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; color: var(--text-muted); text-align: center; padding: 40px; }
        .empty-state i { font-size: 48px; margin-bottom: 20px; opacity: 0.3; }

        /* Notification Dropdown & Toasts */
        .topbar-actions { display: flex; align-items: center; gap: 20px; margin-left: auto; }
        .notif-wrapper { position: relative; cursor: pointer; }
        .notif-bell { font-size: 20px; color: var(--text-muted); transition: 0.2s; }
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
        .notif-content strong { color: var(--text-main); }
        .notif-content p { color: var(--text-muted); margin-top: 2px; }
        
        #toast-container { position: fixed; top: 20px; right: 20px; z-index: 9999; display: flex; flex-direction: column; gap: 10px; }
        .toast { background: #fff; border-left: 4px solid var(--primary); padding: 16px 20px; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); display: flex; align-items: center; gap: 12px; animation: toastIn 0.3s ease-out; min-width: 250px; border: 1px solid var(--border); }
        @keyframes toastIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
        .toast i { color: var(--primary); font-size: 18px; }
        .toast-msg { font-size: 13px; font-weight: 500; }
        
        .user-profile { display: flex; align-items: center; gap: 12px; font-weight: 600; font-size: 14px; color: var(--text-main); }
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
        <a href="chats.jsp" class="nav-item active"><i class="fas fa-message"></i> Messages</a>
        <a href="profile.jsp" class="nav-item"><i class="fas fa-user"></i> My Profile</a>
        <a href="LogoutServlet" class="nav-item" style="margin-top: auto; color: #dc2626;"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main">
        <div class="topbar">
            <h2 style="font-size:18px;">Inbox</h2>
            <div class="topbar-actions">
                <div class="notif-wrapper" onclick="toggleNotif(event)">
                    <i class="fas fa-bell notif-bell"></i>
                    <span id="bellBadge" class="notif-badge"></span>
                    <div id="notifDropdown" class="notif-dropdown">
                        <div class="notif-header">
                            Notifications
                            <span id="notifCountText" style="font-weight:400; font-size:11px; color:var(--text-muted);"></span>
                        </div>
                        <div id="notifList" class="notif-list">
                            <div style="padding:20px; font-size:13px; color:var(--text-muted);">No new notifications</div>
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
            <div class="inbox-list">
                <%
                PreparedStatement ps = con.prepareStatement(
                    "SELECT u.user_id, u.username, " +
                    "(SELECT message FROM messages WHERE (sender_id=u.user_id AND receiver_id=?) OR (sender_id=? AND receiver_id=u.user_id) ORDER BY timestamp DESC LIMIT 1) as last_msg, " +
                    "(SELECT COUNT(*) FROM messages WHERE sender_id=u.user_id AND receiver_id=? AND (is_read=FALSE OR is_read IS NULL)) as unread_count " +
                    "FROM users u JOIN friends f ON (u.user_id = f.friend_id AND f.user_id=?) OR (u.user_id = f.user_id AND f.friend_id=?) " +
                    "WHERE f.status = 'accepted'"
                );
                ps.setInt(1, userId); ps.setInt(2, userId); ps.setInt(3, userId); ps.setInt(4, userId); ps.setInt(5, userId);
                ResultSet rs = ps.executeQuery();
                boolean any = false;
                while(rs.next()){
                    any = true;
                    int fId = rs.getInt("user_id");
                    String fName = rs.getString("username");
                    String last = rs.getString("last_msg");
                    int uc = rs.getInt("unread_count");
                    if(last == null) last = "Say hi!";
                %>
                <a href="chat.jsp?friendId=<%= fId %>&friendName=<%= fName %>" class="inbox-item <%= uc > 0 ? "active-unread" : "" %>">
                    <div class="avatar"><%= (fName != null && !fName.isEmpty()) ? fName.charAt(0) : "?" %></div>
                    <div class="chat-meta">
                        <div class="chat-name <%= uc > 0 ? "unread" : "" %>"><%= fName %></div>
                        <div class="last-msg <%= uc > 0 ? "unread" : "" %>"><%= last %></div>
                    </div>
                    <% if(uc > 0) { %>
                        <div class="unread-dot"></div>
                    <% } %>
                </a>
                <% } if(!any) { %>
                    <div class="empty-state">
                        <i class="fas fa-comment-slash"></i>
                        <p>No conversations yet. Go to "Find Friends" to start chatting!</p>
                    </div>
                <% } %>
            </div>
            <div class="chat-view">
                <div class="empty-state">
                    <i class="fas fa-paper-plane"></i>
                    <h2>Select a contact</h2>
                    <p>Select a friend from the left to start messaging in real-time.</p>
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
                          `<div><div style="font-size:11px; color:var(--text-muted);">${subtitle}</div>` +
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
                    else list.innerHTML = '<div style="padding:20px; font-size:13px; color:var(--text-muted);">No new notifications</div>';

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
