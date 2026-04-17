<%--
    Document   : register
    Author     : meghabhagat
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Account - ChatPlay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --primary: #6366f1; --bg: #f3f4f6; --text: #1f2937; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); display: flex; align-items: center; justify-content: center; height: 100vh; }
        .container { background: #fff; padding: 40px; border-radius: 16px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); width: 100%; max-width: 400px; text-align: center; }
        .logo { font-size: 28px; font-weight: 700; color: var(--primary); margin-bottom: 20px; }
        h1 { font-size: 22px; margin-bottom: 10px; }
        p { color: #6b7280; font-size: 14px; margin-bottom: 30px; }
        .form-group { text-align: left; margin-bottom: 20px; }
        label { display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px; }
        input { width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 14px; font-family: inherit; outline: none; transition: 0.2s; }
        input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(99,102,241,0.1); }
        .btn { width: 100%; padding: 12px; background: var(--primary); color: #fff; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; transition: 0.2s; margin-top: 10px; }
        .links { margin-top: 24px; font-size: 14px; }
        .links a { color: var(--primary); text-decoration: none; font-weight: 500; }
        .error { color: #ef4444; font-size: 13px; margin-bottom: 15px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo"><i class="fas fa-comments"></i> ChatPlay</div>
        <h1>Join the community</h1>
        <p>Create your profile to start chatting and playing</p>
        
        <% String err = request.getParameter("error"); %>
        <% if("exists".equals(err)) { %> <div class="error">Email already registered.</div> <% } %>

        <form action="RegisterServlet" method="post">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" placeholder="johndoe" required>
            </div>
            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="email" placeholder="john@example.com" required>
            </div>
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" placeholder="••••••••" required>
            </div>
            <button type="submit" class="btn">Create Account</button>
        </form>
        <div class="links">Already have an account? <a href="login.jsp">Sign in</a></div>
    </div>
</body>
</html>