#!/bin/bash

PSQL="psql  --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"
RANDOM_NUMBER=$(( RANDOM % 999 + 1 ))

echo -e "\nEnter your username:"
read USERNAME

# find user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# if user_id isn't found
if [[ -z $USER_ID ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

    # insert new user
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")

    # get new user_id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # find games played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")

  # find best game
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")

  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS
NUMBER_OF_GUESSES=1

# loop until secret number is guessed
while [[ $USER_GUESS !=  $RANDOM_NUMBER ]]
do
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      read USER_GUESS
    elif [[ $USER_GUESS > $RANDOM_NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
        read USER_GUESS
    else
      echo -e "\nIt's higher than that, guess again:"
      read USER_GUESS
  fi 
done

# find user's amount of games played
USER_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID") 

# update games played to include new game
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED + 1 WHERE user_id=$USER_ID")

# find user's best game
USER_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")

# change best game if new game had lower amount of guesses or if first game
if [[ $USER_BEST_GAME > $NUMBER_OF_GUESSES || $USER_BEST_GAME = 0 ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE user_id=$USER_ID")
fi

echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"