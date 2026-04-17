package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;

public class RejectRequestServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("DELETE FROM friends WHERE id=?");
            ps.setInt(1, id);
            ps.executeUpdate();
            response.sendRedirect("dashboard.jsp?page=requests");
        } catch(Exception e){
            e.printStackTrace();
        }
    }
}
