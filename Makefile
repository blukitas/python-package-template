.DEFAULT_GOAL := all
isort = isort my_package tests
black = black my_package tests

.PHONY : docs
docs :
	rm -rf docs/build/
	sphinx-autobuild -b html --watch my_package/ docs/source/ docs/build/

.PHONY: virtualenv
virtualenv:
	@echo "Creating virtualenv ... Make sure to have miniconda installed"
	conda create -n my_package python=3.9
	@echo "Environment succesfully created please run conda activate my_package"

.PHONY : run-checks
run-checks :
	isort --check .
	black --check .
	flake8 .
	mypy .
	CUDA_VISIBLE_DEVICES='' pytest -v --color=yes --doctest-modules tests/ my_package/

.PHONY: install
install:
	pip install -U pip
	pip install -r requirements.txt
	pip install -r dev-requirements.txt
	pre-commit install

.PHONY: install-setup-requirements
install-setup-requirements:
	pip install -U pip
	pip install -r setup-requirements.txt

.PHONY: format
format:
	$(isort)
	$(black)

.PHONY: lint
lint:
	flake8 --max-complexity 10 --max-line-length 79 --ignore E203,W503 my_package tests
	$(isort) --check-only --df
	$(black) --check

.PHONY: clean
clean:
	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]' `
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	rm -rf .cache
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf htmlcov
	rm -rf *.egg-info
	rm -f .coverage
	rm -f .coverage.*
	rm -rf build

.PHONY: sync-local-branches-with-remote
sync-local-branches-with-remote:
	git fetch -p
	git fetch -p && for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done
