"""Simple retry helper with exponential backoff and jitter.

This is intentionally small and dependency-free so tests remain fast.
"""
from __future__ import annotations

import random
import time
from typing import Callable, Tuple, Type


def retry_call(func: Callable, *args, exceptions: Tuple[Type[BaseException], ...] = (Exception,), tries: int = 3, backoff: float = 2.0, jitter: float = 0.1, **kwargs):
    """Call func with retries on specified exceptions.

    Args:
        func: callable to execute
        *args: positional args
        exceptions: tuple of exception classes to catch and retry on
        tries: total attempts (including first)
        backoff: multiplier for exponential backoff (seconds)
        jitter: max random jitter added to sleep
        **kwargs: keyword args for func

    Returns:
        The return value of func

    Raises:
        The last exception if all retries fail.
    """
    attempt = 1
    wait = 0.5
    last_exc = None
    while attempt <= tries:
        try:
            return func(*args, **kwargs)
        except exceptions as exc:
            last_exc = exc
            if attempt == tries:
                break
            sleep_time = wait + random.uniform(0, jitter)
            time.sleep(sleep_time)
            wait = max(wait * backoff, 0.1)
            attempt += 1
    # re-raise the last exception
    raise last_exc
