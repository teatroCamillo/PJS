from actions.tools.db import SQLiteDatabase

# database = SQLiteDatabase('..\\..\\restaurant.db')
# database.connect()

# with open("..\..\data.sql") as file:
#     sql_script = file.read()
#database.cursor.executescript(sql_script)
#
# records = database.fetch_data(f'SELECT * FROM orders')
# print('lookup db')
# for record in records:
#     print(record)

# usuwanie rekordow
# table_name = 'orders'
# condition = 'delivery = "Testowa 444"'  # np. 'id = 1' lub 'nazwa = "abc"'
# delete_query = f'DELETE FROM {table_name}'
# database.cursor.execute(delete_query)
# database.connection.commit()



