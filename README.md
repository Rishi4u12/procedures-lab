# Procedure Lab

Our goal here is to implement small, testable procedures, wire them into a local Flask web server, write/verify tests, then discover and fix a simple reflected XSS vulnerability (Yes! You are hacking your own site!). 

This lab teaches *how to design, call, and test procedures* and gives a short, practical security lesson about escaping

Work incrementally. After each small task, run the tests and try the server forms. If something fails, fix it before moving on (small, frequent commits help).


## Setup (do this only once)

1. Create the virtual environment and install dependencies:
    ```bash
    python -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```
2. Run the test suite (it will fail initially -- that's expected):
    ```bash
    pytest -q
    ```

3. Start the server for testing:
    ```bash
    ./run.sh
    # Visit http://127.0.0.1:8000/
    ```


## Project Layout
```py
py-web-assignment/
├─ app/
│  ├─ server.py    # Flask endpoints (some already provided)
│  └─ utils.py     # Your functions to implement
├─ tests/
│  ├─ test_utils.py
│  └─ test_endpoints.py
└─ run.sh
```

**You will mainly edit `app/utils.py` and make a *small* change to `app/server.py` (adding one POST endpoint, and later a mitigation).**


## The Lab

Follow these steps in order. After each step, run `pytest -q` and (for endpoints) exercise the server in the browser or with `curl`.


### Part A: Small pure procedures (tests will check thest)

1. Implement `add(a, b)` in `app/utils.py`
   - Behavior: return the sum of the two `float` arguments.
   - Tests expect exact numeric edition
      - Ex. `add(2, 3) == 5` 

2. Implement `fib(n)` in `app/utils.py`
   - Behavior: return the n-th Fibonacci number with `fib(0) == 0`, `fib(1) == 1`.
   - Hint: look up what the Fibonacci sequence is if you need help!

3. Run `pytest -q`. `test_utils.py` should pass once `add` and `fib` are correct.


### Part B: Simple CRUD (the "database")

`app/utils.py` already declares `_DB: Dict[str, Dict] = {}`. Implement these functions operating on that dictionary:

4. `create_item(key: str, value: Dict) -> None`
   - Store a copy of `value` under `key`. Replacing existing value is fine.

5. `read_item(key: str) -> Optional[Dict]`
   - Return a copy of the stored dict or `None` if absent.

6. `update_item(key: str, patch: Dict) -> bool`
   - If the key exists, merge patch into the stored dict (`existing.update(patch)` semantics) and return `True`. If key missing, return `False`.

7. `delete_item(key: str) -> bool`
   - Delete the key if present; return `True` if deleted, `False` otherwise.

8. `clear_db()` is provided for tests -- do not remove it.

Run `pytest -q`. `test_db_crud` and `test_endpoints` related to items should pass for the utils level behavior.

#### Bonus

If you're really curious, you can try using `curl` to try sending requests to your own web server! We'll be doing this int he next part anyway.

```bash
curl 'http://127.0.0.1:8000/add?a=4&b=1.5'
```

### Part C: Endpoints and a small addition

9. The server already exposes endpoints for `/add`, `/fib`, and `/items/<key>` (GET/PUT/PATCH/DELETE). Confirm these behaviors by running the server using `./run.sh` (if you haven't already) and using the forms by manually typing in your query into the browser or using `curl` from your terminal like this:

```bash
# add
curl 'http://127.0.0.1:8000/add?a=4&b=1.5'

# fib
curl 'http://127.0.0.1:8000/fib?n=6'

# create item (PUT)
curl -X PUT -H 'Content-Type: application/json' \
  -d '{"name":"alice"}' \
  http://127.0.0.1:8000/items/user1

# read item (GET)
curl http://127.0.0.1:8000/items/user1
```

10. Tests: make sure all endpoint tests in `tests/test_endpoints.py` pass. If they fail, read the test failure message and fix the code.


### Part D: Hacking your server

This is a very short section. You will discover a vulnerable endpoint and fix it.

12. **Discovery**
    - Open `http://127.0.0.1:8000/` and use the form that points to `/vulnerable_echo`. Submit this as the input:
        ```html
        name=<script>alert(1)</script>
        ```
    (or paste it in the address bar as `?name=<script>alert(1)</script>`). Observe that the browser executes the script (an alert appears).
    - When you submit this assignment, include a little section explaining:
      - *What you sent*;
      - *What happened in the browser*;
      - *Why the server was vulnerable*;
    - You just hacked your own website!

13. **Mitigation**
    - Replace the vulnerable echo with a safe version: use `markupsafe.escape(name)` (or render via a template that escapes by default so user input is HTML-escaped before insertion).
    - Add a `Content-Security-Policy` header to the response(s) that disallows inline scripts (for example: `Content-Security-Policy: default-src 'self'; script-src 'self'`).
  
14. **Run a test** asserting the raw `"<script>...</script>"` string no longer appears in the body returned by `/vulnerable_echo`.
    - Run `pytest -q`. If you made the right fix, then:
      - `test_vulnerable_echo_reflection` should **FAIL**
      - `test_vulnerable_echo_fix` should **PASS**

15. Run `pytest -q` and ensure all tests pass.


## Submission

Submit your:

1. Implements `app/utils.py` and updates `app/server.py` (XSS mitigation).
2. All tests in `tests/` pass (`pytest -q`).
3. A small section explaining the exploit (mentioned in Part D).

### Checklist

- [ ] `pytest -q` shows all tests passing
- [ ] Server starts and the forms work at `http://127.0.0.1:8000/`
- [ ] You can `PUT/GET/PATCH/DELETE` items and `POST /items` works
- [ ] Security report (Part D) is present and explains the XSS and mitigations
- [ ] `/vulnerable_echo` no longer reflects raw `<script>` tags (verified by `pytest -q`)