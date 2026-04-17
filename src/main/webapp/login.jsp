<%--
    Document   : login
    Author     : meghabhagat
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - ChatPlay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #6366f1;
            --primary-hover: #4f46e5;
            --bg: #f3f4f6;
            --card-bg: #ffffff;
            --text-main: #1f2937;
            --text-muted: #6b7280;
            --error: #ef4444;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg);
            color: var(--text-main);
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }
        .container {
            background: var(--card-bg);
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
            text-align: center;
        }
        .logo { font-size: 32px; font-weight: 700; color: var(--primary); margin-bottom: 24px; display: flex; align-items: center; justify-content: center; gap: 10px; }
        h1 { font-size: 24px; margin-bottom: 8px; font-weight: 600; }
        p { color: var(--text-muted); font-size: 14px; margin-bottom: 32px; }
        
        .role-tabs { display: flex; background: #e5e7eb; padding: 4px; border-radius: 8px; margin-bottom: 24px; }
        .tab { flex: 1; padding: 8px; border-radius: 6px; font-size: 14px; font-weight: 500; cursor: pointer; transition: 0.2s; border: none; background: transparent; color: var(--text-muted); }
        .tab.active { background: #fff; color: var(--primary); box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        
        .form-group { text-align: left; margin-bottom: 20px; }
        .form-group label { display: block; font-size: 13px; font-weight: 500; margin-bottom: 6px; color: var(--text-main); }
        .input-wrapper { position: relative; }
        .input-wrapper i { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: var(--text-muted); font-size: 14px; }
        .form-group input { width: 100%; padding: 12px 12px 12px 40px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 14px; outline: none; transition: 0.2s; font-family: inherit; }
        .form-group input:focus { border-color: var(--primary); ring: 2px solid rgba(99, 102, 241, 0.2); }
        
        .btn { width: 100%; padding: 12px; background: var(--primary); color: #fff; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; transition: 0.2s; margin-top: 10px; font-family: inherit; }
        .btn:hover { background: var(--primary-hover); }
        
        .links { margin-top: 24px; font-size: 14px; }
        .links a { color: var(--primary); text-decoration: none; font-weight: 500; }
        .links a:hover { text-decoration: underline; }
        
        .error-box { background: #fee2e2; color: var(--error); padding: 10px; border-radius: 8px; font-size: 13px; margin-bottom: 20px; border: 1px solid #fecaca; display: none; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo"><i class="fas fa-comments"></i> ChatPlay</div>
        <h1>Welcome Back</h1>
        <p id="subtext">Sign in to your account to continue</p>
        
        <div class="role-tabs">
            <button class="tab active" onclick="setRole('user')">User</button>
            <button class="tab" onclick="setRole('admin')">Admin</button>
        </div>

        <% String err = request.getParameter("error"); %>
        <div class="error-box" id="errorBox" <%= (err != null) ? "style='display:block;'" : "" %>>
            <% if("invalid".equals(err)) { %> Invalid email or password.
            <% } else if("banned".equals(err)) { %> Your account is banned. <% } %>
        </div>

        <form action="LoginServlet" method="post">
            <input type="hidden" name="role" id="roleInput" value="user">
            <div class="form-group">
                <label>Email Address</label>
                <div class="input-wrapper">
                    <i class="fas fa-envelope"></i>
                    <input type="email" name="email" placeholder="name@example.com" required>
                </div>
            </div>
            <div class="form-group">
                <label>Password</label>
                <div class="input-wrapper">
                    <i class="fas fa-lock"></i>
                    <input type="password" name="password" placeholder="********" required>
                </div>
            </div>
            <button type="submit" class="btn">Sign In</button>
        </form>

        <div class="links" id="registerLink">
            Don't have an account? <a href="register.jsp">Create one</a>
        </div>
    </div>

    <script>
        function setRole(role) {
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            event.target.classList.add('active');
            document.getElementById('roleInput').value = role;
            
            const subtext = document.getElementById('subtext');
            const regLink = document.getElementById('registerLink');
            
            if(role === 'admin') {
                subtext.textContent = 'Sign in to the Admin Panel';
                regLink.style.display = 'none';
            } else {
                subtext.textContent = 'Sign in to your account to continue';
                regLink.style.display = 'block';
            }
        }
    </script>
</body>
</html>