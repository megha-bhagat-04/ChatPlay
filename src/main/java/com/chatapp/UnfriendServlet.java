package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class UnfriendServlet extends HttpServlet {
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
            PreparedStatement ps = con.prepareStatement(
                "DELETE FROM friends WHERE (user_id=? AND friend_id=?) OR (user_id=? AND friend_id=?)"
            );
            ps.setInt(1, myId); ps.setInt(2, friendId);
            ps.setInt(3, friendId); ps.setInt(4, myId);
            ps.executeUpdate();
            
            response.sendRedirect("dashboard.jsp?page=friends");
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp");
        }
    }
}
