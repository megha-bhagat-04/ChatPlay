package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;

@WebServlet("/CancelGameInviteServlet")
public class CancelGameInviteServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");
        if(userId == null) return;

        String inviteIdStr = request.getParameter("id");
        if(inviteIdStr == null) return;
        int inviteId = Integer.parseInt(inviteIdStr);

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "DELETE FROM game_invites WHERE id=? AND sender_id=? AND (status='pending' OR status='declined')"
            );
            ps.setInt(1, inviteId);
            ps.setInt(2, userId);
            ps.executeUpdate();

            response.sendRedirect("dashboard.jsp?page=gameInvites&msg=cancelled");
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?error=cancel_failed");
        }
    }
}
