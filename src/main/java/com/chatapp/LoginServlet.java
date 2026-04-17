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

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM users WHERE email=? AND password=? AND status='active'"
            );

            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if(rs.next()) {

                HttpSession session = request.getSession();
                session.setAttribute("user_id", rs.getInt("user_id"));
                session.setAttribute("username", rs.getString("username"));
                session.setAttribute("profile_pic", rs.getString("profile_pic"));
                String role = rs.getString("role");
                session.setAttribute("role", role);

                if ("admin".equalsIgnoreCase(role)) {
                    response.sendRedirect("admin_dashboard.jsp");
                } else {
                    response.sendRedirect("dashboard.jsp");
                }

            } else {
                // Check if user exists but is banned
                PreparedStatement psBan = con.prepareStatement(
                    "SELECT status FROM users WHERE email=? AND password=?"
                );
                psBan.setString(1, email);
                psBan.setString(2, password);
                ResultSet rsBan = psBan.executeQuery();
                if(rsBan.next() && "banned".equals(rsBan.getString("status"))) {
                    response.sendRedirect("login.jsp?error=banned");
                } else {
                    response.sendRedirect("login.jsp?error=invalid");
                }
            }

        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}