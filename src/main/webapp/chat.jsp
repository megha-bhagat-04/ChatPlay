<%--
    Document   : chat
    Author     : meghabhagat
--%>
<%@ page import="java.sql.*, com.chatapp.DBConnection" %>
<%
Integer userIdObj = (Integer) session.getAttribute("user_id");
if(userIdObj == null){ response.sendRedirect("login.jsp"); return; }

int userId = userIdObj;
String friendIdStr = request.getParameter("friendId");
String friendName = request.getParameter("friendName");

if(friendIdStr == null || friendName == null){
    response.sendRedirect("dashboard.jsp");
    return;
}
int friendId = Integer.parseInt(friendIdStr);
Connection con = DBConnection.getConnection();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Chat with <%= friendName %></title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --primary: #6366f1; --bg: #f9fafb; --text: #111827; --border: #e5e7eb; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); display: flex; height: 100vh; overflow: hidden; }
        
        .sidebar { width: 280px; background: #fff; border-right: 1px solid var(--border); display: flex; flex-direction: column; padding: 30px 20px; }
        .logo { font-size: 24px; font-weight: 700; color: var(--primary); margin-bottom: 40px; text-decoration: none; display: block; }
        .nav-item { padding: 12px 16px; border-radius: 10px; color: #6b7280; text-decoration: none; display: flex; align-items: center; gap: 12px; margin-bottom: 4px; font-weight: 500; }
        .nav-item:hover { background: #f3f4f6; color: var(--primary); }

        .main { flex: 1; display: flex; flex-direction: column; background: #fff; }
        .chat-header { height: 70px; background: #fff; border-bottom: 1px solid var(--border); display: flex; align-items: center; padding: 0 40px; gap: 15px; }
        .back-btn { color: var(--text); text-decoration: none; font-size: 18px; margin-right: 10px; }
        .avatar { width: 40px; height: 40px; border-radius: 50%; background: var(--primary); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 600; }
        .chat-info h2 { font-size: 16px; font-weight: 700; }
        
        .chat-container { flex: 1; display: flex; flex-direction: column; background: #fdfdfd; overflow: hidden; }
        #chatBox { flex: 1; padding: 30px 40px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; }
        
        .message { max-width: 60%; padding: 12px 18px; border-radius: 12px; font-size: 14px; position: relative; line-height: 1.5; }
        .message.sent { align-self: flex-end; background: var(--primary); color: #fff; border-bottom-right-radius: 2px; box-shadow: 0 4px 10px rgba(99,102,241,0.2); }
        .message.received { align-self: flex-start; background: #fff; color: var(--text); border: 1px solid var(--border); border-bottom-left-radius: 2px; }
        .time { font-size: 10px; opacity: 0.7; margin-top: 4px; display: block; text-align: right; }
        
        .chat-input-area { padding: 25px 40px; background: #fff; border-top: 1px solid var(--border); display: flex; gap: 15px; }
        .chat-input-area input { flex: 1; padding: 14px 20px; border: 1px solid #d1d5db; border-radius: 12px; outline: none; font-family: inherit; font-size: 15px; transition: 0.2s; }
        .chat-input-area input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
        .send-btn { width: 50px; height: 50px; background: var(--primary); color: #fff; border: none; border-radius: 12px; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 20px; transition: 0.2s; }
        .send-btn:hover { transform: scale(1.05); background: #4f46e5; }
    </style>
</head>
<body>
    <div class="sidebar">
        <a href="dashboard.jsp" class="logo"><i class="fas fa-comments"></i> ChatPlay</a>
        <a href="dashboard.jsp?page=home" class="nav-item"><i class="fas fa-home"></i> Home</a>
        <a href="chats.jsp" class="nav-item"><i class="fas fa-message"></i> Messages</a>
        <a href="profile.jsp" class="nav-item"><i class="fas fa-user"></i> My Profile</a>
        <a href="dashboard.jsp?page=friends" class="nav-item"><i class="fas fa-user-group"></i> My Friends</a>
        <a href="LogoutServlet" class="nav-item" style="margin-top: auto; color: #dc2626;"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="main">
        <div class="chat-header">
            <a href="chats.jsp" class="back-btn"><i class="fas fa-arrow-left"></i></a>
            <div class="avatar"><%= (friendName != null && !friendName.isEmpty()) ? friendName.charAt(0) : "?" %></div>
            <div class="chat-info">
                <h2><%= friendName %></h2>
                <%
                // Head-to-head scores
                int myWins = 0, friendWins = 0;
                PreparedStatement psScore = con.prepareStatement("SELECT winner, COUNT(*) FROM games WHERE winner != 0 AND ((player1=? AND player2=?) OR (player1=? AND player2=?)) GROUP BY winner");
                psScore.setInt(1, userId); psScore.setInt(2, friendId);
                psScore.setInt(3, friendId); psScore.setInt(4, userId);
                ResultSet rsScore = psScore.executeQuery();
                while(rsScore.next()){
                    if(rsScore.getInt(1) == userId) myWins = rsScore.getInt(2);
                    else friendWins = rsScore.getInt(2);
                }
                %>
                <div style="font-size:11px; color:var(--primary); font-weight:600; text-transform:uppercase; margin-top:2px;">
                    Match Score: You <%= myWins %> - <%= friendWins %> <%= friendName %>
                </div>
            </div>
            <div style="margin-left: auto;">
                 <button onclick="openGameModal()" style="background:#eef2ff; color:var(--primary); padding:10px 15px; border-radius:10px; border:none; cursor:pointer; font-weight:600; font-size:14px;"><i class="fas fa-gamepad" style="margin-right:8px;"></i> Play Game</button>
            </div>
        </div>

        <style>
            .modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
            .modal-content { background: #fff; padding: 30px; border-radius: 20px; width: 100%; max-width: 400px; text-align: center; color: var(--text); }
            .game-opt { display: flex; align-items: center; gap: 15px; padding: 15px; border: 1px solid var(--border); border-radius: 12px; margin-top: 10px; cursor: pointer; transition: 0.2s; text-decoration: none; color: inherit; }
            .game-opt:hover { border-color: var(--primary); background: #f8faff; }
            .game-opt i { font-size: 24px; color: var(--primary); }
        </style>

        <div class="modal" id="gameModal">
            <div class="modal-content">
                <h3 style="margin-bottom:10px;">Select Game</h3>
                <p style="font-size:13px; color:#6b7280; margin-bottom:20px;">Challenge <%= friendName %> to a game!</p>
                <a href="SendGameInviteServlet?receiver_id=<%= friendId %>&type=tic_tac_toe" class="game-opt">
                    <i class="fas fa-th"></i>
                    <div style="text-align:left;">
                        <div style="font-weight:600;">Tic Tac Toe</div>
                        <div style="font-size:12px; color:#6b7280;">Classic 3x3 battle</div>
                    </div>
                </a>
                <a href="SendGameInviteServlet?receiver_id=<%= friendId %>&type=rock_paper_scissors" class="game-opt">
                    <i class="fas fa-hand-rock"></i>
                    <div style="text-align:left;">
                        <div style="font-weight:600;">Rock Paper Scissors</div>
                        <div style="font-size:12px; color:#6b7280;">Choice-based challenge</div>
                    </div>
                </a>
                <button onclick="closeModal()" style="width:100%; margin-top:20px; padding:10px; background:#f3f4f6; border:none; border-radius:10px; cursor:pointer; font-weight:600;">Cancel</button>
            </div>
        </div>

        <div class="chat-container">
            <div id="chatBox">
                <div style="text-align:center; color:#9ca3af; font-size:13px; margin-top:20px;">Loading conversation...</div>
            </div>

            <div class="chat-input-area">
                <input type="text" id="msgInput" placeholder="Write something..." onkeypress="handleKey(event)">
                <button class="send-btn" onclick="sendMsg()"><i class="fas fa-paper-plane"></i></button>
            </div>
        </div>
    </div>

    <script>
        const FRIEND_ID = <%= friendId %>;
        const MY_ID = <%= userId %>;
        let lastMsgId = 0;

        function scrollChat() {
            const cb = document.getElementById('chatBox');
            cb.scrollTop = cb.scrollHeight;
        }

        function openGameModal() { document.getElementById('gameModal').style.display = 'flex'; }
        function closeModal() { document.getElementById('gameModal').style.display = 'none'; }
        window.onclick = function(event) { if (event.target == document.getElementById('gameModal')) closeModal(); }

        function loadChat() {
            fetch('FetchMessagesServlet?friendId=' + FRIEND_ID + '&format=json')
                .then(res => res.json())
                .then(msgs => {
                    const cb = document.getElementById('chatBox');
                    const newHtml = msgs.map(function(m) {
                        const isSent = (m.senderId == MY_ID);
                        const date = new Date(m.timestamp);
                        const time = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                        const cls = isSent ? 'sent' : 'received';
                        return '<div class="message ' + cls + '">' +
                                '<div class="msg-content">' + (m.message || "") + '</div>' + 
                                '<span class="time">' + time + '</span>' +
                               '</div>';
                    }).join('');
                    
                    if(cb.innerHTML !== newHtml) {
                        cb.innerHTML = newHtml || '<div style="text-align:center; color:#9ca3af; font-size:13px; margin-top:20px;">No messages yet. Send a greeting!</div>';
                        scrollChat();
                    }
                })
                .catch(err => console.error("Fetch error:", err));
        }

        function sendMsg() {
            const input = document.getElementById('msgInput');
            const msg = input.value.trim();
            if (!msg) return;

            input.value = '';

            fetch('SendMessageServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'message=' + encodeURIComponent(msg) + '&receiver_id=' + FRIEND_ID
            })
            .then(res => {
                if(res.ok) loadChat();
            })
            .catch(err => console.error("Send error:", err));
        }

        function handleKey(e) {
            if (e.key === 'Enter') sendMsg();
        }

        setInterval(loadChat, 1500);
        loadChat();
    </script>
</body>
</html>