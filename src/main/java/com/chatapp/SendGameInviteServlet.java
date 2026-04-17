package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;

@WebServlet("/SendGameInviteServlet")
public class SendGameInviteServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        Integer senderObj = (Integer) request.getSession().getAttribute("user_id");
        if(senderObj == null){
            response.sendRedirect("login.jsp");
            return;
        }

        int senderId = senderObj;
        String receiverStr = request.getParameter("receiver_id");
        String gameType = request.getParameter("type"); // Optional column support
        if(gameType == null) gameType = "tic_tac_toe";

        if(receiverStr == null || receiverStr.trim().isEmpty()) {
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int receiverId = Integer.parseInt(receiverStr);

        try {
            Connection con = DBConnection.getConnection();

            // CHECK DUPLICATE (Active only)
            PreparedStatement check = con.prepareStatement(
                "SELECT * FROM game_invites WHERE sender_id=? AND receiver_id=? AND (status='pending' OR status='declined')"
            );
            check.setInt(1, senderId);
            check.setInt(2, receiverId);
            ResultSet rs = check.executeQuery();

            if(!rs.next()){
                // Defensive: check if game_type column exists or just try insert
                try {
                    PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO game_invites(sender_id, receiver_id, status, game_type) VALUES(?,?,'pending',?)"
                    );
                    ps.setInt(1, senderId);
                    ps.setInt(2, receiverId);
                    ps.setString(3, gameType);
                    ps.executeUpdate();
                } catch(Exception sqlE) {
                    // Fallback if game_type column is missing
                    PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO game_invites(sender_id, receiver_id, status) VALUES(?,?,'pending')"
                    );
                    ps.setInt(1, senderId);
                    ps.setInt(2, receiverId);
                    ps.executeUpdate();
                }
            } else {
                // If it was declined previously, reset it to pending
                PreparedStatement reset = con.prepareStatement(
                    "UPDATE game_invites SET status='pending' WHERE sender_id=? AND receiver_id=? AND status='declined'"
                );
                reset.setInt(1, senderId);
                reset.setInt(2, receiverId);
                reset.executeUpdate();
            }

            // REDIRECT TO INVITES PAGE AS REQUESTED
            response.sendRedirect("dashboard.jsp?page=gameInvites&msg=sent");

        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?error=invite_failed");
        }
    }
}