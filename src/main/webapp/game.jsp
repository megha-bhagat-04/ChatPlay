<%--
    Document   : game
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
    <title>Tic Tac Toe - ChatPlay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --primary: #6366f1; --bg: #f9fafb; --text: #111827; --border: #e2e8f0; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; }
        
        .game-card { background: #fff; padding: 50px; border-radius: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); text-align: center; border: 1px solid var(--border); }
        h1 { font-size: 28px; font-weight: 700; color: #1e293b; margin-bottom: 10px; }
        #status { font-weight: 600; margin-bottom: 30px; font-size: 18px; padding: 8px 16px; border-radius: 10px; display: inline-block; }
        .turn-my { background: #eef2ff; color: var(--primary); }
        .turn-wait { background: #f3f4f6; color: #6b7280; }
        .win-msg { background: #dcfce7; color: #166534; }
        .draw-msg { background: #fef3c7; color: #92400e; }

        .board { display: grid; grid-template-columns: repeat(3, 110px); gap: 12px; margin-top: 20px; }
        .cell { width: 110px; height: 110px; background: #fff; border: 2px solid #f1f5f9; border-radius: 16px; font-size: 42px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; color: #1e293b; }
        .cell:hover { border-color: var(--primary); background: #f8fafc; transform: translateY(-2px); }
        .cell.x { color: var(--primary); }
        .cell.o { color: #ec4899; }
        
        .btn { margin-top: 40px; padding: 12px 28px; background: #fff; border: 1px solid var(--border); border-radius: 10px; cursor: pointer; text-decoration: none; color: #64748b; font-weight: 600; font-size: 14px; transition: 0.2s; display: inline-flex; align-items: center; gap: 8px; }
        .btn:hover { background: #f1f5f9; color: var(--text); }
    </style>
</head>
<body>
    <div class="game-card">
        <h1>Tic Tac Toe</h1>
        <div id="status" class="turn-wait">Connecting...</div>
        
        <div class="board" id="board">
            <!-- Board will be drawn by JS -->
        </div>

        <a href="dashboard.jsp" class="btn"><i class="fas fa-home"></i> Exit to Dashboard</a>
    </div>

    <script>
        const GAME_ID = <%= gameId %>;
        const MY_ID = <%= userId %>;
        let boardArr = "---------";

        function drawBoard() {
            const boardEl = document.getElementById('board');
            boardEl.innerHTML = boardArr.split('').map((v, i) => {
                const charVal = v === '-' ? '' : v;
                const cls = v === 'X' ? 'x' : (v === 'O' ? 'o' : '');
                return '<div class="cell ' + cls + '" onclick="makeMove(' + i + ')">' + charVal + '</div>';
            }).join('');
        }

        let currentTurn = 0;
        let isGameOver = false;
        let opponentId = 0;

        function loadStatus() {
            fetch('GameStateServlet?gameId=' + GAME_ID)
                .then(res => res.json())
                .then(data => {
                    if (data.error) {
                         document.getElementById('status').innerText = data.error;
                         return;
                    }
                    boardArr = data.board;
                    currentTurn = data.turn;
                    opponentId = (data.player1 == MY_ID) ? data.player2 : data.player1;
                    drawBoard();
                    
                    const statusEl = document.getElementById('status');
                    statusEl.className = '';
                    
                    if (data.winner == -1 || data.winner != 0) {
                        isGameOver = true;
                        if (data.winner == -1) {
                            statusEl.innerHTML = '<i class="fas fa-handshake"></i> It\'s a Draw!';
                            statusEl.classList.add('draw-msg');
                        } else if (data.winner == MY_ID) {
                            statusEl.innerHTML = '<i class="fas fa-trophy"></i> Victory!';
                            statusEl.classList.add('win-msg');
                        } else {
                            statusEl.innerHTML = '<i class="fas fa-flag-checkered"></i> Opponent Won';
                            statusEl.classList.add('turn-wait');
                        }
                        
                        // Show Action Buttons
                        if(!document.getElementById('actionPanel')) {
                            const panel = document.createElement('div');
                            panel.id = 'actionPanel';
                            panel.style.display = 'flex';
                            panel.style.gap = '10px';
                            panel.style.justifyContent = 'center';

                            const again = document.createElement('a');
                            again.href = 'SendGameInviteServlet?receiver_id=' + opponentId;
                            again.className = 'btn';
                            again.style.background = 'var(--primary)';
                            again.style.color = '#fff';
                            again.innerHTML = '<i class="fas fa-redo"></i> Play Again';
                            
                            panel.appendChild(again);
                            document.querySelector('.game-card').appendChild(panel);
                        }
                    } else {
                        // Ongoing
                        if(currentTurn == MY_ID) {
                            statusEl.innerHTML = '<i class="fas fa-star"></i> YOUR TURN';
                            statusEl.classList.add('turn-my');
                        } else {
                            statusEl.innerHTML = '<i class="fas fa-spinner fa-spin"></i> WAITING...';
                            statusEl.classList.add('turn-wait');
                        }
                    }
                })
                .catch(err => console.error(err));
        }

        function makeMove(pos) {
            if(isGameOver) return;
            if(currentTurn != MY_ID) {
                alert("Please wait for your turn.");
                return;
            }
            if(boardArr.charAt(pos) != '-') return;

            fetch('MoveServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'gameId=' + GAME_ID + '&pos=' + pos
            }).then(() => loadStatus());
        }

        setInterval(loadStatus, 1500);
        loadStatus();
    </script>
</body>
</html>