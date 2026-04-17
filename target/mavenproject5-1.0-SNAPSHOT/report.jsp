<%--
    Document   : report
    Author     : meghabhagat
--%>
<%@ page import="java.sql.*, com.chatapp.DBConnection" %>
<%
if(session.getAttribute("user_id") == null){ response.sendRedirect("login.jsp"); return; }
String username = (String) session.getAttribute("username");
String reportedName = request.getParameter("name");
if(reportedName == null) reportedName = "User";
String userId = request.getParameter("userId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ChatPlay – Report User</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
:root {
  --bg: #0d0f1a; --surface: rgba(255,255,255,0.05);
  --border: rgba(255,255,255,0.08); --accent: #6c63ff; --accent2: #f857a6;
  --text: #e4e6f0; --muted: #8892b0; --error: #ff6b6b; --radius: 14px;
}
body {
  font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text);
  min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px;
}
.card {
  background: var(--surface); border: 1px solid var(--border); border-radius: 20px;
  padding: 40px; width: 100%; max-width: 460px;
  box-shadow: 0 24px 48px rgba(0,0,0,0.4);
}
.icon-wrap {
  width: 64px; height: 64px; border-radius: 16px;
  background: rgba(255,107,107,0.15); border: 1px solid rgba(255,107,107,0.3);
  display: flex; align-items: center; justify-content: center;
  font-size: 28px; margin-bottom: 20px;
}
h2 { font-size: 22px; font-weight: 700; margin-bottom: 6px; }
p.sub { font-size: 13px; color: var(--muted); margin-bottom: 28px; line-height: 1.5; }
.form-group { margin-bottom: 20px; }
.form-group label { display: block; font-size: 13px; font-weight: 500; color: var(--muted); margin-bottom: 8px; }
.reason-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 14px; }
.reason-btn {
  padding: 10px 14px; border-radius: 8px;
  background: rgba(255,255,255,0.04); border: 1px solid var(--border);
  color: var(--muted); font-size: 12px; font-family: inherit;
  cursor: pointer; transition: all 0.15s; text-align: center;
}
.reason-btn:hover { border-color: var(--error); color: var(--text); background: rgba(255,107,107,0.08); }
.reason-btn.selected { border-color: var(--error); color: var(--text); background: rgba(255,107,107,0.15); }
textarea {
  width: 100%; background: rgba(255,255,255,0.05); border: 1px solid var(--border);
  border-radius: 10px; padding: 12px 14px; color: var(--text); font-size: 14px;
  font-family: inherit; outline: none; resize: vertical; min-height: 80px;
  transition: border-color 0.2s;
}
textarea:focus { border-color: var(--error); }
textarea::placeholder { color: rgba(136,146,176,0.5); }
.btn-row { display: flex; gap: 10px; }
.btn { display: inline-flex; align-items: center; gap: 6px; padding: 11px 22px; border-radius: 10px; font-size: 14px; font-weight: 600; font-family: inherit; cursor: pointer; text-decoration: none; transition: all 0.2s; border: none; }
.btn-danger { background: var(--error); color: #fff; box-shadow: 0 4px 14px rgba(255,107,107,0.3); }
.btn-danger:hover { opacity: 0.9; transform: translateY(-1px); }
.btn-outline { background: transparent; border: 1px solid var(--border); color: var(--muted); }
.btn-outline:hover { border-color: var(--accent); color: var(--text); }
</style>
</head>
<body>
<div class="card">
  <div class="icon-wrap">🚩</div>
  <h2>Report <%= reportedName %></h2>
  <p class="sub">Help us keep ChatPlay safe. Reports are reviewed by our moderation team within 24 hours.</p>

  <form action="ReportServlet" method="post">
    <input type="hidden" name="reported_user" value="<%= userId %>">

    <div class="form-group">
      <label>Select a reason</label>
      <div class="reason-grid">
        <button type="button" class="reason-btn" onclick="selectReason(this,'Harassment')">😤 Harassment</button>
        <button type="button" class="reason-btn" onclick="selectReason(this,'Spam')">📧 Spam</button>
        <button type="button" class="reason-btn" onclick="selectReason(this,'Hate Speech')">🤬 Hate Speech</button>
        <button type="button" class="reason-btn" onclick="selectReason(this,'Cheating')">🎮 Cheating</button>
        <button type="button" class="reason-btn" onclick="selectReason(this,'Inappropriate Content')">🔞 Inappropriate</button>
        <button type="button" class="reason-btn" onclick="selectReason(this,'Other')">❓ Other</button>
      </div>
    </div>

    <div class="form-group">
      <label>Additional details (optional)</label>
      <textarea name="reason" id="reasonInput" placeholder="Describe what happened..."></textarea>
    </div>

    <div class="btn-row">
      <button type="submit" class="btn btn-danger"><i class="fas fa-flag"></i> Submit Report</button>
      <a href="javascript:history.back()" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Cancel</a>
    </div>
  </form>
</div>

<script>
let selectedReason = '';
function selectReason(btn, reason){
  document.querySelectorAll('.reason-btn').forEach(b => b.classList.remove('selected'));
  btn.classList.add('selected');
  selectedReason = reason;
  const input = document.getElementById('reasonInput');
  if(!input.value || input.value === selectedReason){
    input.value = reason;
  }
}
</script>
</body>
</html>