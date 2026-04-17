<%--
    Document   : rps
    Author     : meghabhagat
--%>
<%@ page import="java.sql.*, com.chatapp.DBConnection" %>
<%
Integer userIdObj = (Integer) session.getAttribute("user_id");
if(userIdObj == null){ response.sendRedirect("login.jsp"); return; }
int userId = userIdObj;

String gameIdStr = request.getParameter("gameId");
if(gameIdStr == null){ response.sendRedirect("dashboard.jsp"); return; }
int gameId = Integer.parseInt(gameIdStr);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Rock Paper Scissors - ChatPlay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --primary: #6366f1; --bg: #f9fafb; --text: #111827; --border: #e2e8f0; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; }
        
        .game-card { background: #fff; padding: 50px; border-radius: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); text-align: center; border: 1px solid var(--border); width: 100%; max-width: 500px; }
        h1 { font-size: 26px; font-weight: 700; color: #1e293b; margin-bottom: 30px; }
        
        #status { font-weight: 600; margin-bottom: 40px; font-size: 18px; padding: 10px 20px; border-radius: 12px; display: inline-block; background: #f3f4f6; color: #6b7280; }
        .win { background: #dcfce7 !important; color: #166534 !important; }
        .loose { background: #fee2e2 !important; color: #991b1b !important; }

        .choices { display: flex; justify-content: center; gap: 20px; margin-bottom: 40px; }
        .choice-btn { width: 100px; height: 100px; background: #fff; border: 2px solid #f1f5f9; border-radius: 20px; font-size: 32px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; }
        .choice-btn:hover { border-color: var(--primary); transform: translateY(-5px); background: #f8fafc; }
        .choice-btn.selected { border-color: var(--primary); background: #eef2ff; border-width: 3px; }
        .choice-btn.disabled { opacity: 0.5; cursor: not-allowed; pointer-events: none; }

        .result-area { display: flex; justify-content: space-around; align-items: center; margin-bottom: 30px; padding: 20px; background: #f8fafc; border-radius: 16px; display: none; }
        .player-result i { font-size: 40px; color: var(--primary); }
        .vs { font-weight: 800; color: #cbd5e1; font-size: 20px; }

        .btn { margin-top: 20px; padding: 12px 28px; background: #fff; border: 1px solid var(--border); border-radius: 10px; cursor: pointer; text-decoration: none; color: #64748b; font-weight: 600; font-size: 14px; transition: 0.2s; display: inline-flex; align-items: center; gap: 8px; }
        .btn:hover { background: #f1f5f9; color: var(--text); }
        .choice-label { margin-top: 8px; font-size: 12px; font-weight: 600; color: #6b7280; }
    </style>
</head>
<body>
    <div class="game-card">
        <h1>Rock Paper Scissors</h1>
        <div id="status">Make your choice!</div>
        
        <div class="result-area" id="resultArea">
            <div class="player-result">
                <div style="font-size:12px; margin-bottom:8px; font-weight:600;">YOU</div>
                <div id="myChoiceIcon" style="font-size:36px;">✊</div>
            </div>
            <div class="vs">VS</div>
            <div class="player-result">
                <div style="font-size:12px; margin-bottom:8px; font-weight:600;">OPPONENT</div>
                <div id="oppChoiceIcon" style="font-size:36px;">❓</div>
            </div>
        </div>

        <div class="choices" id="choicesRow">
            <div onclick="makeChoice('R')">
                <button class="choice-btn" id="btnR">✊</button>
                <div class="choice-label">ROCK</div>
            </div>
            <div onclick="makeChoice('P')">
                <button class="choice-btn" id="btnP">✋</button>
                <div class="choice-label">PAPER</div>
            </div>
            <div onclick="makeChoice('S')">
                <button class="choice-btn" id="btnS">✌️</button>
                <div class="choice-label">SCISSORS</div>
            </div>
        </div>

        <a href="dashboard.jsp" class="btn"><i class="fas fa-home"></i> Back to Home</a>
    </div>

    <script>
        const GAME_ID = <%= gameId %>;
        const MY_ID = <%= userId %>;
        let myDone = false;
        const icons = { 'R': '✊', 'P': '✋', 'S': '✌️', '-': '❓' };

        function loadStatus() {
            fetch(`GameStateServlet?gameId=\${GAME_ID}`)
                .then(res => res.json())
                .then(data => {
                    const statusEl = document.getElementById('status');
                    const board = data.board; // e.g. "RP"
                    const isPlayer1 = (data.player1 == MY_ID);
                    const myIdx = isPlayer1 ? 0 : 1;
                    const oppIdx = isPlayer1 ? 1 : 0;
                    
                    const myChoice = board[myIdx];
                    const oppChoice = board[oppIdx];

                    if (myChoice !== '-') {
                        myDone = true;
                        document.querySelectorAll('.choice-btn').forEach(b => b.classList.add('disabled'));
                        document.getElementById('btn' + myChoice).classList.add('selected');
                        document.getElementById('btn' + myChoice).classList.remove('disabled');
                    }

                    if (data.winner != 0) {
                        document.getElementById('resultArea').style.display = 'flex';
                        document.getElementById('choicesRow').style.display = 'none';
                        document.getElementById('myChoiceIcon').innerText = icons[myChoice];
                        document.getElementById('oppChoiceIcon').innerText = icons[oppChoice];
                        
                        if (data.winner == -1) {
                            statusEl.innerText = "It's a Draw! 🤝";
                            statusEl.className = '';
                        } else if (data.winner == MY_ID) {
                            statusEl.innerText = "You Won! 🎉";
                            statusEl.className = 'win';
                        } else {
                            statusEl.innerText = "You Lost! 💀";
                            statusEl.className = 'loose';
                        }
                    } else {
                        if (myChoice !== '-' && oppChoice === '-') {
                            statusEl.innerText = "Waiting for opponent...";
                        } else if (myChoice === '-') {
                            statusEl.innerText = "Your Turn!";
                        }
                    }
                });
        }

        function makeChoice(c) {
            if (myDone) return;
            fetch('MoveServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: `gameId=\${GAME_ID}&pos=-1&choice=\${c}` // pos -1 means RPS choice
            }).then(() => loadStatus());
        }

        setInterval(loadStatus, 2000);
        loadStatus();
    </script>
</body>
</html>
