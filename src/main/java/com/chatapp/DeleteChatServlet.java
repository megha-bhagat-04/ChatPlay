package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class DeleteChatServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        Integer userIdObj = (Integer) request.getSession().getAttribute("user_id");
        if(userIdObj == null){
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = userIdObj;
        String friendIdStr = request.getParameter("friendId");
        if(friendIdStr == null){
            return;
        }
        int friendId = Integer.parseInt(friendIdStr);

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "DELETE FROM messages WHERE (sender_id=? AND receiver_id=?) OR (sender_id=? AND receiver_id=?)"
            );
            ps.setInt(1, userId);
            ps.setInt(2, friendId);
            ps.setInt(3, friendId);
            ps.setInt(4, userId);

            ps.executeUpdate();
            
            // Note: Does not delete friendship, only chat history.
            response.setStatus(200);

        } catch(Exception e){
            e.printStackTrace();
            response.setStatus(500);
        }
    }
}
