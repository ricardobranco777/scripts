FILES=*.py

.PHONY: all
all: flake8 pylint mypy black

.PHONY: flake8
flake8:
	@flake8 --ignore=E501,W503 $(FILES)

.PHONY: pylint
pylint:
	@pylint --disable=duplicate-code $(FILES)

.PHONY: mypy
mypy:
	@mypy --disable-error-code=attr-defined $(FILES)

.PHONY: black
black:
	@black --check $(FILES)
