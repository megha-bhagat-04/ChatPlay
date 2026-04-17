package com.chatapp;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;

@WebServlet("/MoveServlet")
public class MoveServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {

        HttpSession session = request.getSession();
        if(session.getAttribute("user_id") == null) return;
        
        int userId = (int) session.getAttribute("user_id");
        int gameId = Integer.parseInt(request.getParameter("gameId"));
        int pos = Integer.parseInt(request.getParameter("pos"));

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM games WHERE game_id=?");
            ps.setInt(1, gameId);
            ResultSet rs = ps.executeQuery();
            
            if(rs.next()){
                String board = rs.getString("board");
                int turn = rs.getInt("turn");
                int p1 = rs.getInt("player1");
                int p2 = rs.getInt("player2");
                int winner = rs.getInt("winner");

                if(turn != userId || winner != 0 || board.charAt(pos) != '-') return;

                char symbol = (userId == p1) ? 'X' : 'O';
                StringBuilder newBoard = new StringBuilder(board);
                newBoard.setCharAt(pos, symbol);

                int finalWinner = 0;
                if(checkWin(newBoard.toString(), symbol)) finalWinner = userId;
                else if(!newBoard.toString().contains("-")) finalWinner = -1;

                int nextTurn = (userId == p1) ? p2 : p1;

                PreparedStatement update = con.prepareStatement(
                    "UPDATE games SET board=?, turn=?, winner=? WHERE game_id=?"
                );
                update.setString(1, newBoard.toString());
                update.setInt(2, nextTurn);
                update.setInt(3, finalWinner);
                update.setInt(4, gameId);
                update.executeUpdate();
            }
        } catch(Exception e){
            e.printStackTrace();
        }
    }

    private boolean checkWin(String b, char s) {
        int[][] winPos = {{0,1,2},{3,4,5},{6,7,8},{0,3,6},{1,4,7},{2,5,8},{0,4,8},{2,4,6}};
        for(int[] p : winPos) if(b.charAt(p[0]) == s && b.charAt(p[1]) == s && b.charAt(p[2]) == s) return true;
        return false;
    }
}