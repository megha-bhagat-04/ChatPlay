package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;

@WebServlet("/CheckAcceptedServlet")
public class CheckAcceptedServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");
        if(userId == null) return;

        response.setContentType("application/json");

        try {
            Connection con = DBConnection.getConnection();
            // Check for any SENT invite that was accepted in the last 60 seconds
            PreparedStatement ps = con.prepareStatement(
                "SELECT game_id FROM game_invites WHERE sender_id=? AND status='accepted' AND game_id IS NOT NULL LIMIT 1"
            );
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                int gameId = rs.getInt("game_id");
                
                // ✅ UPDATE to 'started' so we don't keep redirecting
                PreparedStatement update = con.prepareStatement(
                    "UPDATE game_invites SET status='started' WHERE sender_id=? AND game_id=?"
                );
                update.setInt(1, userId);
                update.setInt(2, gameId);
                update.executeUpdate();

                response.getWriter().write("{\"gameId\":" + gameId + "}");
            } else {
                response.getWriter().write("{}");
            }
        } catch(Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"DB error\"}");
        }
    }
}
