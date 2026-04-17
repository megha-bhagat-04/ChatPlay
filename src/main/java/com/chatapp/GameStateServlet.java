package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;

@WebServlet("/GameStateServlet")
public class GameStateServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        String gameIdStr = request.getParameter("gameId");
        if(gameIdStr == null) return;
        int gameId = Integer.parseInt(gameIdStr);

        response.setContentType("application/json");

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT board, winner, player1, player2, turn FROM games WHERE game_id=?"
            );
            ps.setInt(1, gameId);
            ResultSet rs = ps.executeQuery();

            if(rs.next()){
                String board = rs.getString("board");
                int winner = rs.getInt("winner");
                int p1 = rs.getInt("player1");
                int p2 = rs.getInt("player2");
                int turn = rs.getInt("turn");

                response.getWriter().write(
                   "{\"board\":\""+board+"\",\"winner\":"+winner+",\"player1\":"+p1+",\"player2\":"+p2+",\"turn\":"+turn+"}"
                );
            }
        } catch(Exception e){
            e.printStackTrace();
            response.getWriter().write("{\"error\":\"Internal Server Error\"}");
        }
    }
}