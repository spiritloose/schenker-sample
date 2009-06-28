all:
migrate:
	$(MAKE) -C db migrate
test:
	$(MAKE) -B ENVIRONMENT=test migrate
	prove t
