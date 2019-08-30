import json
import aiohttp
import asyncio
import sys
import re
import time

API_KEY = "AIzaSyDpdC2yFMTfIbLSWIlKu4Fs5bHUL9XBkCE"

SERVERS = { "Goloman" : { "port" : 11745,
                          "neighbors" : ["Hands", "Holiday", "Wilkes"] },
            "Hands" : { "port" : 11746,
                        "neighbors" : ["Goloman", "Wilkes"] },
            "Holiday" : { "port" : 11747,
                          "neighbors" : ["Goloman", "Welsh", "Wilkes"] },
            "Welsh" : { "port" : 11748,
                        "neighbors" : ["Holiday"] },
            "Wilkes" : { "port" : 11749,
                         "neighbors" : ["Goloman", "Hands", "Holiday"] } }

# CLIENTS is a dictionary that stores the client_id and with each id:
    # CLIENTS[ID][0] = server that received the message
    # CLIENTS[ID][1] = command
    # CLIENTS[ID][2] = coordinates
    # CLIENTS[ID][3] = time sent by client
    # CLIENTS[ID][4] = time received by server

CLIENTS = {}
SERVER_ID = None
LOG = None

# returns an array of the input message delimited by white spaces

def parse_msg(msg):
    
    return msg.strip().split()

# returns a message type depending on input, or None if the input message is not valid

def valid_msg(msg):

    if len(msg) < 1:
        return None

    elif msg[0] == "IAMAT":
        if len(msg) != 4 or parse_coords(msg[2]) == False:
            return None
        else:
            return "IAMAT"

    elif msg[0] == "AT":
        if len(msg) != 6 or parse_coords(msg[4]) == False:
            return None
        else:
            return "AT"

    elif msg[0] == "WHATSAT":
        if len(msg) != 4:
            return None
        else:
            return "WHATSAT"

    else:
        return None

# returns true if coordinates are valid, else false

def parse_coords(coords):

    valid_coords = re.compile(r'^[+-][0-9]+.[0-9]+[+-][0-9]+.[0-9]+$')

    if valid_coords.match(coords):
        return True
    else:
        return False                                        







# writes input/output messages to LOG

async def write_to_log(msg):
    if msg == "":
        return
    else:
        LOG.write(msg)

async def flood_servers(flood_reply, skip):
    for i in SERVERS[SERVER_ID]["neighbors"]:
        if i in skip:
            continue
        try:
            reader, writer = await asyncio.open_connection("127.0.0.1", SERVERS[i]["port"], loop=loop)
            await write_to_log("successfully! connected! server{0}! with! {1}!\n".format(SERVER_ID, i))
            writer.write(flood_reply.encode())
            await writer.drain()
            writer.close
        except:
            print("error while connecting and propogating") # delete
            await write_to_log("connection failed, boo:(.\n")
            pass

# returns reply message depending on input command message

async def reply_msg(message, time):
    msg = parse_msg(message)
    cmnd = valid_msg(msg)
    reply = ""
    error = "? {0}".format(msg)
    time_received = time
    skip = []

    if cmnd == None:
        return error

    elif cmnd == "IAMAT":
        time_sent = float(msg[3])
        CLIENTS[msg[1]] = [SERVER_ID, msg[0], msg[2], time_sent, time_received]
        time_diff = time_received - time_sent

        if time_diff > 0:
            time_diff = "+" + str(time_received)
        else:
            time_diff = str(time_received)

        reply = "AT {0} {1} {2}\n".format(SERVER_ID, time_diff, " ".join(msg[1:]))
        flood_reply = "AT {0} {1} {2} {3}\n".format(SERVER_ID, SERVER_ID, time_received, " ".join(msg[1:]))

        asyncio.ensure_future(flood_servers(flood_reply, []))

    elif cmnd == "WHATSAT":
        if msg[1] not in CLIENTS:
            return error
        else:
            loc = list(filter(lambda x: len(x) > 0, re.split(r'[+-]', str(CLIENTS[msg[1]][2]))))
            places_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?
		          key={0}&location={1},{2}&radius={3}".format(API_KEY, loc[0], loc[1], msg[2])

        time_diff = float(CLIENTS[msg[1]][4]) - float(CLIENTS[msg[1]][3])

        if time_diff > 0:
            time_diff = "+" + str(time_diff)
        else:
            time_diff = str(time_diff)

        reply = "AT {0} {1} {2} {3} {4}\n".format(CLIENTS[msg[1]][0], time_diff, msg[1], 
						  CLIENTS[msg[1]][2], CLIENTS[msg[1]][3])

        async with aiohttp.ClientSession() as session:
            async with session.get(places_url) as places_reply:
                places_info = await places_reply.json()
                places_info["results"] = places_info["results"][:int(msg[3])]
                reply += json.dumps(places_info, indent=3)
                







    elif cmnd == "AT":
        server1 = msg[1]
        server2 = msg[2]
        time_received = msg[3]
        client_id = msg[4]
        coords = msg[5]
        time_sent = msg[6]

        await write_to_log("connecting {0} with {1}.\n".format(server1, server2))
        await write_to_log("dropping connection from {0} to {1}.\n".format(server1, server2))

        # if client_id hasn't been stored yet, or message was sent after the most recent dictionary update
        if client_id not in CLIENTS or time_sent > CLIENTS[client_id][3]:
            CLIENTS[client_id] = [server1, cmnd, coords, time_sent, time_received]
            flood_reply = "{0} {1} {2} {3} {4}\n".format
			(cmnd, server1, SERVER_ID, time_received, " ".join(msg[4:]))
            skip = [server1, server2]
            asyncio.ensure_future(flood_servers(flood_reply, skip))
        else:
            return None

    else:
        return error

    return reply
        
# accepts the input message, writes to log, sends reply message

async def handle_msg(reader, writer):
    data = await reader.readline()
    input_time = time.time()
    msg = data.decode()
    await write_to_log("incoming message: {0}\n".format(msg))

    reply = await reply_msg(msg, input_time)
    await write_to_log("outgoing message: {0}\n".format(reply))
    writer.write(reply.encode())
    await writer.drain()

# main

def main():

    if len(sys.argv) != 2:
        print("invalid number of arguments :( please try again.")
        exit(1)
    
    if sys.argv[1] not in SERVERS:
        print("invalid server input :( please try again.")
        exit(1)
        
    global SERVER_ID
    SERVER_ID = sys.argv[1]
    
    log_file = "{0}_log.txt".format(SERVER_ID)
    global LOG
    LOG = open(log_file, "a+")

    global loop
    loop = asyncio.get_event_loop()
    coroutine = asyncio.start_server(handle_msg, "127.0.0.1", port=SERVERS[SERVER_ID]["port"], loop=loop)
    server = loop.run_until_complete(coroutine)
    
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass

    server.close()
    loop.run_until_complete(server.wait_closed())
    loop.close()
    LOG.close()
    
if __name__ == "__main__":
    main()


