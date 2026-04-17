package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;

@WebServlet("/DeclineGameServlet")
public class DeclineGameServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");
        if(userId == null) return;

        String idStr = request.getParameter("id");
        if(idStr == null) return;
        int inviteId = Integer.parseInt(idStr);

        try {
            Connection con = DBConnection.getConnection();
            // Update status instead of deleting, so sender sees it's declined
            PreparedStatement ps = con.prepareStatement(
                "UPDATE game_invites SET status='declined' WHERE id=? AND receiver_id=?"
            );
            ps.setInt(1, inviteId);
            ps.setInt(2, userId);
            ps.executeUpdate();

            response.sendRedirect("dashboard.jsp?page=gameInvites&msg=declined");
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?error=decline_failed");
        }
    }
}
