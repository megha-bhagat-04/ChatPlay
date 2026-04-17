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

public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            Connection con = DBConnection.getConnection();

            PreparedStatement check = con.prepareStatement("SELECT * FROM users WHERE email=?");
            check.setString(1, email);
            ResultSet rsCheck = check.executeQuery();
            
            if(rsCheck.next()){
                response.sendRedirect("register.jsp?error=exists");
                return;
            }

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO users(username, email, password) VALUES(?,?,?)"
            );

            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, password);

            ps.executeUpdate();

            response.sendRedirect("login.jsp?msg=registered");

        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}