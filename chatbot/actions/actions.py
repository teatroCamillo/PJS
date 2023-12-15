from typing import Text, Dict, Any, List
from rasa_sdk import Action, Tracker, FormValidationAction
from rasa_sdk.events import SlotSet
from rasa_sdk.executor import CollectingDispatcher
from actions.tools.db import SQLiteDatabase
from rasa_sdk.types import DomainDict
import re

database = SQLiteDatabase('restaurant.db')
database.connect()
with open('data.sql') as file:
    sql_script = file.read()
database.cursor.executescript(sql_script)
database.close_connection()

def set_db(input: Text) -> List[Text]:

    database.connect()
    database.cursor.execute(f'SELECT * FROM menu WHERE name=?', (input,))
    result = database.cursor.fetchall()
    database.close_connection()

    if result:
        return [result[0][1], result[0][2], result[0][3]]
    return []

def get_toppings_db():
    database.connect()
    database.cursor.execute(f'SELECT name, price FROM menu WHERE type="toppings"')
    result = database.cursor.fetchall()
    database.close_connection()

    return result

class ActionResetSlots(Action):

    def name(self) -> Text:
      return "action_reset_slots"

    def run(self,
           dispatcher: CollectingDispatcher,
           tracker: Tracker,
           domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:


        # for slot in tracker.slots:
        #     SlotSet(slot, None)

        dispatcher.utter_message(text=f'Formularz został zresetowany. Zaczynamy :)')
        return [SlotSet(slot, None) for slot in tracker.slots.keys()] + [SlotSet("requested_slot", None)]


class ActionGetToppings(Action):

    def name(self) -> Text:
      return "action_get_toppings"

    def run(self,
           dispatcher: CollectingDispatcher,
           tracker: Tracker,
           domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        if tracker.slots['requested_slot'] == 'toppings':
            message = tracker.latest_message
            pattern = re.compile(r'\bser\b|\bbekon\b|\bpieczarki\b', re.IGNORECASE)
            toppings = pattern.findall(str(message['text']).lower())

            if not toppings:
                dispatcher.utter_message(text=f'Podane dodatki nie są dostępne. Możesz wybrać tylko z następujących: ser/bekon/pieczarki.')
                return []

            dispatcher.utter_message(text=f'Dodatki: {toppings} dodane do zamówienia')
            return [SlotSet('toppings', toppings)]
        return []

class ActionSimpleSummary(Action):

    def name(self) -> Text:
      return "action_order_simple_summary"

    def run(self,
           dispatcher: CollectingDispatcher,
           tracker: Tracker,
           domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        price = 0
        if tracker.get_slot("pizza_type"):
            data = set_db(tracker.get_slot("pizza_type"))
            price += float(data[1])
        if tracker.get_slot("drink"):
            data = set_db(tracker.get_slot("drink"))
            price += float(data[1])
        if tracker.get_slot("toppings"):
            data = get_toppings_db()
            toppings = tracker.get_slot("toppings")
            for top in data:
                if top[0] in toppings:
                    price += float(top[1])


        price = '%.2f' % price
        message = (f'\nDziękujemy!\nOto podsumowanie zamówienia:'
                 f'\npizza: {tracker.get_slot("pizza_type")}'
                 f'\nnapój: {tracker.get_slot("drink")}'
                 f'\ndodatki: {tracker.get_slot("toppings")}'
                 f'\ncena: {price} zł'
                 f'\nnr. tel: {tracker.get_slot("phone_number")}'
                 f'\ndostawa: {tracker.get_slot("delivery_address")}')

        dispatcher.utter_message(message)
        return [SlotSet("price", price)]

class ActionConfirmedAndStoredOrder(Action):

    def name(self) -> Text:
      return "action_confirmed_and_stored_order"

    def run(self,
           dispatcher: CollectingDispatcher,
           tracker: Tracker,
           domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        sep = ', '
        description = tracker.get_slot("pizza_type") + sep + tracker.get_slot("drink") + sep + str(tracker.get_slot("toppings"))
        id = hash(description) % (10 ** 8)
        data = [
            id,
            tracker.get_slot("phone_number"),
            tracker.get_slot("delivery_address"),
            tracker.get_slot("price"),
            description]

        database.connect()
        database.insert_data('orders', data)
        database.close_connection()


        message = (f'\nOk, następujące zamówienia zostało zapisane i przekazane do realizacji:'
                 f'\npizza: {tracker.get_slot("pizza_type")}'
                 f'\nnapój: {tracker.get_slot("drink")}'
                 f'\ndodatki: {tracker.get_slot("toppings")}'
                 f'\ncena: {tracker.get_slot("price")} zł'
                 f'\nnr. tel: {tracker.get_slot("phone_number")}'
                 f'\ndostawa: {tracker.get_slot("delivery_address")}'
                 f'\nczas oczekiwania: 45min'
                 f'\nDziękujemy i życzymy smacznego!')

        dispatcher.utter_message(message)
        return []

class ActionSetLackForCurrentSlot(Action):

    def name(self) -> Text:
      return "action_set_lack_for_current_slot"

    def run(self,
           dispatcher: CollectingDispatcher,
           tracker: Tracker,
           domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        print("Uruchamiam action_set_lack_for_current_slot")

        current_requested_slot = tracker.current_slot_values().get('requested_slot')

        dispatcher.utter_message(text=f'Ok, pomijamy ten krok.')

        return [SlotSet(current_requested_slot, 'brak')]


class ValidatePizzaForm(FormValidationAction):

    def name(self) -> Text:
        return "validate_pizza_form"

    def validate_pizza_type(
                           self,
                           slot_value: Any,
                           dispatcher: CollectingDispatcher,
                           tracker: Tracker,
                           domain: DomainDict,
                   ) -> Dict[Text, Any]:
        print('uruchamiam validate_pizza_type')


        set = set_db(slot_value)

        if not set:
            dispatcher.utter_message(text=f'Dostępne są tylko następujące rodzaje: Margherita/Hawajska/Pepperoni.')
            return {'pizza_type': None}

        if set and slot_value == 'brak':
            dispatcher.utter_message(text=f'Ok, pomijamy ten produkt.')
            return {'pizza_type': slot_value}

        dispatcher.utter_message(text=f'Ok, pizza {slot_value} została dodana do zamówienia.')
        return {'pizza_type': slot_value}

    def validate_toppings(
                           self,
                           slot_value: Any,
                           dispatcher: CollectingDispatcher,
                           tracker: Tracker,
                           domain: DomainDict,
                   ) -> Dict[Text, Any]:
        print('uruchamiam validate_toppings')
        toppings_in_db = get_toppings_db()
        avail = []
        records = []
        for record in toppings_in_db:
            records.append(record[0])

        for top in slot_value:
            if top in records:
                avail.append(top)

        if avail:
            dispatcher.utter_message(text=f'Dodatki: {avail} dodane do zamówienia.')
            return {'toppings': avail}

        dispatcher.utter_message(text=f'Niestety nie posiadamy wspomianych dodatków. Dostępne są tylko ser/bekon/pieczarki.')
        return {'toppings': None}

    def validate_drink(
                           self,
                           slot_value: Any,
                           dispatcher: CollectingDispatcher,
                           tracker: Tracker,
                           domain: DomainDict,
                   ) -> Dict[Text, Any]:
        print('uruchamiam validate_drink')
        set = set_db(slot_value)

        if not set:
            dispatcher.utter_message(text=f'Dostępne są tylko następujące rodzaje: Fanta/Coca-Cola/Woda.')
            return {'drink': None}

        if set and slot_value == 'brak':
            dispatcher.utter_message(text=f'Ok, pomijamy ten produkt.')
            return {'drink': slot_value}

        dispatcher.utter_message(text=f'Ok, {slot_value} została dodana do zamówienia.')
        return {'drink': slot_value}

    def validate_phone_number(
                           self,
                           slot_value: Any,
                           dispatcher: CollectingDispatcher,
                           tracker: Tracker,
                           domain: DomainDict,
                   ) -> Dict[Text, Any]:

        if len(slot_value) != 11:
            dispatcher.utter_message(text=f'Numer telefonu powinien składać się z 9 cyfr. Podając, używaj "-" jako znaku sepracji.')
            return {'phone_number': None}

        dispatcher.utter_message(text=f'Ok, numer tel: {slot_value} został zapisany.')
        return {'phone_number': slot_value}




class ActionShowMenu(Action):
   def name(self) -> Text:
      return "action_query_db_and_show_menu"

   def run(self,
           dispatcher: CollectingDispatcher,
           tracker: Tracker,
           domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

      database.connect()
      result = database.cursor.execute('SELECT * FROM menu WHERE type!=?', ('other',))

      if result:
         menu_message = "To nasze manu:\n"
         for row in result:
            menu_message += f"{row[1]} - {row[3]} - cena: {row[2]}zł\n"
         menu_message += '\n'
         dispatcher.utter_message(menu_message)
      else:
         dispatcher.utter_message("Niestety, menu jest obecnie niedostępne.")

      database.close_connection()
      return []

class ActionOpeningHours(Action):
    def name(self) -> Text:
      return "action_query_db_and_show_opening_hours"

    def run(self,
           dispatcher: CollectingDispatcher,
           tracker: Tracker,
           domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:

        database.connect()
        database.cursor.execute('SELECT * FROM open_hours')
        result = database.cursor.fetchall()

        message = (f"To nasze godziny otwarci restauracji w tygodniu\n"
                        f"Poniedziłek: {result[0][1]}\n"
                        f"Wtorek: {result[0][2]}\n"
                        f"Środa: {result[0][3]}\n"
                        f"Czwartek: {result[0][4]}\n"
                        f"Piątek: {result[0][5]}\n"
                        f"Sobota: {result[0][6]}\n"
                        f"Niedziela: {result[0][7]}\n"
                        f"Serdecznie zapraszamy")

        dispatcher.utter_message(message)
        database.close_connection()
        return []