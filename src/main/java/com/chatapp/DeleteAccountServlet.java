package com.chatapp;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import com.chatapp.DBConnection;
import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class DeleteAccountServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        int userId = (int) request.getSession().getAttribute("user_id");

        try {
            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "DELETE FROM users WHERE user_id=?"
            );

            ps.setInt(1, userId);
            ps.executeUpdate();

            request.getSession().invalidate();
            response.sendRedirect("register.jsp");

        } catch(Exception e){
            e.printStackTrace();
        }
    }
}