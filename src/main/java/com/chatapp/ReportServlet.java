/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class ReportServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        int reportedUser = Integer.parseInt(request.getParameter("reported_user"));
        int reportedBy = (int) request.getSession().getAttribute("user_id");
        String reason = request.getParameter("reason");

        try {
            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO reports(reported_user, reported_by, reason) VALUES(?,?,?)"
            );

            ps.setInt(1, reportedUser);
            ps.setInt(2, reportedBy);
            ps.setString(3, reason);

            ps.executeUpdate();

            response.sendRedirect("dashboard.jsp");

        } catch(Exception e){
            e.printStackTrace();
        }
    }
}