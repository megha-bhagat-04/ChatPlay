<%--
    Document   : dashboard
    Author     : meghabhagat
--%>
<%@ page import="java.sql.*, com.chatapp.DBConnection" %>
<%
if(session.getAttribute("user_id") == null){
    response.sendRedirect("login.jsp");
    return;
}

int userId = (int) session.getAttribute("user_id");
String username = (String) session.getAttribute("username");
String pageType = request.getParameter("page");
if(pageType == null) pageType = "home";

Connection con = DBConnection.getConnection();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - ChatPlay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #6366f1;
            --sidebar: #ffffff;
            --bg: #f9fafb;
            --text-main: #111827;
            --text-muted: #6b7280;
            --border: #e5e7eb;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background-color: var(--bg); color: var(--text-main); display: flex; height: 100vh; overflow: hidden; }
        
        .sidebar { width: 280px; background: var(--sidebar); border-right: 1px solid var(--border); display: flex; flex-direction: column; padding: 30px 20px; }
        .logo { font-size: 24px; font-weight: 700; color: var(--primary); margin-bottom: 40px; }
        .nav-item { padding: 12px 16px; border-radius: 10px; color: var(--text-muted); text-decoration: none; display: flex; align-items: center; gap: 12px; margin-bottom: 4px; font-weight: 500; transition: 0.2s; }
        .nav-item:hover, .nav-item.active { background: #f3f4f6; color: var(--primary); }
        .nav-item.active { background: #eef2ff; color: var(--primary); }
        
        .main { flex: 1; display: flex; flex-direction: column; overflow-y: auto; }
        .topbar { height: 70px; background: #fff; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; padding: 0 40px; flex-shrink: 0; }
        .user-profile { display: flex; align-items: center; gap: 12px; font-weight: 600; font-size: 14px; }
        .avatar-circle { width: 36px; height: 36px; border-radius: 50%; background: var(--primary); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 14px; }
        
        .content { padding: 40px; }
        .card { background: #fff; border-radius: 12px; border: 1px solid var(--border); padding: 24px; margin-bottom: 24px; }
        h2 { font-size: 20px; font-weight: 700; margin-bottom: 20px; }
        
        .user-list-item { display: flex; align-items: center; justify-content: space-between; padding: 16px 0; border-bottom: 1px solid var(--border); }
        .user-list-item:last-child { border-bottom: none; }
        .user-info { display: flex; align-items: center; gap: 14px; }
        .user-info .name { font-weight: 600; font-size: 15px; }
        .user-info .bio { font-size: 13px; color: var(--text-muted); }
        
        .btn { padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; border: none; transition: 0.2s; text-decoration: none; font-family: inherit; }
        .btn-primary { background: var(--primary); color: #fff; }
        .btn-secondary { background: #f3f4f6; color: var(--text-main); }
        .btn-danger { background: #fee2e2; color: #dc2626; }
        .btn:hover { opacity: 0.9; }
        
        .actions { display: flex; gap: 8px; }
        .empty { text-align: center; padding: 40px; color: var(--text-muted); font-size: 14px; }

        /* Notification Dropdown & Toasts */
        .topbar-actions { display: flex; align-items: center; gap: 20px; }
        .notif-wrapper { position: relative; cursor: pointer; }
        .notif-bell { font-size: 20px; color: var(--text-muted); transition: 0.2s; }
        .notif-bell:hover { color: var(--primary); }
        .notif-badge { position: absolute; top: -5px; right: -5px; background: #ef4444; color: #fff; font-size: 10px; padding: 2px 5px; border-radius: 50%; display: none; border: 2px solid #fff; }
        
        .notif-dropdown { position: absolute; top: 100%; right: 0; width: 320px; background: #fff; border-radius: 12px; border: 1px solid var(--border); box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); display: none; z-index: 1000; margin-top: 10px; overflow: hidden; animation: slideIn 0.2s ease-out; }
        .notif-dropdown.show { display: block; }
        @keyframes slideIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        
        .notif-header { padding: 15px 20px; border-bottom: 1px solid var(--border); font-weight: 700; font-size: 14px; display: flex; justify-content: space-between; align-items: center; }
        .notif-list { max-height: 350px; overflow-y: auto; }
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
        
        .avatar-img { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; }
        .name.unread { font-weight: 800; color: var(--primary); }
        .unread-dot { width: 8px; height: 8px; background: var(--primary); border-radius: 50%; margin-left: 10px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="logo"><i class="fas fa-comments"></i> ChatPlay</div>
        <a href="dashboard.jsp?page=home" class="nav-item <%= "home".equals(pageType) ? "active" : "" %>"><i class="fas fa-home"></i> Home</a>
        
        <%
        // Get counts for badges with safety checks
        int reqCount = 0, invCount = 0, msgCount = 0;
        try {
            PreparedStatement psBadge = con.prepareStatement("SELECT COUNT(*) FROM friends WHERE friend_id=? AND status='pending'");
            psBadge.setInt(1, userId);
            ResultSet rsBadge = psBadge.executeQuery();
            if(rsBadge.next()) reqCount = rsBadge.getInt(1);
            
            psBadge = con.prepareStatement("SELECT COUNT(*) FROM game_invites WHERE receiver_id=? AND status='pending'");
            psBadge.setInt(1, userId);
            rsBadge = psBadge.executeQuery();
            if(rsBadge.next()) invCount = rsBadge.getInt(1);

            psBadge = con.prepareStatement("SELECT COUNT(*) FROM messages m JOIN users u ON m.sender_id = u.user_id WHERE m.receiver_id=? AND (m.is_read IS NULL OR m.is_read=FALSE)");
            psBadge.setInt(1, userId);
            rsBadge = psBadge.executeQuery();
            if(rsBadge.next()) msgCount = rsBadge.getInt(1);
        } catch(Exception e) {
            // If columns are missing, badges will just show 0 instead of crashing.
        }
        %>
        
        <a href="dashboard.jsp?page=find" class="nav-item <%= "find".equals(pageType) ? "active" : "" %>"><i class="fas fa-search"></i> Find Friends</a>
        <a href="dashboard.jsp?page=friends" class="nav-item <%= "friends".equals(pageType) ? "active" : "" %>"><i class="fas fa-user-group"></i> My Friends</a>
        
        <a href="dashboard.jsp?page=requests" class="nav-item <%= "requests".equals(pageType) ? "active" : "" %>">
            <i class="fas fa-clock"></i> Friend Requests
            <span id="reqBadge" class="badge" style="display:<%= reqCount > 0 ? "block" : "none" %>"><%= reqCount > 0 ? reqCount : "" %></span>
        </a>
        
        <a href="dashboard.jsp?page=gameInvites" class="nav-item <%= "gameInvites".equals(pageType) ? "active" : "" %>">
            <i class="fas fa-gamepad"></i> Game Invites
            <span id="invBadge" class="badge" style="display:<%= invCount > 0 ? "block" : "none" %>"><%= invCount > 0 ? invCount : "" %></span>
        </a>
        
        <a href="chats.jsp" class="nav-item">
            <i class="fas fa-message"></i> Messages
            <span id="msgBadge" class="badge" style="background:var(--primary); display:<%= msgCount > 0 ? "block" : "none" %>"><%= msgCount > 0 ? msgCount : "" %></span>
        </a>
        <a href="profile.jsp" class="nav-item"><i class="fas fa-user"></i> My Profile</a>
        <a href="LogoutServlet" class="nav-item" style="margin-top: auto; color: #dc2626;"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <style>
        .badge { background: #ef4444; color: #fff; font-size: 10px; font-weight: 700; padding: 2px 6px; border-radius: 10px; margin-left: auto; }
    </style>

    <div class="main">
        <div class="topbar">
            <h2><%= pageType.substring(0, 1).toUpperCase() + pageType.substring(1).replaceAll("([A-Z])", " $1") %></h2>
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
                            <div class="empty" style="padding:20px;">No new notifications</div>
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
            <% if(request.getParameter("msg") != null) { %>
                <div style="background:#dcfce7; color:#166534; padding:12px 20px; border-radius:10px; margin-bottom:20px; font-weight:600; font-size:14px; border:1px solid #bdf1d0;">
                   <i class="fas fa-check-circle"></i> Success: Action completed!
                </div>
            <% } %>
            <% if(request.getParameter("error") != null) { %>
                <div style="background:#fee2e2; color:#991b1b; padding:12px 20px; border-radius:10px; margin-bottom:20px; font-weight:600; font-size:14px; border:1px solid #fecaca;">
                   <i class="fas fa-times-circle"></i> Error: Something went wrong.
                </div>
            <% } %>
            <% if("home".equals(pageType)) { %>
                <div class="card">
                    <h2>Welcome back, <%= username %>!</h2>
                    <p style="color:var(--text-muted); margin-bottom: 20px;">You have successfully signed in. Here's what's happening today:</p>
                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div style="padding:20px; border:1px solid var(--border); border-radius:12px; background:#f8faff;">
                            <h4 style="margin-bottom:8px;"><i class="fas fa-users" style="color:var(--primary);"></i> Find People</h4>
                            <p style="font-size:13px; color:var(--text-muted);">Expand your circle and start new chats.</p>
                            <a href="dashboard.jsp?page=find" style="font-size:13px; color:var(--primary); font-weight:600; text-decoration:none; display:block; margin-top:10px;">Browse Users <i class="fas fa-chevron-right" style="font-size:10px;"></i></a>
                        </div>
                        <div style="padding:20px; border:1px solid var(--border); border-radius:12px; background:#f8faff;">
                            <h4 style="margin-bottom:8px;"><i class="fas fa-trophy" style="color:#f59e0b;"></i> Play Games</h4>
                            <p style="font-size:13px; color:var(--text-muted);">Challenge your friends to Tic Tac Toe.</p>
                            <a href="dashboard.jsp?page=friends" style="font-size:13px; color:var(--primary); font-weight:600; text-decoration:none; display:block; margin-top:10px;">Select Friend <i class="fas fa-chevron-right" style="font-size:10px;"></i></a>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <h2><i class="fas fa-message" style="color:var(--primary);"></i> Recent Messages</h2>
                    <%
                    try {
                        PreparedStatement psRecent = con.prepareStatement(
                            "SELECT DISTINCT u.user_id, u.username, " +
                            "(SELECT m.message FROM messages m WHERE (m.sender_id=u.user_id AND m.receiver_id=?) OR (m.sender_id=? AND m.receiver_id=u.user_id) ORDER BY m.timestamp DESC LIMIT 1) as last_msg, " +
                            "(SELECT COUNT(*) FROM messages WHERE sender_id=u.user_id AND receiver_id=? AND is_read=FALSE) as unread_count " +
                            "FROM users u JOIN messages m ON (u.user_id=m.sender_id OR u.user_id=m.receiver_id) " +
                            "WHERE (m.sender_id=? OR m.receiver_id=?) AND u.user_id != ? " +
                            "LIMIT 3"
                        );
                        psRecent.setInt(1, userId); psRecent.setInt(2, userId);
                        psRecent.setInt(3, userId); psRecent.setInt(4, userId);
                        psRecent.setInt(5, userId); psRecent.setInt(6, userId);
                        ResultSet rsRecent = psRecent.executeQuery();
                        boolean anyRecent = false;
                        while(rsRecent.next()){
                            anyRecent = true;
                            int urCount = rsRecent.getInt("unread_count");
                    %>
                    <div class="user-list-item">
                        <div class="user-info">
                            <div class="avatar-circle" style="background:#eef2ff; color:var(--primary);"><%= rsRecent.getString("username").charAt(0) %></div>
                            <div>
                                <div style="display:flex; align-items:center;">
                                    <div class="name <%= urCount > 0 ? "unread" : "" %>"><%= rsRecent.getString("username") %></div>
                                    <% if(urCount > 0) { %><div class="unread-dot"></div><% } %>
                                </div>
                                <div class="bio" style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; <%= urCount > 0 ? "font-weight:700; color:var(--text-main);" : "" %>">
                                    <%= rsRecent.getString("last_msg") != null ? rsRecent.getString("last_msg") : "No messages yet." %>
                                </div>
                            </div>
                        </div>
                        <a href="chat.jsp?friendId=<%= rsRecent.getInt("user_id") %>&friendName=<%= rsRecent.getString("username") %>" class="btn btn-secondary">Open Chat</a>
                    </div>
                    <% } if(!anyRecent) { %>
                        <div class="empty">No recent conversations. <a href="dashboard.jsp?page=friends">Start chatting!</a></div>
                    <% } 
                    } catch(Exception e) { %>
                        <div class="empty">Unable to load messages.</div>
                    <% } %>
                </div>
            <% } else if("find".equals(pageType)) { %>
                <div class="card">
                    <div class="user-list-item" style="border-bottom:none; margin-bottom:10px;">
                         <h2>Find New Friends</h2>
                    </div>
                    <%
                    PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE user_id != ? AND role != 'admin' AND status='active'");
                    ps.setInt(1, userId);
                    ResultSet rs = ps.executeQuery();
                    boolean found = false;
                    while(rs.next()){
                        found = true;
                        int otherId = rs.getInt("user_id");
                        PreparedStatement fCheck = con.prepareStatement("SELECT status FROM friends WHERE (user_id=? AND friend_id=?) OR (user_id=? AND friend_id=?)");
                        fCheck.setInt(1, userId); fCheck.setInt(2, otherId);
                        fCheck.setInt(3, otherId); fCheck.setInt(4, userId);
                        ResultSet fRs = fCheck.executeQuery();
                        String status = fRs.next() ? fRs.getString("status") : "none";
                    %>
                    <div class="user-list-item">
                        <div class="user-info">
                            <div class="avatar-circle" style="background:#e5e7eb; color:#4b5563;"><%= (rs.getString("username") != null && !rs.getString("username").isEmpty()) ? rs.getString("username").charAt(0) : "?" %></div>
                            <div>
                                <div class="name"><%= (rs.getString("username") != null) ? rs.getString("username") : "Unknown" %></div>
                                <div class="bio"><%= rs.getString("bio") != null ? rs.getString("bio") : "No bio." %></div>
                            </div>
                        </div>
                        <div class="actions">
                            <% if("none".equals(status)) { %>
                                <a href="SendRequestServlet?friend_id=<%= otherId %>" class="btn btn-primary">Add Friend</a>
                            <% } else { %>
                                <span style="font-size:12px; color:var(--text-muted); font-weight:600; text-transform:uppercase;"><%= status %></span>
                            <% } %>
                        </div>
                    </div>
                    <% } if(!found) { %> <div class="empty">No other users found.</div> <% } %>
                </div>
            <% } else if("friends".equals(pageType)) { %>
                <div class="card">
                    <h2>My Friends</h2>
                    <%
                    PreparedStatement psF = con.prepareStatement(
                        "SELECT u.user_id, u.username, u.bio FROM users u " +
                        "JOIN friends f ON (u.user_id = f.friend_id AND f.user_id=?) OR (u.user_id = f.user_id AND f.friend_id=?) " +
                        "WHERE f.status = 'accepted'"
                    );
                    psF.setInt(1, userId); psF.setInt(2, userId);
                    ResultSet rsF = psF.executeQuery();
                    boolean hasFriends = false;
                    while(rsF.next()){
                        hasFriends = true;
                        int fId = rsF.getInt("user_id");
                    %>
                    <div class="user-list-item">
                        <div class="user-info">
                            <div class="avatar-circle"><%= (rsF.getString("username") != null && !rsF.getString("username").isEmpty()) ? rsF.getString("username").charAt(0) : "?" %></div>
                            <div>
                                <div class="name"><%= (rsF.getString("username") != null) ? rsF.getString("username") : "Friend" %></div>
                                <div class="bio"><%= rsF.getString("bio") != null ? rsF.getString("bio") : "Friend" %></div>
                            </div>
                        </div>
                        <div class="actions">
                            <a href="chat.jsp?friendId=<%= fId %>&friendName=<%= rsF.getString("username") %>" class="btn btn-secondary">Chat</a>
                            <button onclick="challengeUser(<%= fId %>, '<%= rsF.getString("username") %>')" class="btn btn-primary"><i class="fas fa-gamepad"></i> Play</button>
                            <a href="UnfriendServlet?friendId=<%= fId %>" class="btn btn-danger" onclick="return confirm('Unfriend <%= rsF.getString("username") %>?')">Remove</a>
                        </div>
                    </div>
                    <% } if(!hasFriends) { %> <div class="empty">You have no friends yet. <a href="dashboard.jsp?page=find">Find some!</a></div> <% } %>
                </div>
            <% } else if("requests".equals(pageType)) { %>
                <div class="card">
                    <h2>Friend Requests</h2>
                    <%
                    PreparedStatement psR = con.prepareStatement(
                        "SELECT f.id, u.username FROM friends f JOIN users u ON f.user_id = u.user_id WHERE f.friend_id = ? AND f.status = 'pending'"
                    );
                    psR.setInt(1, userId);
                    ResultSet rsR = psR.executeQuery();
                    boolean anyR = false;
                    while(rsR.next()){
                        anyR = true;
                    %>
                    <div class="user-list-item">
                        <div class="user-info">
                            <div class="name"><%= rsR.getString("username") %> sent you a request</div>
                        </div>
                        <div class="actions">
                            <a href="AcceptRequestServlet?id=<%= rsR.getInt("id") %>" class="btn btn-primary">Accept</a>
                            <a href="RejectRequestServlet?id=<%= rsR.getInt("id") %>" class="btn btn-danger">Reject</a>
                        </div>
                    </div>
                    <% } if(!anyR) { %> <div class="empty">No pending friend requests.</div> <% } %>
                </div>
            <% } else if("gameInvites".equals(pageType)) { %>
                <div class="card">
                    <h2 style="color:var(--primary);"><i class="fas fa-inbox"></i> Challenges Received</h2>
                    <%
                    PreparedStatement psG = con.prepareStatement(
                        "SELECT gi.id, u.username FROM game_invites gi JOIN users u ON gi.sender_id = u.user_id WHERE gi.receiver_id = ? AND gi.status = 'pending'"
                    );
                    psG.setInt(1, userId);
                    ResultSet rsG = psG.executeQuery();
                    boolean anyG = false;
                    while(rsG.next()){
                        anyG = true;
                    %>
                    <div class="user-list-item">
                        <div class="user-info">
                            <div class="name"><strong><%= rsG.getString("username") %></strong> challenged you to Tic Tac Toe!</div>
                        </div>
                        <div class="actions">
                            <a href="AcceptGameServlet?id=<%= rsG.getInt("id") %>" class="btn btn-primary">Accept & Play</a>
                            <a href="DeclineGameServlet?id=<%= rsG.getInt("id") %>" class="btn btn-danger">Decline</a>
                        </div>
                    </div>
                    <% } if(!anyG) { %> <div class="empty">No challenges received.</div> <% } %>
                </div>

                <div class="card">
                    <h2><i class="fas fa-paper-plane"></i> Challenges Sent</h2>
                    <%
                    // ONLY show pending and declined. Accepted games auto-redirect and then hide.
                    PreparedStatement psSent = con.prepareStatement(
                        "SELECT gi.id, gi.status, u.username FROM game_invites gi JOIN users u ON gi.receiver_id = u.user_id WHERE gi.sender_id = ? AND (gi.status='pending' OR gi.status='declined') ORDER BY gi.id DESC"
                    );
                    psSent.setInt(1, userId);
                    ResultSet rsSent = psSent.executeQuery();
                    boolean anySent = false;
                    while(rsSent.next()){
                        anySent = true;
                        String status = rsSent.getString("status");
                    %>
                    <div class="user-list-item">
                        <div class="user-info">
                            <div class="name">Challenge to <strong><%= rsSent.getString("username") %></strong></div>
                            <div class="bio">
                                <% if("pending".equals(status)) { %>
                                    <span style="color:#f59e0b;"><i class="fas fa-clock"></i> Status: Pending...</span>
                                <% } else { %>
                                    <span style="color:#ef4444;"><i class="fas fa-times-circle"></i> Result: Request Declined</span>
                                <% } %>
                            </div>
                        </div>
                        <div class="actions">
                            <a href="CancelGameInviteServlet?id=<%= rsSent.getInt("id") %>" class="btn btn-secondary" style="color:#ef4444;"><%= "declined".equals(status) ? "Dismiss" : "Cancel" %></a>
                        </div>
                    </div>
                    <% } if(!anySent) { %> <div class="empty">No pending challenges sent.</div> <% } %>
                </div>
            <% } %>
        </div>
    </div>
    <style>
        .modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal-content { background: #fff; padding: 30px; border-radius: 20px; width: 100%; max-width: 400px; text-align: center; }
        .game-opt { display: flex; align-items: center; gap: 15px; padding: 15px; border: 1px solid var(--border); border-radius: 12px; margin-top: 10px; cursor: pointer; transition: 0.2s; text-decoration: none; color: inherit; }
        .game-opt:hover { border-color: var(--primary); background: #f8faff; }
        .game-opt i { font-size: 24px; color: var(--primary); }
    </style>

    <div class="modal" id="gameModal">
        <div class="modal-content">
            <h3 style="margin-bottom:10px;">Select Game</h3>
            <p style="font-size:13px; color:var(--text-muted); margin-bottom:20px;">Challenge <span id="targetUsername" style="font-weight:700;"></span> to a game!</p>
            <a id="tttLink" href="#" class="game-opt">
                <i class="fas fa-th"></i>
                <div style="text-align:left;">
                    <div style="font-weight:600;">Tic Tac Toe</div>
                    <div style="font-size:12px; color:var(--text-muted);">Classic 3x3 battle</div>
                </div>
            </a>
            <a id="rpsLink" href="#" class="game-opt">
                <i class="fas fa-hand-rock"></i>
                <div style="text-align:left;">
                    <div style="font-weight:600;">Rock Paper Scissors</div>
                    <div style="font-size:12px; color:var(--text-muted);">Quick-fire choice challenge</div>
                </div>
            </a>
            <button onclick="closeModal()" class="btn btn-secondary" style="width:100%; margin-top:20px;">Cancel</button>
        </div>
    </div>

    <script>
        function challengeUser(id, name) {
            document.getElementById('targetUsername').innerText = name;
            document.getElementById('tttLink').href = 'SendGameInviteServlet?receiver_id=' + id + '&type=tic_tac_toe';
            document.getElementById('rpsLink').href = 'SendGameInviteServlet?receiver_id=' + id + '&type=rock_paper_scissors';
            document.getElementById('gameModal').style.display = 'flex';
        }
        function closeModal() { document.getElementById('gameModal').style.display = 'none'; }
        window.onclick = function(event) { if (event.target == document.getElementById('gameModal')) closeModal(); }

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

        // ✅ UNIVERSAL REAL-TIME UPDATE
        function updateStatus() {
            fetch('RealTimeStatusServlet')
                .then(res => res.json())
                .then(data => {
                    // Update Badge Counters
                    if(data.requests !== undefined) updateBadge('reqBadge', data.requests);
                    if(data.invites !== undefined) updateBadge('invBadge', data.invites);
                    if(data.messages !== undefined) updateBadge('msgBadge', data.messages);
                    
                    // Top Navbar Bell Badge
                    const totalNotifs = (data.messages || 0) + (data.invites || 0);
                    updateBadge('bellBadge', totalNotifs);
                    document.getElementById('notifCountText').innerText = totalNotifs > 0 ? totalNotifs + ' unread' : 'No new alerts';

                    // Update Dropdown Content
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
                    else list.innerHTML = '<div class="empty" style="padding:20px;">No new notifications</div>';

                    // Show Toasts for new messages or invites
                    if(window.lastData) {
                        if(data.messages > window.lastData.messages && data.recentMsgs && data.recentMsgs.length > 0) {
                            showToast(data.recentMsgs[0].sender, data.recentMsgs[0].text, 'message');
                        }
                        if(data.invites > window.lastData.invites && data.recentInvs && data.recentInvs.length > 0) {
                            showToast(data.recentInvs[0].sender, 'Challenged you to ' + data.recentInvs[0].type.replace(/_/g, ' '), 'game');
                        }
                    }

                    // Auto-Redirect if Game Started (for Sender)
                    if(data.redirect > 0) {
                        window.location.href = 'game.jsp?gameId=' + data.redirect;
                    }
                    
                    window.lastData = data;
                }).catch(err => console.log("Poll error"));
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