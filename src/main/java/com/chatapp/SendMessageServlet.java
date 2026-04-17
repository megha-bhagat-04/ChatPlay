/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class SendMessageServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        int senderId = (int) request.getSession().getAttribute("user_id");
        int receiverId = Integer.parseInt(request.getParameter("receiver_id"));
        String message = request.getParameter("message");

        try {
            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO messages(sender_id, receiver_id, message, is_read) VALUES(?,?,?,FALSE)"
            );

            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.setString(3, message);

            ps.executeUpdate();

        } catch(Exception e){
            e.printStackTrace();
        }
    }
}