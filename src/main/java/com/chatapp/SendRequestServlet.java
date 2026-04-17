/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class SendRequestServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        Integer userIdObj = (Integer) request.getSession().getAttribute("user_id");

        if(userIdObj == null){
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = userIdObj;
        int friendId = Integer.parseInt(request.getParameter("friend_id"));

        try {
            Connection con = DBConnection.getConnection();

            // prevent duplicate request (both directions)
            PreparedStatement check = con.prepareStatement(
                "SELECT * FROM friends WHERE (user_id=? AND friend_id=?) OR (user_id=? AND friend_id=?)"
            );
            check.setInt(1, userId);
            check.setInt(2, friendId);
            check.setInt(3, friendId);
            check.setInt(4, userId);

            ResultSet rs = check.executeQuery();

            if(!rs.next()) {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO friends(user_id, friend_id, status) VALUES(?,?, 'pending')"
                );

                ps.setInt(1, userId);
                ps.setInt(2, friendId);

                ps.executeUpdate();
            }

            response.sendRedirect("findFriends.jsp");

        } catch(Exception e){
            e.printStackTrace();
        }
    }
}