import discord
import requests

RASA_ENDPOINT = "http://localhost:5005/webhooks/rasadis/webhook"
TOKEN = 'MTE4MDg4NDIyMDg2NDg4ODk1Mg.GswJmq.AsGdplvNaYzfZCuimlfzobf-_XO2LZUPBzqvZA'

intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f'Zalogowany jako {client.user.name}')

@client.event
async def on_message(message):
    if message.author == client.user:
        return
    else:
        response = get_rasa_response(message.content, message.author.id)
        print("response: " + str(response))
        for res in response:
            await message.channel.send(res['text'])

def get_rasa_response(user_input, sender_id):
    data = {
        "sender": sender_id,
        "text": user_input
    }
    response = requests.post(RASA_ENDPOINT, json=data)
    print("message from rasa")
    print(response.json())

    return response.json()

client.run(TOKEN)
