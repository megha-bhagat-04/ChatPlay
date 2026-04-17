package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class BlockUserServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        Integer myId = (Integer) request.getSession().getAttribute("user_id");
        String friendIdStr = request.getParameter("friendId");
        
        if (myId == null || friendIdStr == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int friendId = Integer.parseInt(friendIdStr);
        
        try {
            Connection con = DBConnection.getConnection();
            // Delete existing friendship and insert a blocked status
            PreparedStatement psDel = con.prepareStatement(
                "DELETE FROM friends WHERE (user_id=? AND friend_id=?) OR (user_id=? AND friend_id=?)"
            );
            psDel.setInt(1, myId); psDel.setInt(2, friendId);
            psDel.setInt(3, friendId); psDel.setInt(4, myId);
            psDel.executeUpdate();
            
            PreparedStatement psBlock = con.prepareStatement(
                "INSERT INTO friends (user_id, friend_id, status) VALUES (?, ?, 'blocked')"
            );
            psBlock.setInt(1, myId);
            psBlock.setInt(2, friendId);
            psBlock.executeUpdate();
            
            response.sendRedirect("dashboard.jsp?page=friends");
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp");
        }
    }
}
