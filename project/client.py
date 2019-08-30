import time
import asyncio
import sys

async def echo_server(loop):
    reader, writer = await asyncio.open_connection("127.0.0.1", 11746, loop=loop)
    try:
        msg = "IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1520023934.918963997"
        print("sending message to server!")
        writer.write(msg.encode())
        await writer.drain()

        while not reader.at_eof():
            data = await reader.read(100000)
            data.decode()
            print("message received!")

    except KeyboardInterrupt:
        print("closing socket!")
        writer.close()
        return

loop = asyncio.get_event_loop()
loop.run_until_complete(echo_server(loop))
loop.close()
