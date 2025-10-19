# Report

Author: Your Name Here

## Security Report (Reflected XSS)
- What I sent: name=<script>alert(1)</script> to GET /vulnerable_echo (via the form on / or query string).
- What happened: the browser executed the inline JavaScript, showing an alert box. This confirmed a reflected XSS.
- Why it was vulnerable: the endpoint inserted untrusted input directly into HTML without escaping, so the <script> tag was interpreted, not displayed.
- Fixes applied:
	- Escaped user input with markupsafe.escape before rendering.
	- Added a Content-Security-Policy header: default-src 'self'; script-src 'self' to disallow inline scripts.

## Pytest (local run)
```bash
PS C:\Users\Rishabh Jha\procedures-lab> py -m pytest -v --tb=no
===================================== test session starts ======================================
platform win32 -- Python 3.13.5, pytest-7.4.2, pluggy-1.6.0 -- C:\Users\Rishabh Jha\AppData\Local
\Programs\Python\Python313\python.exe                                                            cachedir: .pytest_cache
rootdir: C:\Users\Rishabh Jha\procedures-lab
configfile: pytest.ini
collected 8 items                                                                               

tests/test_endpoints.py::test_add_endpoint PASSED                                         [ 12%]
tests/test_endpoints.py::test_fib_endpoint PASSED                                         [ 25%] 
tests/test_endpoints.py::test_item_crud PASSED                                            [ 37%] 
tests/test_endpoints.py::test_vulnerable_echo_reflection SKIPPED (Reflection test ign...) [ 50%] 
tests/test_endpoints.py::test_vulnerable_echo_fixed PASSED                                [ 62%]
tests/test_utils.py::test_add_simple PASSED                                               [ 75%] 
tests/test_utils.py::test_fib_basic PASSED                                                [ 87%] 
tests/test_utils.py::test_db_crud PASSED                                                  [100%] 

================================= 7 passed, 1 skipped in 0.08s =================================
```