package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;

@WebServlet("/AcceptGameServlet")
public class AcceptGameServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        HttpSession session = request.getSession();
        if(session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int userId = (int) session.getAttribute("user_id");
        String idStr = request.getParameter("id");
        if(idStr == null) {
            response.sendRedirect("dashboard.jsp");
            return;
        }
        int inviteId = Integer.parseInt(idStr);

        try {
            Connection con = DBConnection.getConnection();

            PreparedStatement get = con.prepareStatement("SELECT sender_id FROM game_invites WHERE id=?");
            get.setInt(1, inviteId);
            ResultSet rs = get.executeQuery();
            if(!rs.next()) {
                response.sendRedirect("dashboard.jsp");
                return;
            }
            int senderId = rs.getInt("sender_id");

            // Create game
            PreparedStatement create = con.prepareStatement(
                "INSERT INTO games(player1, player2, turn, board, winner) VALUES(?,?,?,?,0)",
                Statement.RETURN_GENERATED_KEYS
            );
            create.setInt(1, senderId);
            create.setInt(2, userId);
            create.setInt(3, senderId);
            create.setString(4, "---------");
            create.executeUpdate();

            ResultSet keys = create.getGeneratedKeys();
            keys.next();
            int gameId = keys.getInt(1);

            // ✅ CRITICAL: Update invite with status AND game_id so sender can find it
            PreparedStatement update = con.prepareStatement(
                "UPDATE game_invites SET status='accepted', game_id=? WHERE id=?"
            );
            update.setInt(1, gameId);
            update.setInt(2, inviteId);
            update.executeUpdate();

            response.sendRedirect("game.jsp?gameId=" + gameId);

        } catch(Exception e){
            e.printStackTrace();
            // Fallback if game_id column doesn't exist yet but user is accepting
            try {
                Connection con = DBConnection.getConnection();
                PreparedStatement update = con.prepareStatement("UPDATE game_invites SET status='accepted' WHERE id=?");
                update.setInt(1, inviteId);
                update.executeUpdate();
                response.sendRedirect("dashboard.jsp?msg=accepted_no_link");
            } catch(Exception e2) {
                 response.sendRedirect("dashboard.jsp?error=accept_failed");
            }
        }
    }
}