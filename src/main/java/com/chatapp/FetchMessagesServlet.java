/*
 * FetchMessagesServlet - returns JSON array for chat.jsp's AJAX calls
 */
package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class FetchMessagesServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        Integer userIdObj = (Integer) request.getSession().getAttribute("user_id");
        if(userIdObj == null){
            response.setStatus(401);
            return;
        }

        int userId = userIdObj;
        String friendIdStr = request.getParameter("friendId");
        if(friendIdStr == null){ response.setStatus(400); return; }
        int friendId = Integer.parseInt(friendIdStr);

        String format = request.getParameter("format"); // "json" or null (legacy html)

        response.setContentType(format != null && format.equals("json") ? "application/json" : "text/html");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Connection con = DBConnection.getConnection();

            // ✅ MARK AS READ: When fetching, mark all messages FROM friend TO user as read (with safety check)
            try {
                PreparedStatement markRead = con.prepareStatement(
                    "UPDATE messages SET is_read=TRUE WHERE sender_id=? AND receiver_id=? AND (is_read=FALSE OR is_read IS NULL)"
                );
                markRead.setInt(1, friendId);
                markRead.setInt(2, userId);
                markRead.executeUpdate();
            } catch(Exception e) {
                // Skip if column is_read doesn't exist yet
            }

            PreparedStatement ps = con.prepareStatement(
                "SELECT m.message_id, m.sender_id, m.receiver_id, m.message, m.timestamp, u.username " +
                "FROM messages m JOIN users u ON m.sender_id = u.user_id " +
                "WHERE (m.sender_id=? AND m.receiver_id=?) OR (m.sender_id=? AND m.receiver_id=?) " +
                "ORDER BY m.timestamp ASC"
            );
            ps.setInt(1, userId); ps.setInt(2, friendId);
            ps.setInt(3, friendId); ps.setInt(4, userId);

            ResultSet rs = ps.executeQuery();

            if(format != null && format.equals("json")){
                // JSON response for modern chat UI
                StringBuilder sb = new StringBuilder("[");
                boolean first = true;
                while(rs.next()){
                    if(!first) sb.append(",");
                    first = false;
                    String rawMsg = rs.getString("message");
                    String msg = (rawMsg != null) ? rawMsg
                        .replace("\\", "\\\\").replace("\"", "\\\"")
                        .replace("\n", "\\n").replace("\r", "") : "";
                        
                    String ts = rs.getTimestamp("timestamp") != null
                        ? rs.getTimestamp("timestamp").toString()
                        : "";
                    sb.append("{")
                      .append("\"id\":").append(rs.getInt("message_id")).append(",")
                      .append("\"senderId\":").append(rs.getInt("sender_id")).append(",")
                      .append("\"receiverId\":").append(rs.getInt("receiver_id")).append(",")
                      .append("\"message\":\"").append(msg).append("\",")
                      .append("\"timestamp\":\"").append(ts).append("\",")
                      .append("\"username\":\"").append(rs.getString("username")).append("\"")
                      .append("}");
                }
                sb.append("]");
                out.print(sb.toString());
            } else {
                // Legacy HTML for backwards compatibility
                while(rs.next()){
                    if(rs.getInt("sender_id") == userId){
                        out.println("<div style='text-align:right;color:#6c63ff;padding:4px 0;'>You: " + rs.getString("message") + "</div>");
                    } else {
                        out.println("<div style='text-align:left;color:#43e97b;padding:4px 0;'>" + rs.getString("username") + ": " + rs.getString("message") + "</div>");
                    }
                }
            }

        } catch(Exception e){
            e.printStackTrace();
            if(format != null && format.equals("json")){
                out.print("[]");
            }
        }
    }
}