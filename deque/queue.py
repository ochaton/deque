import asynctnt

from deque.exceptions import QueueError
from deque.task import Task


_FUNCS = [
	'put',
	'take',
	'touch',
	'ack',
	'release',
	'peek',
	'bury',
	'kick',
	'delete',
	'drop',
]

class Queue:
	__slots__ = ('_conn')

	def __init__(self, conn: asynctnt.Connection):
		self._conn = conn
		pass

	@property
	def conn(self):
		return self._conn

	def _create_task(self, body, *, task_cls=Task):
		"""
			Creates Queue Task instance from Tarantool response body

			:param body: Response body
			:param task_cls: Class to instantiate
			:return: ``task_cls`` instance (by default
				:class:`asynctnt_queue.Task`)
		"""
		return task_cls(body)

	async def pop(self, delay=300, timeout=1):
		"""
			Pops task from the queue, resetting its time to NOW()+delay

			:param delay: Seconds to reschedule task
			:return: Task instance
		"""

		res = await self.conn.call('deque.api.pop', [{'delay': delay, 'timeout': timeout}], timeout=1+2*timeout)
		if len(res.body) > 0:
			return self._create_task(res.body[0])
		return None

	async def pop_many(self, delay=300, limit=100):
		res = await self.conn.call('deque.api.pop_many', [{'delay': delay, 'limit': limit}])
		if len(res.body) > 0:
			return list(map(self._create_task, res.body[0]))
		return []

	async def push(self, task):
		"""
			Pushes task into Tarantool

			:param task: task to be pushed
			:return: status
		"""

		res = await self.conn.call('deque.api.push', [task])

		if len(res.body) == 0:
			raise QueueError("Malformed response from Tarantool {}", res.body)

		if not isinstance(res.body[0], dict):
			raise QueueError("Malformed response from Tarantool {}", res.body)

		if not res.body[0]['ok']:
			raise QueueError("Failed to pass task: {}", res.body[0]['error'])

		return True
