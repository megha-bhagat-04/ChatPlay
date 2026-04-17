package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;

@WebServlet("/EditProfileServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50   // 50MB
)
public class EditProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        HttpSession session = request.getSession();
        if(session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String bio = request.getParameter("bio");

        String fileName = "";
        Part filePart = request.getPart("profile_pic");

        try {
            Connection con = DBConnection.getConnection();
            
            // Get current profile pic in case no new file is uploaded
            PreparedStatement getOld = con.prepareStatement("SELECT profile_pic FROM users WHERE user_id=?");
            getOld.setInt(1, userId);
            ResultSet rsOld = getOld.executeQuery();
            String currentPic = rsOld.next() ? rsOld.getString("profile_pic") : "";

            if (filePart != null && filePart.getSize() > 0) {
                // Use a simple naming convention for uploads
                String originalFileName = filePart.getSubmittedFileName();
                fileName = "user_" + userId + "_" + System.currentTimeMillis() + "_" + originalFileName;
                
                // Get absolute path to the 'uploads' directory in the webapp
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();

                filePart.write(uploadPath + File.separator + fileName);
                fileName = "uploads/" + fileName; // Store relative path for JSP
            } else {
                fileName = currentPic; // Keep old one
            }

            PreparedStatement ps = con.prepareStatement(
                "UPDATE users SET username=?, email=?, bio=?, profile_pic=? WHERE user_id=?"
            );

            ps.setString(1, username);
            ps.setString(2, email);
            ps.setString(3, bio);
            ps.setString(4, fileName);
            ps.setInt(5, userId);

            ps.executeUpdate();
            
            // Sync session
            session.setAttribute("username", username);
            session.setAttribute("profile_pic", fileName);

            response.sendRedirect("profile.jsp?msg=updated");

        } catch(Exception e){
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}