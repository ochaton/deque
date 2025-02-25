from deque.exceptions import TaskEmptyError


class Task:
    __slots__ = ("_id", "_time", "_payload")

    def __init__(self, tnt_tuple):
        if tnt_tuple is None or len(tnt_tuple) == 0:  # pragma: nocover
            raise TaskEmptyError("Queue task is empty")

        self._id = tnt_tuple["id"]
        self._time = tnt_tuple["time"]
        self._payload = tnt_tuple["payload"]

    @property
    def id(self):
        """
        Task id
        """
        return self._id

    @property
    def time(self):
        """
        Task schedule time
        """
        return self._time

    @property
    def payload(self):
        """
        Task data
        """
        return self._payload

    def __repr__(self):
        return "<Task id={} time={}>".format(self._id, self._time)
