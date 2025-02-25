import asyncio
import time
import uuid
from deque.task import Task
import asynctnt

from deque.queue import Queue


def do_smt(t: Task):
    print(time.monotonic_ns(), t.payload)


async def poper(queue: Queue):
    while True:
        count = 0
        start = time.time()
        while True:
            task = await queue.pop(delay=4)
            count += 1
            if task is None or count >= 1e5:
                break
            do_smt(task)
        elapsed = time.time() - start
        print(f"taken {count} / {elapsed:.2f} {count / elapsed:.0f}rps")


async def pop_batcher(queue: Queue):
    while True:
        count = 0
        start = time.time()
        while True:
            tasks = await queue.pop_many(delay=2, limit=1500)
            count += len(tasks)
            if len(tasks) == 0 or count >= 1e5:
                break

        elapsed = time.time() - start
        print(f"taken {count} / {elapsed:.2f} {count / elapsed:.0f}rps")

        if count == 0:
            await asyncio.sleep(1)


async def pusher(queue: Queue):
    while True:
        await queue.push(
            {
                "id": str(uuid.uuid4()),
                "time": time.time(),
                "payload": [0, 1, 2, {"id": "task"}],
            }
        )
        await asyncio.sleep(0.005)


async def main():
    tnt = asynctnt.Connection(
        host="127.0.0.1", port=3301, username="python", password="python"
    )
    await tnt.connect()
    print("Connected")

    queue = Queue(tnt)
    t_pusher = asyncio.create_task(pusher(queue))
    t_poper = asyncio.create_task(poper(queue))
    # t_pop_batcher = asyncio.create_task(pop_batcher(queue))

    await asyncio.gather(t_pusher, t_poper)
    # await 
    # await t_pop_batcher


if __name__ == "__main__":
    asyncio.run(main())
