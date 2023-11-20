#!/bin/bash

echo "Tic tac toe"

CURRENT_PLAYER="X"
TURN=true
cells=(0 1 2 3 4 5 6 7 8)
COUNTER=0
FILE="save.txt"

function board {

 echo ""
 echo " ${cells[0]} | ${cells[1]} | ${cells[2]}"
 echo "---+---+---"
 echo " ${cells[3]} | ${cells[4]} | ${cells[5]}"
 echo "---+---+---"
 echo " ${cells[6]} | ${cells[7]} | ${cells[8]}"

}

function menu {

 echo "1. 1 vs 1"
 echo "2. 1 vs AI"
 echo "3. Load"
 echo "4. Exit"
 echo "Choice[1-4]"
}

function fillCell {

 echo ""
 echo "It's $CURRENT_PLAYER turn"
 echo "Input the cell number[0-8], save[s], quit[q] or reset[r]"
 local cell_nr
 
 if [[ $mod == 1 ]] || [[ $mod == 2 && $CURRENT_PLAYER == "X" ]]
 then
  read cell_nr
 else
  cell_nr=$(ai_move)
 fi
 
 if [ $cell_nr == "q" ]
 then
  quit
 elif [ $cell_nr == "r" ]
 then
  reset
 elif [ $cell_nr == "s" ]
 then
  save
  board
  fillCell
 else
  while [[ $cell_nr < 0 || $cell_nr > 8 ]] ||
  [[ ${cells[$cell_nr]} == "X" || ${cells[$cell_nr]} == "O" ]]
  do
   echo "Incorrect input or this cell is already occupaied, try again."
   read cell_nr
  done
  cells[$cell_nr]=$CURRENT_PLAYER
  COUNTER=$((COUNTER+1))
 fi
}

function nextPlayer {
 if [ $TURN == true ]
 then
  CURRENT_PLAYER="O"
  TURN=false
 else
  CURRENT_PLAYER="X"
  TURN=true
 fi
}

function check {
 local isWin=false
    #rows cols diagonal
 if [[ ${cells[0]} == ${cells[1]} && ${cells[0]} == ${cells[2]} ]] ||
    [[ ${cells[3]} == ${cells[4]} && ${cells[3]} == ${cells[5]} ]] ||
    [[ ${cells[6]} == ${cells[7]} && ${cells[6]} == ${cells[8]} ]] ||
    [[ ${cells[0]} == ${cells[3]} && ${cells[0]} == ${cells[6]} ]] ||
    [[ ${cells[1]} == ${cells[4]} && ${cells[1]} == ${cells[7]} ]] ||
    [[ ${cells[2]} == ${cells[5]} && ${cells[2]} == ${cells[8]} ]] ||
    [[ ${cells[0]} == ${cells[4]} && ${cells[4]} == ${cells[8]} ]] ||
    [[ ${cells[2]} == ${cells[4]} && ${cells[4]} == ${cells[6]} ]]
 then
  isWin=true
 fi
 
 if [ $isWin == true ]
 then
  echo "The winner is $CURRENT_PLAYER !"
  quit
 elif [[ $COUNTER == 9 && $isWin == false ]]
 then
  echo "DRAW!"
  quit
 fi
}

function quit {
  echo "See yeah!"
  exit 0
}

function save {
 data="$CURRENT_PLAYER\n$TURN\n$mod\n"
 
 for el in "${cells[@]}"
 do
  data+="$el\n"
 done
 
 echo -e $data > $FILE
 echo "Game saved"
}

function load {
 if [ -e "$FILE" ]
 cells=()
 local i=0
 then
  while read line
  do
   if [ $i == 0 ]
   then
    CURRENT_PLAYER="$line"
   elif [ $i == 1 ]
   then
    TURN="$line"
   elif [ $i == 2 ]
   then
    mod="$line"
   else
    cells+=("$line")
   fi
   i=$((i+1))
  done < "$FILE"
 else
  echo "The file doesn't exist."
 fi
}

function reset {
 clear
 echo "The game has been restarted"
 cells=(0 1 2 3 4 5 6 7 8)
 TURN=false
}

function ai_move {
 local avail=()
 for el in "${cells[@]}"
 do
  if [[ "$el" != "X" && "$el" != "O" ]]
  then
   avail+=("$el")
  fi
 done
 
 rand=$(shuf -e "${avail[@]}" -n 1)
 echo $rand
}

#MENU
menu
read mod
while [[ $mod < 1 || $mod > 4 ]]
do
 echo "Incorrect input, try again."
 read mod
done

if [ $mod == 3 ]
then
 load
fi

if [ $mod == 4 ]
then
 quit
fi

board
#MAIN LOOP
while [ true ]
do
 fillCell
 board
 check
 nextPlayer $TURN
done


