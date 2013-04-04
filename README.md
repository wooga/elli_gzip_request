# elli_gzip_request


Elli gzip request is an [elli](http://github.com/knutin/elli) middleware that
understand gzip request.

If the request comes with the header ``Content-Encoding``, and with the value
``gzip``, this middleware will:

* Remove the ``Content-Encoding`` header.
* Modify the request body with the ungzip version of the body.
* Update the ``Content-Length`` to represent the body size.

# License

See LICENSE file

# Contributing

Github standard Way of collaborating.

# Issues

Github Standard way of submitting issues.

# Author

Guillermo Álvarez
