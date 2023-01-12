#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"

MAIN_MENU() {
echo -e "\nWelcome to My Salon, how can I help you?\n"
SERVICES="$($PSQL "SELECT service_id, name FROM services")"
echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
  echo -e "$SERVICE_ID) "$SERVICE_NAME""
done
}
MAIN_MENU
read SERVICE_ID_SELECTED

SERVICE_RESULT="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
if [[ -z $SERVICE_RESULT ]]
then
  echo -e "\nI could not find that service. What would you like today?"
  MAIN_MENU
  read SERVICE_ID_SELECTED
  SERVICE_RESULT="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
fi
SERVICE_RESULT=$(echo "$SERVICE_RESULT" | sed -r 's/^ *| *$//')

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_RESULT="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
if [[ -z $CUSTOMER_RESULT ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  INSERT_RESULT="$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")"
  CUSTOMER_RESULT="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
fi
CUSTOMER_RESULT=$(echo "$CUSTOMER_RESULT" | sed -r 's/^ *| *$/ /')
CUSTOMER_ID_RESULT="$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")"
CUSTOMER_ID_RESULT=$(echo "$CUSTOMER_ID_RESULT" | sed -r 's/^ *| *$//')

echo -e "\nWhat time would you like your $SERVICE_RESULT,$CUSTOMER_RESULT?"
read SERVICE_TIME

SERVICE_ID_RESULT="$($PSQL "SELECT service_id FROM services WHERE name = '$SERVICE_RESULT'")"
SERVICE_ID_RESULT=$(echo "$SERVICE_ID_RESULT" | sed -r 's/^ *| *$//')
INSERT_APP_RESULT="$($PSQL "INSERT INTO appointments (customer_id, service_id, time) 
VALUES($CUSTOMER_ID_RESULT,$SERVICE_ID_RESULT,'$SERVICE_TIME')")"

echo -e "\nI have put you down for a $SERVICE_RESULT at $SERVICE_TIME,$CUSTOMER_RESULT."


