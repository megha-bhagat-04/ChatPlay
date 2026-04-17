package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;

@WebServlet("/RealTimeStatusServlet")
public class RealTimeStatusServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");
        if(userId == null) return;

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Connection con = DBConnection.getConnection();
            
            // Return counts for refresh logic
            int requests = 0, invites = 0, messages = 0, sentDeclined = 0;
            
            PreparedStatement psCount = con.prepareStatement("SELECT COUNT(*) FROM friends WHERE friend_id=? AND status='pending'");
            psCount.setInt(1, userId);
            ResultSet rs = psCount.executeQuery();
            if(rs.next()) requests = rs.getInt(1);
            
            psCount = con.prepareStatement("SELECT COUNT(*) FROM game_invites WHERE receiver_id=? AND status='pending'");
            psCount.setInt(1, userId);
            rs = psCount.executeQuery();
            if(rs.next()) invites = rs.getInt(1);

            psCount = con.prepareStatement("SELECT COUNT(*) FROM game_invites WHERE sender_id=? AND status='declined'");
            psCount.setInt(1, userId);
            rs = psCount.executeQuery();
            if(rs.next()) sentDeclined = rs.getInt(1);

            // Unread Messages Count (Sync with dropdown list logic)
            try {
                PreparedStatement psM = con.prepareStatement(
                    "SELECT COUNT(*) FROM messages m JOIN users u ON m.sender_id = u.user_id " +
                    "WHERE m.receiver_id=? AND (m.is_read IS NULL OR m.is_read=FALSE)"
                );
                psM.setInt(1, userId);
                rs = psM.executeQuery();
                if(rs.next()) messages = rs.getInt(1);
            } catch(Exception e) { e.printStackTrace(); }

            // 2. Check for newly accepted game to redirect (for sender)
            int redirectGameId = 0;
            PreparedStatement psS = con.prepareStatement(
                "SELECT game_id FROM game_invites WHERE sender_id=? AND status='accepted' AND game_id IS NOT NULL LIMIT 1"
            );
            psS.setInt(1, userId);
            ResultSet rsS = psS.executeQuery();
            if(rsS.next()){
                redirectGameId = rsS.getInt("game_id");
                // Mark as started so we don't redirect again
                PreparedStatement up = con.prepareStatement("UPDATE game_invites SET status='started' WHERE sender_id=? AND game_id=?");
                up.setInt(1, userId);
                up.setInt(2, redirectGameId);
                up.executeUpdate();
            }

            // 3. Fetch recent notifications for dropdown
            StringBuilder msgList = new StringBuilder("[");
            try {
                PreparedStatement psMsg = con.prepareStatement(
                    "SELECT m.message, u.username, m.sender_id FROM messages m " +
                    "JOIN users u ON m.sender_id = u.user_id " +
                    "WHERE m.receiver_id=? AND (m.is_read IS NULL OR m.is_read=FALSE) ORDER BY m.timestamp DESC LIMIT 5"
                );
                psMsg.setInt(1, userId);
                ResultSet rsMsg = psMsg.executeQuery();
                while(rsMsg.next()){
                    if(msgList.length() > 1) msgList.append(",");
                    String cleanMsg = rsMsg.getString("message").replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
                    msgList.append("{")
                          .append("\"sender\":\"").append(rsMsg.getString("username")).append("\",")
                          .append("\"senderId\":").append(rsMsg.getInt("sender_id")).append(",")
                          .append("\"text\":\"").append(cleanMsg).append("\"")
                          .append("}");
                }
            } catch(Exception e) { 
                e.printStackTrace(); // Log error to help identify column mismatches
            }
            msgList.append("]");

            StringBuilder invList = new StringBuilder("[");
            try {
                // Try full query first (with game_type and ordering)
                PreparedStatement psInv = con.prepareStatement(
                    "SELECT gi.id, u.username, gi.game_type FROM game_invites gi " +
                    "JOIN users u ON gi.sender_id = u.user_id " +
                    "WHERE gi.receiver_id=? AND gi.status='pending' ORDER BY gi.created_at DESC LIMIT 5"
                );
                psInv.setInt(1, userId);
                ResultSet rsInv = psInv.executeQuery();
                while(rsInv.next()){
                    if(invList.length() > 1) invList.append(",");
                    String gType = rsInv.getString("game_type");
                    if(gType == null) gType = "tic_tac_toe";
                    invList.append("{")
                          .append("\"id\":").append(rsInv.getInt("id")).append(",")
                          .append("\"sender\":\"").append(rsInv.getString("username")).append("\",")
                          .append("\"type\":\"").append(gType).append("\"")
                          .append("}");
                }
            } catch(Exception e1) {
                try {
                    // Fallback query (minimal columns)
                    PreparedStatement psInvSimple = con.prepareStatement(
                        "SELECT gi.id, u.username FROM game_invites gi " +
                        "JOIN users u ON gi.sender_id = u.user_id " +
                        "WHERE gi.receiver_id=? AND gi.status='pending' LIMIT 5"
                    );
                    psInvSimple.setInt(1, userId);
                    ResultSet rsInvS = psInvSimple.executeQuery();
                    while(rsInvS.next()){
                        if(invList.length() > 1) invList.append(",");
                        invList.append("{")
                              .append("\"id\":").append(rsInvS.getInt("id")).append(",")
                              .append("\"sender\":\"").append(rsInvS.getString("username")).append("\",")
                              .append("\"type\":\"Game\"")
                              .append("}");
                    }
                } catch(Exception e2) { /* Complete failure */ }
            }
            invList.append("]");

            // Return everything in one JSON call
            out.print("{");
            out.print("\"requests\":" + requests + ",");
            out.print("\"invites\":" + invites + ",");
            out.print("\"messages\":" + messages + ",");
            out.print("\"sentDeclined\":" + sentDeclined + ",");
            out.print("\"redirect\":" + redirectGameId + ",");
            out.print("\"recentMsgs\":" + msgList.toString() + ",");
            out.print("\"recentInvs\":" + invList.toString());
            out.print("}");

        } catch(Exception e) {
            e.printStackTrace();
            out.print("{}");
        }
    }
}
